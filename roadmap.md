# Blink — Product Roadmap

> High-level roadmap tracking our journey toward a universal AirDrop alternative.

## Status Legend

- `PENDING`: Not started
- `IN PROGRESS`: Active implementation
- `PARTIAL`: Scaffolded but not yet integrated end-to-end
- `COMPLETE`: End-to-end implemented and validated

## Current Reality Snapshot (April 24, 2026)

- **Phases 1–3 backend: COMPLETE.** Crypto, HTTP transfer, discovery, and QR handshake are fully implemented with 18 passing tests.
- UI across core features is implemented (scaffolded during Phase 0).
- Phase 4 (UI stitching to live backends) is the active frontier.
- Settings remains the most complete end-to-end UI feature.

Detailed audit: [docs/Status_Audit_2026-04-24.md](docs/Status_Audit_2026-04-24.md)

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

### M3: The Latest Stitch UI — IN PROGRESS
**Target:** Visual parity with the "Midnight Obsidian" Figma designs.
* **Goals:** 
  * [ ] Smooth 60fps/120fps radar animations.
  * [ ] Rebuilt Transfer Cards, Settings, and Onboarding flowing cleanly with `go_router`.
  * [ ] Wire all UI screens to live backend services (discovery, transfer, QR).
* **Status:** IN PROGRESS
* **Active work:**
  * Connect Onboarding persistence (name/avatar → SQLite)
  * Wire Radar UI to DiscoveryNotifier (live device bubbles)
  * Wire Transfer UI to TransferNotifier (real progress bars)
  * Wire QR Scanner UI to QrHandshakeService (scan → validate → derive → send)

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
