// Load environment variables from the backend folder's .env file regardless of the current working directory
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

// ✅ FIX: Crash early if critical env vars are missing
if (!process.env.JWT_SECRET) {
    console.error('FATAL: JWT_SECRET is not set in .env file');
    process.exit(1);
}
if (!process.env.MONGO_URI) {
    console.error('FATAL: MONGO_URI is not set in .env file');
    process.exit(1);
}

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
const { applyUserDefaults } = require('./utils/lazyDefaults');

const app = express();

// ── Security: HTTP headers ────────────────────────────────────────────────────
app.use(helmet());

// ── Security: General rate limiting ──────────────────────────────────────────
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100,
    message: { message: 'Too many requests from this IP, please try again later.' },
    standardHeaders: true,
    legacyHeaders: false,
});
app.use(limiter);

// ── Security: Stricter rate limiting for auth routes ─────────────────────────
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 20,
    message: { message: 'Too many auth attempts, please try again later.' },
    standardHeaders: true,
    legacyHeaders: false,
    skip: (req) => {
        return req.path === '/register';
    }
});

// ── CORS ──────────────────────────────────────────────────────────────────────
const allowedOrigins = [
    'http://localhost:8081',
    'http://localhost:8082',
    'http://localhost:3000',
    'exp://localhost:8081',
];

if (process.env.CLIENT_URL) {
    allowedOrigins.push(process.env.CLIENT_URL);
}
if (process.env.FRONTEND_URL) {
    allowedOrigins.push(process.env.FRONTEND_URL);
}

const corsOptions = {
    origin: (origin, callback) => {
        if (process.env.NODE_ENV !== 'production') {
            return callback(null, true);
        }
        if (!origin || allowedOrigins.includes(origin)) {
            callback(null, true);
        } else {
            callback(new Error('CORS not allowed'), false);
        }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    exposedHeaders: ['Content-Length'],
    maxAge: 86400, // 24 hours
};

app.use(cors(corsOptions));

app.use(express.json({ limit: '100mb' }));
app.use(express.urlencoded({ limit: '100mb', extended: true }));

// ── Static file serving ───────────────────────────────────────────────────────
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ── MongoDB Connection ────────────────────────────────────────────────────────
const mongoOptions = {
    maxPoolSize: 10,
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
};

mongoose.connect(process.env.MONGO_URI, mongoOptions)
    .then(() => {
        console.log('MongoDB Atlas connected');
        const { startCleanupScheduler } = require('./services/cleanupService');
        startCleanupScheduler();
    })
    .catch(err => console.error('MongoDB connection error:', err));

// ── Test DB endpoint (non-production only) ────────────────────────────────────
if (process.env.NODE_ENV !== 'production') {
    app.get('/api/test/db', async (req, res) => {
        try {
            const User = require('./models/User');
            const Chat = require('./models/Chat');
            res.json({
                mongoConnected: mongoose.connection.readyState === 1,
                userCount: await User.countDocuments(),
                chatCount: await Chat.countDocuments(),
            });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    });
}

// ── API Routes ────────────────────────────────────────────────────────────────
app.use('/api/auth', authLimiter, require('./routes/auth'));
app.use('/api/posts', require('./routes/postRoutes'));
app.use('/api/profile', require('./routes/profileRoutes'));
app.use('/api/media', require('./routes/mediaRoutes'));
app.use('/api/chats', require('./routes/chatRoutes'));
app.use('/api/follow', require('./routes/followRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/search', require('./routes/searchRoutes'));
app.use('/api/report', require('./routes/reportRoutes'));
app.use('/api/stories', require('./routes/storyRoutes'));
app.use('/api/e2ee', require('./routes/e2eeRoutes'));
app.use('/api/e2ee', require('./routes/multiDeviceE2eeRoutes'));
app.use('/api/webrtc', require('./routes/webrtcRoutes'));

app.get('/', (req, res) => res.send('AstraChitChat API is running'));

// ── HTTP + Socket.io Server ───────────────────────────────────────────────────
const server = http.createServer(app);

const socketOrigins = process.env.SOCKET_ORIGINS
    ? process.env.SOCKET_ORIGINS.split(',')
    : [
        'https://astrachitchat.onrender.com',
        'http://localhost:8081',
        'http://localhost:8082',
        'exp://localhost:8081',
        'http://192.168.1.7:8081',
        'http://192.168.1.7:5000',
        'exp://192.168.1.7:8081',
    ];

const io = new Server(server, {
    pingTimeout: 120000,
    pingInterval: 25000,
    cors: {
        origin: (origin, callback) => {
            // Allow if no origin (same-origin) or if in whitelist
            // Handle both exact match and with/without trailing slash
            if (!origin || socketOrigins.some(allowed => {
                if (allowed === origin) return true;
                // Compare without trailing slashes
                const normalizedAllowed = allowed.replace(/\/$/, '');
                const normalizedOrigin = origin.replace(/\/$/, '');
                return normalizedAllowed === normalizedOrigin;
            })) {
                callback(null, true);
            } else {
                console.warn(`[CORS] Blocked WebSocket origin: ${origin}`);
                callback(new Error('CORS not allowed'));
            }
        },
        methods: ['GET', 'POST'],
        credentials: true,
    },
});

app.set('io', io);

// ── Socket.io Auth Middleware ─────────────────────────────────────────────────
io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) {
        return next(new Error('Authentication error'));
    }
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        socket.userId = decoded.id;
        next();
    } catch (error) {
        next(new Error('Authentication error'));
    }
});

