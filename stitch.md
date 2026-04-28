# Blink — Complete UI/UX Redesign Brief for Google Stitch

## What Is Blink?

Blink is a **privacy-first, cross-platform offline file sharing app** — an AirDrop alternative for Android, Linux, and Windows. Zero accounts, zero cloud, zero internet required. Files transfer over the local network using military-grade encryption (XChaCha20-Poly1305) with BLAKE3 integrity verification. Devices discover each other via mDNS and Bluetooth LE, pair via QR code handshake (Ed25519 + X25519 ECDH), and stream encrypted files at LAN speed.

**Target Users:** Power users, students in classrooms, professionals in offices, privacy-conscious individuals, anyone who wants fast local file sharing without cloud dependencies.

**Platforms:** Android (phone + tablet), Linux desktop, Windows desktop. Must feel native on each.

---

## Design Philosophy

### Brand Identity: "Midnight Obsidian"

A premium, editorial dark-first aesthetic. Think: the love child of **Apple's SF design language**, **Linear's interface density**, and **Arc browser's playful sophistication**. The UI should feel like holding a polished obsidian stone — deep, reflective, tactile.

**Mood Keywords:** Sleek. Cinematic. Confident. Premium. Fast. Minimal. Glassy. Futuristic but grounded.

### Core Principles

1. **Dark-first, light as a companion** — OLED-optimized true black base. Light mode exists but dark is the star.
2. **No-Line Rule** — Never use borders/dividers for visual hierarchy. Use background color shifts, elevation, and subtle shadows instead. Surfaces float on darkness.
3. **Motion as meaning** — Every animation communicates state. Nothing moves without purpose. Entrance animations are staggered, exits are swift.
4. **Glassmorphism with restraint** — Frosted glass on navigation and floating elements only. Not everywhere. Blur is expensive; use it where it creates depth.
5. **Touch-first, cursor-aware** — Large touch targets (44px minimum), but add hover states, cursor changes, and keyboard shortcuts for desktop.
6. **Information density without clutter** — Show what matters. Hide what doesn't. Progressive disclosure everywhere.

---

## Color System

### Brand Colors
| Token | Hex | Usage |
|-------|-----|-------|
| **Primary** | `#6C63FF` | Electric Violet — buttons, FABs, active nav, selection rings |
| **Primary Hover** | `#7C74FF` | Hover/focus state |
| **Primary Pressed** | `#5A52E0` | Tap/click feedback |
| **Primary Light** | `#9D97FF` | Gradient endpoints, subtle tints |
| **Primary Muted** | `#6C63FF` at 20% | Background washes, card tints |
| **Accent** | `#00D9FF` | Cyan — radar sweep, progress bars, highlights, links |
| **Accent Muted** | `#00D9FF` at 20% | Glow halos, background indicators |

### Gradient Presets
| Name | Stops | Usage |
|------|-------|-------|
| **Radar** | Primary → Accent | Radar sweep cone, hero illustrations |
| **Button** | Primary → Primary Light | CTA buttons, gradient badges |
| **Progress** | Primary → Accent | Progress bars, loading indicators |
| **Card Glow** | Primary at 30% → transparent | Selected card aura |

### Dark Mode Surfaces (Primary Theme)
| Token | Hex | Usage |
|-------|-----|-------|
| **Base** | `#000000` | OLED base, behind everything |
| **Background** | `#0D0D12` | App scaffold, page backgrounds |
| **Surface** | `#1A1A2E` | Cards, containers, input fields |
| **Elevated** | `#2A2A3C` | Modals, dropdowns, popovers, bottom sheets |
| **Hover** | `#35354A` | Desktop hover state overlay |

### Light Mode Surfaces
| Token | Hex | Usage |
|-------|-----|-------|
| **Background** | `#F8F9FC` | Page backgrounds |
| **Surface** | `#FFFFFF` | Cards, containers |
| **Surface Variant** | `#F0F1F5` | Nested surfaces, grouped sections |
| **Elevated** | `#FFFFFF` | Modals with shadow |
| **Hover** | `#E8E9EE` | Desktop hover |

### Semantic Colors
| Token | Hex | Usage |
|-------|-----|-------|
| **Success** | `#4ADE80` | Transfer complete, device online, verified |
| **Warning** | `#FBBF24` | Queued, paused, expiring soon |
| **Error** | `#F87171` | Failed, offline, expired, declined |
| **Info** | `#60A5FA` | Informational badges, tips |

### Text Colors
| Context | Dark Mode | Light Mode |
|---------|-----------|------------|
| **Primary** | `#FFFFFF` | `#0D0D12` |
| **Secondary** | `#A0A0B0` | `#6B7280` |
| **Tertiary** | `#666680` | `#A0A5B5` |
| **On Primary** (text on colored bg) | `#FFFFFF` | `#FFFFFF` |

---

## Typography

**Font Family:** Inter (Google Fonts) — clean, editorial, excellent at small sizes.

