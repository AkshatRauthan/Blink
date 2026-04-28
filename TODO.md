# Blink — Progress Tracker

> Last updated: 2026-04-28
>
> This file tracks every feature required for the full Blink sharing flow.
> Checkboxes: `[x]` = done, `[/]` = partially done, `[ ]` = not started.

---

## 1. Onboarding & Setup

- [x] **Onboarding screen** — Welcome screen with Blink branding, security badges, permission selection
- [x] **Permission handling** — `PermissionsProvider` + `PermissionsScreen` with per-platform permission items (Android, Linux, Windows)
- [x] **Profile setup screen** — `ProfileSetupScreen` for display name entry
- [x] **Settings persistence** — `SettingsNotifier` stores onboarding state, display name, permissions flag via Isar
- [x] **Identity keypair** — `KeyStoreService` generates and persists Ed25519 keypair in platform secure storage on first launch
- [x] **App routing / guards** — `GoRouter` redirects unonboarded users → onboarding → profile setup → discovery

---

## 2. Discovery — Devices Show on Each Other

### mDNS (All Platforms)
- [x] **mDNS advertising** — `MdnsService.startAdvertising()` registers `_blink._tcp` service with device name, ID, port, platform in TXT records via Bonsoir
- [x] **mDNS discovery** — `MdnsService.startDiscovery()` listens for Bonsoir resolution events, parses TXT attributes, emits `Device` objects
- [x] **mDNS device lost** — Emits `onDeviceLost` when a Bonsoir service disappears from the network

### BLE (Android)
- [x] **BLE scanning** — `BleService` uses `flutter_blue_plus` with duty-cycled scanning (scan window + gap) filtering by Blink service UUID
- [x] **BLE beacon parsing** — Parses manufacturer data (`0xFFFF` → `BLINK:{deviceId}|{name}|{platform}`) and local name fallback
- [x] **BLE stale pruning** — Removes devices not seen for 30 seconds via `_pruneStaleDevices()`
- [/] **BLE advertising** — `BleService.startAdvertising()` is a **stub** — logs a message but doesn't actually advertise. Needs platform channel to `BluetoothLeAdvertiser` on Android

### Unified Discovery
- [x] **DiscoveryManager** — Merges mDNS and BLE streams into unified `onDeviceFound` / `onDeviceLost` broadcast streams
- [x] **DiscoveryNotifier** — Riverpod `Notifier` subscribes to `DiscoveryManager`, deduplicates by `deviceId`, auto-removes lost devices
- [x] **Auto-start on screen entry** — `DiscoveryScreen.initState()` calls `DiscoveryManager.startAll()` with device name and port

### Discovery UI
- [x] **Radar view** — Animated radar rings (`RadarPainter`) with sweep animation and pulse effect
- [x] **Device bubbles** — `DeviceBubble` widgets positioned around radar by angle/ring, with platform icons and names
- [x] **Centre avatar** — Current user's initial with pulsing glow
- [x] **Status pill** — Shows "Searching for nearby devices..." or "N devices nearby"
- [x] **Desktop layout** — Side panel with `_DeviceListPanel` listing all discovered devices for wider screens
- [x] **QR buttons in header** — Frosted glass header with "Show QR" and "Scan QR" icon buttons

---

## 3. Pairing / Connection

### QR Code Flow (Alternative to Discovery Tap)
- [x] **QR token generation** — `QrHandshakeService.generateToken()` creates signed payload with Ed25519 pubkey, ephemeral X25519 pubkey, UUID token ID, 5-min TTL
- [x] **QR Show screen** — `QrShowScreen` displays QR code via `qr_flutter`, shows expiry countdown timer, regenerate button, Show/Scan toggle
- [x] **QR Scan screen** — `QrScanScreen` uses `mobile_scanner` to capture QR, calls `PairingNotifier.handleScannedQr()`, shows success/failure feedback overlay with viewfinder animation
- [x] **Token validation** — `QrHandshakeService.validateAndConsume()` checks expiry, single-use enforcement, verifies Ed25519 detached signature
- [x] **Session key derivation (QR path)** — `QrHandshakeService.deriveSessionKey()` uses local ephemeral X25519 secret + remote X25519 public key → ECDH scalar multiplication → 256-bit shared key
- [x] **PairingNotifier** — `handleScannedQr()` validates token, generates local X25519 keypair, derives session key, returns `PairingResult`

### Discovery-Tap Pairing (Auto-Pair)
- [x] **DevicePairingProvider** — `pairWithDevice(deviceId)` generates a random 256-bit session key and caches it per device ID
- [x] **True ECDH pairing on discovery tap** — Discovery taps now perform a handshake over the discovered IP to derive the shared session key
- [x] **Receiver-side session key registration** — Receiver requires a pre-registered session key from the pairing handshake (no plaintext session key in `/transfer/begin`)

