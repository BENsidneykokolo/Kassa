---
name: Boutique Concierge
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#444748'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#747878'
  outline-variant: '#c4c7c7'
  surface-tint: '#5f5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1c1b1b'
  on-primary-container: '#858383'
  inverse-primary: '#c8c6c5'
  secondary: '#775a19'
  on-secondary: '#ffffff'
  secondary-container: '#fed488'
  on-secondary-container: '#785a1a'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#191c1d'
  on-tertiary-container: '#828485'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e5e2e1'
  primary-fixed-dim: '#c8c6c5'
  on-primary-fixed: '#1c1b1b'
  on-primary-fixed-variant: '#474746'
  secondary-fixed: '#ffdea5'
  secondary-fixed-dim: '#e9c176'
  on-secondary-fixed: '#261900'
  on-secondary-fixed-variant: '#5d4201'
  tertiary-fixed: '#e1e3e4'
  tertiary-fixed-dim: '#c5c7c8'
  on-tertiary-fixed: '#191c1d'
  on-tertiary-fixed-variant: '#454748'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  display-lg:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Montserrat
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  display-lg-mobile:
    fontFamily: Montserrat
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 48px
  safe-margin: 20px
  gutter: 12px
---

## Brand & Style
The design system is engineered for high-end hospitality environments, balancing the utilitarian speed required for a POS with the aesthetic grace of a luxury concierge service. The brand personality is poised, efficient, and sophisticated, aiming to make technology feel like an extension of premium service rather than a barrier.

The design style utilizes **Corporate Modern** with a **Tactile** edge. It features generous whitespace, soft depth through multi-layered shadows, and high-contrast typography to ensure legibility in varied lighting conditions—from sun-drenched terraces to dim, candle-lit lounges. The visual language avoids clutter, prioritizing purposeful motion and clear hit targets.

## Colors
The palette is anchored in a professional, "Deep Charcoal" (#1A1A1A) which provides the primary weight for text and structural elements. "Sophisticated Gold" (#C5A059) is used sparingly as a signature accent for primary actions, selection states, and brand-touchpoints, evoking a sense of prestige. 

The background remains a "Clean White" to maintain a sanitised and organized feel. Success and error states should deviate from standard bright tones, using slightly desaturated variations to maintain the premium aesthetic while ensuring immediate recognition for staff operations.

## Typography
This design system pairs **Montserrat** for headings to convey confidence and modern luxury, with **Inter** for body text and UI labels to ensure maximum clarity during fast-paced service. 

Headings use tighter letter spacing and bold weights to create a strong visual hierarchy. Labels and small metadata should utilize increased tracking (letter spacing) when set in all-caps to maintain legibility on mobile screens. For accessibility, the minimum font size for body text in the mobile interface is 14px, with 16px being the standard for interactive list items.

## Layout & Spacing
The system follows a **Fluid Grid** model optimized for mobile handsets and handheld tablets. A standard 4-column grid is used for phone portrait views, expanding to an 8-column grid for tablet views.

Spacing is built on a 4px base unit. Interaction targets (buttons, list items) must maintain a minimum height of 48px to accommodate rapid touch input. Vertical rhythm is driven by the `md` (24px) spacing unit to create the "airy" feel of a boutique service, preventing the interface from feeling cramped even when data-heavy.

## Elevation & Depth
Hierarchy is established through **Ambient Shadows** and **Tonal Layers**. Instead of harsh borders, surfaces use soft, diffused shadows with a slight y-axis offset to simulate physical cards resting on a white marble surface.

- **Level 0 (Base):** Clean White (#FFFFFF) background.
- **Level 1 (Cards/Items):** White surface with a 12% opacity charcoal shadow, 10px blur. Used for menu items and table cards.
- **Level 2 (Active/Modals):** White surface with a 18% opacity charcoal shadow, 20px blur. Used for order summaries and selection overlays.
- **Level 3 (Urgent):** Uses a subtle gold-tinted shadow to draw immediate attention to notifications or "Ready to Serve" alerts.

## Shapes
The shape language is defined by a **Rounded** aesthetic. Large corner radii are used to soften the "technical" nature of the POS, making the interface feel more approachable and modern. 

Standard containers and cards use a 16px (`rounded-lg`) radius. Primary action buttons utilize a 24px (`rounded-xl`) radius to create a distinct, touch-friendly silhouette. Small UI elements like checkboxes or input fields use an 8px radius to maintain consistency without losing structural integrity.

## Components
- **Buttons:** Primary buttons are Solid Charcoal with Gold text or Solid Gold with White text. They feature a high-gloss or subtle gradient effect to feel "pressable." Secondary buttons use a thick 2px border in Charcoal.
- **Cards:** Table and Menu cards use a white background with Level 1 elevation. High-resolution imagery for food items should use the same `rounded-lg` radius for consistency.
- **Chips:** Used for table status (e.g., "Occupied," "Cleaning," "Reserved"). These use low-saturation background tints (soft reds, greens, oranges) with bold, dark text.
- **Input Fields:** Floating labels with a 2px bottom border in Charcoal. On focus, the border transitions to Gold.
- **Lists:** High-density lists (like a kitchen order) use clear separators and 16px internal padding. Active items are highlighted with a vertical Gold bar on the left edge.
- **Table Map:** A custom component representing the floor plan. Tables should be represented as elevated circles or rounded squares with clear numerical labels in Montserrat.