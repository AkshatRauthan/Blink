# Blink — Privacy-First Cross-Platform File Sharing

Blink is a high-performance, fully offline file-sharing application designed to bridge the gap between Android, Windows, and Linux. Built with a "Privacy by Design" philosophy, it offers an AirDrop-like experience without ecosystem lock-in — lightning-fast transfers, beautiful animations, excellent battery life, and the safest possible offline key exchange.

---

## Features

- **No Login Required** — Choose a name + avatar once and you're ready
- **100% Offline** — Zero internet needed, everything on local network
- **Cross-Platform** — Android, Windows, and Linux
- **All File Types** — Images, videos, documents, APKs, folders, and more
- **AirDrop-like UI** — Smooth animations and radar-style discovery screen
- **Live Folders** — Real-time directory sync while devices are nearby
- **Built-in Chat** — Message while transferring files
- **Group Sharing** — Create persistent groups for frequent contacts
- **Parallel Transfers** — Multiple files simultaneously at full Wi-Fi speed
- **Ultra Low-Power** — BLE used only for discovery; Wi-Fi only during transfers
- **Hybrid Protocol Engine** — Dynamically switches LAN → WebRTC → Wi-Fi Hotspot
- **Pause & Resume** — HTTP Range-header-based resumable transfers; never restart a 10 GB send
- **QR-Handshake** — Single-use, time-limited QR codes for offline key exchange
- **Classroom Mode** — One-to-many broadcast for groups or departments
- **Hardware-Accelerated Crypto** — libsodium via FFI; XChaCha20-Poly1305-IETF on all platforms

---

## Architecture

### Connection Flow

```
1. Discovery   → BLE (Android) + mDNS/Bonjour (all platforms)
2. Handshake   → QR scan exchanges Ed25519 pubkeys + HMAC-signed session token
3. Key Derive  → X25519 ECDH (scalarmult) → 256-bit shared session key
4. Tunneling   → LAN/IP  →  WebRTC (fallback)  →  Wi-Fi Hotspot (Android only)
5. Transfer    → Chunked HTTP streaming + XChaCha20-Poly1305 encrypt-as-you-stream
6. Verify      → BLAKE3 checksum per file (streamed during transfer, verified post-transfer)
```

### System Layers

```
┌────────────────────────────────────────────────────────┐
│                      UI Layer                          │
│              (Flutter Widgets + GoRouter)               │
├────────────────────────────────────────────────────────┤
│                    State Layer                         │
│         (Riverpod 3 — Manual Notifier Pattern)         │
├────────────────────┬───────────────────────────────────┤
│  Discovery Service │       Transfer Engine             │
│  (BLE + mDNS)      │  (Shelf HTTP + Dart Isolates)     │
│                    │  (4 MB chunks, parallel streams)  │
├────────────────────┴───────────────────────────────────┤
│                  Security Layer                        │
│  Key Store · QR Handshake · XChaCha20 · Ed25519/X25519 │
├────────────────────────────────────────────────────────┤
│         Native FFI Layer  (C via dart:ffi)             │
│   libsodium (crypto)  ·  BLAKE3 (hashing)  ·  LZ4     │
├────────────────────────────────────────────────────────┤
│        Data Layer  (SQLite via sqflite + FFI)          │
│          Devices · Transfers · Groups · Chat            │
└────────────────────────────────────────────────────────┘
```

---

## Technology Stack

