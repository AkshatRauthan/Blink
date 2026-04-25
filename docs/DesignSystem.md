# Blink Design System — "Midnight Obsidian"

> Comprehensive design language for all Blink UI screens and components

---

## 1. Color Tokens

### Backgrounds (Dark Theme)
| Token | Hex | Usage |
|-------|-----|-------|
| `bg-base` | `#000000` | True black for OLED, splash screens |
| `bg-primary` | `#0D0D12` | Main app background |
| `bg-surface` | `#1A1A2E` | Cards, containers, elevated surfaces |
| `bg-elevated` | `#2A2A3C` | Modals, dialogs, dropdowns |
| `bg-hover` | `#35354A` | Hover states on surfaces |

### Brand Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#6C63FF` | Electric Violet - buttons, active states, links |
| `primary-hover` | `#7C74FF` | Hover state for primary |
| `primary-muted` | `#6C63FF33` | 20% opacity for backgrounds |
| `accent` | `#00D9FF` | Cyan - highlights, progress, indicators |
| `accent-muted` | `#00D9FF33` | 20% opacity for glows |

### Semantic Colors (as implemented in `BlinkColors`)
| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#2ED47A` | Green - completed, online, verified, BLAKE3 badge |
| `success-muted` | `#2ED47A` @ 12% | Success backgrounds (icon tint boxes) |
| `warning` | `#FFBB33` | Amber - pending, caution |
| `warning-muted` | `#FFBB33` @ 12% | Warning backgrounds |
| `error` | `#FF6B6B` | Red - errors, offline, failed, decline |
| `error-muted` | `#FF6B6B` @ 12% | Error backgrounds |
| `info` | `#5B8DEF` | Blue - informational, BLE icon |

### Text Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `text-primary` | `#FFFFFF` | Headings, important content |
| `text-secondary` | `#A0A0B0` | Body text, descriptions |
| `text-tertiary` | `#666680` | Hints, disabled, timestamps |
| `text-inverse` | `#0D0D12` | Text on light/colored backgrounds |

---

## 2. Typography

**Font Family**: Inter (all weights)

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `heading-xl` | 32px | 700 | 40px | Screen titles |
| `heading-lg` | 24px | 600 | 32px | Section headers |
| `heading-md` | 20px | 600 | 28px | Card titles |
| `body-lg` | 16px | 400 | 24px | Primary content |
| `body-md` | 14px | 400 | 20px | Secondary content |
| `body-sm` | 12px | 400 | 16px | Captions, hints |
| `label` | 14px | 500 | 20px | Buttons, labels |
| `mono` | 14px | 500 | 20px | Code, IDs |

---

## 3. Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `space-0` | 0px | - |
| `space-1` | 4px | Tight inline spacing |
| `space-2` | 8px | Icon gaps, compact padding |
| `space-3` | 12px | List item padding |
| `space-4` | 16px | Standard padding |
| `space-5` | 20px | Section gaps |
| `space-6` | 24px | Card padding |
| `space-8` | 32px | Section separation |
| `space-10` | 40px | Large gaps |
| `space-12` | 48px | Screen margins |

---

## 4. Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 6px | Chips, small badges |
| `radius-md` | 12px | Buttons, inputs, cards |
| `radius-lg` | 16px | Dialogs, modals |
| `radius-xl` | 24px | Bottom sheets, large cards |
| `radius-full` | 9999px | Avatars, circular buttons |

---

## 5. Shadows & Elevation

| Level | Shadow | Usage |
|-------|--------|-------|
| `elevation-0` | none | Flat surfaces |
| `elevation-1` | `0 2px 8px rgba(0,0,0,0.4)` | Cards, containers |
| `elevation-2` | `0 4px 16px rgba(0,0,0,0.5)` | Dropdowns, popovers |
| `elevation-3` | `0 8px 32px rgba(0,0,0,0.6)` | Modals, dialogs |
| `elevation-4` | `0 16px 48px rgba(0,0,0,0.7)` | Full-screen overlays |

### Glow Effects
| Effect | CSS | Usage |
|--------|-----|-------|
| `glow-primary` | `0 0 20px rgba(108,99,255,0.5)` | Primary button focus |
| `glow-accent` | `0 0 20px rgba(0,217,255,0.5)` | Active device, highlight |
| `glow-success` | `0 0 12px rgba(74,222,128,0.4)` | Online indicator |

