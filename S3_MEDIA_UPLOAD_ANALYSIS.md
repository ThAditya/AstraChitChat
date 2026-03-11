# AWS S3 Media Upload Analysis Report

## 1. Overview of Current Implementation

### 1.1 Architecture
The application uses AWS S3 for storing media files (images, videos) and CloudFront as a CDN for serving those files:

- **S3 Bucket**: Private storage for all media files
- **CloudFront**: Public-facing CDN that serves files from S3
- **MongoDB**: Stores URLs (`mediaUrl`) and S3 keys (`mediaKey`) for deletion

### 1.2 Upload Methods

There are TWO upload methods implemented:

#### Method 1: Multer-S3 Middleware (backend/routes/post.js, backend/routes/mediaRoutes.js)
- Files are uploaded through the backend server
- Uses `multer-s3` package
- Suitable for smaller files (images, profile pictures)
- Flow: Client → Backend → S3

#### Method 2: Presigned URLs (backend/routes/mediaRoutes.js)
- Client uploads directly to S3 using presigned PUT URL
- Backend generates a presigned URL and returns it to client
- Client uploads directly to S3, then saves the CloudFront URL to MongoDB
- Suitable for large files (videos/Flicks) to avoid server memory issues

### 1.3 S3 Privacy Status

**S3 Bucket is PRIVATE** - This is by design:
- S3 bucket is NOT publicly accessible
- Files are accessed through CloudFront distribution
- For private chat media, the system supports CloudFront signed URLs (time-limited access)
- The `getSignedCloudfrontUrl` function in `mediaService.js` creates time-limited URLs

**However, there's a potential security issue**: If `CLOUDFRONT_KEY_PAIR_ID` and `CLOUDFRONT_PRIVATE_KEY` are not configured, the system falls back to unsigned URLs, making media publicly accessible.

---

## 2. MongoDB Schema for Media Storage

### 2.1 Post Model (backend/models/Post.js)
```javascript
{
  mediaUrl: String,      // CloudFront URL - saved in MongoDB
  mediaKey: String,      // S3 object key - used for deletion
  mediaType: String      // 'image', 'video', or 'flick'
}
```

### 2.2 Message Model (backend/models/Message.js)
```javascript
{
  msgType: String,       // 'text', 'image', 'audio', 'video', 'file'
  mediaUrl: String,      // CloudFront URL for single media
  mediaKey: String,      // S3 key for single media
  mediaMime: String,     // MIME type
  mediaSizeBytes: Number,
  attachments: [{
    type: String,        // 'image', 'video', 'audio', 'file'
    url: String,         // CloudFront URL
    key: String,        // S3 key for deletion
    filename: String,
    size: Number,
    mimeType: String
  }]
}
```

### 2.3 User Model (backend/models/User.js)
```javascript
{
  profilePicture: String  // CloudFront URL
}
```

---

## 3. Errors and Bugs Found

### 🔴 CRITICAL BUGS

#### BUG #1: Duplicate and Conflicting Routes in post.js
**File**: `backend/routes/post.js`
**Issue**: Two `/upload` routes are defined with different handlers:

```javascript
// First upload route - uses multer middleware
router.post("/upload", upload.single("media"), async(req, res)=>{
    // Returns: { message, mediaUrl }
});

// Second upload route - uses createPost controller  
router.post('/upload', protect, createPost); // This will NEVER be reached!
```

**Impact**: The second `/upload` route with `createPost` controller will NEVER execute because Express matches the first route and returns. This breaks the post creation flow where the frontend expects to send `mediaUrl, mediaKey, mediaType, caption` to create a post.

**Evidence**: In `frontend/app/(tabs)/(tabs)/profile.tsx`, the code calls `get('/posts/me')` which should fetch posts with media, but the upload flow might be broken.

---

#### BUG #2: Route Mounting Confusion
**Files**: `backend/server.js` and multiple route files
**Issue**: Two different route files are being used:
- `app.use('/api/posts', require('./routes/postRoutes'));` - used in server.js
- `require('./routes/post.js')` - appears to also exist but may not be mounted

In `backend/routes/post.js`:
```javascript
const express = require('express');
const router = express.Router();
// ... routes defined but file doesn't export properly for mounting
```

**Impact**: Confusion about which route file is actually active. The `post.js` file has its own routes but they're not mounted in `server.js`.

---

#### BUG #3: Frontend Hardcoded Content-Type
**File**: `frontend/services/mediaService.ts`
**Issue**:
```typescript
formData.append('media', {
  uri: fileUri,
  type: 'image/jpeg', // Hardcoded! Always JPEG regardless of actual type
  name: fileName,
} as any);
```