| Style | Size | Weight | Letter Spacing | Line Height | Usage |
|-------|------|--------|----------------|-------------|-------|
| Display L | 48px | Bold | -1.5px | 1.1 | Hero numbers, splash title |
| Display M | 36px | Bold | -1.0px | 1.15 | Section heroes |
| Display S | 28px | Bold | -0.5px | 1.2 | Large headings |
| Headline L | 24px | SemiBold | -0.3px | 1.25 | Screen titles |
| Headline M | 20px | SemiBold | -0.2px | 1.3 | Section titles |
| Headline S | 18px | SemiBold | -0.1px | 1.3 | Card titles |
| Title L | 17px | Medium | 0 | 1.35 | List item titles |
| Title M | 15px | Medium | 0 | 1.35 | Secondary titles |
| Title S | 13px | Medium | 0.1px | 1.4 | Tertiary titles |
| Body L | 16px | Regular | 0 | 1.5 | Paragraphs, descriptions |
| Body M | 14px | Regular | 0 | 1.5 | Default body text |
| Body S | 12px | Regular | 0.1px | 1.4 | Captions, metadata |
| Label L | 14px | Medium | 0.1px | 1.2 | Buttons, nav labels |
| Label M | 12px | Medium | 0.2px | 1.2 | Chips, badges, tags |
| Label S | 10px | Medium | 0.3px | 1.2 | Micro badges, counters |

**Note:** Negative letter-spacing on headlines creates a tighter, more premium feel. Body text uses neutral or slightly positive spacing for readability.

---

## Spacing & Layout

### Base Grid: 4px

| Token | Value | Usage |
|-------|-------|-------|
| xxs | 2px | Hairline gaps |
| xs | 4px | Icon-to-text, inline padding |
| sm | 8px | Tight padding, chip internal |
| md | 16px | Standard padding, card internal |
| lg | 24px | Section gaps, card margins |
| xl | 32px | Large section breaks |
| xxl | 48px | Page-level vertical rhythm |
| xxxl | 64px | Hero spacing |

### Component Heights
| Component | Height |
|-----------|--------|
| Touch target (minimum) | 44px |
| Button (standard) | 48px |
| Button (compact) | 40px |
| Input field | 48px (mobile), 44px (desktop) |
| App bar | 56px |
| Bottom navigation | 64px + safe area |
| Sidebar collapsed | 72px wide |
| Sidebar expanded | 240px wide |

### Avatar Sizes
| Name | Diameter | Usage |
|------|----------|-------|
| XS | 32px | Inline mentions, compact lists |
| SM | 40px | List items, chat messages |
| MD | 56px | Device bubbles, group members |
| LG | 80px | Profile cards, device details |
| XL | 120px | Onboarding, full profile |

### Border Radius
| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Micro badges |
| sm | 6px | Chips, small tags |
| md | 12px | Buttons, inputs, standard cards |
| lg | 16px | Large cards, containers |
| xl | 24px | Bottom sheets, modals |
| full | 9999px | Pills, circles, rounded buttons |

### Content Max Widths
| Breakpoint | Max Width |
|------------|-----------|
| Mobile | 600px |
| Tablet | 720px |
| Desktop | 1200px |
| Dialog | 400px |

### Responsive Breakpoints
| Range | Layout |
|-------|--------|
| < 800px | **Mobile**: Bottom navigation, full-width content, stacked layouts |
| >= 800px | **Desktop**: Sidebar navigation, constrained content with max-width, split panes where appropriate |

---

## Elevation & Shadows

No visible borders. Depth is communicated through background color shifts and soft shadows.

| Level | Blur | Y Offset | Usage |
|-------|------|----------|-------|
| 0 | 0 | 0 | Flat surfaces, inline elements |
| 1 | 8px | 2px | Cards, containers, list items |
| 2 | 16px | 4px | Dropdowns, popovers, tooltips |
| 3 | 32px | 8px | Modals, dialogs, bottom sheets |
| 4 | 48px | 16px | Full-screen overlays |

**Shadow color:** `#000000` at 20-40% opacity (dark mode), `#0D0D12` at 8-15% opacity (light mode).

### Glow Effects
| Type | Blur | Color | Usage |
|------|------|-------|-------|
| Primary glow | 20px | Primary at 30% | Selected cards, active elements |
| Accent glow | 20px | Accent at 30% | Radar center, progress complete |
| Success glow | 20px | Success at 30% | Transfer complete indicator |
| Error glow | 20px | Error at 30% | Failed state indicator |

---

## Motion & Animation

### Duration Tokens
| Token | Duration | Usage |
|-------|----------|-------|
| Instant | 100ms | Micro-interactions (color change, opacity toggle) |
| Quick | 200ms | Button press, ripple alternative, toggle |
| Standard | 350ms | Page cross-fade, card expand/collapse |
| Emphasis | 500ms | Modal appear, bottom sheet slide, radar entrance |
| Slow | 700ms | Onboarding hero, splash fade, ambient loops |
| Stagger | 50ms | Delay between sequential list items |

### Easing Curves
| Name | Curve | Usage |
|------|-------|-------|
| Standard | easeOutCubic | Default for most transitions |
| Enter | easeOutBack | Element entering the screen (slight overshoot) |
| Exit | easeInCubic | Element leaving the screen |
| Spring | elasticOut | Playful micro-interactions (toggle, badge pop) |
| Overshoot | cubic-bezier(0.34, 1.56, 0.64, 1.0) | Bouncy settle (success states) |