// ── Socket.io Connection Handler ─────────────────────────────────────────────
io.on('connection', (socket) => {
    const User = require('./models/User');
    const Chat = require('./models/Chat');
    const Message = require('./models/Message');

    console.log(`User connected: ${socket.userId}`);

    let senderCache = null;
    let senderCacheExpiry = 0;

    const getCachedSenderData = async (userId) => {
        const now = Date.now();
        if (senderCache && senderCache._id === userId && senderCacheExpiry > now) {
            return senderCache;
        }
        const sender = await User.findById(userId).select('_id name username profilePicture');
        senderCache = sender;
        senderCacheExpiry = now + (5 * 60 * 1000);
        return sender;
    };

    socket.on('setup', async (userData) => {
        socket.join(userData._id);
        socket.emit('connected');
        try {
            await User.findByIdAndUpdate(userData._id, {
                isOnline: true,
                lastSeen: new Date(),
            });
            io.emit('user online', { userId: userData._id, isOnline: true });
        } catch (error) {
            console.error('Error updating user online status:', error);
        }
    });

    socket.on('join chat', (room) => {
        socket.join(room);
        console.log('User joined room: ' + room);
    });

    socket.on('new message', async (rawData) => {
        const MAX_TEXT_LENGTH = 2000;
        const MAX_ATTACHMENTS = 5;
        const MAX_ATTACHMENT_SIZE = 5242880;

        const validateMessageData = (data) => {
            if (!data) return false;
            if (typeof data.sender !== 'string' || data.sender.length !== 24 || !mongoose.Types.ObjectId.isValid(data.sender)) return false;
            if (typeof data.receiver !== 'string' || data.receiver.length !== 24 || !mongoose.Types.ObjectId.isValid(data.receiver)) return false;
            if (typeof data.chat !== 'string' || data.chat.length !== 24 || !mongoose.Types.ObjectId.isValid(data.chat)) return false;

            if (data.bodyText && (typeof data.bodyText !== 'string' || data.bodyText.length > MAX_TEXT_LENGTH)) return false;
            if (data.msgType && (typeof data.msgType !== 'string' || !['text', 'image', 'audio', 'video', 'file'].includes(data.msgType))) return false;

            if (data.attachments) {
                if (!Array.isArray(data.attachments) || data.attachments.length > MAX_ATTACHMENTS) return false;
                for (const attachment of data.attachments) {
                    if (!attachment.url || typeof attachment.url !== 'string') return false;
                    if (attachment.size && (typeof attachment.size !== 'number' || attachment.size > MAX_ATTACHMENT_SIZE)) return false;
                }
            }

            if (data.quotedMsgId && (typeof data.quotedMsgId !== 'string' || data.quotedMsgId.length !== 24 || !mongoose.Types.ObjectId.isValid(data.quotedMsgId))) return false;

            return true;
        };

        if (!validateMessageData(rawData)) {
            socket.emit('error', { message: 'Invalid message format (size limits exceeded)' });
            return;
        }

        if (socket.userId !== rawData.sender) {
            socket.emit('error', { message: 'Unauthorized sender' });
            return;
        }

        try {
            const messageData = {
                sender: new mongoose.Types.ObjectId(rawData.sender),
                receiver: new mongoose.Types.ObjectId(rawData.receiver),
                chat: new mongoose.Types.ObjectId(rawData.chat),
                bodyText: rawData.bodyText?.trim() || rawData.content?.trim() || '',
                msgType: rawData.msgType || 'text',
                attachments: rawData.attachments || [],
                quotedMsgId: rawData.quotedMsgId ? new mongoose.Types.ObjectId(rawData.quotedMsgId) : undefined,
                readBy: [{ user: new mongoose.Types.ObjectId(rawData.sender), readAt: new Date() }],
            };

            const [message, senderDoc] = await Promise.all([
                Message.create(messageData),
                getCachedSenderData(rawData.sender),
            ]);

            await message.populate([
                { path: 'sender', select: 'name username profilePicture' },
                { path: 'receiver', select: 'name username profilePicture' },
                { path: 'chat', select: '_id convoType' }
            ]);

            let quotedMessageData = null;
            if (message.quotedMsgId) {
                await message.populate({
                    path: 'quotedMsgId',
                    populate: { path: 'sender', select: 'name username profilePicture' },
                });
                if (message.quotedMsgId?._id) {
                    quotedMessageData = {
                        _id: message.quotedMsgId._id,
                        bodyText: message.quotedMsgId.bodyText,
                        msgType: message.quotedMsgId.msgType,
                        sender: {
                            _id: message.quotedMsgId.sender._id,
                            username: message.quotedMsgId.sender.username,
                            profilePicture: message.quotedMsgId.sender.profilePicture ? (typeof message.quotedMsgId.sender.profilePicture === 'string' ? message.quotedMsgId.sender.profilePicture : message.quotedMsgId.sender.profilePicture.secure_url) : null,
                        },
                    };
                }
            }

            await Chat.findByIdAndUpdate(rawData.chat, {
                lastMessage: {
                    text: rawData.bodyText || rawData.content || (rawData.attachments?.length ? 'Attachment' : ''),
                    createdAt: message.createdAt,
                    sender: message.sender._id,
                },
                lastActivityTimestamp: new Date(),
            });

            const messageToEmit = {
                ...message.toObject(),
                sender: applyUserDefaults(message.sender),
                receiver: message.receiver ? applyUserDefaults(message.receiver) : null,
                quotedMessage: quotedMessageData ? {
                    ...quotedMessageData,
                    sender: quotedMessageData.sender ? applyUserDefaults(quotedMessageData.sender) : null
                } : null,
            };

            io.to(rawData.chat).emit('message received', messageToEmit);

            const conversationUpdate = {
                conversationId: String(rawData.chat),
                lastMessage: {
                    text: rawData.bodyText || rawData.content || (rawData.attachments?.length ? 'Attachment' : ''),
                    createdAt: message.createdAt,
                    sender: senderDoc,
                },
                updatedAt: new Date().toISOString(),
                senderId: String(rawData.sender),
                isNewMessage: true,
            };

            const receiverRoomId = rawData.receiver?.toString() || '';
            const senderRoomId = rawData.sender?.toString() || '';

            if (receiverRoomId) io.to(receiverRoomId).emit('conversationUpdated', conversationUpdate);
            if (senderRoomId) io.to(senderRoomId).emit('conversationUpdated', conversationUpdate);

        } catch (error) {
            console.error('Socket: Error processing new message:', error);
            socket.emit('error', { message: 'Failed to send message' });
        }
    });

    socket.on('typing', (room) => socket.in(room).emit('typing'));
    socket.on('stop typing', (room) => socket.in(room).emit('stop typing'));

    socket.on('read messages', async (room) => {
        socket.in(room).emit('messages read');
        try {
            if (socket.userId) {
                socket.to(room).emit('messages read', { chatId: room, readerId: socket.userId });
            }
        } catch (error) {
            console.error('Error in read messages handler:', error);
        }
    });

    socket.on('message delivered', async (data) => {
        try {
            if (data.messageId && data.receiverId) {
                const message = await Message.findById(data.messageId);
                if (message) {
                    const alreadyDelivered = message.deliveredTo?.some(
                        d => d.user.toString() === data.receiverId.toString()
                    );
                    if (!alreadyDelivered) {
                        message.deliveredTo.push({
                            user: new mongoose.Types.ObjectId(data.receiverId),
                            deliveredAt: new Date(),
                        });
                        await message.save();
                    }
                }
            }
            socket.in(data.chatId).emit('message delivered', data);
            if (data.senderId) {
                socket.to(data.senderId).emit('message delivered', data);
            }
        } catch (error) {
            console.error('Error handling message delivery:', error);
        }
    });

    // WebRTC Signaling
    socket.on('webrtc-offer', (data) => {
        if (socket.userId !== data.callerId) return;
        socket.to(data.targetId).emit('webrtc-offer', data);
    });

    socket.on('webrtc-answer', (data) => {
        if (socket.userId !== data.responderId) return;
        socket.to(data.targetId).emit('webrtc-answer', data);
    });

    socket.on('webrtc-candidate', (data) => {
        if (socket.userId !== data.senderId) return;
        socket.to(data.targetId).emit('webrtc-candidate', data);
    });

    socket.on('end-call', (data) => {
        if (socket.userId !== data.senderId) return;
        socket.to(data.targetId).emit('end-call', data);
    });

    socket.on('disconnect', async () => {
        console.log(`User disconnected: ${socket.userId}`);
        if (socket.userId) {
            try {
                await User.findByIdAndUpdate(socket.userId, {
                    isOnline: false,
                    lastSeen: new Date(),
                });
                io.emit('user online', { userId: socket.userId, isOnline: false });
            } catch (error) {
                console.error('Error updating offline status:', error);
            }
        }
    });
});

// ── Error Handlers ────────────────────────────────────────────────────────────
app.use((req, res, next) => {
    res.status(404).json({ message: 'Route not found', path: req.originalUrl });
});

app.use((err, req, res, next) => {
    const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
    console.error('🔥 ERROR:', err.message);
    res.status(statusCode).json({
        message: err.message,
        stack: process.env.NODE_ENV === 'production' ? null : err.stack,
    });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, '0.0.0.0', () =>
    console.log(`Server running on port ${PORT}`)
);
