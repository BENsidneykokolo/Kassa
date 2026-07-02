---
name: Academic Clarity
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
  secondary: '#006b5f'
  on-secondary: '#ffffff'
  secondary-container: '#6df5e1'
  on-secondary-container: '#006f64'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#40000d'
  on-tertiary-container: '#f23d5c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#71f8e4'
  secondary-fixed-dim: '#4fdbc8'
  on-secondary-fixed: '#00201c'
  on-secondary-fixed-variant: '#005048'
  tertiary-fixed: '#ffdadb'
  tertiary-fixed-dim: '#ffb2b7'
  on-tertiary-fixed: '#40000d'
  on-tertiary-fixed-variant: '#92002a'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
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
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The brand identity focuses on reliability, institutional excellence, and modern accessibility. This design system bridges the gap between traditional academic prestige and the seamless efficiency of a high-growth SaaS product. 

The aesthetic is **Sophisticated Minimalism**. It prioritizes heavy whitespace to reduce cognitive load during complex application processes. The emotional response is one of calm confidence; users should feel that their information is handled with care and that the path forward is always clear. The style utilizes subtle depth through tonal layering and soft, expansive shadows to create a tactile sense of organization without the clutter of traditional "institutional" web design.

## Colors

The palette is anchored by a deep **Navy Blue** (Primary), providing the necessary professional weight and authority for an educational institution. 

- **Primary (#0F172A):** Used for headlines, navigation backgrounds, and primary actions. It ensures high-contrast readability and a sense of stability.
- **Secondary / Teal (#14B8A6):** Represents growth and progress. Used for success states, progress indicators, and subtle callouts.
- **Tertiary / Coral (#F43F5E):** Used sparingly for urgent notifications or specific "Apply Now" accents to draw the eye without feeling aggressive.
- **Neutral / Slate (#F8FAFC):** The foundational canvas. Using off-white slates instead of pure white reduces eye strain and adds a layer of modern sophistication.

## Typography

This design system utilizes **Inter** exclusively to maintain a systematic, utilitarian, yet modern feel. The typeface’s high x-height ensures exceptional legibility in dense form fields and long-form instructional text.

- **Headlines:** Use tighter letter spacing and semi-bold/bold weights to create a strong visual hierarchy.
- **Body Text:** Standard weight with generous line height (1.5x) to facilitate reading speed.
- **Labels:** Slightly increased tracking for all-caps variants to maintain clarity at small sizes.

## Layout & Spacing

The layout follows a **Fluid Grid** model with a maximum container width to ensure readability on ultra-wide monitors. 

- **The 8px Rule:** All spacing increments (padding, margins, gap) must be multiples of 8px to maintain a rhythmic vertical flow.
- **Desktop:** 12-column grid with 24px gutters. Page margins are generous (40px) to enhance the "spacious" feel.
- **Tablet:** 8-column grid with 20px gutters.
- **Mobile:** 4-column grid with 16px gutters. Elements should stack vertically, and padding within cards should reduce to 16px to maximize screen real estate.

## Elevation & Depth

Hierarchy is established through **Ambient Shadows** and **Tonal Layers**. This design system avoids harsh borders in favor of depth.

- **Level 0 (Base):** The neutral background (#F8FAFC).
- **Level 1 (Cards):** Pure white surface (#FFFFFF) with a very soft, diffused shadow: `0px 4px 20px rgba(15, 23, 42, 0.05)`.
- **Level 2 (Interactive/Floating):** Used for dropdowns and active modals. A more pronounced shadow: `0px 10px 30px rgba(15, 23, 42, 0.1)`.
- **Focus States:** Instead of a simple color change, focused inputs use a 2px outer glow in the Secondary Teal color to provide clear visual feedback.

## Shapes

The shape language is friendly and approachable, using **Rounded** corners across all UI elements. 

- **Standard Elements:** 0.5rem (8px) for buttons, inputs, and small widgets.
- **Containers:** 1rem (16px) for main content cards and banners.
- **Large Components:** 1.5rem (24px) for featured sections or onboarding modals.
- **Pills:** Full rounding (999px) is reserved exclusively for status chips (e.g., "In Progress", "Submitted") to distinguish them from actionable buttons.

## Components

### Buttons
- **Primary:** Navy Blue background, White text. High-contrast, 0.5rem radius.
- **Secondary:** White background, Navy Blue border (1px), Navy Blue text.
- **Ghost:** No background or border, Navy Blue text. Used for less important actions like "Cancel."

### Input Fields
- Inputs feature a light grey border (Slate-200) that transitions to the Secondary Teal on focus. 
- Labels are positioned above the field in `label-md` for maximum clarity during the application process.

### Cards
- White background with `rounded-lg` (16px).
- Use cards to group related application questions (e.g., "Personal Information," "Academic History").

### Progress Indicators
- A horizontal stepper at the top of the application is mandatory. 
- Completed steps use the Secondary Teal with a checkmark icon; the current step uses a Primary Navy Blue outline.

### Chips & Tags
- Used for status updates. These are pill-shaped with low-opacity backgrounds of the status color (e.g., light teal background with dark teal text).