| Concern | Package | Notes |
|---|---|---|
| Framework | Flutter + Dart | SDK ^3.10.8 |
| State Management | `flutter_riverpod ^3.2.1` | Manual `Notifier` / `NotifierProvider` pattern — **no code-gen** |
| Routing | `go_router ^17.1.0` | Type-safe routes via `AppRoutes` constants |
| Database | `sqflite ^2.4.1` + `sqflite_common_ffi ^2.3.4` | Android native; Linux/Windows via sqlite3 FFI |
| HTTP Server | `shelf ^1.4.2` + `shelf_router ^1.1.4` | Embedded in Dart Isolate |
| WebRTC | `flutter_webrtc ^1.3.0` | Fallback transport |
| mDNS Discovery | `bonsoir ^6.0.1` | All platforms; sealed-class event API |
| BLE Discovery | `flutter_blue_plus ^2.1.1` | Android; limited desktop |
| QR Generate | `qr_flutter ^4.1.0` | |
| QR Scan | `mobile_scanner ^7.2.0` | Camera + webcam |
| **Native Crypto** | **`sodium_libs ^3.4.6`** | **libsodium Sumo via FFI — XChaCha20-Poly1305-IETF, Ed25519, X25519 scalarmult** |
| FFI Bindings Gen | `ffigen ^12.0.0` | Auto-generates Dart bindings from C headers (BLAKE3, LZ4) |
| File Watching | `watcher ^1.1.1` | Live Folders |
| Permissions | `permission_handler ^11.4.0` | |
| File Picker | `file_picker ^8.0.0` | |
| **Animation** | **`flutter_animate ^4.5.2`** | **Declarative animation chains (.fade, .slide, .blur, .shimmer)** |
| Page Transitions | `animations ^2.1.1` | Google Material Motion: container transform, shared axis, fade through |
| Vector Animation | `lottie ^3.3.1` | Complex animations for loading/success/error states |
| Typography | `google_fonts ^6.2.1` | Inter as primary font — closest OSS match to SF Pro |
| SVG Icons | `flutter_svg ^2.0.17` | Crisp vector icons at any density |
| Spacing DSL | `gap ^3.0.1` | Clean `Gap(16)` syntax instead of `SizedBox(height: 16)` |
| Skeleton Loading | `shimmer ^3.0.0` | Shimmering placeholder skeletons |
| List Animations | `flutter_staggered_animations ^1.1.1` | Staggered entrance animations for lists/grids |

> **No code-gen dependencies.** Models are plain Dart classes with `const` constructors, `copyWith()`, `toJson()`/`fromJson()`, and `==`/`hashCode`. Providers use manual `Notifier` + `NotifierProvider`. This eliminates `build_runner`, `freezed`, `json_serializable`, `riverpod_generator`, and their cascading analyzer conflicts (`riverpod_generator 4.x` requires `analyzer ^9.0.0` which conflicts with `flutter_test` on Flutter 3.38.x).

---

## Native C/C++ Modules  (Dart FFI)

Pure Dart is the CPU bottleneck for crypto and hashing. All three platforms get hardware-accelerated native code via `dart:ffi`. C# was evaluated and dismissed — Windows-only, breaks the cross-platform model.

| Module | Implementation | Speedup vs pure Dart |
|---|---|---|
| **XChaCha20-Poly1305-IETF** | `sodium_libs` Sumo (pre-built libsodium) | ~8–15× |
| **Ed25519 key generation** | `sodium_libs` Sumo | ~20× |
| **X25519 ECDH (scalarmult)** | `sodium_libs` Sumo (requires `SodiumSumo`) | ~15× |
| **BLAKE3 file hashing** | Custom FFI plugin (`native/blake3/`) | ~25× vs SHA-256 Dart |
| **LZ4 compression** | Custom FFI plugin (`native/lz4/`) | ~8× vs pure Dart |
| Chunking / HTTP framing | Pure Dart (Shelf) | Not a CPU bottleneck |

### Why XChaCha20-Poly1305-IETF (not AES-256-GCM)

The Dart `sodium_libs` package **does not expose a high-level AES-256-GCM API**. Only low-level JS bindings exist for it. The recommended AEAD construction in libsodium is XChaCha20-Poly1305-IETF, which:

- Uses **192-bit nonces** — safe for random generation. AES-GCM's 96-bit nonces risk collision at ~2³² messages. XChaCha20 is safe far beyond any practical volume.
- Runs at **~3–4 GB/s** on modern CPUs (SIMD-optimised). Wi-Fi peaks at ~300 MB/s, so crypto is never the bottleneck.
- Is **constant-time** — no timing side channels.
- Works identically on all platforms. AES-NI is x86-only; XChaCha20 has NEON acceleration on ARM (Android).

### Why SodiumSumo

Standard `Sodium` lacks `scalarmult` (needed for X25519 ECDH key derivation). `SodiumSumo` (`sodium_libs_sumo.dart`) includes the full API surface: `scalarmult`, `pwhash`, `sign` (Sumo), etc. The `NativeCryptoService` initialises via `SodiumSumoInit.init()`.

---

## Protocols

| Priority | Protocol | Trigger |
|---|---|---|
| 1 — Primary | LAN (Wi-Fi) + TCP/HTTP + mDNS | Devices on same network |
| 2 — Secondary | WebRTC Data Channels | NAT traversal / max privacy mode |
| 3 — Fallback | Wi-Fi Hotspot + BLE | Android only; no shared AP |

