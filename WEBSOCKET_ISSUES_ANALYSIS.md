# WebSocket Configuration & Issues Analysis

## Overview
Your app uses **Socket.io 4.8.1** on both backend and frontend for real-time chat, WebRTC calls, and typing indicators. Both versions are compatible ✅

---

## 🔴 **CRITICAL ISSUES FOUND**

### 1. **CORS Origin Mismatch - LIKELY ROOT CAUSE**
**Location:** [backend/server.js](backend/server.js#L140-L150) vs [frontend/services/config.ts](frontend/services/config.ts)

**Backend defines:**
```javascript
const socketOrigins = process.env.SOCKET_ORIGINS
    ? process.env.SOCKET_ORIGINS.split(',')
    : [
        'https://astrachitchat.onrender.com',
        'http://localhost:8081',
        'http://localhost:8082',
        'exp://localhost:8081',
        'http://10.170.22.72:8081',      // Android device
        'exp://10.170.22.72:8081',
    ];
```

**Frontend connects to:**
```typescript
export const SOCKET_URL = 'https://astrachitchat.onrender.com/';  // ⚠️ TRAILING SLASH
```

**Problem:** 
- Frontend URL has a **trailing slash** (`/`)
- Backend CORS check might fail on exact matching
- Need to check if production backend is getting `SOCKET_ORIGINS` env var

**Fix Required:**
Check the backend's `.env` file:
```bash
SOCKET_ORIGINS=https://astrachitchat.onrender.com,exp://localhost:8081,http://localhost:8081
```

---

### 2. **Socket CORS Configuration Issue**
**Location:** [backend/server.js](backend/server.js#L157-L163)

```javascript
const io = new Server(server, {
    pingTimeout: 120000,
    pingInterval: 25000,
    cors: {
        origin: socketOrigins,           // ⚠️ Using array directly
        methods: ['GET', 'POST'],
        credentials: true,
    },
});
```

**Problem:**
- Socket.io expects `cors.origin` to be a function or string when using dynamic origins
- Current implementation passes array directly, which may not work in production

**Fix:**
```javascript
const io = new Server(server, {
    pingTimeout: 120000,
    pingInterval: 25000,
    cors: {
        origin: (origin, callback) => {
            if (!origin || socketOrigins.includes(origin)) {
                callback(null, true);
            } else {
                callback(new Error('CORS not allowed'));
            }
        },
        methods: ['GET', 'POST'],
        credentials: true,
    },
});
```

---

### 3. **Potential Token Expiration in Production**
**Location:** [frontend/contexts/SocketContext.tsx](frontend/contexts/SocketContext.tsx#L390-L430)

Frontend validates token **before** connecting:
```typescript
const now = Math.floor(Date.now() / 1000);
if (payload.exp && payload.exp < now) {
    console.warn('[Socket] Token is expired');
    await secureTokenManager.clearAll();
    return;
}
```

**Issue:**
- If token expires **during** socket operations, the connection will fail
- No token refresh mechanism before socket reconnection attempts

**Recommendation:**
- Implement token refresh before socket reconnect attempts
- Consider extending JWT expiry time for socket connections

---

### 4. **Duplicate Conversation Listener**
**Location:** [frontend/contexts/SocketContext.tsx](frontend/contexts/SocketContext.tsx#L355-L370)

The `conversationUpdated` listener is registered in **TWO places**:
```typescript
// First place - Line 365
useEffect(() => {
    if (!socket) return;
    socket.on("conversationUpdated", updateConversation);
    ...
}, [socket, updateConversation]);

// Second place - Line 500 (inside connect callback)
newSocket.on("conversationUpdated", updateConversation);
```

**Issue:**
- Same event registered twice = **duplicate updates** 
- Can cause UI glitches, duplicate messages in state

**Fix:** Remove the duplicate registration inside `connect()` callback (line 500)

---

### 5. **Fallback to Polling is Masking WebSocket Issues**
**Location:** [frontend/contexts/SocketContext.tsx](frontend/contexts/SocketContext.tsx#L410)

```typescript
transports: ["websocket", "polling"],  // Falls back to polling if websocket fails
```

**Issue:**
- Polling is **much slower** and more bandwidth-heavy
- If WebSocket fails silently, app continues with polling
- Real-time experience degrades without visible error

**Recommendation:**
- Add monitoring to detect if polling fallback is active
- Log when WebSocket connection fails and polling kicks in
- Check browser console for WebSocket errors

---

## 🟡 **POTENTIAL ISSUES**

### 6. **Message Validation Too Strict**
**Location:** [backend/server.js](backend/server.js#L270-L290)

```javascript
const MAX_TEXT_LENGTH = 2000;      // Could be too restrictive
const MAX_ATTACHMENTS = 5;         // Reasonable
const MAX_ATTACHMENT_SIZE = 5242880; // 5MB - reasonable
```

**Recommendation:** Verify users aren't hitting these limits legitimately

---

### 7. **WebRTC Performance**
**Location:** [backend/routes/webrtcRoutes.js](backend/routes/webrtcRoutes.js)

ICE candidates may struggle with:
- Multiple TURN servers (check latency)
- Candidate gathering timeout
- No logging of connection quality

**Recommendation:** Monitor WebRTC connection quality metrics

---

## 📋 **DEBUGGING CHECKLIST**

### In Browser Console (Frontend):
```javascript
// Check if WebSocket is connected
console.log('Socket Connected:', socket?.connected);
console.log('Socket Transport:', socket?.io.engine.transport.name);

// Monitor message throughput
socket.on('message received', (msg) => console.log('⬅️ Message:', msg));
socket.emit('new message', {...});  // Check for errors
```

### Backend Logs to Check:
```bash
# Watch backend logs
npm run dev

# Look for:
# ✅ "A user connected via socket."
# ❌ "[SECURITY] Sender mismatch"
# ❌ "[SECURITY] Malformed" - indicates payload issues
# ⚠️  Socket errors
```

### Network Tab (Browser DevTools):
1. Open DevTools → Network tab
2. Filter for WebSocket connections
3. Look for:
   - **101 Switching Protocols** = WebSocket successful
   - **403 Forbidden** = CORS issue
   - **401 Unauthorized** = Auth token issue
   - Socket.io frames in WS tab

---

## 🔧 **IMMEDIATE FIXES TO APPLY**

### Fix #1: Correct Socket.io CORS Configuration
**File:** `backend/server.js` (Lines 157-163)
```javascript
// ✅ FIXED VERSION:
const io = new Server(server, {
    pingTimeout: 120000,
    pingInterval: 25000,
    cors: {
        origin: (origin, callback) => {
            // Allow if no origin (same-origin) or if in whitelist
            if (!origin || socketOrigins.some(allowed => {
                // Handle both exact match and with/without trailing slash
                return allowed === origin || 
                       allowed === origin.replace(/\/$/, '') ||
                       allowed + '/' === origin;
            })) {
                callback(null, true);
            } else {
                console.warn(`[CORS] Blocked origin: ${origin}`);
                callback(new Error('CORS not allowed'));
            }
        },
        methods: ['GET', 'POST'],
        credentials: true,
    },
});
```

### Fix #2: Remove Duplicate Listener
**File:** `frontend/contexts/SocketContext.tsx` (Line ~500)
Search for and remove:
```typescript
// DELETE THIS LINE (duplicate):
newSocket.on("conversationUpdated", updateConversation);
```
Keep only the one in the `useEffect` around line 365

### Fix #3: Add WebSocket Diagnostics
**File:** `frontend/contexts/SocketContext.tsx` (Add after line 460)
```typescript
// Log transport being used
newSocket.on("connect", () => {
    const transport = newSocket.io.engine.transport.name;
    console.log('[Socket] Using transport:', transport);
    
    if (transport === 'polling') {
        console.warn('[Socket] ⚠️ Using polling fallback - WebSocket may be blocked');
    }
});
```

### Fix #4: Handle Token Refresh
**File:** `frontend/contexts/SocketContext.tsx` (Add around line 580)
```typescript
newSocket.on("reconnect_attempt", async () => {
    console.log('[Socket] Reconnection attempt - refreshing token...');
    try {
        // Attempt token refresh before reconnecting
        const newToken = await secureTokenManager.refreshToken();
        if (newToken) {
            newSocket.auth.token = newToken;
            console.log('[Socket] Token refreshed for reconnection');
        }
    } catch (error) {
        console.error('[Socket] Token refresh failed:', error);
    }
});
```

---

## 🧪 **TESTING STEPS**

### Test 1: Basic Connection
```bash
# Backend
npm run dev

# Frontend (different terminal)
npm start

# Check logs for "A user connected via socket." ✅
```

### Test 2: Send Message
1. Open chat
2. Send text message
3. Check browser DevTools Network → WS tab for socket frame
4. Verify message appears on other device instantly

### Test 3: Verify No Polling Fallback
```javascript
// In browser console
socket.io.engine.transport.name  // Should be "websocket", NOT "polling"
```

### Test 4: Check Your Environment Variables
```bash
# Backend .env should have:
SOCKET_ORIGINS=https://astrachitchat.onrender.com,exp://localhost:8081,http://localhost:8081
JWT_SECRET=your_secret_here
```

---

## 📊 **Architecture Summary**

### Message Flow:
```
User A (Frontend)
    ↓ socket.emit('new message')
Backend (Socket.io)
    ✓ Validates payload
    ✓ Saves to MongoDB
    ✓ Caches sender data (5min TTL)
    ↓ io.to(chatId).emit('message received')
User B (Frontend)
    ✓ Updates state
    ✓ UI re-renders
```

### Connection Sequence:
```
1. Frontend requests token from secure storage
2. Frontend validates token expiration
3. Frontend calls io(SOCKET_URL, { auth: { token } })
4. Socket.io middleware verifies JWT
5. Backend marks user as online
6. Frontend emits 'setup' event
7. Both sides ready for messaging
```

---

## ✅ **VERIFIED WORKING FEATURES**

- ✅ JWT authentication with expiration checks
- ✅ Sender data caching (optimized)
- ✅ Message validation & security (sender mismatch check)
- ✅ WebRTC signaling with chat membership verification
- ✅ Typing indicators
- ✅ Read receipts & delivery receipts
- ✅ Offline message queuing
- ✅ Disconnect handling & cleanup

---

## 📞 **Next Steps**

1. **Apply the 4 fixes above** - especially Fix #1 (CORS)
2. **Check `.env` file** - ensure `SOCKET_ORIGINS` is set correctly
3. **Test connection** - use debugging steps in browser console
4. **Monitor logs** - watch backend for connection/auth errors
5. **Check Network tab** - verify WebSocket (not polling)

---

**Last Updated:** April 18, 2026
**Socket.io Version:** 4.8.1 (both backend & frontend)
**Status:** Ready for fixes
