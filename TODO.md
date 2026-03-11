<<<<<<< HEAD
# TODO: Merge changes from AstraChitChat-master to AstraChitChat

## Task: Merge recent changes from server.js and detail.tsx

## Steps:

### Step 1: Merge server.js changes
- [ ] Add detailed FIX EXPLANATION comments (from master)
- [ ] Add more sophisticated 'read messages' handler with JWT verification
- [ ] Keep current performance optimizations (bufferCommands, maxPoolSize, perMessageDeflate, production detection)

### Step 2: Merge detail.tsx changes
- [ ] Add refs for currentUserIdRef, otherUserIdRef, chatIdRef
- [ ] Add inputRef for TextInput
- [ ] Add autoFocus={true} and blurOnSubmit={false} to TextInput
- [ ] Update handleMessagesRead with refs to avoid stale closures
- [ ] Add updates to local message read status in markAllAsRead
=======
# TODO: Fix Chat and Calling Features - COMPLETED

## Chat Detail (detail.tsx) Bugs - ✅ FIXED
- [x] 1. Fix socket event listener registration for message delivery receipts
- [x] 2. Fix read receipts logic 
- [x] 3. Fix loading state with stale closure
- [x] 4. Clear typing timeout on unmount

## Call Context (CallContext.tsx) Bugs - ✅ FIXED
- [x] 5. Fix toggleMute inverted logic
- [x] 6. Add proper audio routing for speaker
- [x] 7. Fix cleanup race conditions
- [x] 8. Add video call UI support

## UI Improvements - ✅ COMPLETED
- [x] 9. Add video call button alongside audio call
- [x] 10. Improve chat header styling
>>>>>>> upstream/master