### Pre-flight Negotiation (Planned)

Before a transfer session begins, the sender and receiver exchange a lightweight JSON capability manifest:

```json
{
  "protocol_version": 1,
  "supported_ciphers": ["xchacha20-poly1305-ietf"],
  "compression": ["lz4", "none"],
  "max_chunk_bytes": 4194304,
  "supports_resume": true,
  "blake3_verify": true
}
```

This allows future protocol upgrades without breaking older clients.

---

## Security

- **XChaCha20-Poly1305-IETF** for all file transfer chunks (via libsodium Sumo)
  — 192-bit random nonces; no nonce reuse risk
- **Ed25519** identity keypairs (generated on first launch, persisted in secure storage)
- **X25519 ECDH** (`scalarmult`) to derive per-session 256-bit symmetric keys — never reused across sessions
- **QR code key exchange** — most secure offline method; no keys ever sent over BLE or Wi-Fi
- **Single-use, time-limited QR tokens** (HMAC-signed, 5-minute TTL)
- **BLAKE3 integrity check** per file — streamed during transfer, verified post-transfer
- **SecureKey zeroing** — libsodium's `SecureKey` type zeroes memory on disposal (no key material left in RAM)
- **Session key rotation** — each transfer session derives a fresh key; paused/resumed transfers re-derive from the same X25519 exchange but never reuse nonces

### Chunk Wire Format

```
┌──────────┬───────────────────────────────────────────┐
│ Nonce    │   Ciphertext + Poly1305 MAC (16 bytes)    │
│ 24 bytes │              N bytes                      │
└──────────┴───────────────────────────────────────────┘
```

Each chunk is `encryptChunk()` → `[24B nonce || ciphertext+tag]`. The receiver splits at byte 24 and decrypts.

---

## Platform Support

| Feature | Android | Linux | Windows |
|---|---|---|---|
| mDNS discovery | Yes | Yes | Yes |
| BLE discovery | Yes | Limited | Limited |
| File transfer (HTTP) | Yes | Yes | Yes |
| WebRTC fallback | Yes | Yes | Yes |
| Wi-Fi Hotspot fallback | Yes | No | No |
| Background service | Yes (foreground svc) | Limited | Limited |
| QR scan | Yes (camera) | Yes (webcam) | Yes (webcam) |
| Hardware crypto (NEON/SIMD) | ARM NEON | x86 SIMD | x86 SIMD |
| Desktop first-class | N/A | Primary dev/test | Primary dev/test |

> **Testing strategy**: Linux desktop is the primary development and testing platform (no emulator overhead). Android testing follows via physical device. Windows validation last.

---

## Folder Structure