---

## 6. Component Specifications

### 6.1 Buttons

#### Primary Button
- Background: `#6C63FF`
- Text: `#FFFFFF`, 14px, 500 weight
- Padding: 12px 24px
- Border Radius: 12px
- Hover: `#7C74FF` + `glow-primary`
- Disabled: 50% opacity

#### Secondary Button
- Background: `transparent`
- Border: 1.5px solid `#6C63FF`
- Text: `#6C63FF`
- Same dimensions as primary

#### Ghost Button
- Background: `transparent`
- Text: `#A0A0B0`
- Hover background: `#FFFFFF0D` (5%)

#### Icon Button
- Size: 44px × 44px (touch target)
- Icon: 24px
- Border Radius: `radius-full`

### 6.2 Input Fields

- Background: `#1A1A2E`
- Border: 1px solid `#35354A`
- Text: `#FFFFFF`
- Placeholder: `#666680`
- Padding: 14px 16px
- Border Radius: 12px
- Focus border: `#6C63FF`
- Error border: `#F87171`
- Height: 48px (mobile), 44px (desktop)

### 6.3 Cards

- Background: `#1A1A2E`
- Border Radius: 16px
- Padding: 16px
- No borders (use background contrast)
- Optional subtle shadow: `elevation-1`

### 6.4 Navigation

#### Bottom Nav (Mobile) — as implemented in `BlinkBottomNav`
- Height: 64px
- Background: `#0D0D12` @ 88% alpha with `BackdropFilter` blur (sigma 24) — frosted glass effect
- Top border: white @ 6% alpha
- Active icon: white @ 90% alpha with 4px purple dot indicator below (primary glow shadow)
- Inactive icon: white @ 40% alpha
- Labels: 10px, always visible (both active and inactive)
- No splash/ripple — `GestureDetector` for iOS feel

#### Sidebar Rail (Desktop) — as implemented in `BlinkSidebar`
- Width: 72px (icon rail, not expandable in current implementation)
- Background: `#1A1A2E` (dark surface) with right border (white @ 4% alpha)
- Active item: primary @ 15% alpha background, subtle primary border (0.2 alpha)
- Inactive: white @ 40% alpha
- Hover: white @ 4% alpha background

### 6.5 Avatars

| Size | Dimensions | Font Size |
|------|------------|-----------|
| `xs` | 32px | 12px |
| `sm` | 40px | 14px |
| `md` | 56px | 20px |
| `lg` | 80px | 28px |
| `xl` | 120px | 40px |

- Border Radius: `radius-full`
- Border: 2px solid `#2A2A3C` (default)
- Online border: 2px solid `#4ADE80`

### 6.6 Dialogs/Modals

- Background: `#1A1A2E`
- Border Radius: 24px
- Padding: 24px
- Overlay: `rgba(0,0,0,0.7)` with blur
- Max width: 400px (mobile), 480px (desktop)
- Shadow: `elevation-3`

### 6.7 Transfer Cards

- Background: `#1A1A2E`
- Progress bar track: `#35354A`
- Progress bar fill: `#6C63FF` (sending) / `#00D9FF` (receiving)
- Border radius: 16px
- Padding: 16px
- File icon: 40px

### 6.8 Device Bubbles (Radar) — as implemented in `DeviceBubble`

- Size: 56px diameter circular container
- Background: `#1A1A2E` @ 70% alpha (semi-transparent for glassmorphism)
- `BackdropFilter` with sigma 12 for frosted glass effect
- Border: 1px solid white @ 8% alpha
- Platform icon badge: 20px primary-tinted circle at bottom-right
- Press animation: `AnimatedScale` 0.92 on tap
- Device name label below (white @ 70% alpha, 11px)
- No splash — `GestureDetector` for iOS feel

---

## 7. Animation Specifications

### Durations
| Token | Value | Usage |
|-------|-------|-------|
| `duration-fast` | 150ms | Micro-interactions |
| `duration-normal` | 250ms | Standard transitions |
| `duration-slow` | 400ms | Page transitions |
| `duration-slower` | 600ms | Complex animations |