**Impact**: 
- All uploaded files are sent as `image/jpeg` even if they're videos
- Could cause incorrect content-type in S3
- May cause playback issues for videos

---

### 🟠 HIGH PRIORITY ISSUES

#### ISSUE #4: CloudFront Signed URL Fallback Exposes Private Media
**File**: `backend/services/mediaService.js`
**Issue**:
```javascript
const getSignedCloudfrontUrl = (s3Key, expiresInSeconds = 3600) => {
    const keyPairId = process.env.CLOUDFRONT_KEY_PAIR_ID;
    const privateKey = process.env.CLOUDFRONT_PRIVATE_KEY;

    if (!keyPairId || !privateKey) {
        // Falls back to PLAIN URL - not signed!
        console.warn('[mediaService] CLOUDFRONT_KEY_PAIR_ID or CLOUDFRONT_PRIVATE_KEY not set...');
        return `${cloudfrontBase}/${s3Key}`; // UNSIGNED!
    }
    // ...
};
```

**Impact**: If CloudFront signing keys are not configured in `.env`, all media (including private chat messages) will be publicly accessible via unsigned URLs. This is a security vulnerability.

**Fix Needed**: Either:
1. Require signing keys to be set for the app to work, OR
2. At minimum, log a WARNING that media is public, OR
3. Use S3 pre-signed URLs instead of CloudFront for private content

---

#### ISSUE #5: Missing Presigned URL Validation in Frontend
**File**: `frontend/services/mediaService.ts`
**Issue**: The frontend generates presigned URLs but doesn't handle errors properly:

```typescript
export const uploadMedia = async (fileUri: string, fileName: string): Promise<string> => {
  try {
    const formData = new FormData();
    formData.append('media', {
      uri: fileUri,
      type: 'image/jpeg', // Bug: hardcoded
      name: fileName,
    } as any);
    const response = await post('/media/upload', formData);
    return response.url; // Assumes always success
  } catch (error) {
    console.error('Error uploading media:', error);
    throw error;
  }
};
```

**Impact**: No retry logic, no upload progress tracking, and errors are not user-friendly.

---

#### ISSUE #6: Missing Media Key in Message Attachments After Upload
**Files**: `backend/controllers/chatController.js`, `backend/routes/mediaRoutes.js`

**Issue**: When uploading media via `/api/media/upload`, the response includes both `url` and `key`:
```javascript
res.json({
    url: fileUrl,              // CloudFront URL
    key: req.file.key,         // S3 object key
    size: req.file.size,
    contentType: req.file.contentType,
});
```

However, in `chatController.js` when sending messages with attachments:
```javascript
const msgObj = {
    // ...
    attachments: attachments || [], // attachments come from frontend
};
```

The frontend might not be saving/returning the `key` (S3 object key) properly when sending messages.

**Impact**: Media files uploaded in chat messages won't be deleted from S3 when messages are deleted because the S3 key is not stored.

---

### 🟡 MEDIUM PRIORITY ISSUES

#### ISSUE #7: No File Size Validation on Presigned URL Endpoint
**File**: `backend/routes/mediaRoutes.js`
**Issue**: The `/presigned-url` endpoint validates file types but NOT file size:
```javascript
const allowedTypes = /^(image\/(jpeg|jpg|png|gif|webp)|video\/(mp4|quicktime|x-msvideo))$/;
if (!allowedTypes.test(fileType)) {
    return res.status(400).json({ message: 'Unsupported file type...' });
}
// No fileSize validation!
```

The multer middleware has `limits: { fileSize: 100 * 1024 * 1024 }` (100MB), but the presigned URL endpoint doesn't enforce this.

**Impact**: Users could request presigned URLs for very large files without validation.

---

#### ISSUE #8: Inconsistent URL Storage
**Files**: `backend/routes/post.js` vs `backend/routes/mediaRoutes.js`

**Issue**: Different URL formats are returned:
- `post.js`: `${process.env.CLOUDFRONT_URL}/${req.file.key}` (may have double slashes)
- `mediaRoutes.js`: `${cloudfrontBase}/${req.file.key}` (removes trailing slash first)

```javascript
// post.js - potential double slash issue
const cloudfrontUrl = `${process.env.CLOUDFRONT_URL}/${req.file.key}`;
// If CLOUDFRONT_URL = "https://cdn.example.com/", URL becomes "https://cdn.example.com//filename"

// mediaRoutes.js - correct
const cloudfrontBase = process.env.CLOUDFRONT_URL.replace(/\/$/, ''); // removes trailing slash
const fileUrl = `${cloudfrontBase}/${req.file.key}`; // correct
```

