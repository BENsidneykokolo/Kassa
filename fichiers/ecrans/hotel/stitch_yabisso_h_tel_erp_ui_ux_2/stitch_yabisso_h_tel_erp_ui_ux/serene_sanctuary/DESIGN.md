---
name: Serene Sanctuary
colors:
  surface: '#faf9f7'
  surface-dim: '#dadad8'
  surface-bright: '#faf9f7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3f1'
  surface-container: '#efeeec'
  surface-container-high: '#e9e8e6'
  surface-container-highest: '#e3e2e0'
  on-surface: '#1a1c1b'
  on-surface-variant: '#434843'
  inverse-surface: '#2f3130'
  inverse-on-surface: '#f1f1ef'
  outline: '#747872'
  outline-variant: '#c3c8c1'
  surface-tint: '#526255'
  primary: '#455548'
  on-primary: '#ffffff'
  primary-container: '#5d6d5f'
  on-primary-container: '#ddeedd'
  inverse-primary: '#bacbba'
  secondary: '#695d40'
  on-secondary: '#ffffff'
  secondary-container: '#eedeb9'
  on-secondary-container: '#6d6244'
  tertiary: '#53514c'
  on-tertiary: '#ffffff'
  tertiary-container: '#6c6964'
  on-tertiary-container: '#eee9e3'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d6e7d6'
  primary-fixed-dim: '#bacbba'
  on-primary-fixed: '#101f14'
  on-primary-fixed-variant: '#3b4a3e'
  secondary-fixed: '#f1e1bc'
  secondary-fixed-dim: '#d4c5a1'
  on-secondary-fixed: '#221b04'
  on-secondary-fixed-variant: '#50462a'
  tertiary-fixed: '#e7e2dc'
  tertiary-fixed-dim: '#cac6c0'
  on-tertiary-fixed: '#1d1b18'
  on-tertiary-fixed-variant: '#494642'
  background: '#faf9f7'
  on-background: '#1a1c1b'
  surface-variant: '#e3e2e0'
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
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.1em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1200px
  gutter: 24px
  margin-mobile: 20px
  section-gap-lg: 120px
  section-gap-md: 80px
---

## Brand & Style
The design system for Yabisso Hôtel’s Spa & Wellness branch is rooted in **Organic Minimalism**. It aims to evoke a sense of immediate deceleration, luxury, and holistic well-being. The target audience is discerning travelers and local patrons seeking a premium, restorative escape.

The aesthetic blends soft, tactile minimalism with editorial elegance. It utilizes generous whitespace to simulate the physical breathing room found in a high-end spa. Elements should feel light, as if floating, avoiding heavy shadows or aggressive transitions. The visual narrative is one of "Quiet Luxury"—where quality is felt through refined proportions and a curated, muted palette rather than ornamental excess.

## Colors
The palette is inspired by natural elements found in a sanctuary:
- **Sage Green (Primary):** Used for primary actions and grounding elements. Represents nature and tranquility.
- **Sand (Secondary):** Used for secondary UI elements and subtle highlights.
- **Muted Gold (Accent):** Reserved for premium indicators, luxury iconography, and thin borders.
- **Off-White (Neutral):** The primary background color to ensure the UI feels expansive and clean.
- **Deep Slate (#2D332E):** Used strictly for high-contrast typography to maintain readability without the harshness of pure black.

## Typography
This design system employs a sophisticated pairing of a literary serif and a contemporary grotesque.
- **Libre Caslon Text** is used for headings to convey the heritage and timelessness of the hotel. It should be used with slightly tighter letter-spacing for large displays.
- **Hanken Grotesk** provides a clean, modern contrast for body text and functional labels, ensuring high legibility and a professional tech-forward feel.
- Use `label-caps` for section headers and small navigational cues to introduce a structured, rhythmic feel to the layout.

## Layout & Spacing
The layout follows a **Fluid Grid** model with significantly exaggerated vertical spacing to emphasize luxury. 
- **Desktop:** 12-column grid with wide gutters (24px) and a centralized container.
- **Mobile:** 4-column grid with 20px side margins.
- **Spacing Philosophy:** Use "Breathable Blocks." Avoid crowding content. Sections should be separated by `section-gap-md` or `section-gap-lg` to create a pacing that feels unhurried. 
- **Alignment:** Use asymmetrical layouts for imagery (overlapping slightly with text) to break the rigidity of standard web grids and feel more like a lifestyle magazine.

## Elevation & Depth
Depth is created through **Tonal Layering** and **Soft Ambient Shadows** rather than structural borders.
- **Surfaces:** Use subtle shifts in background color (e.g., moving from Off-White to Tertiary Sand) to define card areas.
- **Shadows:** Only use shadows for "floating" elements like booking modals or hovering cards. These shadows should be extremely diffused: `0px 20px 40px rgba(93, 109, 95, 0.05)`.
- **Glassmorphism:** Use light backdrop blurs (10px) on navigation bars to maintain the sense of depth while scrolling over rich imagery.

## Shapes
The shape language is **Soft and Architectural**. 
- Buttons and containers use a subtle 4px radius (`roundedness: 1`) to feel intentional and refined.
- **Special Elements:** For decorative imagery or "Featured Treatment" cards, use a single-corner "Leaf" radius (e.g., top-left and bottom-right at 100px) to mirror organic forms found in nature.
- **Dividers:** Use hairline strokes (0.5pt) in Muted Gold or light Sage for a delicate, premium separation.

## Components
- **Buttons:** 
    - *Primary:* Solid Sage Green with white Hanken Grotesk text. 
    - *Secondary:* Ghost style with a Muted Gold border and gold text.
    - *Interaction:* Subtle scale-down effect (0.98) on click to feel tactile.
- **Cards:** Use "Floating Container" style. No borders, just a slight Tonal Layer change or a very soft shadow. 
- **Input Fields:** Bottom-border only (underline style) to maintain a minimalist, non-intrusive appearance. Label should be in `label-caps`.
- **Booking Calendar:** Use high whitespace; selected dates should be highlighted with a soft Sage circle.
- **Chips/Filters:** Pill-shaped with a Tertiary background. For "Treatment Types" (e.g., Massage, Facial), use small organic icons.
- **Relaxation Progress Bar:** For multi-step booking, use a very thin horizontal line with small dots, avoiding heavy "step" indicators.