### Animation Patterns
| Pattern | Properties | Usage |
|---------|------------|-------|
| **Fade + Slide Up** | opacity 0→1, translateY 24→0 | Default entrance for cards, sections |
| **Fade + Slide Right** | opacity 0→1, translateX -12→0 | Sidebar items, horizontal lists |
| **Scale In** | scale 0.9→1.0, opacity 0→1 | Modals, dialogs, popovers |
| **Blur In** | blur 8→0, opacity 0→1 | Hero elements, splash screen |
| **Shimmer Loop** | infinite horizontal gradient sweep | Skeleton loading placeholders |
| **Pulse** | scale 1.0→1.08→1.0, loop | Active indicators, "searching" state |
| **Stagger** | Each item delayed by index * 50ms | Lists, grids, sequential reveals |

### Page Transitions
- iOS-style Cupertino slide transitions on all platforms
- No Material ink splash effects anywhere — custom scale/opacity feedback only

---

## Component Library

Design every component below. Each component should have: default, hover, pressed, focused, disabled, and loading states where applicable.

### 1. BlinkButton
- **Variants:** Primary (gradient fill), Secondary (outline), Ghost (text only), Danger (red)
- **Sizes:** Small (40px), Medium (48px), Large (56px)
- **States:** Default, Hover (glow aura), Pressed (scale 0.98 + darken), Disabled (40% opacity), Loading (spinner replaces text)
- **Features:** Leading/trailing icon support, full-width expansion option
- **Interaction:** Scale down to 0.98 on press (not Material ripple)
- **Icon Button variant:** Circular, 44px touch target, optional tooltip on hover

### 2. BlinkCard
- **Elevation levels:** 0 (flat), 1 (default), 2 (raised), 3 (modal), 4 (overlay)
- **Interactive cards:** Hover brightens background + increases shadow. Press scales to 0.98.
- **Selection state:** Primary color glow border + subtle background tint
- **No borders by default** — use background color shift between card and parent

### 3. BlinkInput
- **Text field with:** Label (above), placeholder, helper text (below), error text (below, red)
- **Features:** Prefix/suffix icons, password toggle, character counter, clear button
- **Focus state:** Primary color underline/border, prefix icon tints to primary
- **Error state:** Error color border, error icon, error text
- **Search variant:** Rounded pill shape, search icon, clear on X

### 4. BlinkAvatar
- **Sizes:** XS (32), SM (40), MD (56), LG (80), XL (120)
- **Content priority:** Image > Initials > Icon fallback
- **Online indicator:** Small green dot at bottom-right (success color)
- **Selection ring:** Primary color border with glow
- **Stack variant:** Overlapping avatars with "+N" overflow counter

### 5. BlinkDialog
- **Container:** Elevated surface (level 3), 24px radius, centered
- **Entrance animation:** Scale 0.9→1.0 + fade
- **Types:** Alert (single action), Confirm (cancel + confirm), Input (text field + buttons), Destructive (red confirm button)
- **Backdrop:** Dark overlay at 60% opacity with blur

### 6. BlinkBottomNav (Mobile)
- **Height:** 64px + safe area
- **Background:** Glassmorphic — frosted blur (20px sigma) with semi-transparent surface
- **Items:** Icon + always-visible label. Active item: primary color icon + small dot indicator below.
- **No Material splash** — smooth color transition only

### 7. BlinkSidebar (Desktop)
- **Collapsed:** 72px wide, icons only, tooltip on hover
- **Expanded:** 240px wide, icon + label
- **Active item:** Pill-shaped background with primary tint + subtle border
- **Hover:** Background brightens
- **Collapse/expand toggle button** at the bottom
- **Header area** for logo, **footer area** for settings/profile

### 8. BlinkBottomSheet
- **Appearance:** Slides up from bottom, 24px top radius, drag handle
- **Background:** Elevated surface with frosted blur behind
- **Snap points:** Half-screen, full-screen, dismiss

### 9. BlinkBadge / BlinkChip
- **Badge:** Small pill with count or label, colored background (semantic colors)
- **Chip:** Selectable pill with icon + label, toggle active state
- **Status chips:** Colored dot + label (Sending, Queued, Complete, Failed)

### 10. BlinkToggle
- **iOS-style CupertinoSwitch** aesthetic — not Material Switch
- **On state:** Primary color fill
- **Smooth thumb slide animation**

### 11. BlinkProgressBar
- **Linear:** Rounded ends, gradient fill (Primary → Accent), animated fill
- **Circular:** Ring style, used for countdown timers

### 12. BlinkEmptyState
- **Layout:** Centered icon/animation + title + subtitle + optional CTA button
- **Animation:** Lottie vector animation (subtle, looping)

---

## Screen Designs

Design every screen below for **both mobile (< 800px) and desktop (>= 800px)** layouts. Include all states: loading, empty, populated, error.

---

### Screen 1: Onboarding / First Run

**Purpose:** Welcome new users. Collect display name and optional avatar. Set the visual tone.

**Mobile Layout:**
- Full-screen dark background with 2-3 **ambient floating gradient orbs** (large, blurred, slowly drifting — Primary and Accent colors at low opacity)
- Centered vertically:
  1. **Blink logo** (SVG, 120px) with a subtle pulsing glow halo behind it
  2. App name **"Blink"** in Display L (48px), bold, tight letter-spacing (-2px)
  3. Tagline: *"Share anything. Instantly. Privately."* in Body L, secondary text color
  4. **Avatar picker** — 96px circle with gradient border (Primary → Accent). Tap to open image picker. Camera icon badge overlay. If image selected, show circular crop.
  5. **Name input** — centered text field, placeholder "Your name", large text
  6. **"Get Started" CTA** — Full-width gradient button (Primary → Primary Light), large (56px), elevated shadow, scale press animation
  7. **Security badges row** — 3 equal columns: "100% Offline" (wifi-off icon), "E2E Encrypted" (lock icon), "Cross-Platform" (devices icon). Each: icon + label in Body S, tertiary color

