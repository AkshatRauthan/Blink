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
| **State** | `AsyncValue<({String name, String? avatarPath})>` |
| **Stitch Screen** | `e7644885a1d64e8782c1801285c42e6a` |

### Description
First-launch screen where users set a display name and optional avatar. Designed with an iOS-inspired aesthetic featuring a pulsing logo glow, animated gradient background, and a staggered entrance animation sequence.

### Key UI Elements
- **Pulsing logo glow** — `AnimationController` driving a pulsing purple/accent glow behind the Blink icon
- **Avatar picker** — Circular avatar with camera overlay icon; taps trigger the `setAvatar()` notifier action
- **Name input** — Full-width `TextField` with underline styling and the Inter font
- **CTA button** — Full-width gradient pill button (`primary → accent`) that calls `save()` and navigates to discovery
- **Entrance animations** — `flutter_animate` fadeIn + slideY staggered per section using `BlinkDurations.standard`

### Navigation
- **On "Get Started" tap** → `context.go(AppRoutes.discovery)`

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
- **Radar rings** — `RadarPainter` (CustomPainter): 4 concentric rings with decreasing cyan opacity, a gradient sweep cone, and a centre glow
- **Device bubbles** — `DeviceBubble` widgets positioned in a circle around centre using angle math (auto-distributed by index)
- **Centre avatar** — Circular gradient avatar with the user's initial, surrounded by a pulsing purple glow
- **Select Files FAB** — Gradient floating action button (`primary → accent`) with shadow, positioned bottom-centre
- **AppBar actions** — QR scan icon (→ `AppRoutes.qrScan`) and settings gear (→ `AppRoutes.settings`)

### Sub-widgets
| Widget | File | Purpose |
|---|---|---|
| `DeviceBubble` | `lib/features/discovery/widgets/device_bubble.dart` | Displays a discovered device with platform icon, cyan glow, name label |
| `RadarPainter` | `lib/features/discovery/widgets/radar_painter.dart` | Paints radar rings, sweep cone, gradient sweep line, centre dot |

### Navigation
- **QR icon** → `AppRoutes.qrScan`
- **Settings gear** → `AppRoutes.settings`
- **Device bubble tap** → `AppRoutes.send` (for sending files to that device)
- **FAB** → File picker flow → `AppRoutes.send`

---

## 3. QR Show Screen

| Key | Value |
|---|---|
| **File** | `lib/features/pairing/screens/qr_show_screen.dart` |
| **Route** | `/qr-show` (`AppRoutes.qrShow`) |
| **Provider** | `pairingNotifierProvider` |
| **State** | `AsyncValue<String?>` (QR string or null) |
| **Stitch Screen** | `010361a38b3544f99221564fdcd1c899` |

### Description
Displays the local device's pairing QR code for the remote device to scan. The QR code has a purple colour scheme with circular dot styling and a countdown timer showing the TTL.

### Key UI Elements
- **QR code** — `QrImageView` with `QrEyeShape.circle`, `QrDataModuleShape.circle`, `BlinkColors.primary` colour, on white background, 240×240 px
- **Countdown timer** — `AnimationController`-driven circular progress indicator showing minutes:seconds remaining (5-minute TTL from `AppConstants.qrCodeTtl`), with auto-regeneration on expiry via `regenerate()`
- **Regenerate button** — Outlined pill button below the timer
- **Encryption label** — Lock icon + "End-to-end encrypted" text in accent colour
- **Segmented toggle** — "Show QR / Scan QR" pill toggle at the bottom; tapping "Scan QR" navigates via `pushReplacement` to `AppRoutes.qrScan`

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
| **State** | `AsyncValue<String?>` |
| **Stitch Screen** | `bc1b72bd074a4bf196e53400da767396` |

### Description
Camera-based QR scanner for pairing with a remote device. Uses `MobileScanner` with a custom viewfinder overlay featuring cyan corner brackets and an animated scanning line.

### Key UI Elements
- **Camera feed** — `MobileScanner` widget filling the screen, with dark overlay (55% opacity black)
- **Viewfinder** — `_ViewfinderPainter` (CustomPainter): 4 rounded corner brackets drawn with `BlinkColors.accent`, 260×260 px
- **Scanning line** — `_ScanningLine`: animated horizontal gradient line (accent colour) that sweeps vertically inside the viewfinder using `AnimationController` with repeat + reverse
- **Torch toggle** — Circular 48 px button toggling flashlight on/off
- **Encryption label** — Shield icon + "Offline encrypted exchange" text
- **Segmented toggle** — "Show QR / Scan QR" pill toggle; tapping "Show QR" → `pushReplacement` to `AppRoutes.qrShow`

