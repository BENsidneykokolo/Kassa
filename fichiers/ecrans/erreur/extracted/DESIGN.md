---
name: Luminous Retail
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#424656'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#727687'
  outline-variant: '#c2c6d8'
  surface-tint: '#0054d6'
  primary: '#0050cb'
  on-primary: '#ffffff'
  primary-container: '#0066ff'
  on-primary-container: '#f8f7ff'
  inverse-primary: '#b3c5ff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#7f4f00'
  on-tertiary: '#ffffff'
  tertiary-container: '#a06500'
  on-tertiary-container: '#fff7f1'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae1ff'
  primary-fixed-dim: '#b3c5ff'
  on-primary-fixed: '#001849'
  on-primary-fixed-variant: '#003fa4'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
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
  label-bold:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  price-display:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 16px
  gutter-md: 12px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style

This design system is built for a high-velocity mobile shopping experience that balances utility with a premium feel. The brand personality is efficient, trustworthy, and vibrant, designed to evoke a sense of clarity and ease during the purchasing journey.

The design style is **Corporate / Modern** with a lean toward **Minimalism**. It prioritizes heavy whitespace to let product imagery lead, while using soft elevation and precise geometry to define the interface. The emotional response should be one of "effortless discovery"—where the UI recedes and the content shines.

## Colors

The palette is anchored by a vibrant **Electric Blue** as the primary color, chosen for its high visibility and association with secure, modern commerce. 

- **Primary:** Used for main actions (CTA), active states, and brand highlights.
- **Secondary:** A lush green used for "In Stock" indicators, success messages, and price drops.
- **Surface & Backgrounds:** We use a high-brightness light mode. Backgrounds stay at `#FFFFFF`, while container surfaces use subtle off-whites to create soft contrast.
- **Overlays:** For camera-view scanning and image zoom, a semi-transparent dark overlay (`rgba(0, 0, 0, 0.65)`) is used to maintain contrast for white iconography and status bars.

## Typography

The design system utilizes **Inter** exclusively to leverage its exceptional legibility and systematic feel. 

- **Headlines:** Use tight letter spacing and bold weights to create a strong hierarchy.
- **Body Text:** Standardizes on a 16px base for accessibility in product descriptions.
- **Price Display:** A specialized weight and size are used to ensure the price is the second most visible element after the product image.
- **Labels:** Small, uppercase bold text is used for category tags and "New Arrival" badges.

## Layout & Spacing

This design system uses a **Fluid Grid** model optimized for mobile-first interaction. 

- **Base Unit:** 4px baseline grid. All margins and paddings must be multiples of 4 or 8.
- **Margins:** A standard 16px horizontal safe area is maintained across all mobile screens.
- **Product Lists:** Utilize a 2-column fluid grid for browsing, switching to a single-column "stack" for detailed list views.
- **Touch Targets:** All interactive elements must maintain a minimum hit area of 44x44px.

## Elevation & Depth

Visual hierarchy is achieved through **Tonal Layers** and **Ambient Shadows**.

- **Level 0 (Base):** Flat background for the main canvas.
- **Level 1 (Cards):** Subtly elevated with a 4px blur, 0% spread, and 5% opacity black shadow. This creates a soft separation without clutter.
- **Level 2 (Sticky Nav/Bars):** Higher elevation with a 12px blur and 8% opacity to signify they sit above the scrolling content.
- **Camera Overlays:** Use depth through "hole-punching"—the UI controls sit at a high elevation (Level 3) over the semi-transparent dark backdrop.

## Shapes

The shape language is **Rounded**, reflecting a modern and friendly aesthetic.

- **Primary Radius:** 0.5rem (8px) for buttons and standard input fields.
- **Large Radius:** 1rem (16px) for product cards and bottom sheets, providing a "contained" and safe feel.
- **Imagery:** Product photos should always inherit the container's roundedness to ensure a cohesive, finished look.

## Components

### Buttons
Primary buttons are high-contrast (Blue background, White text) with 8px rounded corners. Secondary buttons use a light-gray ghost style or a subtle blue outline.

### Product List Items
Cards feature a 1:1 aspect ratio image at the top, followed by a 12px padded content area. The price is always positioned in the bottom-right or directly below the product title in bold.

### Input Fields
Inputs use a 1px border (`#E2E8F0`) that thickens and changes to the primary blue on focus. Error states use a soft red border and text.

### Camera Overlays (Scanning/AR)
The camera interface utilizes a "Clear Viewport" with controls clustered at the bottom. Use a 65% dark alpha background for text labels and the "Close" button to ensure they remain legible against diverse real-world backgrounds.

### Chips & Badges
Small, pill-shaped chips (32px radius) are used for size selection and filtering. Active filters use a primary color fill; inactive ones use a light-gray stroke.