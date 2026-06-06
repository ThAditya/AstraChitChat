const User = require('../models/User');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const asyncHandler = require('./asyncHandler');
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { initializeUserStats } = require('../services/userStatsService');
const { sendResetCodeEmail } = require('../services/emailService');

// Helper function to generate a short-lived access token (15 minutes)
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '15m',
  });
};

// Helper function to generate a refresh token (7 days)
const generateRefreshToken = (id, key) => {
  const secret = process.env.JWT_REFRESH_SECRET;
  if (!secret && process.env.NODE_ENV === 'production') {
    console.error('CRITICAL: JWT_REFRESH_SECRET is not set in production!');
  }
  return jwt.sign({ id, key }, secret || process.env.JWT_SECRET, {
    expiresIn: '7d',
  });
};

// @desc    Register a new user
// @route   POST /api/auth/register
// @access  Public
// @validation Uses Joi validation middleware for input sanitization
exports.registerUser = asyncHandler(async (req, res) => {
  const { name, email, password, deviceId } = req.body;

  // Check if user exists (data already validated by Joi middleware)
  const userExists = await User.findOne({ email });
  if (userExists) {
    res.status(400);
    throw new Error('User with this email already exists');
  }

  // Helper to generate a unique username
  const generateUniqueUsername = async (baseName) => {
    const baseUsername = baseName.toLowerCase().replace(/[^a-z0-9]/g, '');
    let username = baseUsername + Math.random().toString(36).slice(2, 7);

    // Check for collision (loop a few times if needed)
    let attempts = 0;
    while (attempts < 5) {
      const exists = await User.findOne({ username });
      if (!exists) return username;
      username = baseUsername + Math.random().toString(36).slice(2, 7);
      attempts++;
    }
    return username;
  };

  const username = await generateUniqueUsername(name);

  // Create user
  let user;
  try {
    user = await User.create({
      name,
      email,
      password,
      username,
    });
  } catch (error) {
    if (error.code === 11000) {
      res.status(400);
      throw new Error('Username or email already in use. Please try again.');
    }
    throw error;
  }

  if (user) {
    // Initialize UserStats for the new user
    try {
      await initializeUserStats(user._id);
    } catch (statsError) {
      console.error('Failed to initialize UserStats:', statsError.message);
      // Don't fail registration if stats initialization fails
    }

    // Generate tokens
    const accessToken = generateToken(user._id);
    const tokenKey = crypto.randomBytes(16).toString('hex');
    const refreshToken = generateRefreshToken(user._id, tokenKey);
    
    // Hash and store refresh token in DB
    const hashedRefreshToken = await bcrypt.hash(refreshToken, 10);
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
    
    user.refreshTokens.push({
      key: tokenKey,
      token: hashedRefreshToken,
      expiresAt,
      deviceId: req.body.deviceId || 'unknown',
      ipAddress: req.ip,
      userAgent: req.get('user-agent'),
    });
    await user.save();

    // Return user data with tokens
    res.status(201).json({
      _id: user._id,
      name: user.name,
      username: user.username,
      email: user.email,
      profilePicture: user.profilePicture ? (typeof user.profilePicture === 'string' ? user.profilePicture : user.profilePicture.secure_url) : null,
      accessToken,
      refreshToken,
    });
  } else {
    res.status(400);
    throw new Error('Invalid user data');
  }
});

