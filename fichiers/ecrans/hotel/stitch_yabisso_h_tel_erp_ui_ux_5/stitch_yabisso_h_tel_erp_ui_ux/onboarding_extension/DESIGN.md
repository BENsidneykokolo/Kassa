---
name: Onboarding Extension
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
  on-surface-variant: '#434655'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#712ae2'
  on-secondary: '#ffffff'
  secondary-container: '#8a4cfc'
  on-secondary-container: '#fffbff'
  tertiary: '#006242'
  on-tertiary: '#ffffff'
  tertiary-container: '#007d55'
  on-tertiary-container: '#bdffdb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#eaddff'
  secondary-fixed-dim: '#d2bbff'
  on-secondary-fixed: '#25005a'
  on-secondary-fixed-variant: '#5a00c6'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
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
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: JetBrains Mono
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
  container-max: 1280px
  gutter: 24px
  margin-desktop: 48px
  margin-mobile: 16px
  stack-sm: 12px
  stack-md: 24px
  stack-lg: 48px
---

## Brand & Style

The design system is engineered for the "Onboarding Extension" phase of the Yabisso Professional Staff ecosystem. It transitions the user from the high-stakes environment of recruitment into a structured, supportive, and instructional workspace. 

The aesthetic is **Corporate / Modern** with a focus on high legibility and systematic clarity. It utilizes a layered approach to information architecture to reduce cognitive load during complex data entry and document verification tasks. The emotional response is one of organized progress—moving from "candidate" to "colleague" through a clean, reliable, and welcoming interface.

## Colors

The palette maintains professional continuity while introducing functional signaling for onboarding milestones:

- **Primary (Professional Blue):** Used for core navigation, primary actions, and institutional trust.
- **Secondary (Staff Violet):** Used for personnel-specific features, profile management, and decorative brand accents to align with the Staff system.
- **Success Green:** Reserved for completed tasks, verified documents, and milestone achievements.
- **Progress Amber:** Indicates pending reviews, expiring documents, or tasks currently in progress.
- **Neutral (Slate):** Used for secondary text, borders, and UI scaffolding to maintain a grounded, clean environment.

## Typography

The typography system balances modern approachability with technical precision:

- **Headlines (Manrope):** Chosen for its geometric balance and friendly curves, making the onboarding process feel less intimidating while remaining professional.
- **Body (Inter):** A systematic sans-serif designed for high legibility in dense forms and instruction sets.
- **Labels (JetBrains Mono):** Introduced for metadata, status tags, and document IDs to provide a distinct "technical" feel for data-heavy professional contexts.

Use `body-md` as the default for all instructional text. Use `label-md` for status indicators (e.g., "In Progress") to differentiate system-generated data from user content.

## Layout & Spacing

This design system utilizes a **Fixed Grid** for desktop and a **Fluid Grid** for mobile. 

- **Desktop:** 12-column grid with a maximum width of 1280px. Use 24px gutters. Center the container to provide focus and generous white space on large monitors.
- **Mobile:** Single column with 16px side margins. 
- **Spacing Rhythm:** Based on an 8px baseline. Use `stack-md` (24px) for spacing between form sections and `stack-sm` (12px) for internal element grouping (e.g., label to input field).

Onboarding workflows should use a "focused task" layout, typically a 2/3 width main content area for forms and a 1/3 width sidebar for progress tracking and help resources.

## Elevation & Depth

Visual hierarchy is managed through **Tonal Layers** and **Low-Contrast Outlines**.

- **Surface Levels:** The background uses a soft off-white (#F8FAFC). Primary cards and containers use pure white (#FFFFFF).
- **Borders:** Use 1px solid borders in a light neutral (#E2E8F0) for all form inputs and secondary cards. Avoid heavy shadows to maintain the clean, "instructional" feel.
- **Depth:** Reserve soft, ambient shadows (0px 4px 12px rgba(0,0,0,0.05)) exclusively for floating elements like dropdown menus or active modal dialogs to ensure they stand out against the systematic grid.

## Shapes

The design system employs a **Rounded** shape language to soften the professional tone and make the software feel welcoming.

- **Standard Elements:** Buttons, inputs, and small cards use 0.5rem (8px) corners.
- **Large Containers:** Dashboard widgets and onboarding section containers use `rounded-lg` (1rem / 16px).
- **Status Indicators:** Use `rounded-xl` (1.5rem) or full pills for status chips and badges to distinguish them from interactive buttons.

## Components

- **Buttons:** Primary buttons use a solid Blue background with White text. Secondary buttons use a transparent background with a Blue border. Success/Progress buttons are reserved for final submission or specific milestone actions.
- **Onboarding Progress Bar:** A horizontal bar at the top of the workflow. Completed segments are Success Green; current segment is Primary Blue; future segments are Light Slate.
- **Input Fields:** Large, clearly labeled fields with `body-md` text. Focus states should use a 2px Primary Blue border with a soft blue outer glow.
- **Status Chips:** Use `label-sm` font. Colors correspond to the status: "Verified" (Success Green), "Pending" (Progress Amber), "Incomplete" (Slate).
- **Cards:** White background, 1px Slate border, 8px corner radius. Used to group related onboarding tasks (e.g., "Personal Info," "Tax Documents").
- **Checklists:** Large interactive rows. When a task is checked, the entire row background shifts to a very faint green tint with a Success Green check icon.
- **Instructional Callouts:** Soft Blue or Violet tinted boxes used to provide context for specific documents or steps, using `body-sm`.