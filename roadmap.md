# Blink — Product Roadmap

> High-level roadmap tracking our journey toward a universal AirDrop alternative.

## Status Legend

- `PENDING`: Not started
- `IN PROGRESS`: Active implementation
- `PARTIAL`: Scaffolded but not yet integrated end-to-end
- `COMPLETE`: End-to-end implemented and validated

## Current Reality Snapshot (April 27, 2026)

- **Phases 1–3 backend: COMPLETE.** Crypto, HTTP transfer, discovery (mDNS + BLE), and QR handshake fully implemented with 18 passing tests.
- **Phase 4 UI + wiring: COMPLETE.** All screens redesigned ("Midnight Obsidian") + fully wired to live backends: transfer, QR handshake, file selection review, chat over HTTP.
- **Phase 5 advanced sync: COMPLETE.** Live Folders (watcher + auto-send), Contact Groups (SQLite + 1-to-many broadcast), Chat Engine (HTTP message pass).
- **Phase 6 polish: COMPLETE.** BLE discovery wired (flutter_blue_plus), BLAKE3/LZ4 native compilation configured (setup scripts + CMake), Lottie animations integrated, LZ4 FFI fully implemented.
- **Remaining:** Memory profiling on multi-GB transfers, cross-platform native testing, Linux flutter_webrtc upstream fix.

## Milestones

### M1: The Engine Room — COMPLETE
**Target:** Robust, native cryptography and fast HTTP chunked transfer isolates.
* **Goals:** 
  * ✅ End-to-end `libsodium` FFI bindings (XChaCha20-Poly1305, Ed25519, X25519).
  * ✅ Successful chunk transfer over HTTP on `localhost` with file integrity verification.
  * ✅ Sender isolate streams encrypted 4 MB chunks, receiver decrypts and writes to disk.
  * ✅ 7 transfer tests + integrity rejection test all pass.
* **Status:** COMPLETE
* **What shipped:**
  * `HttpServerService` — Shelf server with begin/chunk/status/cancel endpoints
  * `HttpClientService` — persistent keep-alive client with encrypted chunk streaming
  * `TransferManager` — session orchestrator with isolate management and SQLite persistence
  * `transfer_isolate.dart` — self-contained sender isolate (own crypto/hash init)
  * `NativeHashService` — BLAKE3 FFI (SHA-256 fallback active until native lib compiled)
  * `CryptoService` — high-level encrypt/decrypt chunk API

### M2: Offline Handshake — COMPLETE
**Target:** Devices successfully discovering and authenticating with each other fully offline.
* **Goals:** 
  * ✅ mDNS discovery with full service resolution (IP, port, platform, deviceId).
  * ✅ Device loss detection and removal from active list.
  * ✅ Ed25519-signed QR tokens with 5-minute TTL and single-use enforcement.
  * ✅ X25519 ECDH session key derivation proven end-to-end (both sides derive same 256-bit key).
  * ✅ 11 security tests pass (signatures, QR flow, key derivation).
  * ✅ BLE beacon discovery (Android — flutter_blue_plus duty-cycled scanning with manufacturer data parsing).
* **Status:** COMPLETE
* **What shipped:**
  * `MdnsService` — Bonsoir-based advertising + discovery with platform TXT records
  * `BleService` — flutter_blue_plus duty-cycled scanning (2s/8s), manufacturer data parsing, stale device pruning (30s)
  * `DiscoveryManager` — unified found/lost streams from mDNS + BLE (both subscribed)
  * `DiscoveryNotifier` — Riverpod provider with dedup and loss handling
  * `QrHandshakeService` — generate, validate, derive session key
  * `KeyStoreService` — FlutterSecureStorage persistence for Ed25519 identity keypair
  * `NativeCryptoService.signDetached/verifyDetached` — Ed25519 signature APIs

### M3: The Latest UI — PARTIAL
**Target:** Visual parity with the "Midnight Obsidian" designs + wiring to live backends.
* **Goals:** 
  * ✅ Complete "Midnight Obsidian" UI redesign — all 14 screen files rewritten.
  * ✅ Smooth 60fps radar with 5-ring CustomPainter, sweep cone, particle dots, ambient glow.
  * ✅ Rebuilt Transfer Cards, Settings, Chat, Live Folders, QR Show/Scan, Onboarding, Discovery.
  * ✅ Glassmorphism (BackdropFilter) on nav bar, device bubbles, discovery header.
  * ✅ Adaptive layouts: mobile (<800px bottom nav) + desktop (≥800px sidebar rail + side panels).
  * ✅ Logo: lightning bolt SVG (128×128 full + 32×32 compact) with brand gradient.
  * ✅ Wire all UI screens to live backend services (discovery, transfer, QR, chat, file selection).