**Desktop Layout:**
- Same content but constrained to 480px centered column
- Orbs are larger and positioned asymmetrically
- More generous vertical spacing

**States:**
- **Loading:** Spinner replaces "Get Started" text
- **Validation error:** Red border on empty name field, shake animation

**Animations:**
- Staggered entrance: Logo (0ms) → Title (200ms) → Tagline (350ms) → Avatar (500ms) → Input (650ms) → Button (800ms) → Badges (1000ms)
- Each element: fade in + slide up (24px) + slight scale (0.95 → 1.0)
- Logo pulse: continuous subtle glow expansion/contraction

---

### Screen 2: Discovery (Main Screen / Home)

**Purpose:** The heart of the app. Shows a radar visualization of nearby devices. Users select files and tap a device to send.

**Mobile Layout:**
- Full-screen dark background
- **Frosted glass header** (sticky top):
  - Left: Blink logo (small, 24px)
  - Center: (empty or subtle "Blink" wordmark)
  - Right: Two circular icon buttons — "Show QR" and "Scan QR" (frosted glass background)
- **Radar visualization** (fills remaining space):
  - 5 concentric rings radiating from center, thin lines, low opacity
  - **Rotating sweep line** — gradient from Primary → transparent, 5-second rotation
  - **Sweep cone** — trailing wedge of gradient opacity behind the line
  - **Ambient ring dots** — 24 small dots placed on ring intersections, very low opacity
  - **Center avatar** — User's avatar/initial in a 56px circle with pulsing glow halo (accent color)
  - **Device bubbles** — Discovered devices appear as frosted glass circles positioned around the radar at varying distances:
    - 56px diameter
    - Glassmorphic background (backdrop blur + semi-transparent surface)
    - Device name (Label M) below
    - Platform icon badge (Android/Linux/Windows) at top-right
    - Entrance animation: fade + scale from center, staggered
    - **Tap to send** — opens device selection / file picker flow
- **Bottom controls** (floating above bottom nav):
  - **Status pill** — frosted glass rounded pill: "3 devices nearby" or "Searching..." with spinner
  - **"Select Files" button** — large gradient button with file icon, elevated shadow, scale press

**Desktop Layout:**
- **Split pane**: Radar (70% left) + Device List Panel (30% right)
- Radar: same as mobile but larger, more spacious
- Device List Panel:
  - Header: "Nearby Devices" + count badge
  - Scrollable list of device tiles:
    - Avatar (platform icon) + Device name + IP/status
    - Hover: background brightens, cursor pointer
    - Click: opens file picker → sends
  - Staggered entrance animation
  - Empty state if no devices

**States:**
- **Searching (no devices):** Radar animates, center pulses, status shows "Searching..."
- **Devices found:** Bubbles appear with staggered animation
- **File selected:** Bottom shows file count pill, "Send to..." prompt

**Animations:**
- Radar rotation: continuous 5s loop
- Center pulse: 2.5s scale oscillation
- Device entrance: 500ms fade + scale, 100ms stagger between devices
- Sweep cone: follows rotation with gradient fade trail

---

### Screen 3: QR Show (Display Pairing Code)

**Purpose:** Generate and display a QR code for another device to scan and establish encrypted pairing.

**Mobile Layout:**
- Scrollable, centered content
- **Header:** Back arrow (left), "Show QR Code" (Headline L, center)
- **Subtitle:** "Let the other device scan this code" in Body M, secondary color
- **QR Card** (centered, prominent):
  - Dark surface container with 24px radius
  - Subtle primary glow shadow behind the card
  - White QR code with circular eye style (not square), padded inside
  - Card width: ~260px
- **Security badge** — Lock icon + "End-to-end encrypted" in Body S, success color
- **Countdown timer:**
  - Circular progress ring (Primary → transparent as it depletes)
  - Time remaining in center (e.g., "2:45")
  - Ring turns Error color when < 60 seconds
  - When expired: "Code expired" message
- **"Regenerate" button** — Secondary button with refresh icon
- **Pairing mode toggle** (bottom):
  - Two pill chips: "Show" (active, filled) / "Scan" (inactive, ghost)
  - Tapping "Scan" navigates to QR Scan screen
  - Smooth replace transition (not push, to avoid back stack duplication)

**Desktop Layout:**
- Same content, constrained to 480px centered column
- QR card can be slightly larger (300px)

**States:**
- **Loading:** Skeleton shimmer in QR card area
- **Active:** QR code visible, timer counting
- **Expiring (< 60s):** Timer ring turns red, subtle shake
- **Expired:** QR blurred/grayed, "Regenerate" button prominent

**Animations:**
- Entrance: card scale in (0.9→1.0) + fade, elements stagger
- Timer: smooth ring depletion animation
- Regenerate: card flip or cross-fade to new QR

---

### Screen 4: QR Scan (Camera Scanner)

**Purpose:** Scan another device's QR code to complete pairing and derive encryption keys.