// @desc    Authenticate user & get token
// @route   POST /api/auth/login
// @access  Public
// @validation Uses Joi validation middleware for input sanitization
exports.loginUser = asyncHandler(async (req, res) => {
  const { email, password, deviceId } = req.body;
  // Email and password already validated by Joi middleware

  const user = await User.findOne({ email }).select('+password');

  if (!user) {
    res.status(401);
    throw new Error('Invalid email or password');
  }

  // Check password match
  const passwordMatches = await user.matchPassword(password);
  if (!passwordMatches) {
    res.status(401);
    throw new Error('Invalid email or password');
  }

  if (user.isTwoFactorEnabled && user.twoFactorSecret) {
    return res.json({
      requires2FA: true,
      userId: user._id,
    });
  }

  // Generate tokens
  const accessToken = generateToken(user._id);
  const tokenKey = crypto.randomBytes(16).toString('hex');
  const refreshToken = generateRefreshToken(user._id, tokenKey);
  
  // Hash and store refresh token in DB
  const hashedRefreshToken = await bcrypt.hash(refreshToken, 10);
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
  
  user.refreshTokens.push({
    key: tokenKey,
    token: hashedRefreshToken,
    expiresAt,
    deviceId: deviceId || 'unknown',
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
  });
  await user.save();

  return res.json({
    _id: user._id,
    name: user.name,
    username: user.username,
    email: user.email,
    profilePicture: user.profilePicture ? (typeof user.profilePicture === 'string' ? user.profilePicture : user.profilePicture.secure_url) : null,
    accessToken,
    refreshToken,
  });
});

// @desc    Setup 2FA
// @route   POST /api/auth/2fa/setup
// @access  Private
exports.setup2FA = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  const secret = speakeasy.generateSecret({
    name: `AstraChitChat (${user.email})`,
  });

  // Store in temp field until verified
  user.twoFactorTempSecret = secret.base32;
  await user.save();

  const data_url = await QRCode.toDataURL(secret.otpauth_url);
  res.json({ secret: secret.base32, qrCode: data_url });
});

// @desc    Verify 2FA setup
// @route   POST /api/auth/2fa/verify-setup
// @access  Private
// @validation Uses Joi validation middleware for token format validation
exports.verify2FASetup = asyncHandler(async (req, res) => {
  const { token } = req.body;
  const user = await User.findById(req.user._id).select('+twoFactorTempSecret');

  if (!user.twoFactorTempSecret) {
    res.status(400);
    throw new Error('2FA setup not initiated');
  }

  const verified = speakeasy.totp.verify({
    secret: user.twoFactorTempSecret,
    encoding: 'base32',
    token,
  });

  if (verified) {
    user.isTwoFactorEnabled = true;
    user.twoFactorSecret = user.twoFactorTempSecret;
    user.twoFactorTempSecret = undefined;
    await user.save();
    res.json({ message: '2FA enabled successfully' });
  } else {
    res.status(400);
    throw new Error('Invalid 2FA token');
  }
});

// @desc    Disable 2FA
// @route   POST /api/auth/2fa/disable
// @access  Private
// @validation Uses Joi validation middleware for password validation
exports.disable2FA = asyncHandler(async (req, res) => {
  const { password } = req.body;
  // Password already validated by Joi middleware
  const user = await User.findById(req.user._id).select('+password');

  // Verify password for security
  const passwordMatches = await user.matchPassword(password);
  if (!passwordMatches) {
    res.status(401);
    throw new Error('Invalid password');
  }

  user.isTwoFactorEnabled = false;
  user.twoFactorSecret = undefined;
  await user.save();
  res.json({ message: '2FA disabled successfully' });
});

// @desc    Verify 2FA during login
// @route   POST /api/auth/2fa/login
// @access  Public
// @validation Uses Joi validation middleware for input sanitization
exports.verifyLogin2FA = asyncHandler(async (req, res) => {
  const { userId, token, deviceId } = req.body;
  // All inputs already validated by Joi middleware

  const user = await User.findById(userId);
  if (!user) {
    res.status(404);
    throw new Error('User not found');
  }

  const verified = speakeasy.totp.verify({
    secret: user.twoFactorSecret,
    encoding: 'base32',
    token,
  });

  if (verified) {
    // Generate tokens
    const accessToken = generateToken(user._id);
    const tokenKey = crypto.randomBytes(16).toString('hex');
    const refreshToken = generateRefreshToken(user._id, tokenKey);
    
    // Hash and store refresh token in DB
    const hashedRefreshToken = await bcrypt.hash(refreshToken, 10);
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
    
    user.refreshTokens.push({
      key: tokenKey,
      token: hashedRefreshToken,
      expiresAt,
      deviceId: deviceId || 'unknown',
      ipAddress: req.ip,
      userAgent: req.get('user-agent'),
    });
    await user.save();

    res.json({
      _id: user._id,
      name: user.name,
      username: user.username,
      email: user.email,
      profilePicture: user.profilePicture ? (typeof user.profilePicture === 'string' ? user.profilePicture : user.profilePicture.secure_url) : null,
      accessToken,
      refreshToken,
    });
  } else {
    res.status(400);
    throw new Error('Invalid 2FA token');
  }
});