**Impact**: Inconsistent URLs could lead to broken image/video loading.

---

#### ISSUE #9: No Error Handling for S3 Delete Failures
**File**: `backend/controllers/postController.js`
**Issue**:
```javascript
// Delete from S3 first (best-effort — do not block on S3 failures)
if (post.mediaKey) {
    try {
        await deleteS3Object(post.mediaKey);
    } catch (s3Err) {
        console.error('[postController] S3 delete failed...');
        // Continues anyway - orphan files in S3
    }
}
await post.deleteOne(); // S3 delete failure is silently ignored
```

**Impact**: Orphaned files accumulate in S3 bucket, costing storage money.

---

#### ISSUE #10: Chat Media Deletion Not Implemented
**File**: `backend/controllers/chatController.js`
**Issue**: The `unsendMessage` function clears attachments but doesn't delete S3 files:

```javascript
async function unsendMessage(req, res) {
    // ...
    message.bodyText = ''; // clear text
    message.attachments = []; // clear attachments (but S3 files remain!)
    await message.save();
    // No call to deleteS3Object for attachments!
}
```

**Impact**: Chat media files are never deleted from S3, even when messages are unsent.

---

### 🟢 LOW PRIORITY / CODE QUALITY ISSUES

#### ISSUE #11: Test File Exists But May Be Outdated
**File**: `backend/test-s3.js`
**Status**: Exists and appears functional for testing S3/CloudFront connection, but may need updating.

---

#### ISSUE #12: Inconsistent Error Responses
**Issue**: Different endpoints return errors in different formats:
- `{ message: 'error' }`
- `{ error: error.message }`
- `{ message: 'error', error: err.message }`

**Impact**: Frontend has to handle multiple error formats.

---

#### ISSUE #13: Missing Content-Type Header Warning
**File**: `backend/middleware/uploadMiddleware.js`
**Note**: Uses `multerS3.AUTO_CONTENT_TYPE` which is good, but the frontend hardcodes `image/jpeg`.

---

#### ISSUE #14: No Upload Progress Tracking
**Issue**: Both upload methods (multer and presigned URL) don't provide progress events to the frontend.

**Impact**: Large file uploads feel unresponsive to users.

---

## 4. Summary Table

| Bug # | Severity | File | Issue |
|-------|----------|------|-------|
| 1 | 🔴 CRITICAL | backend/routes/post.js | Duplicate /upload routes - second never executes |
| 2 | 🔴 CRITICAL | backend/server.js | Route mounting confusion |
| 3 | 🔴 CRITICAL | frontend/services/mediaService.ts | Hardcoded content-type |
| 4 | 🟠 HIGH | backend/services/mediaService.js | Unsigned URL fallback exposes private media |
| 5 | 🟠 HIGH | frontend/services/mediaService.ts | Poor error handling |
| 6 | 🟠 HIGH | backend/controllers/chatController.js | Missing S3 key in attachments |
| 7 | 🟡 MEDIUM | backend/routes/mediaRoutes.js | No file size validation on presigned URL |
| 8 | 🟡 MEDIUM | backend/routes/post.js | Double slash in URL |
| 9 | 🟡 MEDIUM | backend/controllers/postController.js | Silent S3 delete failures |
| 10 | 🟡 MEDIUM | backend/controllers/chatController.js | Chat media not deleted from S3 |
| 11 | 🟢 LOW | backend/test-s3.js | May need updates |
| 12 | 🟢 LOW | Multiple | Inconsistent error responses |
| 13 | 🟢 LOW | frontend/services/mediaService.ts | Frontend/Backend content-type mismatch |
| 14 | 🟢 LOW | Both upload methods | No upload progress tracking |

---

## 5. Recommendations

### Immediate Actions (Critical):
1. Fix duplicate route in `backend/routes/post.js` - remove or consolidate the routes
2. Fix hardcoded content-type in `frontend/services/mediaService.ts`
3. Add CloudFront signing keys to `.env` or implement proper fallback handling
4. Fix URL construction to prevent double slashes

### High Priority:
5. Implement S3 key storage for chat message attachments
6. Add error handling and retry logic to frontend upload functions
7. Implement proper S3 deletion when chat messages are unsent

### Medium Priority:
8. Add file size validation to presigned URL endpoint
9. Add better error handling for S3 delete failures (consider a cleanup job)
10. Standardize error response format across all endpoints

### Nice to Have:
11. Add upload progress tracking
12. Update test-s3.js if needed
13. Add file type validation on frontend to match backend