### Easings
| Token | Value | Usage |
|-------|-------|-------|
| `ease-out` | `cubic-bezier(0.0, 0, 0.2, 1)` | Entry animations |
| `ease-in` | `cubic-bezier(0.4, 0, 1, 1)` | Exit animations |
| `ease-in-out` | `cubic-bezier(0.4, 0, 0.2, 1)` | Moving elements |
| `ease-bounce` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | Playful pop |

### Specific Animations
| Animation | Duration | Easing |
|-----------|----------|--------|
| Radar sweep | 3s | linear, infinite |
| Device appear | 400ms | ease-bounce |
| Progress bar | 250ms | ease-out |
| Modal enter | 300ms | ease-out |
| Modal exit | 200ms | ease-in |
| Page slide | 350ms | ease-in-out |

---

## 8. Layout Patterns

### Mobile (< 600px)
- Margins: 16px horizontal
- Max content width: none
- Navigation: Bottom bar
- Cards: Full width minus margins

### Tablet (600px - 1024px)
- Margins: 24px horizontal
- Max content width: 720px centered
- Navigation: Bottom bar or sidebar
- Cards: 2-column grid

### Desktop (> 1024px)
- Margins: 32px horizontal
- Max content width: 1200px centered
- Navigation: Sidebar rail
- Cards: 3-4 column grid
- Master-detail layouts

---

## 9. Icon System

- **Size**: 24px (standard), 20px (compact), 32px (featured)
- **Stroke**: 2px
- **Style**: Outlined, rounded caps/joins
- **Color**: `currentColor` for theming
- **Active**: Fill or increased weight

---

## 10. The "No-Line" Rule

**Principle**: Define visual hierarchy through background color shifts, not borders.

✅ **Do**:
- Use `bg-surface` for cards on `bg-primary`
- Use `bg-elevated` for modals on `bg-surface`
- Use spacing to separate sections

❌ **Don't**:
- Add border lines between list items
- Use divider lines in cards
- Add borders to distinguish containers

**Exception**: Input fields and buttons may have subtle borders for affordance.

---

## 11. Platform Considerations

### Android
- Status bar: Transparent, light icons
- Navigation bar: `#0D0D12`, light icons
- Touch targets: minimum 48px

### Windows
- Title bar: Custom with `#0D0D12`
- Window controls: System integrated
- Scrollbars: Thin, overlay style

### Linux
- Client-side decorations
- Match system GTK dark theme where possible
- Respect desktop environment conventions

---

## 12. Implementation Notes (April 2026)

Key patterns established during the Phase 4 UI redesign:

### Interaction Model
- **No InkWell/splash anywhere** — all tappable elements use `GestureDetector` + `AnimatedScale` for iOS feel
- Press scale values: 0.92 (device bubbles), 0.96 (CTA buttons), 0.97 (folder buttons), 0.98 (profile card, settings items)

### Glassmorphism
- `BackdropFilter` with `ImageFilter.blur` used on: bottom nav bar (sigma 24), device bubbles (sigma 12), discovery header (sigma 20), torch toggle (sigma 10)
- Semi-transparent backgrounds required for blur to be visible (typically 70–88% alpha)

### Gradient Patterns
- Primary gradient: `#6C63FF → #8B7BFF` (buttons, sent chat bubbles, profile avatar, active toggles)
- Accent gradient: `#00D9FF → #00B4D8` (accept buttons, receive progress)
- Background gradient orbs: radial gradients of primary/accent at low opacity for atmospheric depth

### Entrance Animations
- All screens use `flutter_animate` declarative chains: `.animate().fadeIn(duration: 400-500.ms).slideY(begin: 0.03, end: 0)`
- Staggered delays: sections animate with 100ms incremental delays
- Radar sweep: 4s `AnimationController` with linear repeat

### Layout Breakpoint
- Single breakpoint: **800px** (not the 600px/1024px from spec)
- <800px: mobile with bottom nav
- ≥800px: desktop with sidebar rail + optional side panels (e.g., device list panel on discovery)

---

*This design system ensures visual consistency across all Blink screens and platforms.*