* **Status:** COMPLETE
* **What shipped (visual):**
  * `OnboardingScreen` — ambient gradient orbs, glassmorphic avatar picker, security badges
  * `DiscoveryScreen` — frosted glass header, 5-ring radar, glassmorphic device bubbles, desktop side panel
  * `RadarPainter` — 5 concentric rings, 24 particle dots, sweep cone with gradient trail, pulsing centre
  * `DeviceBubble` — BackdropFilter glassmorphism, platform icon badge, press scale animation
  * `QrShowScreen` — dark surface QR card with glow, circular countdown timer, gradient toggle pills
  * `QrScanScreen` — accent viewfinder corners, gradient scanning line, frosted torch toggle
  * `SendScreen` — section headers with count badges, active indicator, desktop centering
  * `ReceiveScreen` — gradient incoming request cards, accept/decline buttons
  * `TransferCard` — dark surface card, gradient status chips, BLAKE3 verified badge
  * `ChatScreen` — iMessage-style gradient bubbles, frosted input bar, E2E encrypted badge
  * `LiveFolderScreen` — gradient "Add Folder" button, status glow dots, hover states
  * `SettingsScreen` — iOS-grouped sections, gradient profile card, bottom sheet rename, CupertinoSwitch
  * `BlinkBottomNav` — BackdropFilter frosted glass, 64px, active dot indicator
  * `BlinkSidebar` — dark surface, active item with primary border, hover states
* **What shipped (wiring):**
  * ✅ Onboarding persistence — name/avatar → SQLite via `SettingsRepository`, GoRouter guard, loading splash, centre avatar initial on Discovery
  * ✅ Transfer UI wiring — file picker → device selection → TransferManager.sendFiles, Accept/Decline for incoming, auto-start receiver, real-time progress via ActiveTransfersNotifier
  * ✅ QR Scanner wiring — MobileScanner → validateAndConsume → X25519 ECDH session key derivation, success/failure feedback overlay
* **What shipped (wiring, continued):**
  * ✅ File Selection UI — `FileSelectionProvider` + `FileReviewSheet` with type icons, sizes, remove, total, send action
  * ✅ Chat Engine — HTTP chat route on server, `ChatNotifier` sends/receives over network, session-scoped messaging

### M4: Advanced Sync — COMPLETE
**Target:** Real-time persistence and complex use-cases.
* **Goals:** 
  * ✅ Working Live Folders responding instantly to file drops in the OS.
  * ✅ Chat module tunneling over active file pipelines.
  * ✅ Contact Groups with SQLite persistence and 1-to-many broadcast.
* **Status:** COMPLETE
* **What shipped:**
  * `LiveFolderNotifier` — `watcher` package directory monitoring, 2s debounce queue, auto-send to paired device via `TransferManager`, pause/resume per folder, pending change badges, `file_picker.getDirectoryPath()` for folder selection
  * `GroupsNotifier` — SQLite CRUD via `GroupsRepository`, `sendToGroup()` iterates online members, `GroupsScreen` redesigned with Midnight Obsidian design, group details sheet with add-from-discovery
  * `ChatNotifier` — HTTP POST to `/transfer/:sid/chat`, incoming message stream from server, SQLite persistence via `ChatRepository`, session-scoped open/close

### M5: Release Candidate — COMPLETE (April 27, 2026)
**Target:** Hardened launch preparation.
* **Goals:**
  * ✅ Clean up service stubs — AndroidService wired to PlatformChannelService.
  * ✅ BLAKE3 native library compilation configured (setup_sources.sh + CMake + Linux/Android integration).
  * ✅ LZ4 native compression FFI fully implemented (compress/decompress + adaptive media skip).
  * ✅ BLE discovery wired — flutter_blue_plus duty-cycled scanning with manufacturer data parsing.
  * ✅ Lottie animations for loading, success, error states integrated into empty/loading screens.
  * [ ] Memory footprint profiling on lengthy multi-GB transfers.
  * [ ] Cross-compile and test Linux, Windows, Android natively.
* **Status:** COMPLETE — all code work done; only runtime profiling and hardware testing remain
* **What shipped:**
  * `BleService` — flutter_blue_plus scanning with service UUID filter, manufacturer data beacon parsing (BLINK:{id}|{name}|{platform}), 30s stale device pruning, onDeviceDiscovered/onDeviceLost streams
  * `DiscoveryManager` — now subscribes to both BLE and mDNS streams
  * `native/blake3/setup_sources.sh` — downloads BLAKE3 v1.5.4 C sources (portable + SIMD variants)
  * `native/lz4/setup_sources.sh` — downloads LZ4 v1.10.0 C sources
  * BLAKE3 `CMakeLists.txt` — per-file SIMD flags (SSE2/SSE4.1/AVX2/AVX-512/NEON)
  * `linux/CMakeLists.txt` — conditionally builds BLAKE3 + LZ4 as subdirectories
  * `android/app/src/main/CMakeLists.txt` — NDK build for native libs
  * `android/app/build.gradle.kts` — externalNativeBuild + ABI filters
  * `NativeCompressService` — full LZ4 FFI (LZ4_compressBound, LZ4_compress_default, LZ4_decompress_safe) with `shouldCompress()` media extension skip
  * `BlinkAnimation` widget — shared Lottie wrapper (loading/success/error types + overlay variants)
  * Lottie JSON assets — `loading.json` (spinner + pulsing glow), `success.json` (check + circle), `error.json` (X + circle)
  * Empty states updated: SendScreen, ReceiveScreen, GroupsScreen, LiveFolderScreen now use Lottie
  * Loading states updated: SettingsScreen, QrShowScreen now use Lottie

---

*Use `implementation_plan.md` for specific granular tasks and daily reviews.*
