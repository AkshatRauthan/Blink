# Blink — Complete Implementation Plan

> **Purpose:** Detailed step-by-step execution plan for reimplementing the complete UI and all features of Blink. Track progress by checking off items and adding custom reviews/comments under each section.

## Phase 1: Core Framework & Native Engines

### 1.1 Crypto & Hardware Acceleration (libsodium)
- ✅ Bind `libsodium` FFI for Ed25519/X25519 key exchanges.
- ✅ Bind `libsodium` FFI for XChaCha20-Poly1305 stream encryption.
- ✅ Bind `BLAKE3` for streaming verification.
- ✅ Add Ed25519 detached `signDetached()` / `verifyDetached()` to NativeCryptoService.
- **Review/Comments:**
  > Ed25519 + X25519 keypair generation is now wired through sodium_sumo via `NativeCryptoService`, and QR token generation now uses a real ephemeral X25519 public key instead of the identity key stub. XChaCha20-Poly1305 chunk encryption/decryption is active via `CryptoService.encryptChunk/decryptChunk` using libsodium AEAD. BLAKE3 hashing now has real FFI symbol binding with streamed hashing API and SHA-256 fallback when native library is unavailable. Ed25519 detached signatures added for QR token authentication.

### 1.2 Base HTTP Transfer Server
- ✅ Implement embedded Shelf HTTP Server with route handlers.
- ✅ Implement `POST /transfer/begin` — parses file manifest, creates output dirs, opens IOSink per file.
- ✅ Implement `PUT /transfer/:sid/:fileIndex` — decrypts XChaCha20 chunks, writes plaintext to disk.
- ✅ Implement `GET /transfer/:sid/status` — returns per-file progress JSON.
- ✅ Implement `DELETE /transfer/:sid` — cancels session, closes all sinks.
- ✅ Implement file integrity verification (BLAKE3/SHA-256 hash check on file completion, returns HTTP 422 on mismatch).
- ✅ Expose `ChunkEvent` stream with full metadata (fileIndex, receivedBytes, totalBytes, fileComplete, sessionComplete, error).
- ✅ Add `outputBaseDir` injectable for test environments (bypasses `path_provider` which requires Flutter engine).
- **Review/Comments:**
  > Server runs on `0.0.0.0:49876` via Shelf. Each incoming session tracks files via `IncomingFileInfo` with `IOSink` for direct disk writes. Decryption uses `CryptoService.decryptChunk()` (splits nonce at byte 24). Integrity checking uses `NativeHashService.hashFileHex()` — currently falls back to SHA-256 since native BLAKE3 .c files aren't compiled yet. Session keys can be pre-registered via `registerSessionKey()` or sent inline in the begin request.

### 1.3 HTTP Transfer Client
- ✅ Implement `beginSession()` — sends JSON manifest with sessionId, senderDeviceId, sessionKey (base64), and files array.
- ✅ Implement `sendChunk()` — encrypts plaintext via `CryptoService.encryptChunk()`, sends as `application/octet-stream`, returns received byte count from server.
- ✅ Implement lazy `HttpClient` initialization with Keep-Alive (`AppConstants.httpKeepAlive`).
- **Review/Comments:**
  > `HttpClientService` is the high-level client API. In practice, the sender isolate (`transfer_isolate.dart`) uses its own `HttpClient` directly since isolates don't share singletons. Both follow the same wire protocol.

