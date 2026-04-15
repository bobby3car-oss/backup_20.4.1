---
applyTo: "lib/ui/**,lib/theme/**"
---

# Theme & UI System

## Colors (`lib/ui/theme/colors.dart`)
- Primary: `#007AFF` (iOS blue)
- Accent: `#5856D6` (purple)
- Success/Warning/Error: `#34C759` / `#FF9500` / `#FF3B30`
- Glass: `glassFill` (0x33FFFFFF), `glassBorder`

## Spacing (`lib/ui/theme/spacing.dart`)
Scale: xxs(2), xs(4), sm(8), md(12), lg(16), xl(20), xxl(24), xxxl(32), huge(48), massive(64)
Pre-built: `AppSpacing.paddingSm`, `AppSpacing.screenPadding`, etc.

## Radius (`lib/ui/theme/radius.dart`)
Scale: xs(6), sm(10), md(14), lg(24), xl(26), xxl(32), pill(999)

## Glass System (`lib/ui/theme/glass.dart`)
`GlassContainer` with `GlassElevation` enum: flat, low, medium, high

## Reference
Read `/memories/repo/ui_theme_system_comprehensive.md` for full theme details.
