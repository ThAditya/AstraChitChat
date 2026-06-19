const axios = require('axios');

/**
 * Send 6-digit reset code via email using Brevo API directly via Axios.
 * This approach avoids SDK-specific constructor issues and provides better stability.
 * @param {string} email - Recipient email
 * @param {string} resetCode - 6-digit code
 * @param {string} name - Recipient name
 */
exports.sendResetCodeEmail = async (email, resetCode, name) => {
  const BREVO_API_URL = 'https://api.brevo.com/v3/smtp/email';
  const BREVO_API_KEY = process.env.BREVO_API_KEY;

  if (!BREVO_API_KEY) {
    console.error('❌ BREVO_API_KEY is missing in .env file');
    throw new Error('Email service configuration error');
  }

  const data = {
    sender: {
      name: (process.env.BREVO_SENDER_NAME || "AstraChitChat Support").replace(/"/g, ''),
      email: process.env.BREVO_SENDER_EMAIL
    },
    to: [
      {
        email: email,
        name: name
      }
    ],
    subject: "Password Reset Code - AstraChitChat",
    textContent: `Hello ${name}, your password reset code is: ${resetCode}. It is valid for 15 minutes.`,
    tags: ["auth", "password-reset"],
    htmlContent: `
      <html>
        <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #0f172a; color: #ffffff; padding: 20px;">
          <div style="max-width: 600px; margin: 0 auto; background-color: #1e293b; border-radius: 16px; padding: 40px; border: 1px solid #334155; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);">
            <div style="text-align: center; margin-bottom: 32px;">
              <h1 style="color: #00e5ff; margin: 0; font-size: 28px; letter-spacing: 2px;">ASTRA CHITCHAT</h1>
            </div>

            <h2 style="color: #f8fafc; font-size: 20px; margin-bottom: 16px;">Hello ${name},</h2>

            <p style="color: #94a3b8; font-size: 16px; line-height: 24px; margin-bottom: 32px;">
              We received a request to reset your password. Use the verification code below to continue. If you didn't request this, you can safely ignore this email.
            </p>

            <div style="text-align: center; margin-bottom: 32px;">
              <div style="display: inline-block; background-color: #0f172a; border: 2px solid #00e5ff; border-radius: 12px; padding: 20px 40px;">
                <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #00e5ff; font-family: monospace;">${resetCode}</span>
              </div>
            </div>

            <p style="color: #94a3b8; font-size: 14px; text-align: center; margin-bottom: 32px;">
              This code is valid for <strong>15 minutes</strong>.
            </p>

            <div style="border-top: 1px solid #334155; padding-top: 24px; text-align: center;">
              <p style="color: #64748b; font-size: 12px; margin: 0;">
                &copy; ${new Date().getFullYear()} AstraChitChat. All rights reserved.
              </p>
            </div>
          </div>
        </body>
      </html>
    `
  };

  try {
    console.log(`[EmailService] Attempting to send reset code to: ${email}`);

    const response = await axios.post(BREVO_API_URL, data, {
      headers: {
        'api-key': BREVO_API_KEY,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    });

    console.log('✅ Brevo API Success:', response.data);
    console.log(`✅ Reset code successfully sent to: ${email}`);
    return response.data;
  } catch (error) {
    if (error.response) {
      console.error('❌ Brevo API Error:', JSON.stringify(error.response.data));
      if (error.response.status === 401) {
        console.error('TIP: Your BREVO_API_KEY is unauthorized. Check your .env file.');
      } else if (error.response.data.code === 'invalid_parameter') {
        console.error('TIP: Ensure the BREVO_SENDER_EMAIL in .env is verified in your Brevo Sender settings.');
      }
    } else {
      console.error('❌ Email Network Error:', error.message);
    }
    throw new Error('Failed to send reset email');
  }
};
