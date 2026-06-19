const User = require('../models/User');
const Post = require('../models/Post');

// @desc    Search users and posts
// @route   GET /api/search?q=query
// @access  Private
// FIX: now filters blocked users (both directions) consistent with userController.searchUsers
const searchAll = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q || q.trim().length === 0) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const currentUserId = req.user._id;

    // Build blocked-user exclusion list (same logic as searchUsers)
    const currentUser = await User.findById(currentUserId).select('blockedUsers');
    const blockedUsers = currentUser?.blockedUsers || [];

    const usersWhoBlockedMe = await User.find({ blockedUsers: currentUserId }).select('_id');
    const blockedByIds = usersWhoBlockedMe.map(u => u._id);

    const excludedUsers = [...blockedUsers, ...blockedByIds, currentUserId];

    const users = await User.find({
      _id: { $nin: excludedUsers },
      $or: [
        { username: { $regex: q, $options: 'i' } },
        { name: { $regex: q, $options: 'i' } },
        { category: { $regex: q, $options: 'i' } },
      ],
    })
      .select('username name profilePicture profilePublicId')
      .limit(10);

    const CLOUDINARY_CLOUD = process.env.CLOUDINARY_CLOUD_NAME || 'astrachat';

    // Helper: build Cloudinary URL with transformations
    function buildCloudinaryUrl(publicId, opts = {}) {
        if (!publicId) return '';
        const { width, height, crop = 'fill', gravity, radius, quality = 'auto', format = 'auto' } = opts;
        const transforms = [
            width    && `w_${width}`,
            height   && `h_${height}`,
            crop     && `c_${crop}`,
            gravity  && `g_${gravity}`,
            radius   && `r_${radius}`,
            `q_${quality}`,
            `f_${format}`,
        ].filter(Boolean).join(',');

        return `https://res.cloudinary.com/${CLOUDINARY_CLOUD}/image/upload/${transforms}/${publicId}`;
    }

    // Sort so exact matches come first and map to frontend format
    const lowerQ = q.toLowerCase();
    const exactMatch = [];
    const others = [];
    users.forEach(user => {
      const profilePublicId = user.profilePublicId || user.profilePicture?.public_id;
      const profilePictureUrl = profilePublicId
          ? buildCloudinaryUrl(profilePublicId, { width: 400, height: 400, gravity: 'face', radius: 'max' })
          : '';

      const userObj = {
        _id: user._id,
        username: user.username,
        name: user.name,
        profilePicture: profilePictureUrl
      };

      if (
        user.username.toLowerCase() === lowerQ ||
        (user.name && user.name.toLowerCase() === lowerQ)
      ) {
        exactMatch.push(userObj);
      } else {
        others.push(userObj);
      }
    });
    const sortedUsers = [...exactMatch, ...others];

    // Search posts by caption
    const posts = await Post.find({
      caption: { $regex: q, $options: 'i' },
    })
      .populate('author', 'username name profilePicture profilePublicId')
      .sort({ createdAt: -1 })
      .limit(20)
      .lean();

    // Sanitize posts response to match feed endpoint format
    const sanitizedPosts = posts.map(post => {
      const primaryMedia = post.media && post.media.length > 0 ? post.media[0] : {};

      const authorProfilePublicId = post.author?.profilePublicId || post.author?.profilePicture?.public_id;
      const authorProfilePictureUrl = authorProfilePublicId
          ? buildCloudinaryUrl(authorProfilePublicId, { width: 400, height: 400, gravity: 'face', radius: 'max' })
          : '';

      return {
        _id: post._id || '',
        secure_url: primaryMedia.secure_url || '',
        resource_type: primaryMedia.resource_type || 'image',
        mediaUrl: primaryMedia.secure_url || '',
        mediaType: primaryMedia.resource_type || 'image',
        caption: post.caption || '',
        duration: primaryMedia.duration || null,
        type: primaryMedia.resource_type === 'video' ? 'video' : (primaryMedia.secure_url ? 'photo' : 'text'),
        user: {
          _id: post.author?._id || '',
          username: post.author?.username || 'unknown',
          profilePicture: authorProfilePictureUrl
        },
        author: {
          _id: post.author?._id || '',
          username: post.author?.username || 'unknown',
          profilePicture: authorProfilePictureUrl,
          name: post.author?.name || ''
        },
        createdAt: post.createdAt?.toISOString() || new Date().toISOString(),
        likes: post.likesCount || 0,
        comments: post.commentsCount || 0,
        shares: post.sharesCount || 0,
        hashtags: Array.isArray(post.hashtags) ? post.hashtags : []
      };
    });

    res.json({ 
      users: sortedUsers, 
      posts: sanitizedPosts,
      page: 1,
      hasMore: false,
      category: 'search'
    });
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

module.exports = { searchAll };