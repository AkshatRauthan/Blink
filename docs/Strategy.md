# Blink — Complete Implementation Strategy

> **Privacy-first, cross-platform offline file sharing. AirDrop for everyone.**
>
> This document outlines the complete implementation roadmap, technical specifications, and execution plan for building Blink from the current scaffolded state to a production-ready application.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current State Assessment](#2-current-state-assessment)
3. [Technical Architecture](#3-technical-architecture)
4. [Implementation Phases](#4-implementation-phases)
   - [Phase 1: Core Transfer Engine](#phase-1-core-transfer-engine)
   - [Phase 2: Discovery & Pairing](#phase-2-discovery--pairing)
   - [Phase 3: UI/UX Implementation](#phase-3-uiux-implementation)
   - [Phase 4: Advanced Features](#phase-4-advanced-features)
   - [Phase 5: Platform Hardening](#phase-5-platform-hardening)
   - [Phase 6: Polish & Launch](#phase-6-polish--launch)
5. [Feature Specifications](#5-feature-specifications)
6. [Security Implementation](#6-security-implementation)
7. [Performance Guidelines](#7-performance-guidelines)
8. [Testing Strategy](#8-testing-strategy)
9. [Risk Assessment](#9-risk-assessment)
10. [Appendices](#10-appendices)

---

## 1. Executive Summary

### Vision
Blink aims to be the universal AirDrop alternative — enabling seamless, secure, offline file sharing between Android, Linux, and Windows devices without ecosystem lock-in, cloud dependencies, or user accounts.

### Core Differentiators
- **100% Offline** — Zero internet required; everything on local network
- **No Account Required** — Set a name and avatar once, ready to share
- **Cross-Platform** — Android, Linux, Windows with native performance
- **Privacy by Design** — QR-based offline key exchange, end-to-end encryption
- **Hardware-Accelerated** — Native crypto via libsodium FFI (~8-15x faster than pure Dart)

### Timeline Overview

| Phase | Focus Area | Duration | Dependencies |
|-------|------------|----------|--------------|
| **Phase 0** | Planning & Scaffolding | ✅ Complete | None |
| **Phase 1** | Core Transfer Engine | 2-3 weeks | None |
| **Phase 2** | Discovery & Pairing | 2-3 weeks | Phase 1.1 (Crypto) |
| **Phase 3** | UI/UX Implementation | 3-4 weeks | Phases 1 & 2 |
| **Phase 4** | Advanced Features | 2-3 weeks | Phase 3 |
| **Phase 5** | Platform Hardening | 2-3 weeks | Phase 4 |
| **Phase 6** | Polish & Launch | 1-2 weeks | Phase 5 |

**Total Estimated Timeline**: 12-18 weeks

---

## 2. Current State Assessment

### 2.1 Completed Work (Phase 0)

#### Codebase Statistics
| Metric | Value |
|--------|-------|
| Total Dart Files | 60+ |
| Total Lines of Code | ~9,700 |
| Features Scaffolded | 8 |
| Services Scaffolded | 17 |
| Data Models | 5 |
| Shared Widgets | 8 |
| SVG Icons Created | 51+ |

#### Completed Components

| Category | Status | Files/Details |
|----------|--------|---------------|
| **Documentation** | ✅ Complete | `Blink.md`, `DesignSystem.md`, `Screens.md`, `Assets.md` |
| **Project Structure** | ✅ Complete | Feature-first architecture with clean separation |
| **Design System** | ✅ Complete | Colors, Typography, Spacing, Shadows, Animations, Themes |
| **Data Models** | ✅ Complete | Device, TransferSession, TransferFile, ChatMessage, ContactGroup |
| **Riverpod Providers** | ✅ Complete | 8 providers with manual Notifier pattern (no code-gen) |
| **SQLite Repositories** | ✅ Complete | Device, Transfer, Chat repositories with CRUD |
| **Database Schema** | ✅ Complete | 5 tables via IsarService (SQLite) |
| **Service Stubs** | ✅ Complete | All 17 services scaffolded with method signatures |
| **Screen Stubs** | ✅ Complete | 9+ screens with GoRouter routes |
| **Shared Widgets** | ✅ Complete | BlinkButton, BlinkCard, BlinkInput, BlinkDialog, BlinkAvatar, BlinkNavigation |
| **SVG Assets** | ✅ Complete | devices/, nav/, actions/, status/, qr/, ui/, files/ |
| **Native FFI Stubs** | ✅ Complete | BLAKE3 + LZ4 headers + CMakeLists |
| **GoRouter Config** | ✅ Complete | 9 routes with adaptive shell navigation |

### 2.2 Implementation Status by Feature

| Feature | UI | Provider | Backend | Integration | Overall |
|---------|-----|----------|---------|-------------|---------|
| **Discovery** | ✅ | ✅ | ⚠️ Stub | ❌ | 60% |
| **Pairing (QR)** | ✅ | ✅ | ⚠️ Stub | ❌ | 50% |
| **Transfer** | ✅ | ⚠️ | ⚠️ Stub | ❌ | 40% |
| **Chat** | ✅ | ⚠️ Stub | ❌ | ❌ | 25% |
| **Live Folders** | ✅ | ⚠️ Stub | ❌ | ❌ | 25% |
| **Groups** | ✅ | ✅ Demo | ❌ | ❌ | 30% |
| **Settings** | ✅ | ✅ | ✅ | ✅ | 95% |
| **Onboarding** | ✅ | ⚠️ | ❌ | ❌ | 40% |

### 2.3 Outstanding TODOs in Codebase

```
Total TODOs: 36 items across service and feature files

Critical Path TODOs:
├── QrScanScreen: Derive session key from payload
├── QrScanScreen: Open transfer session with paired device  
├── TransferNotifier: Get session key from CryptoService
├── TransferNotifier: Return sessions from TransferManager
├── TransferManager: File MIME type detection
├── TransferManager: Session key derivation integration
├── ChatNotifier: Send message over TCP connection
├── LiveFolderNotifier: Queue changed files for transfer
└── OnboardingNotifier: Persist to SQLite
```

---

## 3. Technical Architecture

### 3.1 System Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│                           UI LAYER                                   │
│                  Flutter Widgets + GoRouter + Animations             │
│         (flutter_animate, lottie, shimmer, staggered_animations)     │
├─────────────────────────────────────────────────────────────────────┤
│                         STATE LAYER                                  │
│              Riverpod 3 — Manual Notifier/NotifierProvider           │
│                   (No code-gen, no build_runner)                     │
├──────────────────────────┬──────────────────────────────────────────┤
│    DISCOVERY SERVICE     │         TRANSFER ENGINE                   │
│   ┌─────────────────┐    │    ┌────────────────────────────────┐    │
│   │ mDNS (Bonsoir)  │    │    │  Shelf HTTP Server (Isolate)   │    │
│   │ BLE (flutter_   │    │    │  HTTP Client (Streaming PUT)   │    │
│   │   blue_plus)    │    │    │  4 MB chunks, parallel streams │    │
│   └─────────────────┘    │    └────────────────────────────────┘    │
├──────────────────────────┴──────────────────────────────────────────┤
│                        SECURITY LAYER                                │
│    Key Store · QR Handshake · XChaCha20-Poly1305 · Ed25519/X25519   │
│              HMAC-signed tokens · SecureKey zeroing                  │
├─────────────────────────────────────────────────────────────────────┤
│                    NATIVE FFI LAYER (dart:ffi)                       │
│         libsodium (crypto) · BLAKE3 (hashing) · LZ4 (compression)   │
│              NEON (ARM) / SIMD (x86) hardware acceleration           │
├─────────────────────────────────────────────────────────────────────┤
│                         DATA LAYER                                   │
│              SQLite via sqflite + sqflite_common_ffi                 │
│           Tables: devices, transfer_sessions, transfer_files,        │
│                   chat_messages, contact_groups                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Connection Flow

```
Step 1: DISCOVERY
   └─→ BLE (Android) + mDNS/Bonjour (all platforms)
   └─→ Unified Device stream via DiscoveryManager

Step 2: HANDSHAKE
   └─→ QR scan exchanges Ed25519 pubkeys + HMAC-signed session token
   └─→ Single-use, 5-minute TTL tokens

Step 3: KEY DERIVATION
   └─→ X25519 ECDH (scalarmult) → 256-bit shared session key
   └─→ Per-session key, never reused

Step 4: TUNNELING (Priority Order)
   └─→ 1. LAN/IP (primary)
   └─→ 2. WebRTC Data Channels (fallback)
   └─→ 3. Wi-Fi Hotspot (Android only, no shared AP)

Step 5: TRANSFER
   └─→ Chunked HTTP streaming (4 MB chunks)
   └─→ XChaCha20-Poly1305-IETF encrypt-as-you-stream
   └─→ Content-Range headers for pause/resume

Step 6: VERIFICATION
   └─→ BLAKE3 checksum per file (streamed during transfer)
   └─→ Verified post-transfer, "BLAKE3 Verified" badge
```

### 3.3 File Structure

```
lib/
├── main.dart                          # Bootstrap: ProviderScope + runApp
├── app.dart                           # BlinkApp widget, GoRouter, routes
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # Ports, chunk sizes, timeouts
│   │   └── app_strings.dart           # User-facing strings
│   ├── theme/
│   │   ├── app_colors.dart            # BlinkColors + BlinkGradients
│   │   ├── app_typography.dart        # Text styles (Inter font)
│   │   ├── app_spacing.dart           # 4px grid system
│   │   ├── app_shadows.dart           # Elevation shadows
│   │   ├── app_animations.dart        # Durations + Curves
│   │   └── app_theme.dart             # ThemeData builder
│   ├── utils/
│   │   ├── logger.dart                # Debug/info/error logging
│   │   ├── file_utils.dart            # MIME detection, extensions
│   │   └── platform_utils.dart        # Platform detection
│   └── errors/
│       └── blink_exception.dart       # Typed exception hierarchy
│
├── data/
│   ├── models/
│   │   ├── device.dart                # DevicePlatform enum + Device
│   │   ├── transfer_session.dart      # TransferStatus, TransferDirection
│   │   ├── transfer_file.dart         # Per-file state
│   │   ├── chat_message.dart          # ChatMessage
│   │   └── contact_group.dart         # ContactGroup
│   ├── repositories/
│   │   ├── device_repository.dart     # Device CRUD
│   │   ├── transfer_repository.dart   # Transfer session CRUD
│   │   └── chat_repository.dart       # Chat message CRUD
│   └── local/
│       └── isar_service.dart          # SQLite singleton
│
├── features/
│   ├── onboarding/                    # First-launch setup
│   ├── discovery/                     # Radar screen + device bubbles
│   ├── pairing/                       # QR show/scan screens
│   ├── transfer/                      # Send/receive screens
│   ├── chat/                          # Messaging screen
│   ├── live_folder/                   # Auto-sync folders
│   ├── groups/                        # Contact groups
│   └── settings/                      # App preferences
│
├── services/
│   ├── discovery/
│   │   ├── mdns_service.dart          # Bonsoir mDNS
│   │   ├── ble_service.dart           # flutter_blue_plus BLE
│   │   └── discovery_manager.dart     # Unified stream
│   ├── transfer/
│   │   ├── http_server_service.dart   # Shelf server (receiver)
│   │   ├── http_client_service.dart   # HTTP client (sender)
│   │   ├── transfer_isolate.dart      # Per-file isolate
│   │   └── transfer_manager.dart      # Session orchestration
│   ├── security/
│   │   ├── crypto_service.dart        # High-level crypto API
│   │   ├── key_store_service.dart     # Ed25519 keypair storage
│   │   └── qr_handshake_service.dart  # QR token generation
│   ├── connectivity/
│   │   ├── network_info_service.dart  # Local IP, connectivity
│   │   └── webrtc_service.dart        # WebRTC fallback
│   ├── platform/
│   │   ├── android_service.dart       # Android-specific APIs
│   │   └── platform_channel_service.dart
│   └── native/
│       ├── native_crypto_service.dart # SodiumSumo FFI
│       ├── native_hash_service.dart   # BLAKE3 FFI
│       └── native_compress_service.dart # LZ4 FFI
│
└── shared/
    └── widgets/
        ├── blink_button.dart          # Primary/secondary/text buttons
        ├── blink_card.dart            # Elevated surfaces
        ├── blink_input.dart           # Text fields
        ├── blink_dialog.dart          # Alert/action dialogs
        ├── blink_avatar.dart          # User/device avatars
        ├── blink_navigation.dart      # Adaptive shell
        └── widgets.dart               # Barrel export
```

---

## 4. Implementation Phases

### Phase 1: Core Transfer Engine

**Duration**: 2-3 weeks  
**Goal**: End-to-end file transfer working on Linux desktop  
**Priority**: CRITICAL — Foundation for everything else

#### 1.1 Native Crypto Integration

**File**: `lib/services/native/native_crypto_service.dart`  
**Dependencies**: `sodium` package (SodiumSumo)  
**Priority**: P0 — Must be first

##### Tasks

- [ ] Initialize SodiumSumo via `SodiumSumoInit.init()`
- [ ] Implement `generateNonce()` — 24-byte random nonces
- [ ] Implement `encryptChunk(plaintext, key)`:
  ```dart
  // Returns: [24B nonce || ciphertext || 16B Poly1305 tag]
  Uint8List encryptChunk(Uint8List plaintext, SecureKey sessionKey) {
    final nonce = sodium.randombytes.buf(24);
    final ciphertext = sodium.crypto.aeadXChaCha20Poly1305Ietf.encrypt(
      message: plaintext,
      nonce: nonce,
      key: sessionKey,
    );
    return Uint8List.fromList([...nonce, ...ciphertext]);
  }
  ```
- [ ] Implement `decryptChunk(wire, key)`:
  ```dart
  Uint8List decryptChunk(Uint8List wire, SecureKey sessionKey) {
    final nonce = wire.sublist(0, 24);
    final ciphertext = wire.sublist(24);
    return sodium.crypto.aeadXChaCha20Poly1305Ietf.decrypt(
      ciphertext: ciphertext,
      nonce: nonce,
      key: sessionKey,
    );
  }
  ```
- [ ] Implement Ed25519 keypair generation:
  ```dart
  KeyPair generateIdentityKeyPair() {
    return sodium.crypto.sign.keyPair();
  }
  ```
- [ ] Implement X25519 ECDH key derivation:
  ```dart
  SecureKey deriveSessionKey(Uint8List remotePublicKey, SecureKey localPrivateKey) {
    // Convert Ed25519 keys to X25519
    final x25519Pub = sodium.crypto.sign.pkToCurve25519(remotePublicKey);
    final x25519Priv = sodium.crypto.sign.skToCurve25519(localPrivateKey);
    // Perform ECDH
    return sodium.crypto.scalarmult(x25519Priv, x25519Pub);
  }
  ```
- [ ] Implement `SecureKey` disposal with memory zeroing
- [ ] Write unit tests for encrypt/decrypt round-trip

##### Wire Format Specification

```
┌──────────────────┬────────────────────────────────────────────┐
│     NONCE        │       CIPHERTEXT + AUTH TAG                │
│    24 bytes      │         N + 16 bytes                       │
│   (random)       │   (XChaCha20-Poly1305-IETF)               │
└──────────────────┴────────────────────────────────────────────┘

Total overhead per chunk: 40 bytes (24 nonce + 16 auth tag)
Chunk size: 4 MB plaintext → ~4 MB + 40 bytes wire
```

##### Acceptance Criteria
- [x] `flutter analyze` passes with no errors
- [ ] Encrypt → Decrypt produces identical plaintext
- [ ] Different nonces for each encryption
- [ ] SecureKey zeroed after disposal (verify via debugger)

---

#### 1.2 HTTP Transfer Server (Receiver Side)

**File**: `lib/services/transfer/http_server_service.dart`  
**Dependencies**: `shelf`, `shelf_router`  
**Depends On**: 1.1 Native Crypto

##### Tasks

- [ ] Create Shelf HTTP server with router
- [ ] Run server in Dart Isolate to avoid blocking main thread
- [ ] Implement route: `PUT /transfer/:sessionId/:fileIndex`
- [ ] Handle `Content-Range` header for resume support:
  ```dart
  // Content-Range: bytes 4194304-8388607/104857600
  final range = request.headers['content-range'];
  final (start, end, total) = parseContentRange(range);
  ```
- [ ] Stream decrypted chunks directly to disk:
  ```dart
  await for (final chunk in request.read()) {
    final decrypted = cryptoService.decryptChunk(chunk, sessionKey);
    await file.writeAsBytes(decrypted, mode: FileMode.append);
    yield ChunkEvent(bytesReceived: decrypted.length);
  }
  ```
- [ ] Expose `Stream<ChunkEvent>` for progress updates
- [ ] Implement server lifecycle: `start()`, `stop()`
- [ ] Handle connection keep-alive for multiple files

##### API Specification

```
PUT /transfer/:sessionId/:fileIndex
Headers:
  Content-Type: application/octet-stream
  Content-Range: bytes {start}-{end}/{total}
  X-Blink-Chunk-Index: {chunkNumber}
Body: Encrypted chunk bytes

Response:
  200 OK — Chunk received successfully
  206 Partial Content — Resume position acknowledged
  409 Conflict — Session key mismatch
  500 Internal Server Error — Write failure
```

##### Acceptance Criteria
- [ ] Server starts on configured port (49876)
- [ ] Handles concurrent file uploads
- [ ] Correctly parses Content-Range headers
- [ ] Progress events emitted accurately
- [ ] Graceful shutdown with connection draining

---

#### 1.3 HTTP Transfer Client (Sender Side)

**File**: `lib/services/transfer/http_client_service.dart`  
**Dependencies**: `http` package  
**Depends On**: 1.1 Native Crypto

##### Tasks

- [ ] Implement streaming file reader with 4 MB chunks
- [ ] Encrypt each chunk before sending:
  ```dart
  Stream<Uint8List> encryptedChunkStream(File file, SecureKey key) async* {
    final stream = file.openRead();
    await for (final chunk in stream.transform(ChunkedTransformer(4 * 1024 * 1024))) {
      yield cryptoService.encryptChunk(chunk, key);
    }
  }
  ```
- [ ] Send via HTTP PUT with `Content-Range`:
  ```dart
  final request = http.StreamedRequest('PUT', uri);
  request.headers['Content-Range'] = 'bytes $start-$end/$total';
  request.sink.addStream(encryptedChunkStream);
  ```
- [ ] Implement pause/resume by tracking `lastCompletedChunkIndex`
- [ ] Progress callback stream (throttled to 60 fps):
  ```dart
  progressStream
    .throttleTime(Duration(milliseconds: 16)) // ~60fps
    .listen((progress) => notifyListeners());
  ```
- [ ] Connection keep-alive and pooling for efficiency

##### Acceptance Criteria
- [ ] Files stream without loading entirely into memory
- [ ] Progress updates at ~60fps max
- [ ] Pause/resume works via HTTP Range
- [ ] Handles network interruptions gracefully

---

#### 1.4 Transfer Manager Orchestration

**File**: `lib/services/transfer/transfer_manager.dart`  
**Depends On**: 1.2, 1.3

##### Tasks

- [ ] Session state machine:
  ```
  pending → connecting → transferring → completed
                ↓              ↓
              failed        paused → transferring
  ```
- [ ] Isolate pool management:
  ```dart
  static const maxConcurrentTransfers = 4;
  final _isolatePool = <String, Isolate>{};
  ```
- [ ] Progress aggregation per session:
  ```dart
  double get sessionProgress {
    final totalBytes = files.fold(0, (sum, f) => sum + f.sizeBytes);
    final transferred = files.fold(0, (sum, f) => sum + f.transferredBytes);
    return transferred / totalBytes;
  }
  ```
- [ ] Implement `sendFiles(deviceId, List<File> files)`
- [ ] Implement `pauseTransfer(sessionId)`
- [ ] Implement `resumeTransfer(sessionId)`
- [ ] Implement `cancelTransfer(sessionId)`
- [ ] Persist session state to SQLite for crash recovery

##### Session Lifecycle

```dart
class TransferSession {
  final String sessionId;
  final String remoteDeviceId;
  final TransferDirection direction;
  TransferStatus status;
  final List<TransferFile> files;
  int totalBytes;
  int transferredBytes;
  DateTime? startedAt;
  DateTime? completedAt;
  String? failureReason;
  
  // Computed
  double get progress => transferredBytes / totalBytes;
  Duration get elapsed => DateTime.now().difference(startedAt!);
  double get speedBytesPerSec => transferredBytes / elapsed.inSeconds;
}
```

##### Acceptance Criteria
- [ ] Multiple files transfer in parallel (up to 4)
- [ ] Session survives app restart (SQLite persistence)
- [ ] Pause/resume works correctly
- [ ] Progress accurately reflects all files
- [ ] Proper cleanup on cancel

---

#### 1.5 BLAKE3 Integration

**File**: `lib/services/native/native_hash_service.dart`  
**Dependencies**: Custom FFI plugin (`native/blake3/`)

##### Tasks

- [ ] Generate FFI bindings from `blake3.h`:
  ```yaml
  # ffigen_blake3.yaml
  output: 'lib/services/native/blake3_bindings.dart'
  headers:
    entry-points:
      - 'native/blake3/blake3.h'
  ```
- [ ] Implement streaming hash computation:
  ```dart
  Future<String> hashFile(File file) async {
    final hasher = blake3.createHasher();
    await for (final chunk in file.openRead()) {
      blake3.update(hasher, chunk);
    }
    final hash = blake3.finalize(hasher);
    return base64Encode(hash);
  }
  ```
- [ ] Compute hash during transfer (single pass):
  ```dart
  // Inside transfer loop
  blake3.update(hasher, decryptedChunk);
  await file.write(decryptedChunk);
  // After all chunks
  final computedHash = blake3.finalize(hasher);
  if (computedHash != expectedHash) throw ChecksumMismatchException();
  ```
- [ ] Add "BLAKE3 Verified" badge to completed transfers

##### Performance Target
- BLAKE3: ~8-12 GB/s (multi-core native)
- Pure Dart SHA-256: ~0.3 GB/s
- **Target speedup: 25-40x**

##### Acceptance Criteria
- [ ] Hash matches between sender and receiver
- [ ] Single-pass computation (no re-read)
- [ ] Performance: >1 GB/s on desktop

---

### Phase 2: Discovery & Pairing

**Duration**: 2-3 weeks  
**Goal**: Devices discover each other and establish secure sessions  
**Depends On**: Phase 1.1 (Crypto)

#### 2.1 mDNS Discovery

**File**: `lib/services/discovery/mdns_service.dart`  
**Dependencies**: `bonsoir ^6.0.1`

##### Tasks

- [ ] Define service type and TXT records:
  ```dart
  static const serviceType = '_blink._tcp';
  static const port = 49876;
  
  Map<String, String> get txtRecords => {
    'name': displayName,
    'platform': platform.name, // android, linux, windows
    'version': '1',
    'fingerprint': publicKeyFingerprint.substring(0, 8),
  };
  ```
- [ ] Implement advertising with Bonsoir 6.x:
  ```dart
  final broadcast = BonsoirBroadcast(service: BonsoirService(
    name: deviceName,
    type: serviceType,
    port: port,
    attributes: txtRecords,
  ));
  await broadcast.ready;
  await broadcast.start();
  ```
- [ ] Implement discovery with sealed event handling:
  ```dart
  final discovery = BonsoirDiscovery(type: serviceType);
  await discovery.ready;
  await discovery.start();
  
  discovery.eventStream?.listen((event) {
    switch (event) {
      case BonsoirDiscoveryServiceFound(:final service):
        service.resolve(discovery.serviceResolver);
      case BonsoirDiscoveryServiceResolved(:final service):
        final device = Device.fromBonsoirService(service);
        _deviceController.add(device);
      case BonsoirDiscoveryServiceLost(:final service):
        _deviceController.add(DeviceLost(service.name));
    }
  });
  ```
- [ ] Parse resolved service into `Device` model
- [ ] Implement `startAdvertising()`, `stopAdvertising()`
- [ ] Implement `startDiscovery()`, `stopDiscovery()`

##### Service Advertisement

```
Service Type: _blink._tcp
Port: 49876
TXT Records:
  name=Akshat's Laptop
  platform=linux
  version=1
  fingerprint=a1b2c3d4
```

##### Acceptance Criteria
- [ ] Device appears on other devices within 5 seconds
- [ ] TXT records parsed correctly
- [ ] Lost devices removed from list
- [ ] Works on Android, Linux, Windows

---

#### 2.2 BLE Discovery (Android)

**File**: `lib/services/discovery/ble_service.dart`  
**Dependencies**: `flutter_blue_plus ^2.1.1`

##### Tasks

- [ ] Define BLE advertisement data:
  ```dart
  static const blinkServiceUuid = '0000blink-0000-1000-8000-00805f9b34fb';
  
  List<int> get manufacturerData => [
    ...utf8.encode(deviceName.substring(0, min(8, deviceName.length))),
    platform.index,
    ...publicKeyFingerprint.substring(0, 4).codeUnits,
  ];
  ```
- [ ] Implement BLE advertising (Android):
  ```dart
  await FlutterBluePlus.startAdvertising(
    AdvertisementData(
      serviceUuids: [blinkServiceUuid],
      manufacturerData: {0xBLNK: manufacturerData},
    ),
  );
  ```
- [ ] Implement BLE scanning with duty cycle:
  ```dart
  // Scan 2s, sleep 8s — preserves battery
  while (_isScanning) {
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 2));
    await Future.delayed(Duration(seconds: 8));
  }
  ```
- [ ] Parse advertisement into `Device` model
- [ ] Handle platform limitations (desktop BLE is limited)

##### Battery Optimization
- Scan duration: 2 seconds
- Sleep duration: 8 seconds
- Duty cycle: 20%
- Estimated battery impact: <1% per hour

##### Acceptance Criteria
- [ ] BLE discovery works on Android
- [ ] Battery impact within acceptable range
- [ ] Graceful degradation on desktop (uses mDNS only)

---

#### 2.3 Discovery Manager

**File**: `lib/services/discovery/discovery_manager.dart`  
**Depends On**: 2.1, 2.2

##### Tasks

- [ ] Combine mDNS and BLE streams:
  ```dart
  Stream<Device> get onDeviceFound => StreamGroup.merge([
    _mdnsService.onDeviceDiscovered,
    _bleService.onDeviceDiscovered,
  ]).distinct((a, b) => a.deviceId == b.deviceId);
  ```
- [ ] Implement device deduplication by `deviceId`
- [ ] Implement `startAll()`, `stopAll()`, `dispose()`
- [ ] Expose unified `Stream<List<Device>>` for UI
- [ ] Handle device timeout (remove after 30s of no advertisements)

##### Acceptance Criteria
- [ ] Single stream of unique devices
- [ ] mDNS + BLE devices merged correctly
- [ ] Stale devices removed after timeout
- [ ] Clean resource disposal

---

#### 2.4 QR Handshake (Offline Key Exchange)

**File**: `lib/services/security/qr_handshake_service.dart`  
**Depends On**: 1.1 (Crypto)

##### Tasks

- [ ] Define QR payload structure:
  ```dart
  class QrPayload {
    final String publicKey;      // Ed25519 public key, base64
    final String token;          // Random session token
    final int timestamp;         // Unix timestamp
    final String signature;      // HMAC-SHA256 of above
    final String ip;             // Local IP address
    final int port;              // Transfer port
    
    String toJson() => jsonEncode({
      'pk': publicKey,
      'tk': token,
      'ts': timestamp,
      'sg': signature,
      'ip': ip,
      'pt': port,
    });
  }
  ```
- [ ] Implement token generation with HMAC signature:
  ```dart
  QrPayload generateQrToken() {
    final token = base64Encode(sodium.randombytes.buf(32));
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final dataToSign = '$publicKey:$token:$timestamp';
    final signature = hmacSha256(dataToSign, privateKey);
    
    return QrPayload(
      publicKey: base64Encode(identityPublicKey),
      token: token,
      timestamp: timestamp,
      signature: signature,
      ip: localIp,
      port: transferPort,
    );
  }
  ```
- [ ] Implement token validation:
  ```dart
  ValidationResult validateQrToken(String qrData) {
    final payload = QrPayload.fromJson(qrData);
    
    // Check TTL (5 minutes)
    final age = DateTime.now().millisecondsSinceEpoch ~/ 1000 - payload.timestamp;
    if (age > 300) return ValidationResult.expired;
    
    // Verify signature
    final dataToVerify = '${payload.publicKey}:${payload.token}:${payload.timestamp}';
    if (!verifyHmac(dataToVerify, payload.signature, payload.publicKey)) {
      return ValidationResult.invalidSignature;
    }
    
    return ValidationResult.valid(payload);
  }
  ```
- [ ] Derive session key from validated payload:
  ```dart
  SecureKey deriveSessionKey(QrPayload payload) {
    final remotePublicKey = base64Decode(payload.publicKey);
    return cryptoService.deriveSessionKey(remotePublicKey, identityPrivateKey);
  }
  ```
- [ ] Implement auto-regeneration on TTL expiry

##### QR Code Visual Spec
- Size: 240×240 pixels
- Error correction: Level M (15%)
- Module style: Circular dots
- Finder patterns: Circular
- Color: Primary purple (#6C63FF) on white

##### Acceptance Criteria
- [ ] QR code encodes all required data
- [ ] Expired tokens rejected (>5 min)
- [ ] Invalid signatures rejected
- [ ] Session key derived correctly
- [ ] Auto-regeneration works

---

#### 2.5 Key Store

**File**: `lib/services/security/key_store_service.dart`  
**Dependencies**: `flutter_secure_storage`

##### Tasks

- [ ] Generate Ed25519 identity keypair on first launch:
  ```dart
  Future<void> ensureIdentityKey() async {
    final existing = await _storage.read(key: 'identity_private_key');
    if (existing != null) return;
    
    final keyPair = sodium.crypto.sign.keyPair();
    await _storage.write(
      key: 'identity_private_key',
      value: base64Encode(keyPair.secretKey),
    );
    await _storage.write(
      key: 'identity_public_key',
      value: base64Encode(keyPair.publicKey),
    );
  }
  ```
- [ ] Implement secure storage per platform:
  - Android: EncryptedSharedPreferences (Keystore)
  - Linux: libsecret
  - Windows: Windows Credential Manager
- [ ] Implement `getIdentityPublicKey()`, `signData()`, `verifySignature()`
- [ ] Never expose private key outside service

##### Acceptance Criteria
- [ ] Keypair persists across app restarts
- [ ] Private key stored in platform secure storage
- [ ] Sign/verify round-trip works
- [ ] Different keypairs on different devices

---

### Phase 3: UI/UX Implementation

**Duration**: 3-4 weeks  
**Goal**: Beautiful, polished screens with fluid animations  
**Depends On**: Phases 1 & 2

#### 3.1 Onboarding Screen

**File**: `lib/features/onboarding/screens/onboarding_screen.dart`  
**Route**: `/onboarding`

##### Tasks

- [ ] Pulsing logo glow animation:
  ```dart
  AnimatedBuilder(
    animation: _pulseController,
    builder: (context, child) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: BlinkColors.primary.withOpacity(0.5 * _pulseController.value),
            blurRadius: 40 * _pulseController.value,
            spreadRadius: 20 * _pulseController.value,
          ),
        ],
      ),
      child: child,
    ),
    child: BlinkLogo(size: 120),
  )
  ```
- [ ] Avatar picker integration:
  ```dart
  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      ref.read(onboardingProvider.notifier).setAvatarPath(result.files.first.path!);
    }
  }
  ```
- [ ] Name input with validation
- [ ] Gradient CTA button ("Get Started")
- [ ] Staggered entrance animations:
  ```dart
  Column(
    children: [
      _Logo().animate().fadeIn(delay: 0.ms).slideY(begin: -0.3),
      _AvatarPicker().animate().fadeIn(delay: 200.ms).scale(),
      _NameInput().animate().fadeIn(delay: 400.ms).slideX(),
      _GetStartedButton().animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
    ],
  )
  ```
- [ ] Persist settings to SQLite on complete
- [ ] Navigate to discovery: `context.go(AppRoutes.discovery)`

##### Acceptance Criteria
- [ ] Animations feel fluid and polished
- [ ] Avatar picker works with camera/gallery
- [ ] Settings persisted correctly
- [ ] Smooth navigation transition

---

#### 3.2 Discovery/Radar Screen

**File**: `lib/features/discovery/screens/discovery_screen.dart`  
**Route**: `/discovery` (home)

##### Tasks

- [ ] Implement `RadarPainter` CustomPainter:
  ```dart
  class RadarPainter extends CustomPainter {
    final double angle; // 0 to 2π, driven by AnimationController
    
    @override
    void paint(Canvas canvas, Size size) {
      final center = size.center(Offset.zero);
      final maxRadius = size.shortestSide / 2;
      
      // Draw 4 concentric rings
      for (var i = 1; i <= 4; i++) {
        final radius = maxRadius * (i / 4);
        final opacity = 0.3 - (i * 0.05);
        canvas.drawCircle(
          center, radius,
          Paint()..color = BlinkColors.accent.withOpacity(opacity)..style = PaintingStyle.stroke,
        );
      }
      
      // Draw sweep cone
      final sweepGradient = SweepGradient(
        startAngle: angle - 0.5,
        endAngle: angle,
        colors: [Colors.transparent, BlinkColors.accent.withOpacity(0.3)],
      );
      canvas.drawArc(...);
      
      // Draw center glow
      canvas.drawCircle(center, 8, Paint()..color = BlinkColors.primary);
    }
  }
  ```
- [ ] Continuous rotation via AnimationController:
  ```dart
  _radarController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 3),
  )..repeat();
  ```
- [ ] Position device bubbles in circle:
  ```dart
  Positioned(
    left: center.dx + radius * cos(angle) - bubbleSize / 2,
    top: center.dy + radius * sin(angle) - bubbleSize / 2,
    child: DeviceBubble(device: device),
  )
  ```
- [ ] User avatar in center with pulsing glow
- [ ] "Select Files" gradient FAB
- [ ] AppBar with QR scan and Settings icons
- [ ] Empty state with `empty_radar.json` Lottie

##### Visual Spec
- Radar rings: 4 concentric, cyan (#00D9FF), decreasing opacity
- Sweep: 60° cone, gradient fade
- Rotation: 3 seconds per revolution
- Device bubbles: 56px diameter, platform icon, cyan glow on selection

##### Acceptance Criteria
- [ ] Smooth 60fps radar animation
- [ ] Devices appear with pop animation
- [ ] Tap device → select for transfer
- [ ] FAB opens file picker

---

#### 3.3 QR Show Screen

**File**: `lib/features/pairing/screens/qr_show_screen.dart`  
**Route**: `/qr-show`

##### Tasks

- [ ] QR code display with `qr_flutter`:
  ```dart
  QrImageView(
    data: qrPayload.toJson(),
    size: 240,
    backgroundColor: Colors.white,
    eyeStyle: QrEyeStyle(
      eyeShape: QrEyeShape.circle,
      color: BlinkColors.primary,
    ),
    dataModuleStyle: QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.circle,
      color: BlinkColors.primary,
    ),
  )
  ```
- [ ] Countdown timer with circular progress:
  ```dart
  Stack(
    alignment: Alignment.center,
    children: [
      CircularProgressIndicator(
        value: remainingSeconds / 300, // 5 min TTL
        backgroundColor: BlinkColors.surface,
        valueColor: AlwaysStoppedAnimation(BlinkColors.primary),
      ),
      Text('${minutes}:${seconds.toString().padLeft(2, '0')}'),
    ],
  )
  ```
- [ ] Auto-regenerate on expiry via `regenerate()`
- [ ] "Show QR / Scan QR" segmented toggle
- [ ] Encryption badge: lock icon + "End-to-end encrypted"

##### Acceptance Criteria
- [ ] QR code scannable by other device
- [ ] Timer counts down accurately
- [ ] Auto-regenerates at 0
- [ ] Smooth transition to scan screen

---

#### 3.4 QR Scan Screen

**File**: `lib/features/pairing/screens/qr_scan_screen.dart`  
**Route**: `/qr-scan`

##### Tasks

- [ ] Camera feed with `mobile_scanner`:
  ```dart
  MobileScanner(
    onDetect: (capture) {
      if (_scanned) return;
      _scanned = true;
      final code = capture.barcodes.first.rawValue;
      _handleScannedQr(code);
    },
  )
  ```
- [ ] Custom viewfinder overlay:
  ```dart
  CustomPaint(
    painter: ViewfinderPainter(
      size: 260,
      cornerLength: 30,
      cornerWidth: 4,
      color: BlinkColors.accent,
    ),
  )
  ```
- [ ] Animated scanning line:
  ```dart
  AnimatedBuilder(
    animation: _scanLineController,
    builder: (context, child) => Positioned(
      top: _scanLineController.value * viewfinderHeight,
      child: Container(
        width: viewfinderWidth,
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, BlinkColors.accent, Colors.transparent],
          ),
        ),
      ),
    ),
  )
  ```
- [ ] Flash toggle button
- [ ] One-shot scan prevention
- [ ] On valid scan → derive key → navigate to transfer

##### Acceptance Criteria
- [ ] Camera initializes quickly
- [ ] Scans QR codes reliably
- [ ] Validates token correctly
- [ ] Handles invalid/expired codes gracefully

---

#### 3.5 Send Screen

**File**: `lib/features/transfer/screens/send_screen.dart`  
**Route**: `/send`

##### Tasks

- [ ] Section headers: "IN PROGRESS", "QUEUED", "COMPLETED"
- [ ] `TransferCard` implementation:
  ```dart
  class TransferCard extends StatelessWidget {
    final TransferSession session;
    
    @override
    Widget build(BuildContext context) {
      return BlinkCard(
        child: Column(
          children: [
            Row(
              children: [
                _DirectionIcon(direction: session.direction),
                Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${session.files.length} files'),
                      Text(_formatBytes(session.totalBytes)),
                    ],
                  ),
                ),
                _StatusChip(status: session.status),
              ],
            ),
            Gap(12),
            TransferProgressBar(
              progress: session.progress,
              gradient: BlinkGradients.primaryToAccent,
            ),
            Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(session.progress * 100).toInt()}%'),
                if (session.status == TransferStatus.completed)
                  _Blake3VerifiedBadge(),
              ],
            ),
          ],
        ),
      );
    }
  }
  ```
- [ ] Progress bar with gradient and glow:
  ```dart
  class TransferProgressBar extends StatelessWidget {
    final double progress;
    final Gradient gradient;
    
    @override
    Widget build(BuildContext context) {
      return Container(
        height: 6,
        decoration: BoxDecoration(
          color: BlinkColors.surfaceContainer,
          borderRadius: BorderRadius.circular(3),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: BlinkColors.primary.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  ```
- [ ] Empty state with cloud upload icon
- [ ] Encryption footer: "Encrypted with XChaCha20-Poly1305"

##### Acceptance Criteria
- [ ] Transfers grouped by status
- [ ] Progress updates smoothly
- [ ] Pause/resume buttons work
- [ ] BLAKE3 badge shows on complete

---

#### 3.6 Receive Screen

**File**: `lib/features/transfer/screens/receive_screen.dart`  
**Route**: `/receive`

##### Tasks

- [ ] Incoming request cards:
  ```dart
  class IncomingRequestCard extends StatelessWidget {
    final TransferSession session;
    
    @override
    Widget build(BuildContext context) {
      return BlinkCard(
        border: Border.all(color: BlinkColors.accent.withOpacity(0.5)),
        child: Column(
          children: [
            Row(
              children: [
                BlinkAvatar(device: session.remoteDevice),
                Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.remoteDevice.name),
                      Text('${session.files.length} files • ${_formatBytes(session.totalBytes)}'),
                    ],
                  ),
                ),
              ],
            ),
            Gap(16),
            Row(
              children: [
                Expanded(
                  child: BlinkButton.secondary(
                    onPressed: () => ref.read(transferProvider.notifier).decline(session.sessionId),
                    child: Text('Decline'),
                  ),
                ),
                Gap(12),
                Expanded(
                  child: BlinkButton.primary(
                    onPressed: () => ref.read(transferProvider.notifier).accept(session.sessionId),
                    child: Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
  ```
- [ ] Active receiving transfers
- [ ] Completed section with verified badges
- [ ] Empty state with cloud download icon

##### Acceptance Criteria
- [ ] Incoming requests prominent
- [ ] Accept/decline functional
- [ ] Progress accurate
- [ ] Verified badge on complete

---

#### 3.7 Chat Screen

**File**: `lib/features/chat/screens/chat_screen.dart`  
**Route**: `/chat`

##### Tasks

- [ ] iMessage-style chat bubbles:
  ```dart
  class ChatBubble extends StatelessWidget {
    final ChatMessage message;
    final bool isMe;
    
    @override
    Widget build(BuildContext context) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isMe ? BlinkGradients.primaryToLight : null,
            color: isMe ? null : BlinkColors.surfaceContainer,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.text, style: TextStyle(color: isMe ? Colors.white : null)),
              Gap(4),
              Text(
                _formatTime(message.sentAt),
                style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : BlinkColors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }
  }
  ```
- [ ] Time labels between message gaps (>5 min)
- [ ] Pill-shaped input bar:
  ```dart
  Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: BlinkColors.surface,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        IconButton(icon: Icon(Icons.add), onPressed: _attachFile),
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Message',
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_upward),
          onPressed: _sendMessage,
          style: IconButton.styleFrom(
            backgroundColor: BlinkColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  )
  ```
- [ ] Auto-scroll to bottom on new message
- [ ] Empty state with chat bubble icon

##### Acceptance Criteria
- [ ] Messages styled correctly
- [ ] Input bar functional
- [ ] Auto-scroll works
- [ ] Time labels accurate

---

#### 3.8 Live Folders Screen

**File**: `lib/features/live_folder/screens/live_folder_screen.dart`  
**Route**: `/live-folders`

##### Tasks

- [ ] Info card explaining feature
- [ ] Folder cards with sync status:
  ```dart
  class FolderCard extends StatelessWidget {
    final String path;
    final bool isWatching;
    
    @override
    Widget build(BuildContext context) {
      return BlinkCard(
        child: Row(
          children: [
            Icon(Icons.folder, color: BlinkColors.primary, size: 40),
            Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(path.split('/').last, style: BlinkTypography.titleMedium),
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isWatching ? BlinkColors.success : BlinkColors.textTertiary,
                        ),
                      ),
                      Gap(6),
                      Text(isWatching ? 'Watching' : 'Paused'),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: BlinkColors.coral),
              onPressed: () => ref.read(liveFolderProvider.notifier).removeFolder(path),
            ),
          ],
        ),
      );
    }
  }
  ```
- [ ] "Add Folder" gradient FAB
- [ ] `watcher` package integration:
  ```dart
  void addFolder(String path) {
    final watcher = DirectoryWatcher(path);
    watcher.events.listen((event) {
      switch (event.type) {
        case ChangeType.ADD:
        case ChangeType.MODIFY:
          _queueFileForSync(event.path);
      }
    });
  }
  ```
- [ ] Empty state with folder icon

##### Acceptance Criteria
- [ ] Folders added correctly
- [ ] Sync status accurate
- [ ] File changes detected
- [ ] Remove works

---

#### 3.9 Settings Screen

**File**: `lib/features/settings/screens/settings_screen.dart`  
**Route**: `/settings`  
**Status**: ✅ 95% Complete

##### Remaining Tasks

- [ ] Verify avatar editing works
- [ ] Test dark mode persistence
- [ ] Add "Clear cache" functionality

---

#### 3.10 Shared Components

##### Skeleton Loader
**File**: `lib/shared/widgets/skeleton_loader.dart`

```dart
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xFF252533),
      highlightColor: Color(0xFF3A3A4E),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
```

##### Empty State
**File**: `lib/shared/widgets/empty_state.dart`

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: BlinkColors.textTertiary),
          Gap(16),
          Text(title, style: BlinkTypography.titleMedium),
          Gap(8),
          Text(subtitle, style: TextStyle(color: BlinkColors.textSecondary)),
        ],
      ).animate().fadeIn().scale(begin: Offset(0.9, 0.9)),
    );
  }
}
```

##### Bottom Navigation Bar
**File**: `lib/shared/widgets/bottom_nav_bar.dart`

```dart
class BlinkBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  static const tabs = [
    (icon: 'radar', label: 'Discover'),
    (icon: 'transfer', label: 'Transfers'),
    (icon: 'chat', label: 'Chat'),
    (icon: 'folder_sync', label: 'Folders'),
    (icon: 'settings', label: 'Settings'),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: BlinkColors.surface,
        boxShadow: [BlinkShadows.elevation2],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isActive = index == currentIndex;
          return InkWell(
            onTap: () => onTap(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/nav/${tabs[index].icon}${isActive ? '_filled' : ''}.svg',
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    isActive ? BlinkColors.primary : BlinkColors.textTertiary,
                    BlendMode.srcIn,
                  ),
                ),
                if (isActive) ...[
                  Gap(4),
                  Text(tabs[index].label, style: TextStyle(
                    fontSize: 10,
                    color: BlinkColors.primary,
                    fontWeight: FontWeight.w500,
                  )),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}
```

---

### Phase 4: Advanced Features

**Duration**: 2-3 weeks  
**Goal**: Differentiating features beyond basic transfer  
**Depends On**: Phase 3

#### 4.1 Real-time Chat Backend

**Files**: 
- `lib/services/chat/chat_service.dart` (new)
- `lib/features/chat/providers/chat_provider.dart`

##### Tasks

- [ ] Piggyback chat over transfer TCP connection
- [ ] Message encryption with session key:
  ```dart
  Future<void> sendMessage(String sessionId, String text) async {
    final encrypted = cryptoService.encryptChunk(
      utf8.encode(text),
      sessionKeys[sessionId]!,
    );
    await tcpConnection.write(ChatPacket(encrypted));
  }
  ```
- [ ] Delivery receipts (sent, delivered, read)
- [ ] Offline message queue (sync when reconnected)
- [ ] Notification badge on unread messages

##### Acceptance Criteria
- [ ] Messages encrypted end-to-end
- [ ] Delivery receipts work
- [ ] Offline queue syncs correctly
- [ ] Badge updates in real-time

---

#### 4.2 Live Folders Backend

**Files**:
- `lib/services/sync/sync_service.dart` (new)
- `lib/features/live_folder/providers/live_folder_provider.dart`

##### Tasks

- [ ] `DirectoryWatcher` integration:
  ```dart
  void watchFolder(String path) {
    final watcher = DirectoryWatcher(path);
    _watchers[path] = watcher.events.listen((event) {
      switch (event.type) {
        case ChangeType.ADD:
        case ChangeType.MODIFY:
          _queueFileForSync(event.path);
        case ChangeType.REMOVE:
          _queueDeletion(event.path);
      }
    });
  }
  ```
- [ ] Delta detection (changed files only)
- [ ] Auto-sync when devices are nearby
- [ ] Conflict resolution (newer wins):
  ```dart
  ConflictResolution resolveConflict(File local, File remote) {
    if (local.lastModified.isAfter(remote.lastModified)) {
      return ConflictResolution.keepLocal;
    }
    return ConflictResolution.keepRemote;
  }
  ```
- [ ] Sync status indicators per file

##### Acceptance Criteria
- [ ] Changes detected within 1 second
- [ ] Only modified files transferred
- [ ] Conflicts resolved automatically
- [ ] Status indicators accurate

---

#### 4.3 Contact Groups

**Files**:
- `lib/data/repositories/group_repository.dart` (enhance)
- `lib/features/groups/providers/groups_provider.dart`

##### Tasks

- [ ] CRUD operations for groups:
  ```dart
  Future<void> createGroup(String name, List<String> memberDeviceIds) async {
    final group = ContactGroup(
      groupId: uuid.v4(),
      name: name,
      memberDeviceIds: memberDeviceIds,
      createdAt: DateTime.now(),
    );
    await _repository.save(group);
    state = state.copyWith(groups: [...state.groups, group]);
  }
  ```
- [ ] Add/remove devices from groups
- [ ] One-tap share to entire group:
  ```dart
  Future<void> sendToGroup(String groupId, List<File> files) async {
    final group = state.groups.firstWhere((g) => g.groupId == groupId);
    for (final deviceId in group.memberDeviceIds) {
      await transferManager.sendFiles(deviceId, files);
    }
  }
  ```
- [ ] Group persistence in SQLite
- [ ] Group member avatar stack

##### Acceptance Criteria
- [ ] Groups persist across restarts
- [ ] Multi-device send works
- [ ] Edit/delete groups functional
- [ ] Avatar stack shows correctly

---

#### 4.4 Classroom Mode

**Files**:
- `lib/features/classroom/screens/classroom_screen.dart` (new)
- `lib/features/classroom/providers/classroom_provider.dart` (new)
- `lib/services/broadcast/broadcast_service.dart` (new)

##### Tasks

- [ ] Create classroom screen and route
- [ ] Session code generation:
  ```dart
  String generateSessionCode() {
    final random = Random.secure();
    final code = random.nextInt(9000) + 1000; // 1000-9999
    return 'BLINK-$code';
  }
  ```
- [ ] One-to-many broadcast:
  ```dart
  Future<void> broadcastFiles(List<File> files) async {
    for (final device in connectedDevices) {
      // Fire-and-forget, parallel sends
      transferManager.sendFiles(device.deviceId, files);
    }
  }
  ```
- [ ] Connected devices roster
- [ ] "Start/Stop Broadcasting" buttons
- [ ] Connection limit (e.g., 30 devices)

##### Acceptance Criteria
- [ ] Session code unique and easy to read
- [ ] Multiple devices can join
- [ ] Broadcast reaches all devices
- [ ] Clean session termination

---

### Phase 5: Platform Hardening

**Duration**: 2-3 weeks  
**Goal**: Production-ready on all platforms  
**Depends On**: Phase 4

#### 5.1 Android Hardening

**Files**:
- `lib/services/platform/android_service.dart`
- `android/app/src/main/kotlin/.../ForegroundService.kt` (new)

##### Tasks

- [ ] Foreground service for background transfers:
  ```kotlin
  class TransferForegroundService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
      val notification = createNotification()
      startForeground(NOTIFICATION_ID, notification)
      return START_STICKY
    }
  }
  ```
- [ ] Wi-Fi Hotspot fallback (no shared AP scenario):
  ```dart
  Future<void> createHotspot() async {
    await _channel.invokeMethod('createWifiHotspot', {
      'ssid': 'Blink-${deviceId.substring(0, 4)}',
      'password': generateHotspotPassword(),
    });
  }
  ```
- [ ] Battery optimization whitelisting request
- [ ] Storage permissions for Android 13+ (granular media)
- [ ] ProGuard/R8 rules for native libs

##### Acceptance Criteria
- [ ] Transfers continue in background
- [ ] Hotspot fallback works
- [ ] No battery warnings
- [ ] Works on Android 10-14

---

#### 5.2 Desktop Hardening

**Files**:
- `lib/shared/widgets/blink_navigation.dart` (enhance)
- Platform-specific window management

##### Tasks

- [ ] Adaptive layout (sidebar rail + main content):
  ```dart
  LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > 900) {
        return DesktopLayout(sidebar: _Sidebar(), content: content);
      }
      return MobileLayout(bottomNav: _BottomNav(), content: content);
    },
  )
  ```
- [ ] Keyboard shortcuts:
  ```dart
  Shortcuts(
    shortcuts: {
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): OpenFilePicker(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.comma): OpenSettings(),
    },
    child: ...,
  )
  ```
- [ ] Drag-and-drop file selection:
  ```dart
  DropTarget(
    onDragDone: (details) {
      final files = details.files.map((xfile) => File(xfile.path)).toList();
      _startTransfer(files);
    },
    child: ...,
  )
  ```
- [ ] System tray integration (Linux: appindicator, Windows: system_tray)
- [ ] Window state persistence (position, size)

##### Acceptance Criteria
- [ ] Sidebar shows on wide screens
- [ ] Keyboard shortcuts work
- [ ] Drag-drop works
- [ ] Tray icon functional

---

#### 5.3 WebRTC Fallback

**File**: `lib/services/connectivity/webrtc_service.dart`

##### Tasks

- [ ] Data channel setup via `flutter_webrtc`:
  ```dart
  Future<RTCDataChannel> createDataChannel(RTCPeerConnection pc) async {
    return await pc.createDataChannel(
      'blink-transfer',
      RTCDataChannelInit()..ordered = true,
    );
  }
  ```
- [ ] ICE candidate exchange via QR codes:
  ```dart
  // Add ICE candidates to QR payload
  final payload = QrPayload(
    ...
    iceCandidates: await _gatherIceCandidates(),
  );
  ```
- [ ] Fallback trigger conditions:
  ```dart
  if (!await _canReachViaLan(device)) {
    return TransportMethod.webrtc;
  }
  return TransportMethod.lan;
  ```
- [ ] End-to-end testing across NAT

##### Acceptance Criteria
- [ ] Connection established via WebRTC
- [ ] Transfers work over data channel
- [ ] Automatic fallback from LAN
- [ ] Works across NAT

---

#### 5.4 LZ4 Compression

**File**: `lib/services/native/native_compress_service.dart`

##### Tasks

- [ ] Generate FFI bindings from `lz4.h`:
  ```yaml
  # ffigen_lz4.yaml
  output: 'lib/services/native/lz4_bindings.dart'
  headers:
    entry-points:
      - 'native/lz4/lz4.h'
  ```
- [ ] Implement compress/decompress:
  ```dart
  Uint8List compress(Uint8List data) {
    final maxSize = lz4.compressBound(data.length);
    final dest = calloc<Uint8>(maxSize);
    final compressedSize = lz4.compress(
      data.toPointer(), dest, data.length, maxSize,
    );
    return dest.asTypedList(compressedSize);
  }
  ```
- [ ] Adaptive skip for pre-compressed formats:
  ```dart
  static const skipExtensions = {
    '.jpg', '.jpeg', '.png', '.gif', '.webp',  // Images
    '.mp4', '.mkv', '.avi', '.mov', '.webm',    // Video
    '.mp3', '.aac', '.flac', '.ogg',            // Audio
    '.zip', '.gz', '.rar', '.7z', '.tar.gz',   // Archives
  };
  
  bool shouldCompress(String filename) {
    final ext = path.extension(filename).toLowerCase();
    return !skipExtensions.contains(ext);
  }
  ```
- [ ] Chunk-level compression (before encryption)

##### Performance Target
- LZ4: ~500 MB/s compression, ~2 GB/s decompression
- Pure Dart: ~50 MB/s
- **Target speedup: 8-10x**

##### Acceptance Criteria
- [ ] Compression ratio >2x for text files
- [ ] No compression for media files
- [ ] Decompress produces identical data
- [ ] Performance meets targets

---

#### 5.5 Security Audit

##### Tasks

- [ ] Nonce uniqueness verification:
  ```dart
  // Test: Generate 1M nonces, verify no collisions
  test('nonces are unique', () {
    final nonces = <String>{};
    for (var i = 0; i < 1000000; i++) {
      final nonce = cryptoService.generateNonce();
      expect(nonces.add(base64Encode(nonce)), isTrue);
    }
  });
  ```
- [ ] Key zeroing verification:
  ```dart
  // Verify SecureKey zeroes memory on dispose
  test('secure key zeroing', () {
    final key = cryptoService.deriveSessionKey(...);
    final ptr = key.ptr; // Get memory pointer
    key.dispose();
    // Verify memory is zeroed (platform-specific check)
  });
  ```
- [ ] Timing attack resistance:
  - Use constant-time comparison for tokens
  - No early-exit on validation failures
- [ ] Code review checklist:
  - [ ] No hardcoded keys or secrets
  - [ ] No logging of sensitive data
  - [ ] All crypto via libsodium (no custom implementations)
  - [ ] HMAC used for token signing
  - [ ] Session keys never persisted to disk

##### Acceptance Criteria
- [ ] All security tests pass
- [ ] Code review complete
- [ ] No critical vulnerabilities

---

### Phase 6: Polish & Launch

**Duration**: 1-2 weeks  
**Goal**: Production polish and release  
**Depends On**: Phase 5

#### 6.1 Lottie Animations

**Location**: `assets/lottie/`

##### Required Animations

| Animation | File | Duration | Loop | Usage |
|-----------|------|----------|------|-------|
| Loading | `loading.json` | 1.5s | Yes | Progress states, initial load |
| Success | `success.json` | 2s | No | Transfer complete, verification passed |
| Error | `error.json` | 1.5s | No | Transfer failed, connection error |
| Empty Radar | `empty_radar.json` | 3s | Yes | No devices found, scanning |
| Scanning | `scanning.json` | 2s | Yes | QR scanning, discovery active |

##### Specifications

**loading.json**
- Style: Circular spinner with gradient trail
- Colors: Primary (#6C63FF) to Accent (#00D9FF)
- Motion: Smooth rotation with pulsing dots
- Size: 48×48 default, scalable

**success.json**
- Style: Checkmark drawing with particle burst
- Colors: Success green (#2ED47A), purple accents
- Motion: Circle draws → checkmark draws → confetti burst
- Timing: 0.5s circle, 0.5s check, 1s particles

**error.json**
- Style: X mark with shake
- Colors: Error red (#F87171)
- Motion: Circle → X draws → subtle shake
- Keep it quick (don't frustrate users)

**empty_radar.json**
- Style: Radar sweep with no devices
- Colors: Accent cyan, dimmed
- Motion: Continuous sweep, pulsing center
- Atmosphere: Calm, searching

**scanning.json**
- Style: Pulsing concentric circles
- Colors: Accent to primary gradient
- Motion: Waves expanding from center

##### Acceptance Criteria
- [ ] All animations under 100KB each
- [ ] Loop seamlessly where applicable
- [ ] Colors match design system
- [ ] Render correctly on all platforms

---

#### 6.2 Testing Suite

##### Unit Tests

**Coverage targets**:
- Services: 80%
- Providers: 70%
- Models: 90%

**Critical paths**:
```dart
// Crypto service tests
test('encrypt/decrypt round trip', () {
  final plaintext = utf8.encode('Hello, World!');
  final key = cryptoService.generateSessionKey();
  final encrypted = cryptoService.encryptChunk(plaintext, key);
  final decrypted = cryptoService.decryptChunk(encrypted, key);
  expect(decrypted, equals(plaintext));
});

// Transfer manager tests
test('session state transitions', () {
  final session = TransferSession(...);
  expect(session.status, TransferStatus.pending);
  session.start();
  expect(session.status, TransferStatus.connecting);
  // ...
});
```

##### Widget Tests

**Key screens**:
- [ ] Onboarding flow
- [ ] Discovery screen device list
- [ ] Transfer card progress
- [ ] QR code display/scan

##### Integration Tests

**End-to-end flows**:
```dart
testWidgets('complete transfer flow', (tester) async {
  // 1. Launch app
  await tester.pumpWidget(BlinkApp());
  
  // 2. Complete onboarding
  await tester.enterText(find.byType(TextField), 'Test User');
  await tester.tap(find.text('Get Started'));
  
  // 3. Select device
  await tester.tap(find.byType(DeviceBubble).first);
  
  // 4. Select files
  await tester.tap(find.text('Select Files'));
  // Mock file picker...
  
  // 5. Verify transfer starts
  expect(find.byType(TransferCard), findsOneWidget);
});
```

##### Performance Tests

```dart
test('radar animation maintains 60fps', () {
  // Profile radar screen
  // Verify no dropped frames
});

test('transfer progress updates don\'t cause jank', () {
  // Rapid progress updates
  // Verify UI remains responsive
});
```

---

#### 6.3 Documentation

##### README.md Updates

```markdown
# Blink

Privacy-first, cross-platform offline file sharing.

## Features
- 100% offline — no internet required
- Cross-platform — Android, Linux, Windows
- End-to-end encrypted — XChaCha20-Poly1305
- Hardware-accelerated — native crypto via FFI

## Installation
[Platform-specific instructions]

## Usage
[Quick start guide with screenshots]

## Security
[Explanation of crypto, key exchange, etc.]

## Contributing
[Development setup, PR guidelines]
```

##### In-App Help

- First-launch tooltips
- Settings explanations
- Transfer status meanings
- Troubleshooting tips

##### Privacy Policy

- What data is collected (none sent to servers)
- What data is stored locally
- How encryption works
- User rights

##### Build Instructions

```markdown
## Building from Source

### Prerequisites
- Flutter SDK 3.10.8+
- Android SDK (for Android builds)
- CMake (for native builds)

### Linux
```bash
flutter build linux --release
```

### Windows
```bash
flutter build windows --release
```

### Android
```bash
flutter build apk --release
```
```

---

## 5. Feature Specifications

### 5.1 Transfer Protocol

#### Chunk Format
```
┌─────────────┬────────────────────────────────────┐
│   NONCE     │    CIPHERTEXT + AUTH TAG           │
│  24 bytes   │        N + 16 bytes                │
└─────────────┴────────────────────────────────────┘
```

#### HTTP Endpoints

| Method | Path | Description |
|--------|------|-------------|
| PUT | `/transfer/:sessionId/:fileIndex` | Upload file chunk |
| GET | `/transfer/:sessionId/status` | Get session status |
| DELETE | `/transfer/:sessionId` | Cancel transfer |

#### Content-Range Header
```
Content-Range: bytes {start}-{end}/{total}
Example: Content-Range: bytes 4194304-8388607/104857600
```

### 5.2 Discovery Protocol

#### mDNS Service
```
Type: _blink._tcp
Port: 49876

TXT Records:
  name=Device Name
  platform=linux|windows|android
  version=1
  fingerprint=a1b2c3d4 (first 8 chars of pubkey hash)
```

#### BLE Advertisement
```
Service UUID: 0000blink-0000-1000-8000-00805f9b34fb
Manufacturer Data:
  [0-7]: Device name (UTF-8, truncated)
  [8]: Platform index
  [9-12]: Pubkey fingerprint
```

### 5.3 QR Payload

```json
{
  "pk": "base64-ed25519-public-key",
  "tk": "base64-random-token",
  "ts": 1711130000,
  "sg": "base64-hmac-signature",
  "ip": "192.168.1.100",
  "pt": 49876
}
```

---

## 6. Security Implementation

### 6.1 Cryptographic Primitives

| Purpose | Algorithm | Library |
|---------|-----------|---------|
| Symmetric Encryption | XChaCha20-Poly1305-IETF | libsodium |
| Identity Keys | Ed25519 | libsodium |
| Key Exchange | X25519 ECDH | libsodium |
| Token Signing | HMAC-SHA256 | libsodium |
| File Integrity | BLAKE3 | Custom FFI |

### 6.2 Key Lifecycle

```
1. First Launch
   └─→ Generate Ed25519 identity keypair
   └─→ Store in platform secure storage

2. Pairing
   └─→ Exchange public keys via QR
   └─→ Derive X25519 session key via ECDH
   └─→ Session key used for this transfer only

3. Transfer
   └─→ Generate random 24-byte nonce per chunk
   └─→ Encrypt with XChaCha20-Poly1305-IETF
   └─→ Nonce prepended to ciphertext

4. Completion
   └─→ Session key disposed (memory zeroed)
   └─→ Identity key persists
```

### 6.3 Threat Model

| Threat | Mitigation |
|--------|------------|
| Network eavesdropping | End-to-end encryption |
| Key interception | QR-based offline exchange |
| Replay attacks | Single-use tokens with TTL |
| Nonce reuse | 192-bit random nonces |
| Memory scraping | SecureKey zeroing |
| Timing attacks | Constant-time comparisons |

---

## 7. Performance Guidelines

### 7.1 Targets

| Metric | Target |
|--------|--------|
| Transfer speed | >100 MB/s on gigabit LAN |
| Encryption overhead | <5% of transfer time |
| Discovery latency | <5 seconds |
| UI frame rate | 60 fps |
| Battery (Android) | <5% per hour during transfer |
| Memory usage | <200 MB |

### 7.2 Optimizations

| Area | Strategy |
|------|----------|
| File I/O | Isolate for reads/writes |
| Chunking | 4 MB optimal for Wi-Fi MTU |
| Parallelism | Up to 4 concurrent files |
| Memory | Stream processing, no full-file buffers |
| Encryption | Hardware-accelerated via FFI |
| Progress UI | Throttled to 60 fps |
| Discovery | BLE duty cycle (20%) |

### 7.3 Profiling Checkpoints

- [ ] Radar animation: no dropped frames
- [ ] Transfer start: <1s from tap to first chunk
- [ ] Large file (1GB): linear progress, no memory spike
- [ ] 10 devices discovered: no UI lag

---

## 8. Testing Strategy

### 8.1 Test Pyramid

```
        ┌────────────────┐
        │  E2E Tests     │  5%
        │  (Integration) │
        ├────────────────┤
        │  Widget Tests  │  15%
        ├────────────────┤
        │  Unit Tests    │  80%
        └────────────────┘
```

### 8.2 Coverage Targets

| Layer | Target |
|-------|--------|
| Services | 80% |
| Providers | 70% |
| Models | 90% |
| Widgets | 50% |
| Overall | 75% |

### 8.3 Critical Test Cases

1. **Crypto round-trip**: Encrypt → Decrypt = Original
2. **Transfer resume**: Pause at 50%, resume, complete
3. **QR expiry**: Reject tokens >5 minutes old
4. **Discovery merge**: mDNS + BLE → single device list
5. **BLAKE3 verification**: Mismatched hash → error

---

## 9. Risk Assessment

### 9.1 Technical Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| libsodium FFI issues | High | Low | Well-tested library, fallback to pure Dart |
| BLE platform differences | Medium | Medium | Graceful degradation to mDNS |
| Large file memory issues | High | Medium | Strict streaming, profiling |
| WebRTC NAT traversal | Medium | High | TURN server fallback (future) |

### 9.2 Schedule Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Crypto integration complexity | High | Medium | Start with crypto (Phase 1.1) |
| Animation performance | Medium | Low | Use flutter_animate, profile early |
| Platform-specific bugs | Medium | Medium | Test on real devices early |

### 9.3 Contingency Plans

1. **If crypto FFI fails**: Use pure Dart sodium implementation (slower but works)
2. **If BLE unreliable**: Rely solely on mDNS discovery
3. **If WebRTC fails**: LAN-only mode (still valuable)
4. **If animations janky**: Simplify to basic transitions

---

## 10. Appendices

### 10.1 Glossary

| Term | Definition |
|------|------------|
| **AEAD** | Authenticated Encryption with Associated Data |
| **BLE** | Bluetooth Low Energy |
| **ECDH** | Elliptic Curve Diffie-Hellman (key exchange) |
| **FFI** | Foreign Function Interface (calling native code) |
| **mDNS** | Multicast DNS (zero-config discovery) |
| **Nonce** | Number used once (prevents replay attacks) |
| **TTL** | Time To Live |

### 10.2 References

- [libsodium Documentation](https://doc.libsodium.org/)
- [BLAKE3 Specification](https://github.com/BLAKE3-team/BLAKE3-specs)
- [Bonsoir Package](https://pub.dev/packages/bonsoir)
- [Flutter FFI Guide](https://dart.dev/guides/libraries/c-interop)
- [XChaCha20-Poly1305 RFC Draft](https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-xchacha)

### 10.3 Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.1.0 | March 2026 | Initial strategy document |

---

*This document is the source of truth for Blink implementation. Update as work progresses.*
