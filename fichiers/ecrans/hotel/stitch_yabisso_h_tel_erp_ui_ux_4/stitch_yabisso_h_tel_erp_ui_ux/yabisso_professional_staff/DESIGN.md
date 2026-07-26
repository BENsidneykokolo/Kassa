---
name: Yabisso Professional Staff
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
  on-surface-variant: '#444653'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#757684'
  outline-variant: '#c4c5d5'
  surface-tint: '#3755c3'
  primary: '#00288e'
  on-primary: '#ffffff'
  primary-container: '#1e40af'
  on-primary-container: '#a8b8ff'
  inverse-primary: '#b8c4ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#003c36'
  on-tertiary: '#ffffff'
  tertiary-container: '#00554e'
  on-tertiary-container: '#5fcdbf'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dde1ff'
  primary-fixed-dim: '#b8c4ff'
  on-primary-fixed: '#001453'
  on-primary-fixed-variant: '#173bab'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#89f5e7'
  tertiary-fixed-dim: '#6bd8cb'
  on-tertiary-fixed: '#00201d'
  on-tertiary-fixed-variant: '#005049'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
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
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  status-label:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 12px
  headline-md-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
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
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
  sidebar-width: 280px
---

## Brand & Style

The design system is engineered for high-efficiency HR and staff management environments. It prioritizes clarity, reliability, and administrative precision. The visual style leans into **Corporate Modernism** with a focus on structured information density. 

The interface should evoke a sense of organized calm, reducing the cognitive load of managers handling complex schedules and sensitive employee data. This is achieved through generous white space within data containers, a logical hierarchy of information, and a disciplined application of color to signal system status and availability without overwhelming the user.

## Colors

The palette is anchored by a deep **Professional Blue** (Primary) to convey authority and trust. **Slate** (Secondary) is used for supporting UI elements and iconography to maintain a neutral, sophisticated tone. **Teal** (Tertiary) acts as a secondary accent for success states or specialized staff categories.

A dedicated status palette is critical for staff management:
- **Active:** A vibrant emerald green for immediate availability.
- **Off:** A muted slate gray for scheduled time off.
- **Leave:** A warm amber for approved absences or medical leave.
- **Alert:** A sharp red for scheduling conflicts or urgent HR actions.

The background uses a subtle off-white (`#F8FAFC`) to reduce screen glare during long administrative sessions, while containers utilize pure white to create clear separation.

## Typography

This design system utilizes a trio of typefaces to balance character with utility. **Hanken Grotesk** is used for headlines, providing a sharp, contemporary professional feel. **Inter** serves as the workhorse for all body copy and data entry, chosen for its exceptional legibility in dense layouts. **JetBrains Mono** is reserved for metadata, employee IDs, and specific timestamps to provide a technical, structured appearance to administrative data.

All labels for staff status or data categories should use `label-caps` for clear differentiation from standard body text. For mobile views, headlines scale down to ensure employee profiles remain scannable without excessive scrolling.

## Layout & Spacing

The layout follows a **Fixed-Fluid Hybrid** model. Navigation and sidebars are fixed to ensure consistent access to HR tools, while the main content area (Employee Lists, Shift Calendars) is fluid to maximize data visibility on large monitors.

A 4px baseline grid governs all spacing. For employee profiles, use a structured 2-column or 3-column layout depending on screen width. Shift management views should prioritize a horizontal timeline approach.
- **Desktop:** 12-column grid, 24px margins, 16px gutters.
- **Tablet:** 8-column grid, 16px margins, 16px gutters.
- **Mobile:** 4-column grid, 16px margins, 12px gutters.

## Elevation & Depth

This design system employs **Tonal Layering** supplemented by **Low-Contrast Outlines**. Deep shadows are avoided to maintain a clean, professional workspace. 

- **Level 0 (Base):** The main canvas background (`#F8FAFC`).
- **Level 1 (Cards/Containers):** Pure white background with a 1px border (`#E2E8F0`). No shadow.
- **Level 2 (Modals/Overlays):** Pure white with a very soft, high-diffusion shadow (8% opacity, 12px blur) to provide focus during shift editing or profile updates.
- **Interactive Elements:** Buttons and inputs use a subtle 1px inset border or a light tonal shift on hover rather than an elevation change.

## Shapes

The design system uses **Soft** roundedness. A `0.25rem` (4px) corner radius is the standard for most elements, including input fields, buttons, and small containers. This provides a modern touch while maintaining the "grid-like" feel necessary for professional administrative software.

Large containers (like employee profile cards) can use `rounded-lg` (8px) to softly distinguish them from the more rigid data tables within them. Status indicators (dots or chips) are the only elements allowed to be fully circular.

## Components

### Buttons
Primary buttons use the Primary Blue with white text. Secondary buttons use a Slate outline. Action buttons within tables (Edit/View) should be compact with `body-md` typography.

### Status Chips
Status chips are essential for staff availability. They feature a background at 10% opacity of the status color and a solid text/icon color. Example: "Active" has a light green background with dark green text.

### Input Fields
Fields must have clear, persistent labels using `label-caps`. The border color shifts to Primary Blue on focus. Error states use the Alert Red for both the border and a small supporting text label below the field.

### Employee Cards
Cards should include a 40px circular avatar, name in `headline-sm`, and a status chip. Key metadata (Department, Role) should be formatted using `label-caps`.

### Shift Management Grid
The shift grid uses a 1px border grid system (`#E2E8F0`). Individual shifts are represented as blocks with the color corresponding to the staff member's department or role, ensuring the shift manager can visually parse the team mix at a glance.

### Lists & Data Tables
Tables should use zebra-striping with a very light tint (`#F1F5F9`) on even rows to improve horizontal readability across many columns.