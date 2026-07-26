---
name: Yabisso Professional Staff - Recruitment Extension
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
  secondary: '#4648d4'
  on-secondary: '#ffffff'
  secondary-container: '#6063ee'
  on-secondary-container: '#fffbff'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#271901'
  on-tertiary-container: '#98805d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#fcdeb5'
  tertiary-fixed-dim: '#dec29a'
  on-tertiary-fixed: '#271901'
  on-tertiary-fixed-variant: '#574425'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-xl:
    fontFamily: Hanken Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 16px
  margin-desktop: 32px
  margin-mobile: 16px
  pipeline-column-width: 280px
---

## Brand & Style
The design system focuses on high-density, professional efficiency for enterprise-grade recruitment. The brand personality is authoritative yet modern, projecting reliability and data-centric precision. 

The aesthetic blends **Modern Corporate** with **Minimalist** leanings. It prioritizes clarity over decoration, using purposeful whitespace and a structured grid to manage complex talent pipelines. The emotional response is one of organized control, catering to recruiters and HR managers who require rapid information processing and low cognitive load.

## Colors
The palette is rooted in a deep Slate primary for text and high-contrast elements. The **Talent Color** (Indigo) is the centerpiece of the recruitment module, used for interactive elements related to candidate sourcing and talent management.

A semantic status palette is introduced to manage candidate lifecycles:
- **Applied:** Neutral Slate, signifying a pending state.
- **Interview:** Warm Amber, indicating active engagement.
- **Offered:** Emerald Green, representing a successful milestone.
- **Hired:** The signature Talent Indigo, marking the completion of the funnel.
- **Rejected:** A sober Red for clarity in high-volume filtering.

## Typography
The system uses a triple-font strategy to maximize information density:
- **Hanken Grotesk** for headlines provides a sharp, contemporary professional feel.
- **Inter** for body copy ensures maximum legibility in dense tables and candidate profiles.
- **JetBrains Mono** is utilized for specialized labels, metadata, and status badges to provide a technical, data-driven "utility" look.

For mobile, headlines are scaled down to preserve vertical space, ensuring candidate lists remain scannable.

## Layout & Spacing
This design system employs a **Fluid Grid** model with a base unit of 4px. In the recruitment context, the layout prioritizes horizontal real estate for "Kanban" style candidate pipelines.

- **Desktop:** 12-column grid for dashboards; 5-column fixed-width layout for Pipeline views.
- **Table:** 8-column grid with a collapsible side navigation to maximize candidate profile views.
- **Mobile:** Single column with horizontal swiping enabled for pipeline stages.
- **Gaps:** Use 16px (4 units) for standard component spacing and 8px (2 units) for related data points inside cards.

## Elevation & Depth
To maintain a high-density professional look, the system avoids heavy shadows. 
- **Tonal Layers:** The primary method of depth. Backgrounds use the Neutral color (`#F8FAFC`), while cards and containers use pure White (`#FFFFFF`) with a subtle 1px border (`#E2E8F0`).
- **Low-Contrast Outlines:** Interactive elements use a 1px border that darkens on hover.
- **Active State:** Only the "dragged" candidate card in a pipeline receives a soft, ambient shadow (10% opacity) to indicate elevation from the board.

## Shapes
The shape language is **Soft**. 
- Standard components (buttons, inputs) use a `0.25rem` (4px) radius to maintain a serious, structured appearance.
- Status badges use a `rounded-lg` (8px) radius to differentiate them slightly from functional buttons.
- Profile avatars remain circular to provide a organic point of focus amidst the geometric layout.

## Components

### Candidate Status Badges
Badges are rendered in the semantic status colors with a 10% opacity background of the same hue and a 100% opacity text label. Use **label-caps** typography for maximum scannability in lists.

### Pipeline Cards
Candidate cards in the pipeline view are condensed. They must include:
- Candidate Name (Body MD, Bold)
- Current Role (Body SM, Muted)
- Status Badge (Top Right)
- "Days in Stage" counter (Label Caps, Muted)

### Job Listing Rows
High-density rows featuring:
- Job Title and Department.
- Applicant count (using the Talent Color).
- Toggle switch for "Internal/External" listing status.
- Action menu for "Edit/Share/Close".

### Input Fields
Inputs use a "Quiet" style: no background, only a bottom border that transforms into a full 1px Indigo border on focus. This reduces visual noise in complex forms.

### Primary Action Buttons
Use the Talent Color (`#4F46E5`) for primary actions like "Add Candidate" or "Publish Job". Buttons have a subtle inner glow on hover to reinforce the professional, tactile feel.