### Behaviour
- On barcode detect → `handleScannedQr(code)` → `context.pop()`
- One-shot scan (prevents duplicate processing via `_scanned` flag)

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
- **Section headers** — Uppercase labels with count badges (e.g. "IN PROGRESS 2")
- **Transfer cards** — `TransferCard` widgets with direction icon, file count, size info, status chip (animated spinner for active), gradient progress bar, BLAKE3 verified badge for completed
- **Active count badge** — AppBar trailing badge showing number of actively transferring sessions
- **Empty state** — Cloud upload icon with instructional text
- **Encryption footer** — Lock icon + "Encrypted with XChaCha20-Poly1305"

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
Incoming file transfers screen. Features incoming request cards with Accept/Decline actions, plus active receiving and completed sections.

### Key UI Elements
- **Incoming request card** — `_IncomingRequestCard`: gradient-bordered card with file info, "Accept" (filled accent) and "Decline" (outlined coral) buttons. Shows for `TransferStatus.pending` sessions.
- **Active receiving** — Standard `TransferCard` widgets for `TransferStatus.transferring` sessions
- **Completed section** — Standard `TransferCard` with BLAKE3 verified badge
- **Empty state** — Circular accent-tinted cloud download icon with descriptive text
- **Encryption footer** — "All transfers are end-to-end encrypted"

---

## 7. Chat Screen

| Key | Value |
|---|---|
| **File** | `lib/features/chat/screens/chat_screen.dart` |
| **Route** | `/chat` (`AppRoutes.chat`) |
| **Provider** | `chatNotifierProvider` |
| **State** | `List<ChatMessage>` |
| **Stitch Screen** | `f5ceeb07eb27409288c3ff3503ea54c9` |

### Description
iMessage-style device chat for sending quick messages alongside file transfers. Features gradient sent bubbles, grey received bubbles, and a pill-shaped input bar.

