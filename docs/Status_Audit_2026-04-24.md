# Blink Status Audit - April 24, 2026

This audit summarizes what is implemented, what is partially implemented, and what still needs work.

## Scope Reviewed

- All files in docs/
- All files in lib/
- All files in test/
- Top-level project files:
  - README.md
  - implementation_plan.md
  - roadmap.md
  - pubspec.yaml
  - analysis_options.yaml

Generated/build directories were intentionally excluded from implementation assessment.

## Executive Snapshot

- **Phases 1–3 backend services are fully implemented and tested (18 tests, 0 failures).**
- Architecture and UI foundation are strong.
- Feature UIs are mostly complete (scaffolded in Phase 0).
- Phase 4 (wiring UI to live backends) is the current frontier.
- Settings is the most complete end-to-end feature.

## Feature Maturity

| Feature | UI | Provider | Backend | Integration | Overall |
|---|---|---|---|---|---|
| Onboarding | High | Low | Low | Low | 35-40% |
| Discovery | High | High | High | Medium | 75-80% |
| Pairing (QR) | High | Medium | High | Medium | 70-75% |
| Transfer | High | High | High | Medium | 75-80% |
| Chat | High | Low | Low | Low | 25-40% |
| Live Folder | High | Low-Med | Low | Low | 30-45% |
| Groups | Medium-High | Low-Med | Low | Low | 30-40% |
| Settings | High | High | High | High | 90-96% |

## What Is Done

### Documentation
- docs/Blink.md, docs/Strategy.md, docs/DesignSystem.md, docs/Screens.md, and docs/Assets.md provide broad and deep planning coverage.

### Foundation and Architecture
- App shell, routing, and adaptive navigation are implemented.
- Core theme, design tokens, and shared widgets are implemented.
- Data models are implemented as plain Dart classes.
- SQLite service and repository scaffolding are implemented.

### UI Delivery
- Core screens for onboarding, discovery, pairing, transfer, chat, live folders, groups, and settings are present with polished visuals.

### Phase 1: Core Transfer Engine (COMPLETE)
- **HttpServerService** — Shelf HTTP server with 4 endpoints (begin, chunk, status, cancel). Decrypts XChaCha20-Poly1305 chunks and writes plaintext to disk via IOSink. Integrity verification on file completion (BLAKE3/SHA-256 hash check, HTTP 422 on mismatch).
- **HttpClientService** — Persistent keep-alive HTTP client. Sends encrypted chunks with session metadata.
- **TransferManager** — Full session orchestrator. Spawns/kills sender isolates, tracks per-file progress, persists to SQLite, exposes `onProgress` stream for UI.
- **transfer_isolate.dart** — Self-contained Dart Isolate for sender side. Initializes own crypto + hash services, pre-computes file checksums, streams 4MB encrypted chunks.
- **TransferNotifier / ActiveTransfersNotifier** — Riverpod providers wired to TransferManager progress stream.
- **NativeHashService** — BLAKE3 FFI bindings with SHA-256 fallback. Integrated into transfer flow (sender computes, receiver verifies).
- **CryptoService** — High-level encrypt/decrypt API wrapping NativeCryptoService (nonce prepended, tag appended).

### Phase 2: Discovery (COMPLETE — except BLE)
- **MdnsService** — Full Bonsoir integration. Advertising with deviceId + platform in TXT records. Discovery with service resolution → Device objects. Lost device stream for cleanup.
- **DiscoveryManager** — Combines mDNS + BLE into unified `onDeviceFound` / `onDeviceLost` streams. Proper subscription lifecycle management.
- **DiscoveryNotifier** — Riverpod provider. Deduplicates devices by ID, updates on re-discovery, removes on loss events, proper `ref.onDispose` cleanup.
- **BleService** — Skeleton with duty-cycled timing logic. Actual flutter_blue_plus calls are TODOs (Android-only feature).

### Phase 3: QR Handshake & Key Exchange (COMPLETE)
- **QrHandshakeService** — Ed25519 detached signatures (correct for pre-pairing asymmetric auth). Generates signed tokens with 5-min TTL, validates with signature verification, single-use enforcement.
- **deriveSessionKey()** — X25519 ECDH from local ephemeral secret + remote public key. Proven end-to-end in tests (both sides derive identical 256-bit session key, usable for XChaCha20 encryption).
- **KeyStoreService** — Ed25519 identity keypair generation on first launch. Persisted in FlutterSecureStorage (Android Keystore, Linux Secret Service, Windows DPAPI). `@visibleForTesting initWithKeyPair()` for test environments.
- **NativeCryptoService.signDetached/verifyDetached** — Ed25519 detached signature APIs added.

### Test Suite (18 tests, all passing)
- `test/transfer_e2e_test.dart` (7 tests): crypto round-trip, nonce uniqueness, HTTP lifecycle, e2e file transfer with disk verification, error handling, integrity rejection.
- `test/security_test.dart` (11 tests): Ed25519 signatures (sign/verify, tamper, wrong key), QR token flow (generate, encode/decode, validate, single-use, tamper rejection), X25519 ECDH (shared secret agreement, uniqueness), full handshake integration.

## What Still Needs To Be Done

### P0 (Immediate — Phase 4 UI Wiring)
- Connect onboarding persistence for name/avatar (→ SQLite via OnboardingNotifier).
- Wire QR Scanner UI to QrHandshakeService (scan → validate → derive key → start transfer).
- Wire Radar/Discovery UI to DiscoveryNotifier (live device bubbles from mDNS).
- Wire Transfer UI to TransferNotifier (real progress bars, accept/decline flow).
- Wire File Explorer/Selection UI to transfer send flow.

### P1 (Core Integration)
- Compile BLAKE3 native .c files (download from upstream BLAKE3 repo, build via CMake).
- Implement BLE discovery on Android (flutter_blue_plus calls in BleService).
- Complete MIME metadata handling for transfer file entries.

### P2 (Advanced Features)
- Complete chat-over-session transport.
- Complete live-folder delta queueing.
- Complete Android platform service channels.
- Implement WebRTC fallback path.
- Contact groups / classroom mode.

## Test Readiness

- **18 tests across 2 files, all passing.**
- Tests run without Flutter engine (no platform channels required) thanks to:
  - `outputBaseDir` injection on HttpServerService
  - `@visibleForTesting initWithKeyPair()` on KeyStoreService
- Recommended next test expansions:
  - Provider state transition tests (discovery/transfer)
  - Repository CRUD tests
  - Multi-file transfer tests
  - Transfer cancellation tests
  - Widget tests for key UI flows

---

Last updated: April 24, 2026