```
lib/
├── main.dart                          # Bootstrap: ProviderScope + runApp
├── app.dart                           # BlinkApp widget, GoRouter config, AppRoutes
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # Ports, chunk sizes, timeouts, mDNS type
│   │   └── app_strings.dart           # User-facing strings
│   ├── theme/                         # Design tokens (colors, type, spacing, motion)
│   │   ├── app_colors.dart            # BlinkColors + BlinkGradients
│   │   ├── app_typography.dart        # Text styles via Google Fonts (Inter)
│   │   ├── app_spacing.dart           # 4 px grid: BlinkSpacing + BlinkRadius
│   │   ├── app_shadows.dart           # Elevation system: BlinkShadows (light/dark)
│   │   ├── app_animations.dart        # BlinkDurations + BlinkCurves + BlinkEffects
│   │   └── app_theme.dart             # BlinkTheme.light() / .dark() ThemeData builder
│   ├── utils/
│   │   ├── logger.dart                # Thin wrapper for debug/info/error logging
│   │   ├── file_utils.dart            # Extension helpers, MIME detection
│   │   └── platform_utils.dart        # Platform detection (isAndroid, isDesktop)
│   └── errors/
│       └── blink_exception.dart       # App exception hierarchy (typed errors)
│
├── data/
│   ├── models/                        # Plain Dart immutable classes (no code-gen)
│   │   ├── device.dart                #   DevicePlatform enum + Device
│   │   ├── transfer_session.dart      #   TransferStatus, TransferDirection, TransferSession
│   │   ├── transfer_file.dart         #   TransferFile (per-file state)
│   │   ├── chat_message.dart          #   ChatMessage
│   │   └── contact_group.dart         #   ContactGroup
│   ├── repositories/                  # sqflite CRUD, toJson/fromJson ↔ row mappers
│   │   ├── device_repository.dart
│   │   ├── transfer_repository.dart
│   │   └── chat_repository.dart
│   └── local/
│       └── isar_service.dart          # SQLite singleton (sqflite + sqflite_common_ffi)
│
├── features/                          # Feature-first modules (provider + screen + widgets)
│   ├── onboarding/
│   │   ├── providers/onboarding_provider.dart
│   │   └── screens/onboarding_screen.dart
│   ├── discovery/
│   │   ├── providers/discovery_provider.dart
│   │   ├── screens/discovery_screen.dart
│   │   └── widgets/
│   │       ├── device_bubble.dart
│   │       └── radar_painter.dart     # CustomPainter: animated concentric radar rings
│   ├── pairing/
│   │   ├── providers/pairing_provider.dart
│   │   ├── screens/qr_show_screen.dart
│   │   └── screens/qr_scan_screen.dart
│   ├── transfer/
│   │   ├── providers/transfer_provider.dart
│   │   ├── screens/send_screen.dart
│   │   ├── screens/receive_screen.dart
│   │   └── widgets/
│   │       ├── transfer_card.dart
│   │       └── progress_bar.dart
│   ├── chat/
│   │   ├── providers/chat_provider.dart
│   │   └── screens/chat_screen.dart
│   ├── live_folder/
│   │   ├── providers/live_folder_provider.dart
│   │   └── screens/live_folder_screen.dart
│   └── settings/
│       ├── providers/settings_provider.dart
│       └── screens/settings_screen.dart
│
└── services/                          # Platform-level services (no UI)
    ├── discovery/
    │   ├── mdns_service.dart          # Bonsoir mDNS advertise + discover (sealed events)
    │   ├── ble_service.dart           # flutter_blue_plus BLE beacon (Android)
    │   └── discovery_manager.dart     # Combines mDNS + BLE into unified Device stream
    ├── transfer/
    │   ├── http_server_service.dart   # Shelf server (receiver side); ChunkEvent stream
    │   ├── http_client_service.dart   # HTTP PUT streaming (sender side)
    │   ├── transfer_isolate.dart      # Isolate entry point + progress messaging
    │   └── transfer_manager.dart      # Orchestrates sessions, isolate pool, resume logic
    ├── security/
    │   ├── crypto_service.dart        # High-level API: deriveSessionKey, encryptChunk, decryptChunk
    │   ├── key_store_service.dart     # Ed25519 identity keypair (generate + secure persist)
    │   └── qr_handshake_service.dart  # QR payload: HMAC-signed, time-limited, single-use tokens
    ├── connectivity/
    │   ├── network_info_service.dart  # Local IP, Wi-Fi SSID, connectivity checks
    │   └── webrtc_service.dart        # flutter_webrtc data channel setup (fallback)
    ├── platform/
    │   ├── android_service.dart       # Android foreground service, Wi-Fi hotspot
    │   └── platform_channel_service.dart
    └── native/                        # Dart FFI wrappers for C libraries
        ├── native_crypto_service.dart # SodiumSumo: XChaCha20, Ed25519, X25519 scalarmult
        ├── native_hash_service.dart   # BLAKE3 via custom FFI (native/blake3/)
        └── native_compress_service.dart # LZ4 via custom FFI (native/lz4/)

native/                                # C source + headers, compiled per-platform via CMake
├── blake3/
│   ├── blake3.h
│   └── CMakeLists.txt
└── lz4/
    ├── lz4.h
    └── CMakeLists.txt

assets/                                # Static assets
├── images/
├── icons/
├── lottie/                            # Lottie JSON animations (loading, success, error)
└── svg/                               # Platform icons, brand marks
```

---

## Design System

Blink targets a **Swift/iOS-inspired aesthetic**: fluid spring animations, frosted glass surfaces, generous spacing, and a restrained colour palette with electric accent pops. Performance is non-negotiable — every animation primitive is GPU-composited and never blocks the main isolate.

### Colour Palette

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#6C63FF` | Brand purple — FABs, active states, primary buttons |
| `primaryLight` | `#9D97FF` | Hover/focus tint; dark-mode primary |
| `accent` | `#00D9FF` | Radar rings, active connections |
| `coral` | `#FF6B6B` | Notifications, send actions |
| `mint` | `#2ED47A` | Success, completed transfers |
| `amber` | `#FFBB33` | Warning, paused states |
| `lightBackground` | `#F8F9FC` | Light mode scaffold |
| `darkBackground` | `#0D0D12` | Dark mode scaffold |

