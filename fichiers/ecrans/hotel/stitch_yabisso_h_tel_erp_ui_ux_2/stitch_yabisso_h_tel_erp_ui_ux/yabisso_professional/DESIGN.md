---
name: Yabisso Professional
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
  on-surface-variant: '#45464d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#2a1700'
  on-tertiary-container: '#b87500'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 16px
  gutter-mobile: 12px
---

## Brand & Style

The design system is engineered for high-stakes hospitality management, blending the technical precision of developer-centric tools with the refined elegance of luxury African hospitality. The brand personality is **Trustworthy, Sophisticated, and Efficient**, aimed at general managers and operations staff who require immediate clarity and professional-grade reliability.

The visual direction follows a **Modern Minimalist** aesthetic with **Material 3 influences**. It prioritizes high-quality white space, crisp functional boundaries, and subtle depth. By drawing inspiration from industry leaders like Stripe and Linear, the UI maintains a "digital-first" feel that signifies speed and modernity, ensuring that the software feels like a premium asset rather than a legacy administrative burden.

## Colors

The palette is rooted in a deep, authoritative primary blue that provides a stable foundation for a professional ERP environment. 

- **Primary (#0F172A):** Used for navigation, headers, and primary actions to anchor the user's focus.
- **Secondary/Accent (#10B981):** A vibrant emerald reserved for success states, "Check-in" confirmations, and growth indicators in analytics.
- **Backgrounds:** Light mode uses a "cool-tinted" white (#F8FAFC) to reduce eye strain during long shifts, while dark mode leverages the primary blue for a deep charcoal, high-contrast experience.
- **System States:** Gold (#F59E0B) is utilized for "Pending" or "Warning" statuses (e.g., late check-outs), and a soft, high-visibility red (#EF4444) is dedicated to critical system errors or "Overbooked" alerts.

## Typography

This design system utilizes **Inter** exclusively to ensure a systematic, utilitarian, and highly readable interface. The hierarchy is tight and disciplined, optimized for data-heavy ERP screens where information density must be balanced with clarity.

**Headlines** use tighter letter-spacing and bold weights to provide immediate visual anchors. **Body text** is kept at a comfortable 14px-16px for readability. **Labels** are designed for metadata—such as room numbers, timestamps, and status badges—often utilizing slightly increased letter spacing and medium/semibold weights to ensure they stand out even at small sizes. For mobile, headline sizes are capped to prevent awkward text wrapping in portrait mode.

## Layout & Spacing

The layout philosophy is built on a **4px baseline grid** to ensure mathematical harmony across all components. For mobile (Android/Flutter), a **fluid column system** is used.

- **Mobile (Default):** 4-column layout with 16px side margins and 12px gutters.
- **Touch Targets:** Minimum touch targets are strictly maintained at 48x48px to accommodate fast-paced operational use.
- **Rhythm:** Vertical spacing between cards or list items should follow the `md` (16px) unit, while internal padding within containers should use `md` or `lg` (24px) to maintain a premium, airy feel.

## Elevation & Depth

This design system uses **Tonal Layers** and **Ambient Shadows** to create a structured hierarchy without visual clutter. Depth is used functionally to separate the background from interactive surfaces.

- **Base Level (Level 0):** Background (#F8FAFC).
- **Surface Level (Level 1):** Cards and main content containers. These use a very soft, diffused shadow: `0px 1px 3px rgba(15, 23, 42, 0.08)`.
- **Raised Level (Level 2):** Hover states or active selections. Increased shadow depth: `0px 4px 6px rgba(15, 23, 42, 0.12)`.
- **Overlay Level (Level 3):** Modals, bottom sheets, and floating action buttons (FABs). These use the most prominent depth: `0px 10px 15px rgba(15, 23, 42, 0.15)`.

Dark mode elevation is achieved primarily through tonal shifts (lighter shades of blue-charcoal) rather than shadows.

## Shapes

The shape language is **Rounded**, conveying a modern and approachable professional tool. 

- **Standard Elements:** Buttons, input fields, and small cards use an **8px (0.5rem)** corner radius.
- **Large Containers:** Dashboard widgets and main content sections use a **16px (1rem)** radius to soften the high-density data.
- **Interactive Indicators:** Status badges and chips use a "Full" pill-shape to distinguish them from actionable buttons.

## Components

### Buttons
- **Primary:** Solid #0F172A background with white text. 8px radius. High emphasis.
- **Secondary:** Transparent background with #0F172A border (1px) or subtle grey fill.
- **Action/Success:** Solid #10B981 for "Check-in" or "Confirm Payment."

### Cards
Cards are the primary organizational unit. They should feature a 1px border (#E2E8F0) and the Level 1 Ambient Shadow. Use internal padding of 16px-24px.

### Input Fields
Inputs follow the Material 3 "Outlined" style. 1px border (#CBD5E1), 8px radius. On focus, the border shifts to Primary (#0F172A) with a 2px width.

### Chips & Badges
- **Status Badges:** Subtle background tints (e.g., light green for #10B981) with high-contrast text.
- **Room Tags:** Small, grey-filled pill shapes for room types or floor numbers.

### Lists
High-density lists (e.g., guest arrivals) should use thin dividers (#F1F5F9). Each list item should have a minimum height of 56px for clear touch accessibility.

### Bottom Sheets
For mobile-first ERP actions, use rounded top corners (24px) for bottom sheets to provide quick access to "Guest Details" or "Billing" without leaving the main view.