### Key UI Elements
- **Chat bubbles** — `_ChatBubble`: sent = purple gradient (`primary → #8B80FF`), received = grey surface container. Rounded corners with iOS-style asymmetric bottom corners (smaller on sender's side). Each bubble shows the message text + timestamp.
- **Time labels** — `_TimeLabel`: shown between messages that are >5 minutes apart, formatted as "HH:MM AM/PM"
- **Input bar** — Row with circular "+" attachment button (primary tint), pill-shaped text field, and gradient circular send button (primary → accent, arrow-up icon)
- **AppBar subtitle** — "End-to-end encrypted" in mint green
- **Empty state** — Chat bubble outline icon with instructional text, animated fade-in

### Behaviour
- Auto-scrolls to bottom after sending via `WidgetsBinding.addPostFrameCallback`
- `sendMessage(text)` via `chatNotifierProvider.notifier`
- Maintains focus on text field after send

---

## 8. Live Folders Screen

| Key | Value |
|---|---|
| **File** | `lib/features/live_folder/screens/live_folder_screen.dart` |
| **Route** | `/live-folders` (`AppRoutes.liveFolders`) |
| **Provider** | `liveFolderNotifierProvider` |
| **State** | `LiveFolderState { syncedFolders: List<String> }` |
| **Stitch Screen** | `31787a6643ad46b59daac2ec97cffeed` |

### Description
Auto-sync screen where users watch local folders for changes that automatically transfer to paired devices. Uses the `watcher` package under the hood for file system events.

### Key UI Elements
- **Info card** — Gradient-bordered explanation card with info icon: "Live Folders auto-sync file changes to your paired device whenever modifications are detected."
- **Folder cards** — `_FolderCard`: surface container with folder icon (primary), folder name (from `path.basename`), sync status indicator (green dot + "Watching" or grey + "Paused"), and a coral remove button
- **Gradient FAB** — "Add Folder" button with `primary → accent` gradient and shadow
- **Empty state** — Circular folder icon + description + info card, animated fade-in
- **Staggered entrance** — Folder cards animate in with staggered delays (50ms × index)

### Behaviour
- `addFolder(path)` — starts a `DirectoryWatcher` on the path
- `removeFolder(path)` — cancels the watcher subscription and removes from state

---

## 9. Settings Screen

| Key | Value |
|---|---|
| **File** | `lib/features/settings/screens/settings_screen.dart` |
| **Route** | `/settings` (`AppRoutes.settings`) |
| **Provider** | `settingsNotifierProvider` |
| **State** | `AppSettings { displayName, bleEnabled, compressionEnabled, darkMode }` |
| **Stitch Screen** | `e10e369e6f64495e84f113d51f62d9ab` |

### Description
iOS-style grouped settings screen with a profile card, toggle switches (CupertinoSwitch), and info tiles organised into labelled sections.

### Key UI Elements
- **Profile card** — Gradient-bordered card with circular avatar (initial letter, primary → accent gradient), display name, "Tap to edit" subtitle. Tap opens a rename dialog.
- **Section groups** — `_SettingsGroup`: rounded surface container with dividers between children, 5 sections:
  - **General** — Dark Mode toggle
  - **Transfer** — LZ4 Compression toggle
  - **Discovery** — BLE Discovery toggle
  - **Security** — Encryption info (XChaCha20-Poly1305 · Ed25519), File Integrity info (BLAKE3)
  - **About** — Version 0.1.0 (tap opens `showAboutDialog`)
- **Toggle tiles** — `_ToggleTile`: coloured icon box + title/subtitle + `CupertinoSwitch` with primary active track
- **Info tiles** — `_InfoTile`: coloured icon box + title/subtitle + optional chevron for tappable items
- **Rename dialog** — `AlertDialog` with rounded shape, text field, Cancel/Save actions

### Behaviour
- `setDarkMode(bool)`, `setCompressionEnabled(bool)`, `setBleEnabled(bool)`, `setDisplayName(String)` via settings notifier

---

## Shared Widgets

### TransferCard
| Key | Value |
|---|---|
| **File** | `lib/features/transfer/widgets/transfer_card.dart` |
| **Used by** | Send Screen, Receive Screen |

Polished card showing a single `TransferSession`'s progress. Features:
- Direction icon (up/down arrow) in coloured container
- File count + transferred/total size
- Animated status chip with spinner (transferring), check icon (completed), or coloured label
- Gradient progress bar (primary→accent for send, accent→mint for receive)
- Percentage label + pause icon (active) or BLAKE3 verified badge (completed)
- `_formatBytes()` helper for human-readable size strings
- Entrance animation: fadeIn + slideY

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

Discovered device indicator on the radar with:
- Cyan glow effect via `BoxShadow`
- Platform-specific icon (switch expression on `DevicePlatform` — phone, laptop, desktop, tablet)
- Dark surface styling for radar context
- Device name label below

### RadarPainter
| Key | Value |
|---|---|
| **File** | `lib/features/discovery/widgets/radar_painter.dart` |
| **Used by** | Discovery Screen |

`CustomPainter` rendering the radar visualisation:
- 4 concentric rings at 25%, 50%, 75%, 100% radius with decreasing cyan opacity
- `ui.Gradient.sweep` for the cone/sweep effect
- Gradient sweep line from centre to edge
- Pulsing centre dot glow
- Rotates via the `angle` parameter driven by `AnimationController`

---

## Design System Reference

| Token | Value |
|---|---|
| **Primary** | `#6C63FF` (Indigo-violet) |
| **Accent** | `#00D9FF` (Electric cyan) |
| **Coral** | `#FF6B6B` |
| **Mint** | `#2ED47A` |
| **Amber** | `#FFBB33` |
| **Font** | Inter (via `google_fonts`) |
| **Spacing grid** | 4 px base (`BlinkSpacing`) |
| **Radius** | `xs:4, sm:8, md:12, lg:16, xl:24, xxl:32, full:999` |
| **Durations** | `instant:100ms, quick:200ms, standard:350ms, emphasis:500ms, slow:700ms` |
| **Curves** | `standard:easeOutCubic, enter:easeOutBack, spring:elasticOut, overshoot:custom` |
| **Animations** | `flutter_animate ^4.5.2` with `BlinkEffects` presets |

---

## Routing Reference

All routes defined in `lib/app.dart` → `AppRoutes`:

| Route | Path | Screen |
|---|---|---|
| `onboarding` | `/onboarding` | `OnboardingScreen` |
| `discovery` | `/discovery` | `DiscoveryScreen` |
| `qrShow` | `/qr-show` | `QrShowScreen` |
| `qrScan` | `/qr-scan` | `QrScanScreen` |
| `send` | `/send` | `SendScreen` |
| `receive` | `/receive` | `ReceiveScreen` |
| `chat` | `/chat` | `ChatScreen` |
| `liveFolders` | `/live-folders` | `LiveFolderScreen` |
| `settings` | `/settings` | `SettingsScreen` |

---

## 10. Contact Groups Screen

| Key | Value |
|---|---|
| **File** | `lib/features/groups/screens/groups_screen.dart` |
| **Route** | `/groups` (`AppRoutes.groups`) |
| **Provider** | `groupsNotifierProvider` |
| **State** | `List<ContactGroup>` |
| **Stitch Screen** | Generated March 2026 |

### Description
Manage device groups for quick multi-device sharing. Groups persist across sessions and allow one-tap sharing to multiple devices.

### Key UI Elements
- **Groups list** — Grid or list layout of saved groups
- **Group card** — Shows avatar stack of member devices, group name, member count, chevron for navigation
- **Empty state** — Folder icon with "Create your first group" message
- **FAB** — Gradient purple-cyan "New Group" button

### Navigation
- **Group card tap** → Group detail view
- **FAB tap** → Create group flow

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
| **File** | `lib/shared/widgets/bottom_nav_bar.dart` |
| **Type** | Component |
| **Stitch Screen** | Generated March 2026 |

### Tabs
1. **Discovery** — Radar icon, active state purple filled
2. **Transfer** — Up/down arrows icon
3. **Chat** — Chat bubble icon with optional badge
4. **Folders** — Folder icon
5. **Settings** — Gear icon

### States
- Active: Purple #6C63FF filled icon with subtle glow
- Inactive: Grey #9CA3AF outline icon
- Badge: Coral dot for unread notifications

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
