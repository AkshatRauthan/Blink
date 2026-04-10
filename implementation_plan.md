# Blink — Complete Implementation Plan

> **Purpose:** Detailed step-by-step execution plan for reimplementing the complete UI and all features of Blink. Track progress by checking off items and adding custom reviews/comments under each section.

## Phase 1: Core Framework & Native Engines

### 1.1 Crypto & Hardware Acceleration (libsodium)
- [ ] Bind `libsodium` FFI for Ed25519/X25519 key exchanges.
- [ ] Bind `libsodium` FFI for XChaCha20-Poly1305 stream encryption.
- [ ] Bind `BLAKE3` for streaming verification.
- **Review/Comments:**
  > 

### 1.2 Base HTTP Transfer Server & Client 
- [ ] Implement embedded Shelf HTTP Server inside a Dart Isolate.
- [ ] Implement persistent Keep-Alive HTTP streaming client.
- [ ] Implement chunked stream logic (4 MB chunks) for Resume/Pause (HTTP Range-header-based).
- **Review/Comments:**
  > 

## Phase 2: Local Network Discovery

### 2.1 Multi-Platform Discovery Setup
- [ ] Implemented `bonsoir` for mDNS/Bonjour network discovery.
- [ ] Implement `flutter_blue_plus` for BLE beacon discovery natively on Android.
- [ ] Create `DiscoveryManager` to map platform events to unified device streams.
- **Review/Comments:**
  > 

## Phase 3: Pairing & QR Handshake

### 3.1 QR Generation & TTL 
- [ ] Generate timed QR tokens (5-minute TTL) signed with HMAC.
- [ ] Expose Ed25519 pubkeys via QR token.
- **Review/Comments:**
  > 

### 3.2 Key Exchange & Scanner
- [ ] Wire `MobileScanner` UI and custom viewfinder gradient animation.
- [ ] Derive 256-bit session key via X25519 ECDH (scalarmult) on scan success.
- **Review/Comments:**
  > 

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
- **Review/Comments:**
  > 