**Mobile Layout:**
- **Full-screen camera feed** as background
- **Dark overlay** covering everything except the viewfinder cutout
- **Viewfinder:** 260x260px rounded rectangle cutout:
  - Cyan/Accent colored corner brackets (not full border — just the 4 corners)
  - Animated scanning line: horizontal gradient line that sweeps top-to-bottom repeatedly
  - Subtle inner shadow/glow
- **Header** (floating on overlay):
  - Back button (left, white, circular frosted)
  - "Scan QR Code" title (center, white)
- **Bottom controls** (floating):
  - Instruction text: "Point camera at the QR code" in Body M, white
  - **Flashlight toggle** — circular frosted button with flash icon, toggles on/off
  - **Pairing toggle** — Show/Scan pills (same as QR Show screen)
- **Success overlay:**
  - Viewfinder turns Success green
  - Large checkmark animation (Lottie or icon scale-in)
  - "Paired successfully!" message
  - Auto-navigates back after 1.2 seconds
- **Error overlay:**
  - Viewfinder turns Error red
  - X icon animation
  - Error message ("Invalid code", "Code expired", etc.)
  - Resets scanner after 2 seconds

**Desktop Layout:**
- Camera feed centered in a 400px container (desktop cameras have different aspect ratios)
- Dark background around camera area
- Same overlay elements, adjusted positioning

**Animations:**
- Viewfinder entrance: fade + scale (0.9→1.0)
- Scan line: continuous top-to-bottom sweep with easeOut curve
- Success: icon scale-in with overshoot curve, green flash on viewfinder
- Error: shake animation on viewfinder, red flash

---

### Screen 5: Send / Outgoing Transfers

**Purpose:** Monitor all outgoing file transfers — in progress, queued, and completed.

**Mobile Layout:**
- **Header:** "Transfers" (Headline L) + active count badge (animated spinner icon + number in a primary pill)
- **Scrollable sections** (each with a section label):

  **Section: In Progress**
  - Transfer cards showing:
    - Direction icon (upload arrow in gradient circle)
    - Device name + platform icon
    - File count + total size ("3 files, 24.5 MB")
    - **Progress bar** — gradient fill (Primary → Accent), rounded ends, percentage label
    - Status badge: "Sending" with spinner in primary pill
    - Tap to expand: shows individual file progress list

  **Section: Queued**
  - Same card layout but:
    - Status badge: "Queued" in warning color pill
    - No progress bar (or empty/indeterminate)
    - Cancel button available

  **Section: Completed**
  - Same card layout but:
    - Status badge: "Complete" with checkmark in success pill
    - "BLAKE3 Verified" badge (lock + checkmark, accent color)
    - Progress bar at 100% (success gradient)
    - Timestamp of completion

- **Empty state:** Lottie animation (paper airplane floating) + "No transfers yet" + "Start by selecting files on the radar" subtitle
- **Security footer:** Lock icon + "All transfers encrypted with XChaCha20-Poly1305" in Body S, tertiary

**Desktop Layout:**
- Constrained to 720px centered column
- Cards can show more detail inline (individual files visible without expansion)
- Hover effects on cards

**Animations:**
- Cards entrance: staggered fade + slide up
- Progress bar: smooth animated fill
- Completion: progress bar flashes success color, checkmark badge pops in

---

### Screen 6: Receive / Incoming Transfers

**Purpose:** View and accept/decline incoming file transfer requests. Monitor receiving progress.

**Mobile Layout:**
- **Header:** "Incoming" (Headline L) + Back button
- **Scrollable sections:**

  **Section: Incoming Requests (Pending)**
  - Prominent request cards with:
    - **Gradient border** (Accent → Primary) — makes them stand out as actionable
    - Sender device name + platform icon
    - File count + total size
    - File type previews (icons for images, documents, etc.)
    - Two buttons at bottom:
      - **"Accept"** — Primary gradient button, checkmark icon
      - **"Decline"** — Ghost/danger button, X icon
    - Auto-dismiss animation on accept/decline

  **Section: Receiving (Active)**
  - Same as Send screen "In Progress" but with download icon
  - Status: "Receiving" in accent pill

  **Section: Completed**
  - Same as Send completed
  - "Open" button to view received files

- **Empty state:** Download icon animation + "No incoming transfers"

**Desktop Layout:**
- Same as Send desktop layout with 720px constraint
- Accept/Decline buttons more prominent with hover states

**Animations:**
- Incoming request: slide in from right with gradient border glow pulse
- Accept: card shrinks and transitions into "Receiving" section
- Decline: card fades out and slides away
- Completion: success animation + "Open Files" button appears

---

### Screen 7: Chat (In-Transfer Messaging)

**Purpose:** Real-time messaging between paired devices during a transfer session. End-to-end encrypted.

**Mobile Layout:**
- **Header:**
  - Back button (left)
  - "Chat" title (center)
  - "E2E Encrypted" badge (right) — small pill with lock icon in success color
- **Message area** (scrollable, flex-grow):
  - **Time labels** — rounded pill with timestamp, centered, appears between messages > 5 min apart. Tertiary color, Body S.
  - **Own messages** (right-aligned):
    - Gradient background (Primary → Primary Light)
    - White text
    - Rounded corners everywhere EXCEPT bottom-right (sharp corner pointing to sender)
    - Subtle shadow
  - **Other's messages** (left-aligned):
    - Dark surface background with subtle border
    - Primary text color
    - Rounded corners everywhere EXCEPT bottom-left (sharp corner)
  - **Delivery indicators:** Single check (sent), double check (delivered)
