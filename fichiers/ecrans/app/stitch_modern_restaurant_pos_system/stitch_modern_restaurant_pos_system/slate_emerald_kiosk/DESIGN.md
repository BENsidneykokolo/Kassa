---
name: Slate & Emerald Kiosk
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
  on-surface-variant: '#3c4a42'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#6c7a71'
  outline-variant: '#bbcabf'
  surface-tint: '#006c49'
  primary: '#006c49'
  on-primary: '#ffffff'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#4edea3'
  secondary: '#565e74'
  on-secondary: '#ffffff'
  secondary-container: '#dae2fd'
  on-secondary-container: '#5c647a'
  tertiary: '#505f76'
  on-tertiary: '#ffffff'
  tertiary-container: '#94a4bd'
  on-tertiary-container: '#2a3a4f'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#dae2fd'
  secondary-fixed-dim: '#bec6e0'
  on-secondary-fixed: '#131b2e'
  on-secondary-fixed-variant: '#3f465c'
  tertiary-fixed: '#d3e4fe'
  tertiary-fixed-dim: '#b7c8e1'
  on-tertiary-fixed: '#0b1c30'
  on-tertiary-fixed-variant: '#38485d'
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
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  label-lg:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 18px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  touch-target-min: 48px
  sidebar-width: 320px
  content-margin: 32px
  gutter: 24px
  stack-sm: 12px
  stack-md: 24px
  stack-lg: 40px
---

## Brand & Style

This design system is optimized for high-traffic kiosk environments, prioritizing speed, legibility, and physical ergonomics. The aesthetic merges **Corporate Modern** reliability with **Minimalist** clarity to ensure that users—ranging from staff to customers—can navigate complex POS flows without cognitive friction. 

The personality is professional and efficient, utilizing deep charcoal tones to ground the interface while vibrant emerald accents guide the eye toward primary actions. The emotional response is one of confidence and stability; the interface feels like a high-performance tool rather than a generic application. Large touch targets and generous whitespace account for the physical distance and varying light conditions typical of tablet kiosk placements.

## Colors

The palette is built on a foundation of "Slate" neutrals to provide a sophisticated, low-glare background for long-duration use. 

- **Primary (Emerald):** Used exclusively for successful actions, "Add to Cart" buttons, and active states. It must maintain high contrast against both white and slate backgrounds.
- **Secondary (Slate 900):** Reserved for headers, high-level navigation, and text to ensure maximum readability.
- **Tertiary (Slate 500):** Used for secondary information, icons, and deactivated states.
- **Neutral (Slate 50):** The primary canvas color, providing a clean, "paper-like" feel that reduces eye strain in bright retail environments.

## Typography

This design system employs **Hanken Grotesk** across all roles to maintain a cohesive, technical, and sharp appearance. 

For the kiosk context, font sizes are bumped significantly higher than standard mobile or desktop sizes to compensate for the arm's-length viewing distance. Headlines use a tighter letter-spacing for a "unit-like" feel, while labels are slightly tracked out to ensure clarity in uppercase formats (like SKU numbers or prices). Hierarchy is strictly enforced through weight: use Bold (700) and SemiBold (600) for interactive elements and Regular (400) for descriptive content.

## Layout & Spacing

The layout follows a **Fixed Sidebar + Fluid Content** model optimized for landscape tablet orientation. 

- **Sidebar (320px):** Positioned on the left for navigation or on the right for a persistent "Current Order/Cart" summary. This area uses a Slate 900 background for high contrast against the content area.
- **Grid:** A 12-column grid is used within the fluid content area, with 24px gutters to prevent visual crowding.
- **Safe Zones:** A 32px outer margin ensures no interactive elements are placed too close to the physical bezel of the tablet or the kiosk enclosure.
- **Touch Targets:** All interactive elements (buttons, list items) must be at least 48px in height, though 56px or 64px is preferred for primary transactional buttons.

## Elevation & Depth

To maintain a clean, professional "tool" feel, this design system avoids heavy shadows. Instead, it utilizes **Tonal Layers** and **Low-Contrast Outlines**.

- **Level 0 (Base):** Slate 50.
- **Level 1 (Cards/Containers):** Pure white background with a 1px Slate 200 border. This distinguishes items like product tiles from the background.
- **Level 2 (Active/Modals):** A soft, neutral shadow (0px 4px 20px, 5% Slate 900 opacity) is used only for elements that sit above the main plane, such as pop-up modifiers or numerical keypads.
- **Interaction:** When a card is selected, the border color shifts to Emerald 500 with a 2px stroke, rather than using a shadow, to maintain a flat and efficient look.

## Shapes

The shape language is **Soft** but disciplined. 

A 4px (0.25rem) base radius is used for small elements like checkboxes and input fields. Larger containers, such as product cards and primary buttons, use an 8px (0.5rem) radius. This subtle rounding softens the industrial feel of the Slate palette without appearing overly "bubbly" or consumer-oriented, maintaining the professional rigor required for POS software.

## Components

- **Buttons:** Primary buttons are Emerald with white text, using a minimum height of 56px. Secondary buttons use a Slate 900 outline or ghost style.
- **Product Cards:** Tile-based with an image top, title center, and price bottom-right. The entire tile acts as a touch target.
- **Input Fields:** Large, 56px height fields with a 1px Slate 300 border. Labels are always visible above the field (never floating) for maximum clarity.
- **Lists:** High-density list items for the cart sidebar use 64px minimum heights. Swipe-to-delete gestures should be supplemented with visible "X" icons for clarity.
- **Chips:** Used for modifiers (e.g., "No Onions"). These use a Slate 100 background with Slate 700 text; when selected, they flip to Emerald background.
- **Numerical Keypad:** Large, clear buttons (minimum 80x80px) with high-contrast text for rapid price or quantity entry.