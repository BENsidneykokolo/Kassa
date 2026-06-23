---
name: Clean African Tech
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0edec'
  surface-container-high: '#ebe7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#3d4943'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#6d7a73'
  outline-variant: '#bccac1'
  surface-tint: '#006c4e'
  primary: '#00694c'
  on-primary: '#ffffff'
  primary-container: '#008560'
  on-primary-container: '#f5fff7'
  inverse-primary: '#68dbae'
  secondary: '#0060a8'
  on-secondary: '#ffffff'
  secondary-container: '#5da9fe'
  on-secondary-container: '#003d6d'
  tertiary: '#805200'
  on-tertiary: '#ffffff'
  tertiary-container: '#a16900'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#86f8c9'
  primary-fixed-dim: '#68dbae'
  on-primary-fixed: '#002115'
  on-primary-fixed-variant: '#00513a'
  secondary-fixed: '#d2e4ff'
  secondary-fixed-dim: '#a1c9ff'
  on-secondary-fixed: '#001c38'
  on-secondary-fixed-variant: '#004880'
  tertiary-fixed: '#ffddb4'
  tertiary-fixed-dim: '#ffb955'
  on-tertiary-fixed: '#291800'
  on-tertiary-fixed-variant: '#633f00'
  background: '#fcf9f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
  coral-red: '#E24B4A'
  surface-muted: '#F7F8FA'
  surface-success: '#E1F5EE'
  surface-error: '#FCEBEB'
  surface-info: '#E6F1FB'
  surface-warning: '#FAEEDA'
  border-default: '#E0E0E0'
  text-secondary: '#555555'
  text-muted: '#999999'
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
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
  caption:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '400'
    lineHeight: 12px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter-mobile: 12px
  gutter-desktop: 24px
  margin-page: 16px
  stack-gap-sm: 8px
  stack-gap-md: 16px
  stack-gap-lg: 24px
---

## Brand & Style
The design system embodies a "Clean African Tech" aesthetic—a fusion of high-trust professional finance and the vibrant, energetic spirit of modern African enterprise. It is built to feel like a "Super-App," balancing the utilitarian requirements of a Point of Sale (POS) system with an inviting, accessible interface that scales from small merchant mobile screens to comprehensive tablet and desktop dashboards.

The visual style is **Corporate / Modern** with a **Tactile** edge. It moves away from purely flat design toward a layered, card-based system that uses soft shadows and depth to indicate interactivity. The brand personality is optimistic, reliable, and high-contrast, ensuring legibility in varied lighting conditions common in retail environments.

## Colors
The palette is rooted in a vibrant "V-shape" of functional colors. **Emerald Green** serves as the primary brand and success color, symbolizing growth and completed transactions. **Sky Blue** acts as the secondary brand identifier and information signal, while **Coral Red** is reserved strictly for critical errors and "expired" statuses. **Amber/Orange** provides a warm accent for warnings or highlights.

The neutral system uses a near-black for high-contrast typography against a pure white base. Muted surfaces (near-grays) are used to group secondary information within cards, ensuring the UI feels organized and uncluttered despite high information density.

## Typography
The system utilizes **Inter** exclusively to achieve a systematic, utilitarian, and modern feel. The hierarchy is designed for rapid scanning. 

- **Headlines:** Bold and tight-lettered to command attention for totals and boutique names.
- **Body:** Open and legible for product descriptions and list items.
- **Labels:** Semi-bold caps or medium weights used for status indicators and form labels to ensure they stand out even at small sizes.
- **Mobile Scaling:** Large headlines scale down for mobile to prevent awkward text wrapping, while body and label sizes remain consistent to preserve touch-target alignment.

## Layout & Spacing
This design system uses a **Fluid Grid** approach that adapts across three main breakpoints. The underlying rhythm is based on a **4px base unit**.

- **Mobile:** Single column or tight 2-column grids (for product cards). Horizontal page margins are set to 16px.
- **Tablet:** Transitions to a sidebar-and-canvas model. Information density increases, utilizing 3 or 4-column product grids.
- **Desktop:** A full dashboard experience with a multi-column fixed sidebar. Large-scale data tables and analytics dashboards utilize 12-column layouts.

Spacing between related elements (e.g., label to input) uses `stack-gap-sm`, while separation between distinct modules (e.g., product grid to payment bar) uses `stack-gap-lg`.

## Elevation & Depth
Visual hierarchy is established through a combination of **Tonal Layers** and **Ambient Shadows**. 

1.  **The Base:** The primary application background is `pure white` or `surface-muted`.
2.  **Level 1 (Cards):** Interactive cards use a subtle 1px border (`border-default`) and a low-opacity, wide-diffusion shadow to suggest "lift." 
    - *Shadow:* `0 4px 12px rgba(0, 0, 0, 0.05)`
3.  **Level 2 (Modals/Popups):** Bottom sheets and floating modals use a more pronounced shadow to indicate they are the focus.
    - *Shadow:* `0 8px 24px rgba(0, 0, 0, 0.12)`
4.  **State Feedback:** Active or "focused" cards lose their shadow in favor of a 2px `primary-color` border, creating a "pressed" or "selected" tactile response.

## Shapes
The shape language is friendly and approachable, utilizing a **Rounded** (0.5rem base) corner strategy. 

- **Interactive Elements:** Buttons, inputs, and product cards use a 16px (`rounded-lg`) radius to feel soft and touch-friendly.
- **Status Indicators:** Status pills and badges use a full `rounded-pill` (32px+) style to distinguish them from functional containers.
- **Layout Containers:** Larger layout blocks (like the "Super-App" menu containers) use a 24px (`rounded-xl`) radius to frame content comfortably.

## Components
- **Buttons:** Large (min 48px height) for mobile accessibility. Primary buttons use a solid `neutral-color` (black) with white text for maximum punch, while success-specific actions (like "Pay") use `primary-color`.
- **Cards:** Product cards must include a defined image area (often an emoji or icon on a `surface-muted` background) and clear price/quantity labels.
- **Input Fields:** Use a 16px corner radius and a `surface-muted` background. In focus mode, the background turns white and the border thickens to 2px `primary-color`.
- **Chips & Pills:** Used for status (Online/Offline, Stock). They must always pair a dark text color with a 10% opacity background of the same hue (e.g., Green text on `surface-success`).
- **Payment Bar:** A "sticky" component at the bottom of the screen that uses a high-contrast background to summarize the cart total and primary CTA.
- **Checkboxes/Radios:** Circular in shape with a thick 2px stroke when unselected, filling with `primary-color` and a white checkmark when active.