- **Input bar** (sticky bottom, above keyboard):
  - Frosted glass background
  - Left: circular "+" button (primary tint) for attachments
  - Center: rounded text input (dark surface background), placeholder "Message..."
  - Right: circular send button (gradient, arrow-up icon), only visible when text is entered (fade in)
- **Empty state:** Chat bubble icon + "No messages yet" + "Say hello!" subtitle

**Desktop Layout:**
- Fixed-width chat column (600px) centered
- Messages slightly wider, more padding
- Input bar: larger, keyboard shortcuts visible (Enter to send)

**Animations:**
- New message: fade + slide up from bottom
- Send button: scale in when text entered, scale out when empty
- Time labels: fade in
- Typing indicator (future): three bouncing dots

---

### Screen 8: Groups

**Purpose:** Create and manage device groups for bulk file transfers (e.g., "Classroom", "Team").

**Mobile Layout:**
- **Header:** "Groups" (Headline L) + "New Group" button (secondary, compact, plus icon)
- **Group cards** (scrollable list):
  - Dark surface card with:
    - Left: Group icon (44px circle with gradient background, group/people icon)
    - Center:
      - Group name (Title L)
      - Member count ("4 members") in Body S, secondary
      - **Member avatar dots** — overlapping tiny circles (3 visible + "+N")
    - Right:
      - Send button (circular, primary, arrow icon) — send files to group
      - More menu button (circular, subtle, three dots) — edit, delete

- **Create group flow:**
  - Bottom sheet slides up:
    - "Create Group" title
    - Name input field
    - "Create" gradient button
  - After creation: group detail sheet opens

- **Group detail sheet** (bottom sheet, half-to-full screen):
  - Group name (editable)
  - **Members section:**
    - List of member devices with:
      - Avatar (platform icon)
      - Device name
      - Online status dot (green/grey)
      - Remove button (X, on hover/long-press)
  - **Add from nearby section:**
    - Discovered devices not in group
    - Tap to add (checkmark animation)
  - **Delete group** button (danger, bottom)

- **Empty state:** Lottie animation (people connecting) + "No groups yet" + "Create a group to send files to multiple devices at once" + "Create Group" CTA button

**Desktop Layout:**
- Two-column: Group list (left, 300px) + Group detail (right, flex)
- Master-detail pattern — selecting a group shows its details on the right
- Empty right panel: "Select a group" placeholder

**Animations:**
- Card entrance: staggered fade + slide
- Member add: avatar slides in, checkmark pops
- Group delete: card collapses and fades

---

### Screen 9: Live Folders

**Purpose:** Auto-sync a designated folder to a paired device. Changes are detected and sent in real-time.

**Mobile Layout:**
- **Header:** "Live Folders" (Headline L) + "Add Folder" gradient button (compact, folder-plus icon)
- **Folder cards** (scrollable list):
  - Dark surface card with:
    - Left: Folder icon with gradient (Primary → Accent), 44px
    - Center:
      - Folder name / path (Title L, truncated)
      - Status line:
        - **Watching:** Success color dot + "Watching" label + "to Device X"
        - **Paused:** Warning color dot + "Paused"
        - **Pending changes:** Warning badge with count ("3 changes pending")
    - Right:
      - Pause/Resume toggle button (circular)
      - Remove button (circular, subtle, X icon)

- **Info banner** (top, dismissible):
  - Accent tinted surface
  - Info icon + "Changes are detected automatically and sent to your paired device"
  - Dismiss X button

- **Empty state:** Folder icon animation + "No live folders" + "Add a folder to start auto-syncing" + "Add Folder" CTA

**Desktop Layout:**
- Same list but wider cards, more path visible
- Constrained to 720px

**Animations:**
- Watching dot: subtle pulse animation
- New pending changes: badge count increments with bounce
- Folder add: card slides in from bottom

---

### Screen 10: Settings

**Purpose:** User preferences, profile management, and app information.

**Mobile Layout:**
- **Scrollable page** with centered content (max-width 600px)
- **Profile card** (top, prominent):
  - Large avatar (80px) with gradient border (Primary → Accent)
  - Tap avatar to change photo (file picker)
  - Display name below (Title L)
  - "Tap to edit" subtitle (Body S, secondary)
  - Tapping name opens rename bottom sheet:
    - Current name in input field
    - Cancel + Save buttons
  - Whole card has scale press animation (0.98)
  - Subtle gradient background tint

- **Settings sections** (iOS-style grouped list):

  **General**
  - Dark Mode toggle (CupertinoSwitch style, Primary when on)

  **Transfer**
  - LZ4 Compression toggle
    - Subtitle: "Faster transfers, slightly larger files"

  **Discovery**
  - Bluetooth LE toggle
    - Subtitle: "Use Bluetooth for nearby device discovery"

  **Security** (info only, not toggleable)
  - Encryption: "XChaCha20-Poly1305-IETF" with lock icon
  - File Integrity: "BLAKE3 + SHA-256" with shield icon

  **About**
  - Version badge: "v1.0.0" in a subtle pill

- **Footer:**
  - Blink logo (small, 24px, low opacity)
  - "Privacy First. Always." tagline in Body S, tertiary

**Each settings section:**
- Section label above (Label L, tertiary, uppercase tracking)
- Dark surface container with grouped items
- Items separated by color shift (not dividers — No-Line Rule)
- Each item: icon (left) + title + subtitle (center) + toggle/value (right)

