/**
 * mediaService.js
 * ---------------
 * Centralised helpers for all S3 / CloudFront media operations.
 *
 * Exports:
 *   getPresignedUploadUrl(userId, fileName, fileType, expiresIn?)
 *     → { presignedUrl, key, cloudfrontUrl }
 *     Client PUTs directly to S3; saves cloudfrontUrl in MongoDB.
 *
 *   deleteS3Object(key)
 *     → void  (throws on error)
 *     Removes an object from the S3 bucket.
 *
 *   getSignedCloudfrontUrl(s3Key, expiresInSeconds?)
 *     → signed URL string
 *     Time-limited CF URL for private DM/chat media.
 *     Requires CLOUDFRONT_KEY_PAIR_ID + CLOUDFRONT_PRIVATE_KEY in .env.
 */

const { PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const s3 = require('../config/s3');

// ─────────────────────────────────────────────────────────────────────────────
// 1. Presigned upload URL — client uploads directly to S3
// ─────────────────────────────────────────────────────────────────────────────
const getPresignedUploadUrl = async (userId, fileName, fileType, expiresIn = 300) => {
    const safeFileName = fileName.replace(/[^a-zA-Z0-9._-]/g, '_');
    const key = `${userId}/${Date.now()}-${safeFileName}`;
    const bucket = process.env.AWS_BUCKET_NAME;
    const cloudfrontBase = process.env.CLOUDFRONT_URL.replace(/\/$/, '');

    const command = new PutObjectCommand({
        Bucket: bucket,
        Key: key,
        ContentType: fileType,
    });

    const presignedUrl = await getSignedUrl(s3, command, { expiresIn });

    return {
        presignedUrl,          // Client PUTs to this URL (expires in `expiresIn` seconds)
        key,                   // Store this in MongoDB as mediaKey for future deletion
        cloudfrontUrl: `${cloudfrontBase}/${key}`, // Store this as mediaUrl in MongoDB
    };
};

// ─────────────────────────────────────────────────────────────────────────────
// 2. Delete an S3 object by key
// ─────────────────────────────────────────────────────────────────────────────
const deleteS3Object = async (key) => {
    if (!key) return; // Gracefully skip if no key stored
    await s3.send(new DeleteObjectCommand({
        Bucket: process.env.AWS_BUCKET_NAME,
        Key: key,
    }));
};

// ─────────────────────────────────────────────────────────────────────────────
// 3. CloudFront Signed URL — time-limited access for private chat media
//    Requires CLOUDFRONT_KEY_PAIR_ID and CLOUDFRONT_PRIVATE_KEY in .env
//    The private key value should be the PEM string with newlines replaced by \n
// ─────────────────────────────────────────────────────────────────────────────
const getSignedCloudfrontUrl = (s3Key, expiresInSeconds = 3600) => {
    const keyPairId = process.env.CLOUDFRONT_KEY_PAIR_ID;
    const privateKey = process.env.CLOUDFRONT_PRIVATE_KEY;

    if (!keyPairId || !privateKey) {
        // Fall back to plain CloudFront URL if signing keys not configured yet.
        // Set up CloudFront key pair in AWS Console → CloudFront → Key management
        // to enable proper signed URLs for private chat media.
        console.warn('[mediaService] CLOUDFRONT_KEY_PAIR_ID or CLOUDFRONT_PRIVATE_KEY not set. Returning unsigned URL.');
        const cloudfrontBase = process.env.CLOUDFRONT_URL.replace(/\/$/, '');
        return `${cloudfrontBase}/${s3Key}`;
    }

    try {
        const { getSignedUrl: cfGetSignedUrl } = require('@aws-sdk/cloudfront-signer');
        const url = `${process.env.CLOUDFRONT_URL.replace(/\/$/, '')}/${s3Key}`;
        return cfGetSignedUrl({
            url,
            keyPairId,
            privateKey: privateKey.replace(/\\n/g, '\n'), // Handle escaped newlines in env
            dateLessThan: new Date(Date.now() + expiresInSeconds * 1000).toISOString(),
        });
    } catch (err) {
        console.error('[mediaService] Failed to create CF signed URL:', err.message);
        const cloudfrontBase = process.env.CLOUDFRONT_URL.replace(/\/$/, '');
        return `${cloudfrontBase}/${s3Key}`;
    }
};

module.exports = { getPresignedUploadUrl, deleteS3Object, getSignedCloudfrontUrl };
