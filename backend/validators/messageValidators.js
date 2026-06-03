const Joi = require('joi');

// Create chat validator
exports.createChatValidator = Joi.object({
  userId: Joi.string()
    .required()
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid user ID format',
      'any.required': 'User ID is required',
    }),
});

// Create group chat validator
exports.createGroupChatValidator = Joi.object({
  name: Joi.string()
    .trim()
    .min(1)
    .max(100)
    .required()
    .messages({
      'string.min': 'Group name cannot be empty',
      'string.max': 'Group name must not exceed 100 characters',
      'any.required': 'Group name is required',
    }),
  participants: Joi.array()
    .items(
      Joi.string()
        .regex(/^[0-9a-fA-F]{24}$/)
        .messages({
          'string.pattern.base': 'Each participant ID must be a valid MongoDB ObjectId',
        })
    )
    .min(1)
    .required()
    .messages({
      'array.min': 'At least one participant is required',
      'any.required': 'Participants are required',
    }),
});

// Send message validator
exports.sendMessageValidator = Joi.object({
  chatId: Joi.string()
    .optional()
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid chat ID format',
    }),
  receiverId: Joi.string()
    .optional()
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid receiver ID format',
    }),
  bodyText: Joi.string()
    .max(5000)
    .allow('', null)
    .optional()
    .messages({
      'string.max': 'Message must not exceed 5000 characters',
    }),
  msgType: Joi.string()
    .valid('text', 'image', 'video', 'audio', 'file', 'location', 'contact', 'sticker')
    .default('text')
    .optional(),
  mediaUrl: Joi.string()
    .uri()
    .allow('', null)
    .optional()
    .messages({
      'string.uri': 'Media URL must be a valid URI',
    }),
  mediaType: Joi.string()
    .valid('image', 'video', 'audio', 'file')
    .optional()
    .messages({
      'any.only': 'Media type must be one of: image, video, audio, file',
    }),
  attachments: Joi.array()
    .items(Joi.object({
      public_id: Joi.string().required(),
      secure_url: Joi.string().uri().required(),
      resource_type: Joi.string().valid('image', 'video', 'audio', 'file').required(),
      size: Joi.number().optional(),
      format: Joi.string().optional(),
    }))
    .optional(),
  quotedMsgId: Joi.string()
    .optional()
    .allow(null)
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid quoted message ID format',
    }),
}).custom((value, helpers) => {
  // Ensure at least bodyText or mediaUrl or attachments is provided
  const hasContent = (value.bodyText && value.bodyText.trim().length > 0) ||
                    value.mediaUrl ||
                    (value.attachments && value.attachments.length > 0);

  if (!hasContent) {
    return helpers.message('Either message text or media is required');
  }
  return value;
});

// Send encrypted message validator
exports.sendEncryptedMessageValidator = Joi.object({
  encryptedBody: Joi.string()
    .required()
    .messages({
      'any.required': 'Encrypted body is required',
    }),
  nonce: Joi.string()
    .required()
    .messages({
      'any.required': 'Nonce is required',
    }),
  msgType: Joi.string()
    .valid('text', 'image', 'video', 'audio', 'file')
    .default('text')
    .optional(),
  receiverId: Joi.string()
    .optional()
    .regex(/^[0-9a-fA-F]{24}$/),
  attachments: Joi.array()
    .items(Joi.object({
      public_id: Joi.string().required(),
      secure_url: Joi.string().uri().required(),
      resource_type: Joi.string().valid('image', 'video', 'audio', 'file').required(),
      size: Joi.number().optional(),
    }))
    .optional(),
  quotedMsgId: Joi.string()
    .optional()
    .allow(null)
    .regex(/^[0-9a-fA-F]{24}$/),
}).unknown(false);

// Edit message validator
exports.editMessageValidator = Joi.object({
  bodyText: Joi.string()
    .max(5000)
    .required()
    .messages({
      'string.max': 'Message must not exceed 5000 characters',
      'any.required': 'New message text is required',
    }),
}).unknown(false);

