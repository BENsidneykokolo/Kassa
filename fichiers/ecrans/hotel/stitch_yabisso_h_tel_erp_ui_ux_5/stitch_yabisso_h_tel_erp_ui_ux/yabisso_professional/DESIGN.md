---
name: Yabisso Professional
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
  secondary: '#515f74'
  on-secondary: '#ffffff'
  secondary-container: '#d5e3fd'
  on-secondary-container: '#57657b'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#001e2f'
  on-tertiary-container: '#008cc7'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#d5e3fd'
  secondary-fixed-dim: '#b9c7e0'
  on-secondary-fixed: '#0d1c2f'
  on-secondary-fixed-variant: '#3a485c'
  tertiary-fixed: '#c9e6ff'
  tertiary-fixed-dim: '#89ceff'
  on-tertiary-fixed: '#001e2f'
  on-tertiary-fixed-variant: '#004c6e'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Hanken Grotesk
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
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
  display-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 24px
  gutter: 16px
  section-gap: 32px
  sidebar-width: 280px
  stack-xs: 4px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style
The design system is engineered for high-stakes administrative environments where clarity, security, and precision are paramount. The brand personality is **authoritative, systematic, and stoic**, prioritizing functional density over decorative flair. 

The aesthetic follows a **Modern Corporate** direction with subtle **Minimalist** influences. It utilizes a structured information hierarchy to manage complex data sets, such as granular user permissions and audit logs. The emotional response should be one of "controlled reliability"—users should feel that the system is unshakeable and that every action is intentional and secure. High-fidelity execution is achieved through precise alignment, rigorous typographic scales, and a restrained use of depth.

## Colors
The palette is rooted in a "Command Navy" and "Industrial Slate" foundation to evoke security and institutional trust. 

- **Primary (#0F172A):** Used for navigation sidebars, primary headings, and high-importance interaction states. It grounds the UI in authority.
- **Secondary (#334155):** Applied to supporting text, icons, and secondary interface elements to maintain hierarchy without visual clutter.
- **Tertiary (#0EA5E9):** A high-visibility "Logic Blue" used sparingly for primary actions, focus states, and active selection indicators.
- **Neutral (#F8FAFC):** A clean, cool-gray base for application backgrounds, ensuring that content and status indicators remain the focal point.
- **Functional Colors:** Success, Error, and Warning colors are highly saturated to ensure critical security protocols and permission conflicts are immediately recognizable.

## Typography
The typographic strategy balances modern professionalism with technical precision. 

**Hanken Grotesk** is used for headlines to provide a sharp, contemporary corporate feel. Its geometric clarity aids in quick scanning of section titles. **Inter** handles all body copy and data entry, chosen for its exceptional legibility in dense ERP layouts. **JetBrains Mono** is utilized for labels, metadata, and permission codes (e.g., UUIDs or Access Keys) to give the UI a technical, secure "under the hood" aesthetic.

Maintain a strict 4px baseline grid for all typographic elements to ensure vertical rhythm.

## Layout & Spacing
This design system employs a **Fixed-Fluid Hybrid** grid. 
- **Desktop:** A fixed-width sidebar (280px) sits to the left, with a fluid content area that utilizes a 12-column grid. Large data tables and user lists should span the full width of the fluid container.
- **Margins & Gutters:** Global page margins are set to 24px. Gutters between cards or data columns are set to 16px to maximize data density without sacrificing readability.
- **Rhythm:** All spacing must be multiples of 4px. Use "stack-md" (16px) for standard spacing between form fields and "stack-lg" (24px) for spacing between logical groups of settings.
- **Mobile:** On small screens, the sidebar collapses into a drawer, and the 12-column layout reflows to a single-column stack with 16px horizontal margins.

## Elevation & Depth
Depth is conveyed through **Tonal Layers** and **Low-Contrast Outlines** rather than heavy shadows. This maintains the "flat and professional" ERP aesthetic.

- **Base Level:** The background uses the neutral slate (#F8FAFC).
- **Surface Level:** Cards and containers use a pure white (#FFFFFF) background with a 1px solid border (#E2E8F0).
- **Active States:** Subtle 2px "Soft Shadows" (Color: Primary, Opacity: 4%, Blur: 4px) are used only for active dropdowns or modals to lift them slightly from the interface.
- **Interaction:** Hover states on list items are indicated by a subtle background shift to #F1F5F9, never by a change in elevation.

## Shapes
The shape language is **Soft (0.25rem)**. This slight rounding takes the edge off the "brutal" corporate aesthetic while maintaining a sense of structure and mathematical precision. 

- **Buttons & Inputs:** Use the base 4px (0.25rem) radius.
- **Cards & Modals:** Use the `rounded-lg` (8px / 0.5rem) radius for a slightly softer container feel.
- **Status Badges:** Use a pill-shape (full radius) to distinguish them clearly from interactive buttons.

## Components
- **Buttons:** Primary buttons use the Command Navy background with white text. Secondary buttons use a slate outline. Destructive actions (Revoke Access) use a solid Red background with a distinct "Double-Confirmation" pattern.
- **Data Tables:** The core of the user management system. Use sticky headers, zebra-striping (subtle), and JetBrains Mono for ID columns. Include a "Status" column with pill-shaped badges.
- **Input Fields:** Use 1px borders with a 2px blue focus ring. Labels must always be visible (never placeholder-only) and set in Inter Bold 12px.
- **Permission Toggles:** Use a custom-styled switch that clearly indicates "Enabled" in Success Green and "Disabled" in Neutral Gray.
- **Audit Logs:** A specialized list component using a vertical timeline thread. It uses JetBrains Mono for timestamps and IP addresses.
- **User Avatars:** Square with 4px rounding. For users without photos, use two-letter initials with a secondary-slate background.