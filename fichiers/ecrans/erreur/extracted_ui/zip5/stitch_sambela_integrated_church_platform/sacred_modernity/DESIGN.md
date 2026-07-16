---
name: Sacred Modernity
colors:
  surface: '#fbf9f8'
  surface-dim: '#dbd9d9'
  surface-bright: '#fbf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f3'
  surface-container: '#efeded'
  surface-container-high: '#eae8e7'
  surface-container-highest: '#e4e2e2'
  on-surface: '#1b1c1c'
  on-surface-variant: '#45474c'
  inverse-surface: '#303030'
  inverse-on-surface: '#f2f0f0'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e72'
  primary: '#040c1c'
  on-primary: '#ffffff'
  primary-container: '#1a2233'
  on-primary-container: '#81899e'
  inverse-primary: '#bec6dd'
  secondary: '#775a19'
  on-secondary: '#ffffff'
  secondary-container: '#fed488'
  on-secondary-container: '#785a1a'
  tertiary: '#0b0c09'
  on-tertiary: '#ffffff'
  tertiary-container: '#22221f'
  on-tertiary-container: '#8a8985'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fa'
  primary-fixed-dim: '#bec6dd'
  on-primary-fixed: '#131b2c'
  on-primary-fixed-variant: '#3f4759'
  secondary-fixed: '#ffdea5'
  secondary-fixed-dim: '#e9c176'
  on-secondary-fixed: '#261900'
  on-secondary-fixed-variant: '#5d4201'
  tertiary-fixed: '#e4e2dd'
  tertiary-fixed-dim: '#c8c6c2'
  on-tertiary-fixed: '#1b1c19'
  on-tertiary-fixed-variant: '#474744'
  background: '#fbf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e2'
typography:
  display-lg:
    fontFamily: Libre Caslon Text
    fontSize: 48px
    fontWeight: '400'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Libre Caslon Text
    fontSize: 36px
    fontWeight: '400'
    lineHeight: 44px
  headline-md:
    fontFamily: Libre Caslon Text
    fontSize: 32px
    fontWeight: '400'
    lineHeight: 40px
  headline-sm:
    fontFamily: Libre Caslon Text
    fontSize: 24px
    fontWeight: '400'
    lineHeight: 32px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  caption:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  container-max: 1200px
  gutter: 24px
  margin-mobile: 20px
---

## Brand & Style

The design system is built on the intersection of ancient tradition and contemporary connection. It aims to evoke a sense of peace, reverence, and belonging. The visual language balances the weight of spiritual history with the lightness of modern digital utility, moving away from "corporate" or "clinical" aesthetics toward a warmer, more tactile experience.

The style is **Modern Minimalist with Tonal Layering**. It utilizes generous white space (or cream space) to allow content to breathe, high-quality editorial typography, and soft, organic depth. The goal is to make the user feel unhurried and inspired, as if they are entering a digital sanctuary.

## Colors

The palette is anchored in a deep, midnight navy that provides a foundation of trust and timelessness. This is contrasted by a warm, metallic gold used sparingly for highlights, calls to action, and symbols of "light" or "divinity." 

The canvas uses a soft cream rather than a pure digital white to reduce eye strain and provide a more parchment-like, organic feel. 

- **Primary (Midnight Navy):** Used for headlines, primary buttons, and navigation backgrounds to establish authority and depth.
- **Secondary (Warm Amber):** Used for interactive accents, iconography, and signifying special spiritual content.
- **Surface (Cream):** The primary background color for all screens.
- **Functional Neutrals:** Mid-tone charcoals and soft greys are used for body text and secondary information to maintain high legibility without the harshness of pure black.

## Typography

This design system uses a sophisticated typographic pairing to bridge the gap between the traditional and the modern.

**Libre Caslon Text** is used for headings. Its classical proportions and elegant serifs evoke the feeling of scripture and historical liturgy. It should be used with slightly tighter letter-spacing for large displays to maintain a premium, editorial look.

**Plus Jakarta Sans** is used for all functional and body text. Its soft, rounded terminals and open apertures make it highly legible and approachable, ensuring that long-form devotionals or community updates are easy to digest. Labels and small buttons use uppercase styling with increased letter-spacing for a modern, refined touch.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** with generous vertical rhythm. Content should never feel cramped; vertical spacing between sections (using `lg` and `xl` tokens) is encouraged to create a "breathing" effect.

- **Mobile:** A single-column layout with 20px side margins. 
- **Desktop:** A 12-column grid with a maximum container width of 1200px to ensure line lengths for text remain optimal for reading.
- **Rhythm:** All spacing is based on an 8px baseline grid. Use `md` (24px) for most component spacing to maintain a relaxed, open feel.

## Elevation & Depth

To maintain the peaceful and modern aesthetic, this design system avoids heavy, dark shadows. Instead, it uses **Ambient Tonal Depth**.

- **Surface Tiers:** Depth is primarily communicated through subtle shifts in background color (e.g., a slightly darker cream or a very soft gold tint for cards).
- **Shadows:** When elevation is required (such as for floating action buttons or primary cards), use long, diffused shadows with a low opacity (5-8%) tinted with the Primary Midnight Navy. This makes the elements feel as though they are gently lifting off the surface rather than casting a harsh silhouette.
- **Glassmorphism:** Use subtle backdrop blurs (10px - 20px) on top navigation bars to allow the warm background colors to peek through as the user scrolls.

## Shapes

The shape language is defined by "Rounded" (Level 2) geometry. This avoids the clinical feel of sharp corners and the overly casual feel of full pill-shapes.

- **Standard Elements:** 0.5rem (8px) corner radius for buttons and input fields.
- **Containers:** 1rem (16px) for cards and modals to create a soft, framing effect for community content and imagery.
- **Media:** Photography should use the `rounded-lg` (16px) or `rounded-xl` (24px) setting to feel like "portals" rather than flat images.

## Components

### Buttons
- **Primary:** Solid Midnight Navy with White or Gold text. 8px corner radius. Bold, centered labels using Plus Jakarta Sans.
- **Secondary:** Outlined in Navy or Gold with a transparent background. 
- **Tertiary:** Text-only with a Gold underline or icon for subtle navigation.

### Cards
Cards are the primary vehicle for content (Sermons, Events, Prayers). They should use a slightly lifted white surface against the cream background. Padding should be generous (`md` or 24px). Headers within cards use the Serif font.

### Lists
Lists should be separated by thin, low-contrast cream-grey lines rather than heavy borders. Each item should have a large touch target (minimum 56px height).

### Input Fields
Inputs use a soft-filled background (a tint of the Primary color at 5% opacity) with a bottom-only border that thickens when focused. This mimics traditional stationery.

### Specialized Components
- **Prayer Wall:** A masonry-style layout of cards with varying soft-tinted backgrounds (pale gold, pale navy, pale cream).
- **Meditation Player:** A minimalist audio interface using the secondary gold for progress bars and play buttons, emphasizing the "light" of the message.