// @desc    Logout user
// @route   POST /api/auth/logout
// @access  Private
exports.logoutUser = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  const userId = req.user._id;

  if (refreshToken) {
    try {
      // Decode to get the key (even if expired, we might want to allow logout)
      const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET, { ignoreExpiration: true });

      const user = await User.findById(userId);
      if (user && decoded.key) {
        const tokenIndex = user.refreshTokens.findIndex(t => t.key === decoded.key);
        if (tokenIndex > -1) {
          user.refreshTokens.splice(tokenIndex, 1);
          await user.save();
          console.log(`✅ User ${userId} logged out from device (key: ${decoded.key})`);
        }
      }
    } catch (err) {
      console.error('Logout error (token decode failed):', err.message);
    }
  }
  
  res.json({ 
    message: 'Logged out successfully',
    userId: userId
  });
});

// @desc    Refresh access token using refresh token
// @route   POST /api/auth/refresh-token
// @access  Public
// @validation Uses Joi validation middleware for input sanitization
exports.refreshAccessToken = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;

  try {
    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);

    if (!user) {
      res.status(404);
      throw new Error('User not found');
    }

    // Find matching refresh token in DB using the KEY (fast)
    const foundTokenIndex = user.refreshTokens.findIndex(t => t.key === decoded.key);

    if (foundTokenIndex === -1) {
      res.status(401);
      throw new Error('Refresh token not found or invalid');
    }

    const foundToken = user.refreshTokens[foundTokenIndex];

    // Verify hashed token matches (extra security layer)
    const isMatch = await bcrypt.compare(refreshToken, foundToken.token);
    if (!isMatch) {
      res.status(401);
      throw new Error('Invalid refresh token');
    }

    // Check if refresh token has expired
    if (new Date() > foundToken.expiresAt) {
      user.refreshTokens.splice(foundTokenIndex, 1);
      await user.save();
      res.status(401);
      throw new Error('Refresh token has expired');
    }

    // Generate new tokens (Rotation)
    const newAccessToken = generateToken(user._id);
    const newTokenKey = crypto.randomBytes(16).toString('hex');
    const newRefreshToken = generateRefreshToken(user._id, newTokenKey);

    // Replace the old refresh token with the new one
    const hashedNewRefreshToken = await bcrypt.hash(newRefreshToken, 10);
    user.refreshTokens[foundTokenIndex] = {
      key: newTokenKey,
      token: hashedNewRefreshToken,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      createdAt: foundToken.createdAt,
      lastUsedAt: new Date(),
      deviceId: foundToken.deviceId,
      ipAddress: req.ip,
      userAgent: req.get('user-agent'),
    };
    
    await user.save();

    res.json({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    });
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      res.status(401);
      throw new Error('Refresh token has expired');
    }
    throw error;
  }
});

// @desc    Logout from all devices
// @route   POST /api/auth/logout-all-devices
// @access  Private
exports.logoutAllDevices = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  
  const user = await User.findById(userId);
  
  // Clear all refresh tokens
  user.refreshTokens = [];
  await user.save();

  console.log(`✅ User ${userId} logged out from all devices`);
  
  res.json({ 
    message: 'Logged out from all devices successfully',
    userId: userId
  });
});