**Desktop Layout:**
- Same content, constrained to 600px centered
- Slightly more vertical spacing
- Hover effects on tappable items

**Animations:**
- Staggered section entrance: each section fades in with 100ms delay
- Profile card: slide down on entrance
- Toggle: smooth thumb slide
- Avatar change: cross-fade from old to new image

---

### Screen 11: File Review Sheet (Bottom Sheet)

**Purpose:** After selecting files, review them before confirming the send.

**Layout (Bottom Sheet):**
- Drag handle at top
- **Header:** "Review Files" (Headline M) + file count
- **File list** (scrollable):
  - Each file:
    - File type icon (image, video, document, audio, archive, generic) with colored circle background
    - File name (Title M, truncated)
    - File size (Body S, secondary)
    - Remove button (X, circular, subtle) — tap to remove from selection
- **Footer (sticky bottom):**
  - Total size summary: "4 files, 128.5 MB" (Body M, secondary)
  - **"Send" button** — full-width gradient button, large, with send icon
  - Cancel text button below

**Animations:**
- Sheet slides up with spring curve
- File items: staggered entrance
- Remove file: item collapses and fades, list reflows smoothly
- Send: button loading state with spinner

---

### Screen 12: Device Selection Sheet (Bottom Sheet)

**Purpose:** When multiple devices are discovered, choose which one to send files to.

**Layout (Bottom Sheet):**
- Drag handle
- **Header:** "Send to..." (Headline M)
- **Device list:**
  - Each device:
    - Platform avatar (Android/Linux/Windows icon in circle)
    - Device name (Title M)
    - IP address / connection info (Body S, secondary)
    - Online status dot
  - Tap to select → begins transfer
- **Empty state:** "No devices found" + "Make sure both devices are on the same network"

**Animations:**
- Device items: staggered fade in
- Tap selection: item flashes primary tint, sheet dismisses downward

---

## Navigation Structure

### Mobile (< 800px): Bottom Navigation Bar
5 tabs with icons + always-visible labels:

| Tab | Icon | Label | Route |
|-----|------|-------|-------|
| 1 | radar/signal icon | Discover | `/discovery` |
| 2 | upload-arrow icon | Send | `/transfers/send` |
| 3 | download-arrow icon | Receive | `/transfers/receive` |
| 4 | chat-bubble icon | Chat | `/chat` |
| 5 | settings-gear icon | Settings | `/settings` |

**Bottom nav design:**
- Glassmorphic frosted background (blur + semi-transparent)
- Active tab: Primary color icon + small dot indicator below icon
- Inactive tabs: secondary/tertiary color icons
- No Material splash — smooth color transition
- 64px height + platform safe area

**Additional navigation targets (not in bottom nav):**
- Groups: accessed via long-press on Discover tab or from a button within Discovery
- Live Folders: accessed from Settings or a floating action element
- QR Show/Scan: accessed via header buttons on Discovery screen
- File Review Sheet: triggered from file selection flow
- Device Selection Sheet: triggered when multiple devices available

### Desktop (>= 800px): Sidebar Navigation
- **Collapsed state (72px):** Icons only, tooltips on hover
- **Expanded state (240px):** Icon + label for each item
- **Items:** Same 5 as mobile + Groups + Live Folders (7 total)
- Active item: pill-shaped background with primary color tint + left accent bar
- Hover: background lightens
- Collapse/expand toggle at bottom
- Logo in header area
- Profile/settings shortcut in footer

### Transitions Between Screens
- Tab switches: instant cross-fade (100ms)
- Push navigation (QR, details): Cupertino slide from right
- Bottom sheets: spring slide from bottom
- Modals/dialogs: scale in (0.9→1.0) + fade + backdrop dim

---

## Interaction Patterns

### Press Feedback (Mobile)
- **All tappable elements:** Scale to 0.98 on press, return on release (Quick duration)
- **No Material InkWell/splash** — GestureDetector with AnimatedScale everywhere
- Buttons additionally darken slightly on press

### Hover Feedback (Desktop)
- **Cards:** Background brightens one level (surface → hover), shadow increases
- **Buttons:** Glow aura appears (primary glow for primary buttons)
- **List items:** Background brightens, cursor changes to pointer
- **Destructive items:** Background tints slightly red on hover

### Long Press
- Cards: context menu (edit, delete, share)
- Avatars: full-size preview
- Text: system copy menu

### Pull to Refresh
- Discovery screen: re-triggers device scan
- Transfers: refreshes session list

### Swipe Gestures
- Transfer cards: swipe left to cancel
- Chat messages: swipe right to reply (future)

### Keyboard Shortcuts (Desktop)
- `Cmd/Ctrl + N`: New group
- `Cmd/Ctrl + F`: Search/filter
- `Escape`: Close modal/sheet/go back
- `Enter`: Confirm dialog
- `Tab`: Navigate between focusable elements

---

## Empty, Loading, Error, and Skeleton States

### Empty States
Every screen with a list must have an empty state:
- Centered vertically
- Animated illustration (Lottie, subtle loop, ~120px)
- Title (Headline S)
- Subtitle (Body M, secondary, max 2 lines)
- Optional CTA button (Primary, medium)
- Consistent across all screens

