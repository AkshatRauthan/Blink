# Blink — Assets Documentation

> SVG Icons, Lottie Animations, and Visual Assets Inventory

**Status**: ✅ Complete (51 SVG icons created)

---

## 1. SVG Icons

All icons designed at 24x24px base size, single-color (uses `currentColor` for theming), with consistent 2px stroke width.

### 1.1 Platform Device Icons (3 icons)
Location: `assets/svg/devices/`

| Icon | File | Description |
|------|------|-------------|
| Android Phone | `android_phone.svg` | Smartphone with home button |
| Windows Laptop | `windows_laptop.svg` | Laptop with Windows logo hint |
| Linux Laptop | `linux_laptop.svg` | Laptop with circle (Tux hint) |

### 1.2 Navigation Icons (9 icons)
Location: `assets/svg/nav/`

| Icon | File | Description |
|------|------|-------------|
| Radar | `radar.svg` | Concentric radar waves |
| Radar Filled | `radar_filled.svg` | Filled radar for active state |
| Transfer | `transfer.svg` | Up/down arrows |
| Chat | `chat.svg` | Speech bubble outline |
| Chat Filled | `chat_filled.svg` | Filled speech bubble |
| Folder Sync | `folder_sync.svg` | Folder with sync arrows |
| Settings | `settings.svg` | Gear cog |
| Groups | `groups.svg` | Multiple people |
| Classroom | `classroom.svg` | Broadcast antenna |

### 1.3 Action Icons (10 icons)
Location: `assets/svg/actions/`

| Icon | File | Description |
|------|------|-------------|
| Add | `add.svg` | Plus sign |
| Close | `close.svg` | X mark |
| Check | `check.svg` | Checkmark |
| Send | `send.svg` | Arrow pointing up |
| Receive | `receive.svg` | Arrow pointing down |
| Pause | `pause.svg` | Two vertical bars |
| Resume | `resume.svg` | Play triangle |
| Retry | `retry.svg` | Circular refresh |
| Delete | `delete.svg` | Trash can |
| Edit | `edit.svg` | Pencil |

### 1.4 Status Icons (7 icons)
Location: `assets/svg/status/`

| Icon | File | Description |
|------|------|-------------|
| Verified | `verified.svg` | Shield with checkmark |
| Encrypted | `encrypted.svg` | Lock icon |
| WiFi | `wifi.svg` | Wireless signal |
| Success | `success.svg` | Circle checkmark |
| Error | `error.svg` | Circle X |
| Warning | `warning.svg` | Triangle alert |
| Info | `info.svg` | Circle i |

### 1.5 QR/Camera Icons (5 icons)
Location: `assets/svg/qr/`

| Icon | File | Description |
|------|------|-------------|
| QR Code | `qr_code.svg` | QR code pattern |
| Scan | `scan.svg` | Viewfinder corners |
| Camera | `camera.svg` | Camera with lens |
| Flash On | `flash_on.svg` | Lightning bolt |
| Flash Off | `flash_off.svg` | Lightning with slash |

### 1.6 File Type Icons (7 icons)
Location: `assets/svg/files/`

| Icon | File | Description |
|------|------|-------------|
| File Generic | `file_generic.svg` | Basic document |
| File Image | `file_image.svg` | Image file with mountains |
| File Video | `file_video.svg` | Video with play button |
| File Audio | `file_audio.svg` | Audio with note |
| File Archive | `file_archive.svg` | ZIP with stripes |
| Folder | `folder.svg` | Basic folder |
| Folder Sync | `folder_sync.svg` | Folder with arrows |

### 1.7 UI Chrome Icons (10 icons)
Location: `assets/svg/ui/`

| Icon | File | Description |
|------|------|-------------|
| Arrow Back | `arrow_back.svg` | Left arrow |
| Chevron Right | `chevron_right.svg` | Right chevron |
| More Vert | `more_vert.svg` | Three vertical dots |
| Search | `search.svg` | Magnifying glass |
| Menu | `menu.svg` | Hamburger menu |
| Expand | `expand.svg` | Corners expanding |
| Collapse | `collapse.svg` | Corners collapsing |
| Copy | `copy.svg` | Overlapping rectangles |
| Share | `share.svg` | Share network |
| Filter | `filter.svg` | Funnel |

---

## 2. Lottie Animations

All Lottie files should be optimized for mobile, under 100KB each, and loop seamlessly where applicable.

### 2.1 Essential Animations (5 Required)

| Animation | File | Duration | Loop | Usage |
|-----------|------|----------|------|-------|
| `loading.json` | `assets/lottie/` | 1.5s | Yes | Global loading spinner, progress states |
| `success.json` | `assets/lottie/` | 2s | No | Transfer complete, setup complete, verification passed |
| `error.json` | `assets/lottie/` | 1.5s | No | Transfer failed, connection error, verification failed |
| `empty_radar.json` | `assets/lottie/` | 3s | Yes | No devices found, scanning state |
| `scanning.json` | `assets/lottie/` | 2s | Yes | Discovery in progress, QR scanning |