---

## 4. File Selection

- [x] **File picker** — `FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any)` opens native file explorer
- [x] **FileSelectionProvider** — Riverpod `Notifier` with `addFiles()`, `removeFile()`, `clear()` — deduplicates by path, resolves file name/size/mime
- [x] **SelectedFile model** — Contains `path`, `name`, `sizeBytes`, `mimeType`, `isMedia` derived from `FileUtils`
- [x] **File review bottom sheet** — `FileReviewSheet` shows list of selected files with file-type icons (color-coded), individual remove buttons, total size, and "Send" confirm button
- [x] **Add more files** — User can add files to existing selection before confirming (dedup logic in `addFiles()`)
- [x] **File type icons** — Comprehensive icon + color mapping for images, videos, audio, PDF, archives, APK, documents, spreadsheets, presentations

---

## 5. Transfer Engine

### Sender Side
- [x] **TransferManager.sendFiles()** — Creates `TransferSession` + `TransferFile` models, persists to DB, spawns sender isolate
- [x] **Transfer Isolate** — `transferIsolateMain()` runs in a separate Dart isolate with its own `NativeCryptoService` instance
- [x] **Session begin handshake** — Isolate sends `POST /transfer/begin` with file manifest (fileId, fileName, mimeType, sizeBytes, blake3Checksum, sessionKey)
- [x] **Chunked streaming** — Reads files in `chunkSizeBytes` chunks (4 MB), encrypts each with XChaCha20-Poly1305, prepends 24-byte nonce, sends via `PUT /transfer/:sid/:fileIndex`
- [x] **Progress reporting** — Isolate sends `TransferProgress` messages back to main isolate via `SendPort` with per-file bytes transferred, file completion, session completion flags
- [x] **Error handling** — Chunk failures, missing files, and session open failures are reported back and surface as `TransferStatus.failed`

### Receiver Side
- [x] **HTTP server** — `HttpServerService` runs embedded `shelf` + `shelf_router` server on port `AppConstants.transferPort`
- [x] **POST /transfer/begin** — Parses file manifest, creates output directory, opens file sinks for each incoming file
- [x] **PUT /transfer/:sid/:fileIndex** — Receives encrypted chunk, decrypts via `CryptoService.decryptChunk()`, writes plaintext to disk
- [x] **BLAKE3 integrity check** — On file completion, computes BLAKE3 hash of received file and compares with sender's checksum. Returns HTTP 422 on mismatch
- [x] **GET /transfer/:sid/status** — Returns per-file progress JSON
- [x] **DELETE /transfer/:sid** — Cancels session, closes file sinks
- [x] **Session key registration** — `registerSessionKey()` allows pre-registering a key before the sender connects

### Transfer UI
- [x] **TransferNotifier** — Riverpod `Notifier` drives `startSend()` flow — converts file paths to `File` objects, calls `TransferManager.sendFiles()`
- [x] **ActiveTransfersNotifier** — Subscribes to `TransferManager.onProgress`, rebuilds on every update, auto-starts receiver server
- [x] **Send screen** — `SendScreen` shows all outgoing transfers grouped by Active / Queued / Completed with `TransferCard` widgets
- [x] **TransferCard** — Shows session direction icon, device ID, progress bar, percentage, bytes transferred / total, status indicator
- [x] **Receive screen** — `ReceiveScreen` shows incoming transfers with Accept/Decline buttons for pending requests
- [x] **Cancel transfer** — `TransferManager.cancelTransfer()` kills isolate, updates status

### Transfer — Missing / Incomplete
- [ ] **Save to `Download/Blink/{file_type}/`** — Currently files save to `Documents/Blink/Received/{sessionId_prefix}/`. Need to change output path to `Download/Blink/Image/`, `Download/Blink/Video/`, `Download/Blink/Music/`, `Download/Blink/Document/` based on file MIME type
- [x] **Save to `Download/Blink/{file_type}/`** — Received files now route to `Download/Blink/Image|Video|Music|Document` by MIME type
- [x] **Per-file progress on transfer screen** — Transfer cards now show per-file name and progress
- [x] **File name visible on transfer screen** — File list includes name + progress bar per file
- [x] **"Add files" button on bottom sheet while reviewing** — File review sheet has an explicit "Add more" button

---

## 6. Crypto & Security Layer

- [x] **NativeCryptoService** — libsodium via `sodium` package with XChaCha20-Poly1305-IETF AEAD, Ed25519 signing, X25519 ECDH
- [x] **CryptoService** — High-level API: `encryptChunk()` prepends nonce, `decryptChunk()` strips nonce
- [x] **NativeHashService** — BLAKE3 via dart:ffi with Dart SHA-256 fallback (graceful degradation)
- [x] **KeyStoreService** — Ed25519 identity key in FlutterSecureStorage (Keystore/SecretService/DPAPI)
- [x] **QrHandshakeService** — Full token lifecycle: generate → sign → serialize → validate → consume → derive session key

