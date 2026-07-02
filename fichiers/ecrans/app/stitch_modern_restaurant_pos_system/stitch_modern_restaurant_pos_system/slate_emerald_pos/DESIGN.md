---
name: Slate & Emerald POS
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
  secondary: '#006c4a'
  on-secondary: '#ffffff'
  secondary-container: '#82f5c1'
  on-secondary-container: '#00714e'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#07006c'
  on-tertiary-container: '#7073ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#85f8c4'
  secondary-fixed-dim: '#68dba9'
  on-secondary-fixed: '#002114'
  on-secondary-fixed-variant: '#005137'
  tertiary-fixed: '#e1e0ff'
  tertiary-fixed-dim: '#c0c1ff'
  on-tertiary-fixed: '#07006c'
  on-tertiary-fixed-variant: '#2f2ebe'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style

This design system is engineered for high-performance hospitality environments, balancing premium aesthetics with uncompromising utility. The brand personality is **authoritative, precise, and sophisticated**, moving away from the cluttered layouts of traditional POS systems toward a refined, editorial-inspired interface.

The visual style is **Corporate / Modern with a touch of Minimalism**. It utilizes deep tonal layering to manage visual complexity, ensuring that servers and bartenders can navigate high-density information under harsh or dim lighting without cognitive friction. The mood is calm and professional, instilling confidence in both the operator and the guest.

## Colors

The palette is anchored by **Deep Slate (#0F172A)**, used for primary navigation and high-contrast text to ensure maximum legibility. **Emerald Green (#059669)** serves as the "Action" color, reserved strictly for primary buttons, active order states, and "paid" confirmations.

Soft neutrals provide a sophisticated backdrop, reducing eye strain during long shifts. We utilize a "layered light" approach where the background is the lightest value, and interactive containers use subtle grey-scale shifts to denote hierarchy. High-contrast ratios are maintained for all critical touch targets to accommodate various ambient lighting conditions in restaurant settings.

## Typography

The design system employs **Hanken Grotesk** for its exceptional clarity and modern geometry. It provides a professional, "tech-forward" feel while remaining highly readable at various distances—crucial for kitchen displays and handheld devices.

For technical data, quantities, and prices, **JetBrains Mono** is used. This monospaced font ensures that price columns align perfectly and numbers remain distinct, preventing errors during fast-paced order entry. Letter spacing is slightly tightened on headlines for a premium look, while body text remains open to aid scanning.

## Layout & Spacing

The design system utilizes a **Fluid Grid** model built on a **4px baseline shift**. For tablet and desktop POS terminals, a 12-column grid provides the framework for the "split-screen" layout: the left 60-70% is dedicated to menu selection (Product Grid), while the right 30-40% is reserved for the active "Receipt/Order" sidebar.

On mobile handhelds, the layout reflows into a single-column stacked view with a persistent "View Cart" footer. Spacing is intentionally generous around touch targets (minimum 44x44px area) to prevent accidental taps in high-pressure service environments.

## Elevation & Depth

Visual hierarchy is established through **Tonal Layers** rather than heavy shadows. The base application background is the most recessed level. Surfaces like product cards and menu categories sit on a "Level 1" surface with a subtle 1px border (#E2E8F0).

Active selections or focused modals use **Ambient Shadows**—highly diffused, low-opacity (8%) shadows—to appear as if they are floating slightly above the interface. This "soft depth" maintains the clean, modern aesthetic while providing clear tactile feedback on what is currently interactive. Backdrop blurs (12px) are used behind modals to keep the focus on the immediate task.

## Shapes

The shape language is **Soft**, utilizing a consistent 0.25rem (4px) base radius. This provides a precise, professional look that feels modern without being overly "bubbly" or informal. Larger components like the "Order Sidebar" or "Checkout Modals" utilize the `rounded-lg` (8px) token to create a clear container distinction. Product photos within cards are clipped with the same radius to maintain a unified architectural feel.

## Components

### Buttons
- **Primary:** Emerald Green background, white text. Used for "Send to Kitchen" or "Pay".
- **Secondary:** Deep Slate outline, Slate text. Used for modifiers or non-critical actions.
- **Ghost:** No background/border, Slate text. Used for "Cancel" or "Back" actions.

### Product Cards
Cards feature a top-aligned image (if applicable) with the price in the top-right corner using the `label-md` (JetBrains Mono) style. The background should be white with a 1px Slate-100 border.

### Chips & Modifiers
Used for table numbers or order tags. These should have a light grey background with Slate text, switching to Emerald Green when selected.

### Input Fields
Clean, underlined or lightly boxed inputs with 16px internal padding. Labels must always be visible (never placeholder-only) using the `label-sm` style to ensure clarity during fast entry.

### List Items (The Receipt)
High-density rows with a 1px bottom border. Quantities are bolded in JetBrains Mono. Swipe-to-delete gestures should be visually hinted at with a subtle chevron.