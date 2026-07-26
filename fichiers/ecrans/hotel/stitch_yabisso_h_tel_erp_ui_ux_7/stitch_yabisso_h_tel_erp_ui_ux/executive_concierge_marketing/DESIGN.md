---
name: Executive Concierge & Marketing
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#44474d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#75777e'
  outline-variant: '#c5c6cd'
  surface-tint: '#515f78'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#0d1c32'
  on-primary-container: '#76849f'
  inverse-primary: '#b9c7e4'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#261900'
  on-tertiary-container: '#a17f3b'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#b9c7e4'
  on-primary-fixed: '#0d1c32'
  on-primary-fixed-variant: '#39475f'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#ffdea5'
  tertiary-fixed-dim: '#e9c176'
  on-tertiary-fixed: '#261900'
  on-tertiary-fixed-variant: '#5d4201'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Libre Caslon Text
    fontSize: 48px
    fontWeight: '400'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Libre Caslon Text
    fontSize: 32px
    fontWeight: '400'
    lineHeight: '1.2'
  headline-lg-mobile:
    fontFamily: Libre Caslon Text
    fontSize: 24px
    fontWeight: '400'
    lineHeight: '1.2'
  title-md:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '600'
    lineHeight: '1.5'
    letterSpacing: 0.01em
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1'
    letterSpacing: 0.08em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1440px
  gutter: 24px
  margin-desktop: 64px
  margin-mobile: 20px
---

## Brand & Style
The brand personality is authoritative, discreet, and high-touch. It targets ultra-high-net-worth individuals and the professional teams that serve them. The UI must evoke a sense of calm reliability and exclusive access, moving beyond simple utility into a "digital concierge" experience.

The design style is **Minimalist with a High-Contrast/Bold edge**. It utilizes expansive white space (or deep navy voids in dark mode), razor-sharp typography, and a refined use of subtle tonal layering. The aesthetic is inspired by luxury horology and premium hospitality—functional, yet deeply sophisticated.

## Colors
The palette is anchored by **Deep Navy** (#0A192F) for primary actions and text, establishing a foundation of trust. **Slate** (#64748B) acts as the bridge for secondary information and borders. A **Champagne Gold** (#C5A059) tertiary accent is reserved strictly for VIP indicators, premium features, or "concierge-level" highlights.

For the marketing and reservation modules, specific semantic tokens are introduced:
- **Marketing Status:** Draft uses muted Slate; Active uses a crisp Emerald; Completed uses a refined Indigo.
- **Reservation States:** Confirmed utilizes a deep Forest Green; Pending uses a sophisticated Amber; Cancelled uses a high-visibility Crimson.

## Typography
The system uses a sophisticated pairing of **Libre Caslon Text** for editorial-style headlines and **Manrope** for functional interface elements.

- **Headlines:** Set in Libre Caslon Text to provide a literary, established feel. Use tight tracking for large display sizes.
- **Body & Functional:** Manrope provides a clean, modern contrast. It ensures maximum legibility for dense reservation lists and marketing analytics.
- **Labels:** Always use Manrope Bold with increased letter-spacing and uppercase styling for status indicators (e.g., "CONFIRMED") to maintain a professional, systematic look.

## Layout & Spacing
The layout follows a **Fixed Grid** philosophy on desktop to ensure a curated, controlled visual experience, transitioning to a fluid model on mobile.

- **Rhythm:** An 8px base unit governs all dimensions.
- **Margins:** Generous 64px outer margins on desktop create a "gallery" feel, centering the focus on high-value data.
- **Grid:** A 12-column structure for marketing dashboards, allowing for asymmetrical layouts where sidebars contain concierge filters and the main area displays reservation timelines.

## Elevation & Depth
In this design system, depth is achieved through **Tonal Layers and Low-contrast Outlines** rather than aggressive shadows.

- **Surfaces:** Use subtle shifts in background color (e.g., from White to an ultra-light Slate #F8FAFC) to differentiate card containers from the main canvas.
- **Outlines:** Use 1px borders in a soft Slate (#E2E8F0) for card boundaries.
- **Interactive Depth:** When an item is selected (like a specific reservation), apply a very soft, ambient shadow (15% opacity, 20px blur, 0px offset) to lift it slightly, creating a "tactile" focus without breaking the minimalist aesthetic.

## Shapes
The shape language is **Soft**. Sharp edges are avoided to maintain an approachable luxury feel, but excessive rounding is shunned to preserve professional "seriousness." 

- **Primary Elements:** Buttons and Input fields use a 0.25rem (4px) radius.
- **Containers:** Large cards and modal overlays use a 0.75rem (12px) radius.
- **Status Pills:** Utilize a full pill-shape (999px) to distinguish them from functional buttons.

## Components
- **Buttons:** Primary buttons are Solid Navy with White text. Secondary buttons are Ghost-style with a Slate border. No gradients.
- **Status Chips:** Used for Reservations and Marketing. They consist of a light-tinted background of the status color with high-contrast text in the same hue (e.g., Pending: Light Amber background, Dark Amber text).
- **Reservation Cards:** Must include a "VIP" slot for the Gold accent color. Content is left-aligned with a clear hierarchy: Guest Name (Title-MD), Date/Time (Body-MD), and Status (Label-SM).
- **Inputs:** Clean, bottom-border-only or fully outlined with 1px Slate. Labels sit above the input in Manrope Bold 12px.
- **Timeline/Calendar:** A custom component for Concierge views, using thin Slate lines and Navy dots to represent booking density.