---

## 7. Network & Connectivity

- [x] **NetworkInfoService** — Detects local IPv4 address by scanning network interfaces (prefers wlan/wifi/en/eth)
- [ ] **WebRtcService** — **Stub only**. `init()` and `createPeerConnection()` are empty with TODO comments. Not blocking for LAN transfers but needed for cross-subnet/NAT traversal

---

## 8. Data Layer

- [x] **Device model** — Full JSON serialization, copyWith, equality by deviceId
- [x] **TransferSession model** — Status enum (pending/connecting/transferring/completed/failed/cancelled), direction enum, timestamps
- [x] **TransferFile model** — Per-file tracking with transferredBytes, completed flag
- [x] **ChatMessage model** — JSON serialization for in-session messaging
- [x] **TransferRepository** — SQLite persistence for sessions and files
- [x] **IsarService** — Database initialization

---

## 9. Chat (Bonus Feature)

- [x] **ChatScreen UI** — Full chat interface with message bubbles (gradient for sent, dark surface for received), time labels, input bar
- [x] **ChatNotifier** — Provider with `sendMessage()` that adds to local state
- [x] **POST /transfer/:sid/chat** — HTTP endpoint on receiver server to receive chat messages
- [x] **Actual network chat delivery** — `ChatNotifier.sendMessage()` posts to `remoteIp:port/transfer/{sid}/chat`
- [x] **Incoming chat listener** — `ChatNotifier` subscribes to `HttpServerService.onChatMessage`

---

## 10. Live Folders (Bonus Feature)

- [x] **LiveFolderScreen UI** — Folder list with status (Watching/Paused), pending changes badge, add/remove/pause controls
- [x] **LiveFolderNotifier** — Provider with `addFolder()`, `removeFolder()`, `togglePause()`
- [ ] **File system watcher** — No actual `FileSystemEntity.watch()` implementation to detect changes in watched folders
- [ ] **Auto-sync engine** — No logic to automatically transfer changed files to the paired device when changes are detected
- [ ] **Paired device awareness** — `pairedDeviceId` exists on state but is never set from the pairing flow

---

## 11. End-to-End Integration Gaps

> These are the critical items needed for the full desired flow to work seamlessly.

- [ ] **Discovery → Auto-pair with real key exchange** — Tapping a discovered device bubble should perform an ECDH handshake (or force QR flow) rather than generating a random key the receiver doesn't know about
- [ ] **QR pair → Return to discovery with active session** — After QR pairing succeeds, the user should return to discovery screen with the paired device highlighted and ready for file transfer
- [ ] **Receiver notification / consent** — When a sender initiates a transfer, the receiver should see an accept/decline prompt. The UI exists (`ReceiveScreen._IncomingRequestCard`) but is on a separate screen — it should appear as an overlay or push notification while the receiver is on the discovery screen
- [ ] **Save path: `Download/Blink/{file_type}/`** — Received files need to be routed to categorized folders (`Image/`, `Video/`, `Music/`, `Document/`) based on MIME type instead of a flat session-ID folder
- [ ] **Transfer screen shows file-level detail** — Each file should show its name and individual transfer progress bar, not just session-level aggregate
- [ ] **Both-direction transfers in single session** — Currently only the sender side initiates. Either user should be able to send files to the other within an active connection

---

## 12. Polish & Platform-Specific

- [ ] **BLE peripheral advertising on Android** — Implement native platform channel to `BluetoothLeAdvertiser` so the device is discoverable via BLE (not just mDNS)
- [ ] **Android foreground service** — Transfer should continue in background with a persistent notification showing progress
- [ ] **Linux/Windows tray integration** — Keep discovery alive in system tray when app window is closed
- [ ] **File open after transfer** — Tap a completed file in transfer history to open it with the system default app
- [ ] **Transfer history persistence** — Completed transfers are in-memory only via `TransferManager._sessions`. Load/display history from SQLite on app restart
- [ ] **Connection indicator** — Show a persistent "Connected to {device}" banner/chip on the discovery screen after pairing

---

## Priority Order for Next Development

1. **Fix discovery-tap pairing** — Implement proper key exchange so tapping a device bubble actually works end-to-end
2. **Change save path** to `Download/Blink/{file_type}/`
3. **Show per-file progress** on transfer screen with file names
4. **Add "Add More Files" button** to `FileReviewSheet`
5. **Wire up chat delivery** over the network
6. **BLE advertising** on Android
7. **Background transfer service** (Android foreground service)
8. **Live Folders** file watcher + auto-sync