### 1.4 Transfer Manager & Sender Isolate
- ✅ Implement `TransferManager` orchestrator — session state machine (connecting → transferring → completed/failed/cancelled).
- ✅ Implement `sendFiles()` — creates `TransferFile` records, persists to SQLite, spawns sender isolate.
- ✅ Implement sender `Isolate` that self-initializes crypto + hash services (isolates don't share state).
- ✅ Pre-compute file checksums in isolate and include in session manifest.
- ✅ Implement chunked file streaming with `BytesBuilder` buffering (4 MB chunks per `AppConstants.chunkSizeBytes`).
- ✅ Report per-file and per-session progress via `TransferProgress` messages back to main isolate.
- ✅ Handle errors: file-not-found, chunk send failure, session begin failure.
- ✅ Implement `startReceiver()` — starts `HttpServerService`, listens for `ChunkEvent`, auto-creates session tracking.
- ✅ Implement `cancelTransfer()` — kills isolate, updates state, persists to SQLite.
- ✅ Wire `TransferNotifier` (Riverpod) — `ActiveTransfersNotifier` subscribes to `onProgress`, `TransferNotifier.startSend()` accepts `sessionKey` as parameter.
- **Review/Comments:**
  > The isolate architecture ensures file I/O and encryption never block the UI thread. Each isolate creates its own `NativeCryptoService` and `NativeHashService` instances. Progress flows: Isolate → ReceivePort → TransferManager → StreamController → TransferNotifier → UI rebuild. SQLite persistence happens on every progress update for crash recovery.

### 1.5 File Integrity (BLAKE3 / SHA-256)
- ✅ Wire hash computation into sender isolate (pre-computes per-file checksum before transfer).
- ✅ Wire hash verification into receiver server (verifies after final chunk, returns 422 on mismatch).
- ✅ `NativeHashService` — FFI struct definitions and symbol lookup written for BLAKE3.
- ✅ SHA-256 fallback via `crypto` package (active — BLAKE3 native lib not compiled yet).
- [ ] Download BLAKE3 C reference implementation from upstream (`blake3.c`, `blake3_dispatch.c`, `blake3_portable.c`).
- [ ] Build native `.so`/`.dll` via CMake for Linux/Windows/Android.
- **Review/Comments:**
  > Integrity verification is fully integrated into the transfer protocol. Currently uses SHA-256 as fallback. Once the native C files are compiled, it auto-upgrades to BLAKE3 (~8-12 GB/s vs ~0.3 GB/s). The `NativeHashService.init()` call gracefully falls back if the .so isn't found.

### 1.6 Test Coverage (Phase 1)
- ✅ `test/transfer_e2e_test.dart` — 7 tests:
  - Crypto round-trip (encrypt → decrypt = identical plaintext)
  - Crypto different nonces per encryption
  - HTTP server start/stop lifecycle
  - End-to-end file transfer: send file over HTTP, verify received bytes match on disk
  - Server rejects chunk for unknown session (404)
  - Session status endpoint returns progress
  - Integrity check rejects corrupted transfer (422)
- ✅ `test/security_test.dart` — 11 tests:
  - Ed25519 sign/verify round-trip
  - Tampered message fails verification
  - Wrong key fails verification
  - QR token generation produces valid signed payload
  - QR encode/decode round-trip preserves all fields
  - validateAndConsume accepts valid token
  - Token is single-use (second validation throws)
  - Tampered token signature is rejected
  - X25519 ECDH: both sides derive same shared secret
  - Different keypairs produce different shared secrets
  - Full QR handshake: generate → validate → derive → encrypt/decrypt
- **Review/Comments:**
  > All 18 tests pass. Tests run without Flutter engine (no platform channels) thanks to `outputBaseDir` injection and `initWithKeyPair()` test helper.

## Phase 2: Local Network Discovery

### 2.1 Multi-Platform Discovery Setup
- ✅ Implement `bonsoir` mDNS/Bonjour discovery with full service resolution.
- ✅ Handle `BonsoirDiscoveryServiceResolvedEvent` → parse into `Device` object (IP, port, platform, deviceId from TXT record).
- ✅ Handle `BonsoirDiscoveryServiceLostEvent` → emit device ID on `onDeviceLost` stream.
- ✅ Include `platform` attribute in mDNS TXT record for cross-platform identification.
- ✅ Create `DiscoveryManager` with unified `onDeviceFound` + `onDeviceLost` streams combining mDNS + BLE.
- ✅ Wire `DiscoveryNotifier` (Riverpod) — deduplicates by deviceId, removes on loss, proper `ref.onDispose` cleanup.
- [ ] Implement `flutter_blue_plus` BLE beacon discovery on Android (duty-cycled scan skeleton exists).
- [ ] Implement BLE advertising via flutter_blue_plus or method channel.
- **Review/Comments:**
  > mDNS is the primary discovery channel and works on all 3 platforms. Bonsoir v6.0.2 handles both advertising and discovery. Each advertised service includes `id` (device UUID) and `platform` (android/linux/windows) in TXT records. BLE is Android-only and supplementary — the `BleService` skeleton has duty-cycled timing logic but the actual `flutter_blue_plus` calls are still TODOs.

## Phase 3: Pairing & QR Handshake

### 3.1 QR Generation & TTL
- ✅ Generate timed QR tokens (5-minute TTL) with Ed25519 detached signature.
- ✅ Expose Ed25519 identity pubkey + ephemeral X25519 pubkey via QR payload.
- ✅ Sign canonical `[tokenId|pk|xk|exp]` bytes with Ed25519 secret key.
- ✅ QR payload serialization: JSON → base64url for QR content.
- **Review/Comments:**
  > Uses Ed25519 detached signatures (not HMAC) — correct for pre-pairing where no shared secret exists. The signature proves the token was generated by the owner of the claimed Ed25519 public key. Ephemeral X25519 keys are generated per-token and stored in `_localEphemeralSecretsByToken` map until consumed.

### 3.2 Key Exchange & Scanner
- ✅ Implement `validateAndConsume()` — verifies Ed25519 signature, checks TTL, enforces single-use.
- ✅ Implement `deriveSessionKey()` — X25519 ECDH using local ephemeral secret + remote's X25519 public key from token.
- ✅ Implement `KeyStoreService` with FlutterSecureStorage persistence (Android Keystore, Linux Secret Service, Windows DPAPI).
- ✅ Add `@visibleForTesting initWithKeyPair()` for test environments.
- [ ] Wire `MobileScanner` UI to `QrHandshakeService` flow (scan → validate → derive → start transfer).
- [ ] Implement custom viewfinder gradient animation.
- **Review/Comments:**
  > The full crypto flow is proven by tests: generate token → encode QR → decode → verify signature → derive shared X25519 key → encrypt/decrypt with that key. The derived 256-bit shared secret is suitable as a session key for XChaCha20-Poly1305. KeyStoreService generates identity keypair on first launch and persists to platform secure storage.

## Phase 4: UI Stitching & Feature Rewrites

### 4.1 Onboarding screen
- [ ] Connect pulsed logo glow and avatar picker UI to `OnboardingNotifier` and SQLite.
- [ ] Navigation transition to Radar discovery.
- **Review/Comments:**
  > 

### 4.2 Discovery / Radar UI
- [ ] Render 4 concentric pulsing rings using custom `RadarPainter`.
- [ ] Bind active connections from Phase 2 into `DeviceBubble` distribution around center.
- **Review/Comments:**
  > 

### 4.3 File Exploration and Selection UI
- [ ] Create file exploration and selection UI via Stitch templates.
- [ ] Integrate UI with state management/providers (bridge with device discovery).
- [ ] Implement backend logic for efficient directory indexing and file handling.
- [ ] Optimize the UX for smooth scrolling, fast visual selection, and thumbnail generation of massive quantities of files.
- **Review/Comments:**
  > 

### 4.4 Transfer UI (Send/Receive)
- [ ] Layout Active, Queued, and Completed file queues.
- [ ] Render `TransferCard` showing granular file progress bar tracking isolate bytes.
- [ ] Implement Accept/Decline request flows for receiver.
- **Review/Comments:**
  > 

### 4.5 In-Transfer Chat Engine
- [ ] Create lightweight TCP/HTTP message pass over active session channel.
- [ ] Hook UI layout for bubble chat overlays.
- **Review/Comments:**
  > 

## Phase 5: Advanced Synchronization Modes

### 5.1 Live Folders Sync
- [ ] Use `watcher` package on directory to map real-time file updates.
- [ ] Auto-queue delta diffs directly into HTTP chunk transfer logic.
- **Review/Comments:**
  > 

### 5.2 Contact Groups & Classroom Mode
- [ ] Allow grouping persistent paired public keys.
- [ ] Classroom 1-to-many broadcast logic (iterate chunk transfers to multi-IP targets).
- **Review/Comments:**
  > 

## Phase 6: Final Polish
- [ ] Audit platform-specific power settings (turn off BLE during Wi-Fi hotspot sync).
- [ ] Lottie/Staggered animations review against design system.
- [ ] Compile BLAKE3 native library for all target platforms.
- [ ] Memory footprint profiling on multi-GB transfers.
- [ ] Cross-compile and test Linux, Windows, Android natively.
- **Review/Comments:**
  > 