// @desc    Forgot password - generate 6-digit reset code
// @route   POST /api/auth/forgot-password
// @access  Public
exports.forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;
  const normalizedEmail = email.toLowerCase().trim();
  const user = await User.findOne({ email: normalizedEmail });

  if (!user) {
    res.status(404);
    throw new Error('User with this email does not exist');
  }

  // Generate 6-digit reset code
  const resetCode = Math.floor(100000 + Math.random() * 900000).toString();

  // Hash and set to resetPasswordToken field
  const hashedCode = crypto
    .createHash('sha256')
    .update(resetCode)
    .digest('hex');

  user.resetPasswordToken = hashedCode;

  // Set expire (15 minutes for code)
  user.resetPasswordExpire = Date.now() + 15 * 60 * 1000;

  await user.save();

  console.log(`[Auth] Generated OTP for ${normalizedEmail}: ${resetCode} (Hash: ${hashedCode})`);

  // Send email via Brevo
  try {
    await sendResetCodeEmail(user.email, resetCode, user.name);
  } catch (emailError) {
    // If email fails, we might want to log it and potentially inform the user
    // but in development we can still provide the code if needed
    console.error('Failed to send reset email:', emailError.message);
    if (process.env.NODE_ENV === 'production') {
      res.status(500);
      throw new Error('Error sending reset email. Please try again later.');
    }
  }

  const response = { message: 'Reset code sent to your email' };
  if (process.env.NODE_ENV !== 'production') {
    response.resetCode = resetCode;
    response.debug_note = "Development mode: Code also included here.";
  }

  res.json(response);
});

// @desc    Verify reset code
// @route   POST /api/auth/verify-reset-code
// @access  Public
exports.verifyResetCode = asyncHandler(async (req, res) => {
  const { email, code } = req.body;

  console.log('[Auth] Incoming verify-reset-code request:', { email, code });

  if (!code) {
    res.status(400);
    throw new Error('Verification code is required');
  }

  // Ensure code is string and trimmed before hashing
  const codeStr = code.toString().trim();
  const normalizedEmail = email.toLowerCase().trim();

  const hashedCode = crypto
    .createHash('sha256')
    .update(codeStr)
    .digest('hex');

  // Find user by email first to provide better diagnostic feedback
  const user = await User.findOne({ email: normalizedEmail });

  if (!user) {
    console.warn(`[Auth] Verification failed: No user found with email ${normalizedEmail}`);
    res.status(400);
    throw new Error('Invalid or expired reset code');
  }

  const isTokenMatch = user.resetPasswordToken === hashedCode;
  const isExpired = user.resetPasswordExpire < Date.now();

  if (!isTokenMatch || isExpired) {
    console.warn(`[Auth] Verification failed for ${normalizedEmail}.
    - Stored Hash: ${user.resetPasswordToken || 'NULL'}
    - Input Hash:  ${hashedCode}
    - Match: ${isTokenMatch}
    - Expired: ${isExpired} (Expires at: ${user.resetPasswordExpire})
    - Entered Code: "${codeStr}"
    - Current Time: ${new Date().toISOString()}`);

    res.status(400);
    throw new Error(isExpired ? 'Reset code has expired' : 'Invalid reset code');
  }

  console.log(`[Auth] Code verified successfully for: ${user.email}`);

  // Generate a temporary long-lived token to allow password reset
  const resetToken = crypto.randomBytes(32).toString('hex');
  user.resetPasswordToken = crypto
    .createHash('sha256')
    .update(resetToken)
    .digest('hex');

  // Give them 10 minutes to set the new password
  user.resetPasswordExpire = Date.now() + 10 * 60 * 1000;
  await user.save();

  res.json({
    message: 'Code verified successfully',
    resetToken
  });
});

// @desc    Reset password
// @route   POST /api/auth/reset-password
// @access  Public
exports.resetPassword = asyncHandler(async (req, res) => {
  const { resetToken, password } = req.body;

  // Get hashed token
  const hashedToken = crypto
    .createHash('sha256')
    .update(resetToken)
    .digest('hex');

  const user = await User.findOne({
    resetPasswordToken: hashedToken,
    resetPasswordExpire: { $gt: Date.now() },
  });

  if (!user) {
    res.status(400);
    throw new Error('Invalid or expired reset token. Please start over.');
  }

  // Set new password
  user.password = password;
  user.resetPasswordToken = undefined;
  user.resetPasswordExpire = undefined;
  await user.save();

  res.json({ message: 'Password reset successful' });
});