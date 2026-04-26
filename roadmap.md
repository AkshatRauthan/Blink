# Blink — Product Roadmap

> High-level roadmap tracking our journey toward a universal AirDrop alternative.

## Status Legend

- `PENDING`: Not started
- `IN PROGRESS`: Active implementation
- `PARTIAL`: Scaffolded but not yet integrated end-to-end
- `COMPLETE`: End-to-end implemented and validated

## Current Reality Snapshot (April 25, 2026)

- **Phases 1–3 backend: COMPLETE.** Crypto, HTTP transfer, discovery, and QR handshake are fully implemented with 29 passing tests.
- **Phase 4 visual UI redesign: COMPLETE.** All 9 core screens + 5 sub-widgets fully rewritten with "Midnight Obsidian" premium dark design. Logo created. 0 analyzer errors/warnings.
- Phase 4 wiring (UI → live backend services) is the active frontier.
- Linux build blocked by upstream flutter_webrtc plugin issue (missing libwebrtc headers).

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
  * [ ] BLE beacon discovery (Android only — skeleton exists, flutter_blue_plus calls pending).
* **Status:** COMPLETE (core flow; BLE is P1 enhancement)
* **What shipped:**
  * `MdnsService` — Bonsoir-based advertising + discovery with platform TXT records
  * `DiscoveryManager` — unified found/lost streams from mDNS + BLE
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
  * [ ] Wire all UI screens to live backend services (discovery, transfer, QR).
* **Status:** PARTIAL — visual redesign complete, backend wiring pending
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
* **Active work (wiring):**
  * File Explorer/Selection UI (dedicated browsing experience)
  * In-Transfer Chat Engine

### M4: Advanced Sync — PENDING
**Target:** Real-time persistence and complex use-cases.
* **Goals:** 
  * Working Live Folders responding instantly to file drops in the OS.
  * Chat module tunneling over active file pipelines.
  * Classroom Mode testing.
* **Status:** PENDING

### M5: Release Candidate — PENDING
**Target:** Hardened launch preparation.
* **Goals:**
  * Clean up previous dead code and stubs.
  * Compile BLAKE3 native library for all platforms.
  * Memory footprint profiling on lengthy multi-GB transfers.
  * Cross-compile and test Linux, Windows, Android natively.
* **Status:** PENDING

---

*Use `implementation_plan.md` for specific granular tasks and daily reviews.*
