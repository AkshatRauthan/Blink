# Blink — Screen Documentation

> Auto-generated screen reference for the **Blink** privacy-first local file sharing app.
> Stitch Project ID: `4663667797961451103`

---

## Table of Contents

### Core Screens
1. [Onboarding Screen](#1-onboarding-screen)
2. [Discovery / Radar Screen](#2-discovery--radar-screen)
3. [QR Show Screen](#3-qr-show-screen)
4. [QR Scan Screen](#4-qr-scan-screen)
5. [Send Screen](#5-send-screen)
6. [Receive Screen](#6-receive-screen)
7. [Chat Screen](#7-chat-screen)
8. [Live Folders Screen](#8-live-folders-screen)
9. [Settings Screen](#9-settings-screen)

### New Screens (Added March 2026)
10. [Contact Groups Screen](#10-contact-groups-screen)
11. [Classroom Mode Screen](#11-classroom-mode-screen)

### Desktop Screens
12. [Desktop Discovery Screen](#12-desktop-discovery-screen)
13. [Desktop Transfer Screen](#13-desktop-transfer-screen)

### Component Libraries
14. [Bottom Navigation Bar](#14-bottom-navigation-bar)
15. [Empty States](#15-empty-states)
16. [Loading Skeletons](#16-loading-skeletons)
17. [Transfer Card States](#17-transfer-card-states)
18. [Button Components](#18-button-components)
19. [Input Components](#19-input-components)
20. [Dialog Components](#20-dialog-components)

---

## 1. Onboarding Screen

| Key | Value |
|---|---|
| **File** | `lib/features/onboarding/screens/onboarding_screen.dart` |
| **Route** | `/onboarding` (`AppRoutes.onboarding`) |
| **Provider** | `onboardingNotifierProvider` |
| **State** | `OnboardingState { name, avatarPath, isSaving }` |
| **Stitch Screen** | `e7644885a1d64e8782c1801285c42e6a` |

### Description
First-launch screen where users set a display name and optional avatar. Designed with an iOS-inspired aesthetic featuring a pulsing logo glow, animated gradient background, and a staggered entrance animation sequence. Persists onboarding data to SQLite and guards all other routes until completed.

### Key UI Elements
- **Ambient gradient orbs** — Two large radial gradients (primary + accent) positioned behind content for atmospheric depth
- **Pulsing logo glow** — `AnimationController` driving a pulsing purple/accent glow behind the Blink SVG logo (`blink_logo.svg`)
- **Avatar picker** — Circular avatar (96px) with gradient border, camera badge overlay; taps trigger `file_picker` (`FileType.image`), selected image shown via `Image.file()`, falls back to person icon
- **Name input** — Full-width `TextFormField` on dark surface (`#1A1A2E`) with rounded container styling and subtle border, validates non-empty
- **CTA button** — Full-width gradient pill button (`primary → #8B7BFF`) with `AnimatedScale` press animation (0.97) and glow shadow; shows `CircularProgressIndicator` when `isSaving`
- **Security badges** — Row of badges showing "100% Offline", "E2E Encrypted", "Cross-Platform" with subtle icon + text
- **Entrance animations** — `flutter_animate` fadeIn + slideY staggered per section
- **Desktop responsive** — At ≥800px, content centers with max width constraint (420px)

### Persistence
- `OnboardingNotifier.save()` calls `SettingsNotifier.completeOnboarding()` which persists displayName, avatarPath, and `onboarded=true` to SQLite `app_settings` table
- GoRouter redirect guard in `app.dart`: unonboarded users are redirected to `/onboarding`, onboarded users are redirected away from `/onboarding` to `/`

### Navigation
- **On "Get Started" tap** → validates form → `save()` → `context.go(AppRoutes.discovery)`

---

## 2. Discovery / Radar Screen

| Key | Value |
|---|---|
| **File** | `lib/features/discovery/screens/discovery_screen.dart` |
| **Route** | `/discovery` (`AppRoutes.discovery`) |
| **Provider** | `discoveryNotifierProvider` |
| **State** | `AsyncValue<List<Device>>` |
| **Stitch Screen** | `f51b3e7b2aac455d87c56b51a6582942` |

### Description
Dark atmospheric radar screen that discovers nearby devices. Forces dark theme via `Theme(data: theme.copyWith(brightness: Brightness.dark))`. A constantly rotating radar sweep is painted behind positioned device bubbles.

### Key UI Elements
- **Frosted glass header** — `_FrostedHeader` with `BackdropFilter` blur, Blink logo (small SVG), QR scan + settings icon buttons
- **Radar rings** — `RadarPainter` (CustomPainter): 5 concentric rings with ambient radial glow, 24 particle dots that brighten near sweep, gradient sweep cone with trail, sweep line with tip glow, pulsing centre glow
- **Device bubbles** — `DeviceBubble` widgets positioned in a circle using angle math, glassmorphic with `BackdropFilter` (sigma 12)
- **Centre avatar** — `_CentreAvatar`: circular gradient avatar with user's initial, animated pulsing purple glow (`AnimationController`)
- **Bottom controls** — `_BottomControls`: `_StatusPill` showing "Scanning nearby..." with animated dot + `_SelectFilesButton` gradient pill with press animation
- **Desktop layout** — Row with radar (flex: 3) + `_DeviceListPanel` (320px sidebar) with `_DeviceListTile` items and hover states (`MouseRegion`)

### Sub-widgets
| Widget | File | Purpose |
|---|---|---|
| `DeviceBubble` | `lib/features/discovery/widgets/device_bubble.dart` | Glassmorphic discovered device with `BackdropFilter`, platform icon badge, press scale (0.92) |
| `RadarPainter` | `lib/features/discovery/widgets/radar_painter.dart` | 5-ring radar with ambient glow, 24 particle dots, sweep cone, pulsing centre. Accepts `pulseValue` + `deviceCount` |
| `_FrostedHeader` | inline in `discovery_screen.dart` | BackdropFilter frosted glass header with logo + action icons |
| `_CentreAvatar` | inline in `discovery_screen.dart` | Pulsing gradient avatar in radar centre |
| `_BottomControls` | inline in `discovery_screen.dart` | Status pill + select files button |
| `_DeviceListPanel` | inline in `discovery_screen.dart` | Desktop-only side panel (320px) listing devices with hover states |
| `_DeviceSelectionSheet` | inline in `discovery_screen.dart` | Bottom sheet for choosing which device to send to (shown when multiple devices nearby) |

### Transfer Flow (wired)
- **Select Files button** → `file_picker` (allowMultiple, FileType.any) → if 1 device, auto-send; if multiple, show `_DeviceSelectionSheet` → start transfer via `TransferNotifier.startSend()` → navigate to `/transfers`
- **Device bubble tap** → `file_picker` → start transfer to that device → navigate to `/transfers`
- **Device list tile tap** (desktop) → same as bubble tap
- Session key: random 256-bit key per transfer (replaced by QR-derived X25519 key in Phase 4.5)

### Navigation
- **QR icon** → `AppRoutes.qrScan`
- **QR show icon** → `AppRoutes.qrShow`
- **Device bubble tap** → file picker → transfer → `AppRoutes.transfers`
- **Select Files button** → file picker → device selection → transfer → `AppRoutes.transfers`

---

## 3. QR Show Screen

| Key | Value |
|---|---|
| **File** | `lib/features/pairing/screens/qr_show_screen.dart` |
| **Route** | `/qr-show` (`AppRoutes.qrShow`) |
| **Provider** | `pairingNotifierProvider` |
| **State** | `PairingState { qrString, lastPairing, error, isLoading }` |
| **Stitch Screen** | `010361a38b3544f99221564fdcd1c899` |

### Description
Displays the local device's pairing QR code for the remote device to scan. The QR code has a purple colour scheme with circular dot styling and a countdown timer showing the TTL.

### Key UI Elements
- **QR code** — `QrImageView` on dark surface card (`#1A1A2E`) with primary glow shadow, white QR with circular dark modules, 220×220 px
- **Countdown timer** — Circular progress indicator ring (accent → error color under 60s) with minutes:seconds in center, auto-regeneration on expiry
- **Regenerate button** — Subtle dark surface button with refresh icon, below the QR card
- **Encryption label** — Shield icon + "End-to-end encrypted" text with accent color
- **Gradient toggle pills** — `_PairingToggle`: "Show QR / Scan QR" gradient pills at bottom; active pill has primary gradient background, inactive has dark surface
- **Entrance animation** — `flutter_animate` fadeIn + slideY staggered

### Navigation
- **"Scan QR" toggle** → `context.pushReplacement(AppRoutes.qrScan)`
- **Back arrow** → `context.pop()`

---

## 4. QR Scan Screen

| Key | Value |
|---|---|
| **File** | `lib/features/pairing/screens/qr_scan_screen.dart` |
| **Route** | `/qr-scan` (`AppRoutes.qrScan`) |
| **Provider** | `pairingNotifierProvider` |
| **State** | `PairingState { qrString, lastPairing, error, isLoading }` |
| **Stitch Screen** | `bc1b72bd074a4bf196e53400da767396` |

### Description
Camera-based QR scanner for pairing with a remote device. Uses `MobileScanner` with a custom viewfinder overlay featuring cyan corner brackets and an animated scanning line. On scan, validates Ed25519 signature, derives X25519 ECDH session key, and shows success/failure feedback.

### Key UI Elements
- **Camera feed** — `MobileScanner` widget filling the screen, with 50% dark overlay
- **Viewfinder** — `_ViewfinderPainter` (CustomPainter): 4 accent-colored corner brackets with quadratic bezier rounded corners, 2.5px stroke width, 260×260 px
- **Scanning line** — `_ScanningLine`: animated horizontal gradient line (accent → transparent) that sweeps vertically inside viewfinder using `AnimationController` with 2s repeat + reverse; hidden when feedback overlay is shown
- **Feedback overlay** — `_ScanFeedback`: centered dark surface card (0.95 alpha) with success (green check) or failure (red X) icon, message text, bordered with success/error color. Success auto-pops after 1.2s, failure resets scanner after 2s
- **Torch toggle** — Circular button toggling flashlight on/off, accent-tinted when enabled
- **Encryption label** — Shield icon + "Offline encrypted exchange" text
- **Gradient toggle pills** — `_PairingToggle`: "Show QR / Scan QR" gradient pills matching QR Show screen style

### Behaviour
- On barcode detect → `handleScannedQr(code)` → validates Ed25519 signature → generates ephemeral X25519 keypair → derives session key via ECDH → returns `PairingResult`
- Success: shows green check overlay (1.2s) → `context.pop(result)` returning `PairingResult` to caller
- Failure: shows error overlay with friendly message (expired / invalid / already used) → resets scanner after 2s for retry
- One-shot scan (prevents duplicate processing via `_scanned` flag, reset on failure)

### Navigation
- **"Show QR" toggle** → `context.pushReplacement(AppRoutes.qrShow)`
- **Back arrow** → `context.pop()`

---

## 5. Send Screen

| Key | Value |
|---|---|
| **File** | `lib/features/transfer/screens/send_screen.dart` |
| **Route** | `/send` (`AppRoutes.send`) |
| **Provider** | `activeTransfersProvider` |
| **State** | `List<TransferSession>` (filtered to `direction == send`) |
| **Stitch Screen** | `deaab363a66443ae9ed469c76ee54647` |

### Description
Active outbound file transfers screen. Categorises transfers into In Progress, Queued, and Completed sections with polished transfer cards.

### Key UI Elements
- **Header** — "Transfers" title (28px, w800, -1 letter spacing) with active count badge (primary-tinted pill with spinner + "N active")
- **Section headers** — `_SectionHeader`: uppercase labels with primary-tinted count badges (rounded pill)
- **Transfer cards** — `TransferCard` widgets on dark surface with gradient direction icon containers, status chips, BLAKE3 verified badge for completed
- **Empty state** — Circular primary-tinted icon (swap arrows) with descriptive text, animated fadeIn
- **Encryption footer** — Lock icon + "Encrypted with XChaCha20-Poly1305" in subtle white (0.2 alpha)
- **Desktop centering** — `ConstrainedBox` maxWidth 600 for desktop layout

### Sub-widgets
| Widget | File | Purpose |
|---|---|---|
| `TransferCard` | `lib/features/transfer/widgets/transfer_card.dart` | Individual transfer session card with progress, status chip, actions |
| `TransferProgressBar` | `lib/features/transfer/widgets/progress_bar.dart` | Gradient animated progress bar with glow effect |

---

## 6. Receive Screen

| Key | Value |
|---|---|
| **File** | `lib/features/transfer/screens/receive_screen.dart` |
| **Route** | `/receive` (`AppRoutes.receive`) |
| **Provider** | `activeTransfersProvider` |
| **State** | `List<TransferSession>` (filtered to `direction == receive`) |
| **Stitch Screen** | `752074d96b414e74b8483b85954e0629` |

### Description
Incoming file transfers screen. Features incoming request cards with Accept/Decline actions, plus active receiving and completed sections. Accept/Decline are wired to `TransferManager.acceptTransfer()` / `declineTransfer()` via `ActiveTransfersNotifier`.

### Key UI Elements
- **Incoming request card** — `_IncomingRequestCard`: gradient background (accent 0.08 → primary 0.04), file info with file count + total size, "Accept" button (cyan gradient `#00D9FF → #00B8D9`) calls `acceptTransfer(sessionId)` → transitions to transferring, "Decline" button (error border outline) calls `declineTransfer(sessionId)` → cancels session + deletes received files. Shows for `TransferStatus.pending` sessions.
- **Active receiving** — Standard `TransferCard` widgets for `TransferStatus.transferring` sessions
- **Completed section** — Standard `TransferCard` with BLAKE3 verified badge
- **Empty state** — Circular accent-tinted download icon with descriptive text, animated fadeIn
- **Encryption footer** — Lock icon + "All transfers are end-to-end encrypted" in subtle white

---

## 7. Chat Screen

| Key | Value |
|---|---|
| **File** | `lib/features/chat/screens/chat_screen.dart` |
| **Route** | `/chat` (`AppRoutes.chat`) |
| **Provider** | `chatNotifierProvider` |
| **State** | `ChatState { sessionId, remoteIp, remotePort, messages }` |
| **Stitch Screen** | `f5ceeb07eb27409288c3ff3503ea54c9` |

### Description
iMessage-style device chat for sending quick messages alongside file transfers. Features gradient sent bubbles, grey received bubbles, and a pill-shaped input bar.

### Key UI Elements
- **Chat header** — `_ChatHeader`: device name title with "E2E Encrypted" badge (success color shield icon) in subtitle area
- **Chat bubbles** — `_ChatBubble`: sent = gradient (`primary → #8B7BFF`) with rounded corners (topLeft/topRight/bottomLeft: 18, bottomRight: 4), received = dark surface (`#1A1A2E`) with subtle border and mirrored radius. Each shows message text + time.
- **Time pill labels** — `_TimePill`: frosted pill with `BackdropFilter`, shown between message groups >5 min apart
- **Input bar** — `_InputBar`: dark surface container with rounded TextField, gradient circular send button (primary → accent, arrow-up icon), no attachment button in current version
- **Empty state** — Circular primary-tinted chat bubble icon with descriptive text, animated fadeIn

### Behaviour
- Auto-scrolls to bottom after sending via `WidgetsBinding.addPostFrameCallback`
- `sendMessage(text)` via `chatNotifierProvider.notifier` — persists to SQLite + sends over HTTP to paired device
- `openSession(sessionId, remoteIp, remotePort)` — binds chat to a transfer session for network messaging
- Incoming messages received via `HttpServerService.onChatMessage` stream, stored + displayed in real time
- Maintains focus on text field after send

---

## 8. Live Folders Screen

| Key | Value |
|---|---|
| **File** | `lib/features/live_folder/screens/live_folder_screen.dart` |
| **Route** | `/live-folders` (`AppRoutes.liveFolders`) |
| **Provider** | `liveFolderNotifierProvider` |
| **State** | `LiveFolderState { folders: List<WatchedFolder>, pairedDeviceId, pairedDeviceIp, pairedDevicePort }` |
| **Stitch Screen** | `31787a6643ad46b59daac2ec97cffeed` |

### Description
Auto-sync screen where users watch local folders for changes that automatically transfer to paired devices. Uses the `watcher` package under the hood for file system events.

### Key UI Elements
- **Info banner** — `_InfoBanner`: gradient background (primary 0.06 → accent 0.03) with info icon, explanation text, and subtle border
- **Folder cards** — `_FolderCard`: dark surface container with folder icon (primary gradient), folder name, sync status glow dots (green dot + "Watching" with success glow, or grey + "Paused"), coral remove button. `MouseRegion` hover states on desktop.
- **Gradient "Add Folder" button** — Full-width gradient button (`primary → #8B7BFF`) with plus icon, press animation (`AnimatedScale` 0.97), and primary glow shadow
- **Empty state** — Circular primary-tinted folder icon with descriptive text, info banner below
- **Staggered entrance** — `flutter_animate` fadeIn + slideY with staggered delays per card

### Behaviour
- `addFolder(path)` — opens `file_picker.getDirectoryPath()`, starts a `DirectoryWatcher` on the path
- `removeFolder(path)` — cancels the watcher subscription and removes from state
- `togglePause(path)` — pauses/resumes watching without removing the folder
- `setPairedDevice(deviceId, ip, port)` — binds a target device for auto-sync
- File changes debounced 2s, then queued and sent via `TransferManager.sendFiles()`
- Pending change count badge shown per folder card
- "No paired device" warning banner when no device is bound

---

## 9. Settings Screen

| Key | Value |
|---|---|
| **File** | `lib/features/settings/screens/settings_screen.dart` |
| **Route** | `/settings` (`AppRoutes.settings`) |
| **Provider** | `settingsNotifierProvider` |
| **State** | `AsyncValue<AppSettings> { displayName, avatarPath, bleEnabled, compressionEnabled, darkMode, onboarded }` |
| **Stitch Screen** | `e10e369e6f64495e84f113d51f62d9ab` |

### Description
iOS-style grouped settings screen with a profile card, toggle switches (CupertinoSwitch), and info tiles organised into labelled sections. State is `AsyncValue<AppSettings>` — shows loading spinner until settings load from SQLite.

### Key UI Elements
- **Profile card** — `_ProfileCard`: gradient background (primary 0.1 → accent 0.05) with primary border (0.15 alpha), circular avatar (gradient `primary → #8B7BFF` with glow shadow) showing user initial letter, display name, "Tap to edit display name" subtitle, chevron. Press animation (`AnimatedScale` 0.98).
- **Section groups** — `_buildSection()`: `SliverToBoxAdapter` with dark surface container (`#1A1A2E`), clipped with antiAlias, subtle border, dividers between children. 5 sections:
  - **GENERAL** — Dark Mode toggle
  - **TRANSFER** — LZ4 Compression toggle
  - **DISCOVERY** — BLE Discovery toggle
  - **SECURITY** — Encryption info (XChaCha20-Poly1305 · Ed25519), File Integrity info (BLAKE3) — both with success-colored icons
  - **ABOUT** — Version 0.1.0 with `_VersionBadge` ("Beta" pill in primary tint)
- **Toggle tiles** — `_ToggleTile`: 32px icon box with colored tint + title/subtitle + `CupertinoSwitch` with primary active track
- **Info tiles** — `_InfoTile`: 32px icon box with colored tint + title/subtitle + optional trailing widget
- **Rename bottom sheet** — `showModalBottomSheet` (not AlertDialog): dark surface container with rounded corners (20px), dark background text field, gradient "Save" button (`primary → #8B7BFF`), "Cancel" with subtle background
- **Footer** — Small logo SVG (20px, 0.12 alpha) + "Blink · Privacy First" text
- **Entrance animations** — `flutter_animate` fadeIn with staggered delays per section (100ms increments)
- **Desktop centering** — `ConstrainedBox` maxWidth 560

### Behaviour
- `setDarkMode(bool)`, `setCompressionEnabled(bool)`, `setBleEnabled(bool)`, `setDisplayName(String)` via settings notifier

---

## Shared Widgets

### TransferCard
| Key | Value |
|---|---|
| **File** | `lib/features/transfer/widgets/transfer_card.dart` |
| **Used by** | Send Screen, Receive Screen |

Dark surface card (`#1A1A2E`) showing a single `TransferSession`'s progress. Features:
- Direction icon (up/down arrow) in gradient container (primary → accent for send, accent → success for receive)
- Device name + file count + transferred/total size
- Status chips: gradient-tinted pills — primary for transferring (with spinner), success for completed (with check), warning for pending, error for failed
- Gradient progress bar (primary → `#8B7BFF` for send, accent → success for receive) with rounded track on dark hover background
- BLAKE3 verified badge on completion (success-tinted shield icon + "BLAKE3 Verified" text)
- `_formatBytes()` helper for human-readable size strings
- Entrance animation: `flutter_animate` fadeIn + slideY

### TransferProgressBar
| Key | Value |
|---|---|
| **File** | `lib/features/transfer/widgets/progress_bar.dart` |
| **Used by** | TransferCard |

Animated gradient linear progress bar with:
- Configurable height (default 6 px)
- Customisable gradient colours
- Glow shadow on the filled portion
- Full-radius rounded corners
- `AnimatedContainer` for smooth width transitions

### DeviceBubble
| Key | Value |
|---|---|
| **File** | `lib/features/discovery/widgets/device_bubble.dart` |
| **Used by** | Discovery Screen |

Glassmorphic discovered device indicator on the radar with:
- `BackdropFilter` with sigma 12 for glassmorphism effect
- Semi-transparent dark surface background (0.7 alpha) with subtle white border (0.08 alpha)
- Platform-specific icon badge (switch expression on `DevicePlatform` — phone, laptop, desktop, tablet) in a small 20px primary-tinted circle
- Device name label below with white 0.7 alpha text
- Press scale animation (`AnimatedScale` 0.92) via `GestureDetector` tap handlers
- 56px diameter circular container

### RadarPainter
| Key | Value |
|---|---|
| **File** | `lib/features/discovery/widgets/radar_painter.dart` |
| **Used by** | Discovery Screen |

`CustomPainter` rendering a premium 5-ring radar visualisation:
- Ambient radial glow (primary gradient) behind rings
- 5 concentric rings at 20%, 40%, 60%, 80%, 100% radius with decreasing white opacity
- 24 particle dots distributed across rings that brighten when near the sweep angle
- `ui.Gradient.sweep` for the cone/trail effect with 60° arc
- Gradient sweep line from centre to edge with accent tip glow
- Pulsing centre glow driven by `pulseValue` parameter
- Accepts `deviceCount` for future adaptive rendering
- Rotates via the `animationValue` parameter driven by `AnimationController`

---

## Design System Reference

| Token | Value |
|---|---|
| **Primary** | `#6C63FF` (Electric Violet) |
| **Primary Light** | `#8B7BFF` (gradient end for buttons/active) |
| **Accent** | `#00D9FF` (Cyan) |
| **Dark Background** | `#0D0D12` (True black OLED base) |
| **Dark Surface** | `#1A1A2E` (Cards, containers) |
| **Dark Hover** | `#2A2A3C` (Hover states) |
| **Dark Border** | `#35354A` (Subtle borders when needed) |
| **Success** | `#2ED47A` (Completed, verified) |
| **Warning** | `#FFBB33` (Pending, caution) |
| **Error** | `#FF6B6B` (Failed, decline) |
| **Info** | `#5B8DEF` (Informational) |
| **Font** | Inter (via `google_fonts`) |
| **Spacing grid** | 4 px base (`BlinkSpacing`) |
| **Animations** | `flutter_animate ^4.5.2` with declarative chains |
| **Interaction** | `GestureDetector` + `AnimatedScale` (no InkWell/splash) |
| **Glassmorphism** | `BackdropFilter` sigma 10–24 on nav, bubbles, headers |
| **No-Line Rule** | Hierarchy via background color shifts, not borders |

---

## Routing Reference

All routes defined in `lib/app.dart` → `AppRoutes`:

| Route | Path | Screen | Shell |
|---|---|---|---|
| `onboarding` | `/onboarding` | `OnboardingScreen` | Standalone (no nav) |
| `discovery` | `/` | `DiscoveryScreen` | `_MainShell` (bottom nav / sidebar) |
| `transfers` | `/transfers` | `SendScreen` | `_MainShell` |
| `chat` | `/chat` | `ChatScreen` | `_MainShell` |
| `liveFolder` | `/live-folder` | `LiveFolderScreen` | `_MainShell` |
| `settings` | `/settings` | `SettingsScreen` | `_MainShell` |
| `qrShow` | `/qr/show` | `QrShowScreen` | Standalone |
| `qrScan` | `/qr/scan` | `QrScanScreen` | Standalone |
| `send` | `/transfer/send` | `SendScreen` | Standalone |
| `receive` | `/transfer/receive` | `ReceiveScreen` | Standalone |

**GoRouter redirect guard:** If `settings.onboarded == false`, all routes redirect to `/onboarding`. If onboarded, `/onboarding` redirects to `/`.

---

## 10. Contact Groups Screen

| Key | Value |
|---|---|
| **File** | `lib/features/groups/screens/groups_screen.dart` |
| **Route** | `/groups` (`AppRoutes.groups`) |
| **Provider** | `groupsNotifierProvider` |
| **State** | `GroupsState { groups: List<ContactGroup>, isLoading }` |
| **Persistence** | SQLite via `GroupsRepository` (member_ids stored as JSON array) |

### Description
Manage device groups for quick multi-device 1-to-many sharing. Groups persist to SQLite. Midnight Obsidian redesign with dark surface cards, gradient group icons, bottom sheet dialogs. Members added from nearby discovered devices.

### Key UI Elements
- **Group card** — `_GroupCard`: dark surface with gradient group icon, name, member dot stack + count, send button (primary circle), more/delete button. Hover states on desktop.
- **Empty state** — Circular primary-tinted group icon, descriptive text, gradient "New Group" button
- **Create dialog** — Bottom sheet with dark input field, Cancel/Create buttons (gradient CTA)
- **Group details sheet** — Header with gradient icon + name + member count, MEMBERS list with online/offline status, remove button. ADD NEARBY DEVICES section populated from `discoveryNotifierProvider`.
- **Delete confirmation** — Bottom sheet with Cancel/Delete (error-tinted) buttons
- **New Group header button** — Gradient pill with plus icon, press scale animation

### Behaviour
- `createGroup(name)` — generates UUID, persists to SQLite, prepends to state
- `deleteGroup(groupId)` — removes from SQLite + state with confirmation dialog
- `addMember(groupId, deviceId)` / `removeMember(groupId, deviceId)` — SQLite + state sync
- `sendToGroup(groupId, filePaths, availableDevices)` — opens file_picker, iterates online group members, spawns parallel `TransferManager.sendFiles()` per device
- Group details sheet shows nearby non-member devices for quick add

---

## 11. Classroom Mode Screen

| Key | Value |
|---|---|
| **File** | `lib/features/classroom/screens/classroom_screen.dart` |
| **Route** | `/classroom` (`AppRoutes.classroom`) |
| **Provider** | `classroomNotifierProvider` |
| **State** | `ClassroomSession { isActive, connectedDevices, sessionCode }` |
| **Stitch Screen** | Generated March 2026 |

### Description
One-to-many broadcast mode for presentations, classes, or team file distribution.

### Key UI Elements
- **Broadcast status card** — Shows "BROADCASTING TO X devices", session code (e.g., BLINK-4827)
- **Connected devices row** — Avatar/icon stack with overflow indicator (+N)
- **Send to All button** — Gradient primary button for file broadcast
- **Stop Broadcasting button** — Coral red outline button to end session

### Navigation
- **File select** → Standard file picker
- **Stop** → Returns to Discovery screen

---

## 12. Desktop Discovery Screen

| Key | Value |
|---|---|
| **File** | `lib/features/discovery/screens/discovery_screen.dart` (adaptive) |
| **Route** | `/` (`AppRoutes.discovery`) |
| **Layout** | Sidebar rail + main content |
| **Stitch Screen** | Generated March 2026 (DESKTOP) |

### Description
Desktop variant with collapsible sidebar navigation. Shows radar visualization in the main content area.

### Key UI Elements
- **Sidebar rail** — 72px collapsed width, icons for Radar (active), Transfer, Chat, Folders, Settings
- **Main content** — Radar visualization, device bubbles, Select Files button
- **Top bar** — Blink title, QR and Settings action icons

---

## 13. Desktop Transfer Screen

| Key | Value |
|---|---|
| **File** | `lib/features/transfer/screens/transfer_screen.dart` (adaptive) |
| **Route** | `/transfer` (`AppRoutes.transfer`) |
| **Layout** | Sidebar rail + split panel |
| **Stitch Screen** | Generated March 2026 (DESKTOP) |

### Description
Desktop transfer management with split view for Send and Receive panels.

### Key UI Elements
- **Sidebar rail** — Transfer icon highlighted
- **Split view** — Left panel for Send transfers, Right panel for Receive transfers
- **Transfer cards** — Same as mobile with progress bars and status chips

---

## 14. Bottom Navigation Bar

| Key | Value |
|---|---|
| **File** | `lib/shared/widgets/blink_navigation.dart` (`BlinkBottomNav`) |
| **Type** | Component |

### Implementation
- **Frosted glass** — `BackdropFilter` with sigma 24, semi-transparent dark background (0.88 alpha)
- **Height** — 64px
- **Top border** — Subtle white border (0.06 alpha) for glass edge effect
- **All labels visible** — Both active and inactive items show labels (10px, medium weight)

### Tabs
1. **Discover** — Radar icon
2. **Transfer** — Swap vertical icon
3. **Chat** — Chat bubble icon
4. **Folders** — Folder icon
5. **Settings** — Settings icon

### States
- Active: White icon (0.9 alpha) + active dot indicator (4px purple circle with primary glow shadow)
- Inactive: White icon (0.4 alpha)
- No splash/ripple — uses `GestureDetector` for iOS feel

---

## 15. Empty States

| Key | Value |
|---|---|
| **File** | `lib/shared/widgets/empty_state.dart` |
| **Type** | Component |
| **Stitch Screen** | Generated March 2026 |

### Variants
1. **No Devices Found** — Radar icon with dashed circle, "No devices nearby"
2. **No Transfers** — Cloud with arrows, "No transfers yet"
3. **No Messages** — Chat bubble outline, "Start a conversation"
4. **No Folders** — Folder outline, "No folders synced"

---

## 16. Loading Skeletons

| Key | Value |
|---|---|
| **File** | `lib/shared/widgets/skeleton_loader.dart` |
| **Type** | Component |
| **Stitch Screen** | Generated March 2026 |

### Variants
- Transfer Card skeleton
- Device Bubble skeleton
- Chat Message skeleton
- Settings Tile skeleton

Uses shimmer animation with #252533 base and #3A3A4E highlight.

---

## 17. Transfer Card States

| Key | Value |
|---|---|
| **File** | `lib/features/transfer/widgets/transfer_card.dart` |
| **Type** | Component |
| **Stitch Screen** | Generated March 2026 |

### States
1. **Pending** — Amber status chip, waiting
2. **Transferring** — Progress bar, spinner, speed label
3. **Paused** — Amber chip, Resume button
4. **Completed** — Green check, BLAKE3 Verified badge
5. **Failed** — Red chip, Retry button, error message
6. **Cancelled** — Grey chip, dimmed card

---

## 18. Button Components

| Key | Value |
|---|---|
| **File** | `lib/shared/widgets/blink_button.dart` |
| **Type** | Component |
| **Stitch Screen** | Generated March 2026 |

### Variants
- **Primary** — Gradient pill button (default, hover, pressed, loading, disabled)
- **Secondary** — Outlined button
- **Text** — No background button
- **Icon** — Circular (filled, outlined, ghost)
- **FAB** — Floating action button
- **Destructive** — Coral red for delete/cancel

---

## 19. Input Components

| Key | Value |
|---|---|
| **File** | `lib/shared/widgets/blink_input.dart` |
| **Type** | Component |
| **Stitch Screen** | Generated March 2026 |

### Variants
- **Text Field** — Single line (empty, filled, focused, error, disabled)
- **Text Area** — Multi-line
- **Search Bar** — Pill with search icon and clear button
- **Toggle Switch** — Cupertino style (on purple, off grey)
- **Checkbox** — Unchecked, checked, indeterminate

---

## 20. Dialog Components

| Key | Value |
|---|---|
| **File** | `lib/shared/widgets/blink_dialog.dart` |
| **Type** | Component |
| **Stitch Screen** | Generated March 2026 |

### Variants
1. **Alert Dialog** — Icon, title, message, OK button
2. **Confirm Dialog** — Warning icon, title, message, Cancel/Confirm buttons
3. **Input Dialog** — Title, text field, Cancel/Save buttons
4. **Bottom Sheet** — Slide up with drag handle, options list