// Delete message validator
exports.deleteMessageValidator = Joi.object({}).unknown(false);

// Unsend message validator
exports.unsendMessageValidator = Joi.object({}).unknown(false);

// Mark message as read validator
exports.markMessageAsReadValidator = Joi.object({}).unknown(false);

// Mark all messages as read validator
exports.markAllMessagesAsReadValidator = Joi.object({
  chatId: Joi.string()
    .optional()
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid chat ID format',
    }),
}).unknown(false);

// Add reaction validator
exports.addReactionValidator = Joi.object({
  emoji: Joi.string()
    .required()
    .messages({
      'any.required': 'Emoji is required',
    }),
}).unknown(false);

// Remove reaction validator
exports.removeReactionValidator = Joi.object({}).unknown(false);

// Mute/Unmute chat validator
exports.muteChatValidator = Joi.object({
  mutedUntil: Joi.date()
    .allow(null)
    .optional()
    .messages({
      'date.base': 'mutedUntil must be a valid date',
    }),
}).unknown(false);

// Pin chat validator
exports.pinChatValidator = Joi.object({
  isPinned: Joi.boolean()
    .required()
    .messages({
      'any.required': 'isPinned flag is required',
    }),
}).unknown(false);

// Clear chat validator
exports.clearChatValidator = Joi.object({}).unknown(false);

// Get chat messages validator
exports.getChatMessagesValidator = Joi.object({
  limit: Joi.number()
    .integer()
    .min(1)
    .max(100)
    .default(50)
    .messages({
      'number.base': 'Limit must be a number',
      'number.min': 'Limit must be at least 1',
      'number.max': 'Limit must not exceed 100',
    }),
  beforeMessageId: Joi.string()
    .optional()
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid message ID format',
    }),
}).unknown(false);

// Search chats validator
exports.searchChatsValidator = Joi.object({
  query: Joi.string()
    .trim()
    .min(1)
    .max(100)
    .required()
    .messages({
      'string.min': 'Search query cannot be empty',
      'string.max': 'Search query must not exceed 100 characters',
      'any.required': 'Search query is required',
    }),
}).unknown(false);

// Add group member validator
exports.addGroupMemberValidator = Joi.object({
  chatId: Joi.string()
    .required()
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid chat ID format',
      'any.required': 'Chat ID is required',
    }),
  userId: Joi.string()
    .required()
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid user ID format',
      'any.required': 'User ID is required',
    }),
}).unknown(false);

// Remove group member validator
exports.removeGroupMemberValidator = Joi.object({
  chatId: Joi.string()
    .required()
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid chat ID format',
      'any.required': 'Chat ID is required',
    }),
  userId: Joi.string()
    .required()
    .regex(/^[0-9a-fA-F]{24}$/)
    .messages({
      'string.pattern.base': 'Invalid user ID format',
      'any.required': 'User ID is required',
    }),
}).unknown(false);

// --- Parameter Validators ---
const mongoIdSchema = Joi.string().regex(/^[0-9a-fA-F]{24}$/).required().messages({
  'string.pattern.base': 'Invalid ID format',
  'any.required': 'ID is required'
});

exports.chatIdParamValidator = Joi.object({
  chatId: mongoIdSchema
});

exports.messageIdParamValidator = Joi.object({
  messageId: mongoIdSchema
});

exports.userIdParamValidator = Joi.object({
  userId: mongoIdSchema
});

exports.messageIdAndEmojiParamValidator = Joi.object({
  messageId: mongoIdSchema,
  emoji: Joi.string().required()
});

// Leave group validator
exports.leaveGroupValidator = Joi.object({}).unknown(false);

// Pagination validator
exports.paginationValidator = Joi.object({
  page: Joi.number()
    .integer()
    .min(1)
    .default(1)
    .messages({
      'number.min': 'Page must be at least 1',
    }),
  limit: Joi.number()
    .integer()
    .min(1)
    .max(100)
    .default(20)
    .messages({
      'number.min': 'Limit must be at least 1',
      'number.max': 'Limit must not exceed 100',
    }),
}).unknown(true);
