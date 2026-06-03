const express = require('express');
const {
    getChats,
    getChatMessages,
    findChat,
    createChat,
    searchChats,
    sendMessage,
    markMessageAsRead,
    markAllMessagesAsRead,
    addReaction,
    removeReaction,
    editMessage,
    unsendMessage,
    deleteMessage,
    getMessageReceipts,
    getMessageReactions,
    getUserStatus,
    createGroupChat,
    getChatInfo,
    getChatMedia,
    muteChat,
    pinChat,
    clearChat,
    sendEncryptedMessage,
    getEncryptedChatMessages
} = require('../controllers/chatController');

const { protect } = require('../middleware/auth');
const { leaveGroup, addGroupMember, removeGroupMember } = require('../controllers/groupManagement');
const { validateRequest } = require('../middleware/validateRequest');
const {
  createChatValidator,
  createGroupChatValidator,
  sendMessageValidator,
  sendEncryptedMessageValidator,
  editMessageValidator,
  markMessageAsReadValidator,
  markAllMessagesAsReadValidator,
  addReactionValidator,
  muteChatValidator,
  pinChatValidator,
  getChatMessagesValidator,
  searchChatsValidator,
  addGroupMemberValidator,
  removeGroupMemberValidator,
  leaveGroupValidator,
  paginationValidator,
  chatIdParamValidator,
  messageIdParamValidator,
  userIdParamValidator,
  messageIdAndEmojiParamValidator,
} = require('../validators/messageValidators');
const {
  chatLimiter,
  messageLimiter,
  editMessageLimiter,
  deleteMessageLimiter,
  createChatLimiter,
  searchLimiter,
} = require('../middleware/rateLimiter');

const router = express.Router();

// ── Static routes first ──────────────────────────────────────
// FIX: Add searchLimiter to prevent search spam
router.get('/search', protect, searchLimiter, validateRequest({ querySchema: searchChatsValidator }), searchChats);

// Find existing chat with a user
router.get('/find/:userId', protect, chatLimiter, validateRequest({ paramsSchema: userIdParamValidator }), findChat);

// Get user online status
router.get('/user-status/:userId', protect, chatLimiter, validateRequest({ paramsSchema: userIdParamValidator }), getUserStatus);

// FIX: Add createChatLimiter to prevent spam chat creation
router.post('/create', protect, createChatLimiter, validateRequest({ bodySchema: createChatValidator }), createChat);

// FIX: Add createChatLimiter to group chat creation
router.post('/group', protect, createChatLimiter, validateRequest({ bodySchema: createGroupChatValidator }), createGroupChat);

// FIX: Add chatLimiter to mark all as read
router.post('/read-all', protect, chatLimiter, validateRequest({ bodySchema: markAllMessagesAsReadValidator }), markAllMessagesAsRead);

// ── Message-specific routes (before /:chatId wildcard) ───────
// FIX: Add chatLimiter to mark read operations
router.post('/messages/:messageId/read', protect, chatLimiter, validateRequest({ paramsSchema: messageIdParamValidator, bodySchema: markMessageAsReadValidator }), markMessageAsRead);

// FIX: Add editMessageLimiter to prevent edit spam
router.put('/messages/:messageId', protect, editMessageLimiter, validateRequest({ paramsSchema: messageIdParamValidator, bodySchema: editMessageValidator }), editMessage);

// FIX: Add deleteMessageLimiter to prevent delete spam
// NOTE: DELETE routes should not have body schemas for better compatibility
router.delete('/messages/:messageId/unsend', protect, deleteMessageLimiter, validateRequest({ paramsSchema: messageIdParamValidator }), unsendMessage);

// FIX: Add deleteMessageLimiter to prevent delete spam
router.delete('/messages/:messageId', protect, deleteMessageLimiter, validateRequest({ paramsSchema: messageIdParamValidator }), deleteMessage);

// FIX: Add chatLimiter to receipt queries
router.get('/messages/:messageId/receipts', protect, chatLimiter, validateRequest({ paramsSchema: messageIdParamValidator }), getMessageReceipts);

// FIX: Add chatLimiter to reaction operations
router.post('/messages/:messageId/reactions', protect, chatLimiter, validateRequest({ paramsSchema: messageIdParamValidator, bodySchema: addReactionValidator }), addReaction);

router.delete('/messages/:messageId/reactions/:emoji', protect, chatLimiter, validateRequest({ paramsSchema: messageIdAndEmojiParamValidator }), removeReaction);

router.get('/messages/:messageId/reactions', protect, chatLimiter, validateRequest({ paramsSchema: messageIdParamValidator }), getMessageReactions);

// ── Wildcard /:chatId routes last ────────────────────────────
// FIX: Add paginationValidator to the main chat list route
router.get('/', protect, chatLimiter, validateRequest({ querySchema: paginationValidator }), getChats);

// ✅ FIX: sendMessage supports both routes with messageLimiter:
// - POST / sends message by receiverId (finds/creates chat automatically)
// - POST /:chatId/messages sends message to existing chat using chatId
router.post('/', protect, messageLimiter, validateRequest({ bodySchema: sendMessageValidator }), sendMessage);

router.get('/:chatId/messages', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator, querySchema: getChatMessagesValidator }), getChatMessages);

router.post('/:chatId/messages', protect, messageLimiter, validateRequest({ paramsSchema: chatIdParamValidator, bodySchema: sendMessageValidator }), sendMessage);

router.get('/:chatId/encrypted-messages', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator, querySchema: getChatMessagesValidator }), getEncryptedChatMessages);

router.post('/:chatId/encrypted-messages', protect, messageLimiter, validateRequest({ paramsSchema: chatIdParamValidator, bodySchema: sendEncryptedMessageValidator }), sendEncryptedMessage);

router.get('/:chatId/info', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator }), getChatInfo);

router.get('/:chatId/media', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator, querySchema: paginationValidator }), getChatMedia);

router.post('/:chatId/mute', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator, bodySchema: muteChatValidator }), muteChat);

router.post('/:chatId/pin', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator, bodySchema: pinChatValidator }), pinChat);

router.post('/:chatId/clear', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator }), clearChat);

router.post('/:chatId/leave', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator, bodySchema: leaveGroupValidator }), leaveGroup);

router.post('/:chatId/add-member', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator, bodySchema: addGroupMemberValidator }), addGroupMember);

router.post('/:chatId/remove-member', protect, chatLimiter, validateRequest({ paramsSchema: chatIdParamValidator, bodySchema: removeGroupMemberValidator }), removeGroupMember);

module.exports = router;
