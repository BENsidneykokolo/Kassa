---
name: Executive Revenue Concierge
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#444748'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#747878'
  outline-variant: '#c4c7c7'
  surface-tint: '#5f5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1c1b1b'
  on-primary-container: '#858383'
  inverse-primary: '#c8c6c5'
  secondary: '#7b41b3'
  on-secondary: '#ffffff'
  secondary-container: '#c588fe'
  on-secondary-container: '#54118a'
  tertiary: '#735c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#cca730'
  on-tertiary-container: '#4f3e00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e5e2e1'
  primary-fixed-dim: '#c8c6c5'
  on-primary-fixed: '#1c1b1b'
  on-primary-fixed-variant: '#474746'
  secondary-fixed: '#f0dbff'
  secondary-fixed-dim: '#ddb7ff'
  on-secondary-fixed: '#2c0050'
  on-secondary-fixed-variant: '#622599'
  tertiary-fixed: '#ffe088'
  tertiary-fixed-dim: '#e9c349'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#574500'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-lg:
    fontFamily: Libre Caslon Text
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Libre Caslon Text
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-md:
    fontFamily: Libre Caslon Text
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  ai-insight-callout:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 28px
  data-tabular:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.1em
  body-main:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  container-max: 1440px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
  data-density-gap: 8px
---

## Brand & Style
The design system embodies the "Digital Majordomo" archetype—an elite, proactive concierge for high-stakes revenue management. It targets C-suite executives and luxury asset managers who require immediate, AI-synthesized clarity over raw data. 

The visual style is **Contemporary Luxury**, blending the prestige of high-end editorial design with the precision of advanced financial technology. It utilizes a refined **Minimalism** punctuated by **Glassmorphism** to represent the "transparency" of AI logic. The emotional response is one of calm authority, absolute reliability, and effortless control.

## Colors
The palette is rooted in a "Tuxedo" base of deep obsidian and crisp paper whites, ensuring high-contrast legibility. 

- **Primary & Neutral**: Establish a classic, formal foundation.
- **AI Accent (Deep Indigo)**: Used exclusively for predictive features, machine-learning insights, and automated recommendations.
- **Yield Indicators**: Emerald and Crimson are calibrated for financial "stop/go" signals, maintaining professional saturation levels to avoid a "gaming" aesthetic.
- **Market Neutral**: A stable slate for baseline data and historical benchmarks.
- **Gold Accent (Tertiary)**: Reserved for "Executive Tier" insights or premium milestones.

## Typography
This design system employs a high-contrast typographic pairing to distinguish between narrative authority and technical precision.

- **Libre Caslon Text**: Used for page titles, executive summaries, and high-level insights. It provides the "editorial" feel of a bespoke financial report.
- **Hanken Grotesk**: The primary engine for body text and revenue figures. Its high x-height and clean geometry ensure readability in dense data grids.
- **JetBrains Mono**: Utilized for micro-labels, metadata, and AI "confidence scores" to evoke a sense of technical accuracy and systematic processing.
- **Numerical Formatting**: All financial figures must use **Tabular Lining** figures (tnum) to ensure vertical alignment in tables.

## Layout & Spacing
The layout follows a **Fixed Grid** philosophy on desktop to maintain the "Dashboard as a Document" feel, transitioning to a fluid stack on mobile.

- **The 8px Rhythm**: All components and whitespace are multiples of 8px (or 4px for tight data views).
- **Executive Margins**: Ample whitespace (48px+) is required around primary insights to prevent cognitive overload.
- **Data Density**: Within AI modules, padding is reduced to 8px to allow for side-by-side comparison of predictive vs. actual yields.
- **Breakpoints**: 
  - Mobile: 0 - 599px (Single column, 16px margins)
  - Tablet: 600px - 1023px (8-column grid)
  - Desktop: 1024px+ (12-column grid, 1440px max-width)

## Elevation & Depth
Hierarchy is established through **Tonal Layers** and **Glassmorphism**, avoiding heavy drop shadows to maintain a clean, modern aesthetic.

- **Level 0 (Surface)**: The main canvas, using `neutral_color_hex`.
- **Level 1 (Cards)**: White backgrounds with a subtle 1px border (#E2E8F0). No shadow.
- **Level 2 (AI Overlays)**: Predictive analytics panels use a "Frosted Glass" effect (Background Blur: 12px, Opacity: 80%) to float above historical data.
- **Depth Cues**: Instead of shadows, use subtle inner-glows or 1px strokes in `ai_accent` to indicate active AI "thinking" states or focus areas.

## Shapes
The shape language is **Soft and Disciplined**. 

- **Global Radius**: A base of 4px (`rounded-sm`) is used for buttons and inputs to keep the look sharp and professional.
- **Large Components**: Cards and AI insight modules use 8px (`rounded-lg`) to provide a subtle modern friendliness.
- **Interactive Elements**: Checkboxes and radio buttons maintain sharp corners or minimal rounding to align with the "Standardized Form" aesthetic of elite institutions.

## Components

- **Executive Buttons**: Primary buttons use obsidian backgrounds with gold (`tertiary`) hover states. Text is always uppercase `label-caps`.
- **AI Insight Cards**: Distinguished by a vertical `ai_accent` left-border and a subtle indigo gradient wash. They feature an "AI Explained" toggle to reveal the logic behind a yield prediction.
- **Yield Badges**: Small, pill-shaped indicators for +/-% changes. Backgrounds are high-transparency (10%) versions of `yield_up` or `yield_down`, with solid-color text.
- **Data Grids**: High-density rows with `data-tabular` typography. Every second row features a subtle ghost-grey fill for scanability.
- **Predictive Sparklines**: Minimalist charts using the `ai_accent` color with a gradient area fill to show forecasted revenue trajectories.
- **Trend Icons**: Custom-drawn, ultra-thin (1pt) icons that indicate market volatility, neutral stability, or aggressive growth.