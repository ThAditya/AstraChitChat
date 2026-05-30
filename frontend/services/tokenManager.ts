import secureTokenManager from './secureTokenManager';

/**
 * Decode a JWT payload without verifying the signature.
 * Works on both web (atob) and native (Buffer via hermes or polyfill).
 */
const decodeJwtPayload = (token: string): Record<string, any> | null => {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    const base64 = parts[1];
    let json: string;

    // Buffer is available in Node and React Native (Hermes via polyfill)
    if (typeof Buffer !== 'undefined') {
      json = Buffer.from(base64, 'base64').toString('utf8');
    } else if (typeof atob !== 'undefined') {
      // Web fallback
      json = atob(base64.replace(/-/g, '+').replace(/_/g, '/'));
    } else {
      console.warn('[TokenManager] No base64 decoder available');
      return null;
    }

    return JSON.parse(json);
  } catch {
    return null;
  }
};

/**
 * Validate a JWT token structurally (no network call).
 * Checks: presence, format, expiration, and required payload field.
 */
export const validateToken = async (token?: string): Promise<boolean> => {
  try {
    const tokenToCheck = token ?? (await secureTokenManager.getToken());
    if (!tokenToCheck || typeof tokenToCheck !== 'string' || !tokenToCheck.trim()) {
      console.log('[TokenManager] Validation failed: No token string');
      return false;
    }

    const payload = decodeJwtPayload(tokenToCheck);
    if (!payload) {
      console.log('[TokenManager] Validation failed: Could not decode payload');
      return false;
    }

    // Check expiration
    const now = Math.floor(Date.now() / 1000);
    if (payload.exp && payload.exp < now) {
      console.log('[TokenManager] Validation failed: Token expired', { exp: payload.exp, now });
      return false;
    }

    // Backend signs with { id } — also accept _id/userId for forward compat
    const hasId = !!(payload.id || payload._id || payload.userId);
    if (!hasId) {
      console.log('[TokenManager] Validation failed: No user ID in payload');
      return false;
    }

    return true;
  } catch (error) {
    console.error('[TokenManager] Validation error:', error);
    return false;
  }
};

/**
 * Returns true if a valid (non-expired, well-formed) token is in secure storage.
 */
export const hasValidToken = async (): Promise<boolean> => {
  try {
    const token = await secureTokenManager.getToken();
    if (!token) return false;
    return validateToken(token);
  } catch {
    return false;
  }
};

/**
 * Clear token and related data from secure storage.
 * Exists for backwards compat — prefer secureTokenManager.clearAll() directly.
 */
export const clearToken = async (): Promise<void> => {
  try {
    await secureTokenManager.clearAll();
  } catch (e) {
    console.error('[TokenManager] Error clearing token:', e);
  }
};