### Typography

**Primary font: Inter** (Google Fonts, loaded lazily).  
Falls back to system sans-serif. Weights: 400 (body), 500 (labels), 600 (titles, headlines), 700 (display, hero).

| Style | Size | Weight | Use |
|---|---|---|---|
| `displayLarge` | 48 | Bold | Splash hero numbers |
| `headlineMedium` | 20 | SemiBold | Screen titles |
| `titleMedium` | 15 | SemiBold | Card/list-tile titles |
| `bodyMedium` | 14 | Regular | Descriptions, paragraphs |
| `labelLarge` | 14 | SemiBold | Button text |
| `labelSmall` | 10 | Medium | Badges, chips |

### Spacing (4 px base grid)

`xxs=2 · xs=4 · sm=8 · md=16 · lg=24 · xl=32 · xxl=48 · xxxl=64`

Border radii: `sm=8 · md=12 · lg=16 · xl=24 · full=999`

### Animation Strategy

| Pattern | Package | Duration | Curve |
|---|---|---|---|
| Card/list entrance | `flutter_animate` | 350 ms | `easeOutCubic` |
| Modal appear | `flutter_animate` | 500 ms | `easeOutBack` |
| Page transition | `animations` (Material Motion) | — | CupertinoPageTransition |
| Radar rings | `AnimationController` | continuous | `linear` |
| Success/error | `lottie` | — | built-in |
| Skeleton loading | `shimmer` | 1500 ms loop | — |
| List stagger | `flutter_staggered_animations` | 50 ms delay | `easeOutCubic` |

### Theme Architecture

`BlinkTheme.light()` and `BlinkTheme.dark()` produce complete `ThemeData` instances by composing all design tokens:

- **No splash ink** — `NoSplash.splashFactory` for iOS feel
- **Cupertino page transitions** on all platforms
- **Cards**: 0 elevation, 0.5 px border, `BlinkRadius.lg` corners
- **Buttons**: pill-shaped elevated (primary), outlined (secondary), text (tertiary)
- **Inputs**: filled with no border; focus ring on tap
- **Bottom sheets**: 24 px top radius, drag handle visible
- **Snackbars**: floating, inverted surface colour

### Performance Guardrails

- All animations use `flutter_animate`'s GPU-composited effects (no `saveLayer` abuse)
- `shimmer` and `lottie` do not re-render on every frame — they use `RepaintBoundary` internally
- `google_fonts` caches HTTP responses and fonts on disk — no re-download per session
- No glassmorphism `BackdropFilter` on scroll views (expensive on low-end Android)
- Spring physics via `Curves.elasticOut` / custom `Cubic`, not full `SpringSimulation` (cheaper)
- Progress bar updates capped at 60 fps via `AppConstants.progressUpdateFps`

---

## Performance Optimisations

| Area | Strategy |
|---|---|
| File I/O | All reads/writes in a dedicated `Isolate` — never block main thread |
| Chunking | 4 MB chunks — optimal for Wi-Fi MTU and XChaCha20 auth tag overhead |
| Parallelism | Per-file isolate; `IsolatePool` capped at `AppConstants.maxConcurrentTransfers` |
| Memory | `Stream<List<int>>` file streaming — never load full file into RAM |
| Encryption | Encrypt-as-you-stream — no double buffering of plaintext |
| Nonces | 192-bit random nonces (XChaCha20) — no counter tracking needed |
| Discovery | BLE duty-cycle: scan 2 s / sleep 8 s — preserves battery |
| HTTP | Persistent keep-alive connections per session; connection pooling |
| Progress UI | Throttled to max 60 updates/sec — `Stream.throttle()` |
| Database | sqflite `async/await` queries; stream controllers for reactive UI |
| QR | Pre-generate + cache QR payload; regenerate only on expiry (5 min TTL) |
| Crypto | libsodium auto-selects NEON (ARM) or SIMD (x86) — zero Dart-level overhead |
| Hashing | BLAKE3 multi-core C: ~8–12 GB/s vs ~0.3 GB/s pure Dart SHA-256 |
| Compression | Adaptive: skip for already-compressed formats (jpg, png, mp4, zip, gz, rar) |
| SecureKey | `SecureKey.dispose()` zeroes key material in native memory immediately |

### Planned Optimisations (Phase 5+)

| Area | Strategy |
|---|---|
| Adaptive chunks | Dynamically adjust ch