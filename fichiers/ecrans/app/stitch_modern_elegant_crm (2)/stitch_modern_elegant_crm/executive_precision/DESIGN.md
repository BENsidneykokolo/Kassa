---
name: Executive Precision
colors:
  surface: '#f7fafd'
  surface-dim: '#d7dadd'
  surface-bright: '#f7fafd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f4f7'
  surface-container: '#ebeef1'
  surface-container-high: '#e5e8eb'
  surface-container-highest: '#e0e3e6'
  on-surface: '#181c1e'
  on-surface-variant: '#43474d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eef1f4'
  outline: '#74777e'
  outline-variant: '#c4c6ce'
  surface-tint: '#49607e'
  primary: '#000f22'
  on-primary: '#ffffff'
  primary-container: '#0a2540'
  on-primary-container: '#768dad'
  inverse-primary: '#b0c8eb'
  secondary: '#4a3ee6'
  on-secondary: '#ffffff'
  secondary-container: '#645cff'
  on-secondary-container: '#fffbff'
  tertiary: '#001117'
  on-tertiary: '#ffffff'
  tertiary-container: '#002832'
  on-tertiary-container: '#0098b7'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d2e4ff'
  primary-fixed-dim: '#b0c8eb'
  on-primary-fixed: '#001c37'
  on-primary-fixed-variant: '#314865'
  secondary-fixed: '#e2dfff'
  secondary-fixed-dim: '#c3c0ff'
  on-secondary-fixed: '#0f0069'
  on-secondary-fixed-variant: '#321ed2'
  tertiary-fixed: '#b4ebff'
  tertiary-fixed-dim: '#3cd7ff'
  on-tertiary-fixed: '#001f27'
  on-tertiary-fixed-variant: '#004e5f'
  background: '#f7fafd'
  on-background: '#181c1e'
  surface-variant: '#e0e3e6'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
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
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 20px
  safe-area: env(safe-area-inset-bottom)
---

## Brand & Style
The design system is engineered for a modern, high-stakes CRM environment where clarity and confidence are paramount. It targets sales professionals and executives who require a tool that feels both powerful and effortless. 

The aesthetic is **Corporate Modern** with a focus on high-contrast clarity and premium finishes. By utilizing a "Soft White" base, the interface reduces eye strain during long working sessions while allowing the "Trust Blue" and "Innovation Purple" to signal authority and action. The emotional response is one of organized control, reliability, and technological sophistication. Heavy whitespace is used strategically to separate complex data sets, ensuring the user is never overwhelmed by the density of CRM information.

## Colors
The palette is anchored by **Trust Blue** (#0A2540), used for primary navigation, headers, and core structural elements to establish a foundation of stability. **Innovation Purple** (#635BFF) serves as the high-energy accent color for primary actions, progress indicators, and "new" states, guiding the user's eye toward growth-oriented tasks. 

A tertiary **Cyan** is introduced sparingly for data visualization and success states. The background is strictly **Soft White** (#F6F9FC), providing a clean canvas that feels more premium and less sterile than pure white. Text utilizes a tiered slate scale to maintain high legibility without the harshness of pure black.

## Typography
This design system utilizes **Inter** across all levels to leverage its exceptional legibility and systematic feel. The type hierarchy is strictly enforced to organize complex customer data. 

Headlines use tighter letter-spacing and heavier weights to command attention, while body text remains airy and functional. Labels use a slightly increased letter-spacing and uppercase styling for secondary metadata (like timestamps or status categories) to distinguish them from actionable data. Mobile-specific headlines ensure that large titles remain readable on narrow viewports without breaking into excessive lines.

## Layout & Spacing
The layout follows a **fluid grid** model optimized for mobile-first interaction. A 4px baseline grid ensures vertical rhythm, while a standard 16px gutter provides consistent horizontal breathing room. 

On mobile devices, the side margins are set to 20px to prevent content from feeling crowded against the screen edges. Component spacing relies on "Safe Areas" for gestures. Elements like contact lists and deal cards should utilize a consistent 16px internal padding (md) to maintain the "generous whitespace" required for a premium feel.

## Elevation & Depth
Depth is created through **Ambient Shadows** and **Tonal Layers**. Instead of harsh black shadows, this design system uses low-opacity shadows tinted with the Primary Blue: `box-shadow: 0 4px 12px rgba(10, 37, 64, 0.08)`. 

- **Level 0 (Surface):** The Soft White background.
- **Level 1 (Cards):** Pure White (#FFFFFF) surfaces with a subtle 1px border (#E3E8EE) and the ambient shadow mentioned above.
- **Level 2 (Modals/Overlays):** Elevated surfaces with a deeper shadow for focus.

Shadows should feel "soft" and diffused, suggesting a physical object resting just above the surface rather than a floating light source.

## Shapes
The shape language is defined by **Rounded** geometry. A base radius of 12px (0.75rem) is used for standard components like input fields and small cards. Primary action containers and large dashboard cards utilize 16px (1rem) for a more approachable and modern silhouette. 

Interactive elements like chips and specific tag indicators may utilize a pill-shape (full rounding) to contrast against the structured grid of the CRM cards. This balance of geometric precision and organic curves creates a "friendly professional" atmosphere.

## Components

### Buttons
Primary buttons use the **Innovation Purple** (#635BFF) with white text and a 12px corner radius. Secondary buttons should use a ghost style (Trust Blue outline) or a subtle gray fill to maintain hierarchy.

### Input Fields
Inputs feature a 12px radius, a Soft White fill, and a subtle 1px border. When focused, the border transitions to the Innovation Purple with a slight outer glow (2px). Labels are positioned above the input in the `label-md` style.

### Cards (Leads & Deals)
Cards are the heart of the CRM. They must be pure white (#FFFFFF) against the Soft White background. They utilize 16px padding and 16px corner radius. Include a subtle shadow to separate them from the background.

### Chips & Badges
Used for status indicators (e.g., "In Progress", "Closed"). Use a low-saturation background of the status color (e.g., light green for "Won") with high-saturation text for maximum readability and a pill-shaped radius.

### Navigation
The mobile bottom navigation should use a "glass" effect (backdrop-blur) with a thin top border. Icons are outlined when inactive and filled with Trust Blue when active.

### Progress Bars
Used for deal pipelines. These should be smooth, using a 4px height and the Innovation Purple to indicate the "active" stage, with a light gray for "upcoming" stages.