### 2.2 Animation Specifications

#### `loading.json`
- Style: Circular spinner with gradient
- Colors: Primary purple (#6C63FF) to cyan (#00D9FF) gradient
- Motion: Smooth rotation, possibly with pulsing dots
- Size: 48x48 default, scalable

#### `success.json`
- Style: Checkmark drawing animation with burst/confetti
- Colors: Mint green (#2ED47A) for check, subtle purple accents
- Motion: Circle draws, then check marks, small particle burst
- Timing: 0.5s circle, 0.5s check, 1s particles

#### `error.json`
- Style: X mark with shake/bounce
- Colors: Coral red (#FF6B6B) for X
- Motion: Circle appears, X draws with slight shake
- Timing: Clean and quick to not frustrate users

#### `empty_radar.json`
- Style: Radar sweep with no devices
- Colors: Cyan (#00D9FF) for rings, dimmed
- Motion: Continuous sweep, pulsing center
- Atmosphere: Calm, searching, "keep waiting"

#### `scanning.json`
- Style: Pulsing concentric circles or radar wave
- Colors: Cyan to purple gradient
- Motion: Waves expanding from center
- Use: Discovery screen, QR scan active state

### 2.3 Nice-to-Have Animations (Future)

| Animation | Description |
|-----------|-------------|
| `transfer_progress.json` | Animated file icon moving between devices |
| `pairing_success.json` | Two devices connecting with beam |
| `encryption.json` | Lock animation for secure transfer start |
| `folder_sync.json` | Folder with rotating arrows |
| `celebration.json` | First transfer complete celebration |

---

## 3. Asset Organization

```
assets/
├── svg/
│   ├── devices/
│   │   ├── android_phone.svg
│   │   ├── android_tablet.svg
│   │   ├── windows_laptop.svg
│   │   ├── windows_desktop.svg
│   │   ├── linux_laptop.svg
│   │   └── linux_desktop.svg
│   ├── nav/
│   │   ├── radar.svg
│   │   ├── transfer.svg
│   │   ├── chat.svg
│   │   ├── folder_sync.svg
│   │   ├── settings.svg
│   │   ├── groups.svg
│   │   └── classroom.svg
│   ├── actions/
│   │   └── ... (13 icons)
│   ├── status/
│   │   └── ... (12 icons)
│   ├── qr/
│   │   └── ... (5 icons)
│   ├── ui/
│   │   └── ... (10 icons)
│   └── files/
│       └── ... (8 icons)
├── lottie/
│   ├── loading.json
│   ├── success.json
│   ├── error.json
│   ├── empty_radar.json
│   └── scanning.json
└── images/
    └── (app icon, splash, etc.)
```

---

## 4. Icon Design Guidelines

### Color Usage
- Icons use `currentColor` for easy theming
- Active state: Primary purple (#6C63FF)
- Inactive state: Grey (#9CA3AF)
- Error state: Coral (#FF6B6B)
- Success state: Mint (#2ED47A)
- Warning state: Amber (#FFBB33)

### Stroke & Fill
- Outline icons: 2px stroke, rounded caps and joins
- Filled icons: Used for active/selected states
- Consistent padding: 2px margin within 24x24 viewBox

### Accessibility
- All icons should have semantic meaning conveyed via labels
- Touch targets: Minimum 44x44px tap area for interactive icons
- Sufficient contrast against dark backgrounds

---

## 5. Implementation Notes

### Flutter SVG Loading
```dart
// Use flutter_svg package
SvgPicture.asset(
  'assets/svg/nav/radar.svg',
  colorFilter: ColorFilter.mode(
    BlinkColors.primary,
    BlendMode.srcIn,
  ),
  width: 24,
  height: 24,
);
```

### Lottie Loading
```dart
// Use lottie package
Lottie.asset(
  'assets/lottie/success.json',
  width: 120,
  height: 120,
  repeat: false,
  onLoaded: (composition) {
    // Animation loaded
  },
);
```

---

## 6. Asset Checklist

### SVG Icons (Total: 56)
- [ ] Platform Device Icons (6)
- [ ] Navigation Icons (7 × 2 states = 14)
- [ ] Action Icons (13)
- [ ] Status Icons (12)
- [ ] QR Icons (5)
- [ ] UI Chrome Icons (10)
- [ ] File Type Icons (8)

### Lottie Animations (Total: 5 essential)
- [ ] loading.json
- [ ] success.json
- [ ] error.json
- [ ] empty_radar.json
- [ ] scanning.json