| Screen | Animation Concept | Title | Subtitle |
|--------|-------------------|-------|----------|
| Discovery | Pulsing radar rings | "No devices nearby" | "Make sure devices are on the same network" |
| Send | Paper airplane floating | "No outgoing transfers" | "Select files from the radar to start" |
| Receive | Download cloud | "No incoming transfers" | "Transfers will appear when someone sends files" |
| Chat | Chat bubbles | "No messages yet" | "Start a conversation during a transfer" |
| Groups | Connected people | "No groups yet" | "Create a group to send to multiple devices" |
| Live Folders | Folder with sync arrows | "No live folders" | "Add a folder to auto-sync changes" |

### Loading States
- **Initial load:** Full-screen centered Lottie loading animation
- **Content loading:** Shimmer skeleton placeholders matching the content layout
- **Action loading:** Button spinner (replaces text), disabled state
- **Refresh:** Pull-to-refresh indicator or inline spinner

### Error States
- **Connection error:** Red-tinted card with error icon + retry button
- **Transfer failed:** Card status turns error red, "Retry" button appears
- **QR expired:** Timer turns red, "Regenerate" button highlighted
- **Generic error:** Lottie error animation + error message + retry CTA

---

## Dark Mode vs Light Mode

Design **both** themes for every screen. Dark mode is primary.

### Dark Mode (Primary)
- OLED-optimized true black base (`#0D0D12`)
- Purple/cyan gradients pop against dark backgrounds
- Glassmorphism with dark tinted blur
- Text: white primary, grey secondary
- Cards: dark surface (`#1A1A2E`) on dark background
- Glow effects are more prominent and beautiful in dark

### Light Mode (Secondary)
- Off-white background (`#F8F9FC`)
- Same color accents but slightly adjusted for contrast
- Cards: white with subtle shadow (no glassmorphism — use shadows instead)
- Text: near-black primary, grey secondary
- Glassmorphism replaced with elevated shadows + light blur
- Purple/cyan accents remain the same (they pop on white too)
- Reduce glow effects — use shadows for depth instead

**Both modes share:**
- Same layout and spacing
- Same component sizes and touch targets
- Same animation timings and curves
- Same typography scale
- Same iconography

---

## Iconography

- **Style:** SF Symbols / Lucide style — clean, consistent stroke weight (1.5-2px), rounded joins
- **Size:** 24px default on 24px grid, 20px compact, 16px inline
- **Color:** Always set at runtime via tint/color filter (never baked-in color)
- **Categories needed:**

| Category | Icons |
|----------|-------|
| **Navigation** | radar, send (arrow-up), receive (arrow-down), chat-bubble, settings-gear, folder-sync |
| **Actions** | add/plus, delete/trash, edit/pencil, send, receive, pause, resume, retry, check, close/x, copy, share |
| **Devices** | smartphone (Android), laptop (Linux), desktop (Windows), unknown-device |
| **Files** | image, video, audio, document, archive/zip, generic-file |
| **QR** | qr-code, scan, camera |
| **Status** | online-dot, offline-dot, checkmark-circle, x-circle, warning-triangle, info-circle |
| **Security** | lock, shield, key, fingerprint |
| **UI** | menu/hamburger, search, filter, back-arrow, chevron-right, expand, collapse, more-vertical, drag-handle |

---

## Accessibility Requirements

- **Contrast ratios:** WCAG AA minimum (4.5:1 for body text, 3:1 for large text)
- **Touch targets:** 44px minimum on all interactive elements
- **Focus indicators:** visible focus ring (2px primary outline with 2px offset) for keyboard navigation
- **Screen reader labels:** every icon-only button must have a semantic label
- **Reduce motion:** when system prefers-reduced-motion, disable all decorative animations (radar spin, ambient orbs, entrance staggers). Keep functional transitions (page changes, state feedback).
- **Font scaling:** layouts must accommodate up to 200% text scale without breaking

---

## Deliverable Expectations

For each screen, generate:

1. **Mobile portrait** (390px width — iPhone 15 size) in both dark and light mode
2. **Desktop** (1440px width) in both dark and light mode
3. All interactive states where applicable (default, hover, pressed, loading, error, empty)
4. Both collapsed and expanded sidebar states for desktop

**Total screens to design:** 12 screens x 2 platforms x 2 themes = **48 screen designs minimum** plus component states.

### Design Quality Bar
- Every pixel should feel intentional
- Whitespace is a design element — use it generously
- The UI should feel like a $50M startup's flagship product
- Inspiration references: Linear, Arc Browser, Raycast, Craft, Apple Music, Spotify desktop, Telegram, Nothing Phone UI
- No generic Material Design or stock Flutter look — this is a premium, opinionated design system

---

## Logo Reference

The Blink logo is a **lightning bolt** (representing speed/instant transfer) surrounded by **concentric gradient circles** (representing signal/discovery waves):
- Gradient: Primary (#6C63FF) → Accent (#00D9FF)
- Bolt: white fill with gradient stroke
- Available in 128x128 (full) and 32x32 (compact) sizes
- Used in: onboarding hero, nav header/sidebar, settings footer, loading splash

---

## Summary

Redesign **Blink** from the ground up as a **sexy, sleek, modern** file sharing app that makes AirDrop jealous. The UI should be dark, glassy, gradient-rich, and buttery smooth. Every screen must work on phones and desktops. Every interaction must feel tactile and premium. No compromises on aesthetics or usability.

Make it the kind of app people show off to their friends.
