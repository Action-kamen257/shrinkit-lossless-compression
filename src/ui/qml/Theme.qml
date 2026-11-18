pragma Singleton
import QtQuick

/**
 * ShrinkIt Global Theme Token System
 *
 * Color System: Graphite Black × Neutral Gray × Crisp White
 * Aesthetic: Professional, Minimalist, Precision Desktop Engineering.
 * Typography: Modern Variable UI Typeface.
 */
QtObject {
    id: theme

    // ─────────────────────────────────────────────
    // 1. TYPOGRAPHY (Modern Variable UI)
    // ─────────────────────────────────────────────
    readonly property string fontFamily:     "Segoe UI Variable Display, Segoe UI Variable Text, Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif"
    readonly property string fontFamilyMono: "Cascadia Code, Consolas, SF Mono, Menlo, monospace"

    readonly property int fontSizeXS:   10
    readonly property int fontSizeSM:   12
    readonly property int fontSizeMD:   13
    readonly property int fontSizeLG:   15
    readonly property int fontSizeXL:   18
    readonly property int fontSize2XL:  24
    readonly property int fontSize3XL:  32

    readonly property int fontWeightNormal:    400
    readonly property int fontWeightMedium:    500
    readonly property int fontWeightSemibold:  600
    readonly property int fontWeightBold:      700

    // ─────────────────────────────────────────────
    // 2. GRAPHITE BLACK & GRAY PALETTE
    // ─────────────────────────────────────────────
    readonly property color bgPrimary:       "#09090B"   // Deep Graphite Black (zinc-950)
    readonly property color bgDeep:          "#0C0C0E"   // Layered Canvas
    readonly property color bgGraphite:      "#141417"   // Surface / Card background (zinc-900)
    readonly property color bgPanel:         "#111114"   // Sidebar & Panels
    readonly property color bgElevated:      "#18181B"   // Floating Cards & Menus

    // High contrast monochrome accents
    readonly property color accentWhite:     "#FFFFFF"   // Crisp Pure White
    readonly property color accentSilver:    "#E4E4E7"   // Light Zinc (zinc-200)
    readonly property color accentMuted:     "#A1A1AA"   // Medium Zinc (zinc-400)

    // Legacy aliases pointing to neutral white/silver for smooth compatibility
    readonly property color accentRed:       "#FFFFFF"
    readonly property color accentRedHigh:   "#E4E4E7"

    // ─────────────────────────────────────────────
    // 3. TEXT HIERARCHY
    // ─────────────────────────────────────────────
    readonly property color textPrimary:     "#FFFFFF"   // Pure White
    readonly property color textSecondary:   "#A1A1AA"   // Zinc 400
    readonly property color textMuted:       "#71717A"   // Zinc 500
    readonly property color textSilver:      "#D4D4D8"   // Zinc 300

    // ─────────────────────────────────────────────
    // 4. BORDERS & SEPARATORS
    // ─────────────────────────────────────────────
    readonly property color borderSubtle:    Qt.rgba(1, 1, 1, 0.08)
    readonly property color borderMedium:    Qt.rgba(1, 1, 1, 0.14)
    readonly property color borderFocus:     Qt.rgba(1, 1, 1, 0.28)

    // ─────────────────────────────────────────────
    // 5. GLASS SURFACE COLORS
    // ─────────────────────────────────────────────
    readonly property color glassBgDark:          Qt.rgba(0.06, 0.06, 0.08, 0.85)
    readonly property color glassBgMid:           Qt.rgba(0.09, 0.09, 0.11, 0.75)
    readonly property color glassEdgeReflection:  Qt.rgba(1, 1, 1, 0.08)
    readonly property color glassFrostOverlay:    Qt.rgba(1, 1, 1, 0.02)
    readonly property color glassHighlight:       Qt.rgba(1, 1, 1, 0.06)

    // ─────────────────────────────────────────────
    // 6. BUTTON SYSTEM (Clean shadcn monochrome)
    // ─────────────────────────────────────────────
    // Primary: Solid Crisp White with Black Text
    readonly property color btnPrimaryBg:    "#FFFFFF"
    readonly property color btnPrimaryBgHov: "#E4E4E7"
    readonly property color btnPrimaryBgPrs: "#D4D4D8"
    readonly property color btnPrimaryText:  "#09090B"
    readonly property color btnPrimaryGlow:  Qt.rgba(1, 1, 1, 0.12)

    // Secondary: Dark Graphite Glass with White Text
    readonly property color btnSecondaryBg:    Qt.rgba(1, 1, 1, 0.05)
    readonly property color btnSecondaryBgHov: Qt.rgba(1, 1, 1, 0.09)
    readonly property color btnSecondaryBd:    Qt.rgba(1, 1, 1, 0.12)
    readonly property color btnSecondaryText:  "#FFFFFF"

    // Destructive
    readonly property color btnDestructiveBg: Qt.rgba(0.40, 0.10, 0.12, 0.80)
    readonly property color btnDestructiveBd: Qt.rgba(0.80, 0.20, 0.22, 0.40)

    // ─────────────────────────────────────────────
    // 7. SIDEBAR NAVIGATION
    // ─────────────────────────────────────────────
    readonly property color sidebarBg:          Qt.rgba(0.05, 0.05, 0.07, 0.95)
    readonly property color sidebarBd:          Qt.rgba(1, 1, 1, 0.08)
    readonly property color sidebarItemActive:  Qt.rgba(1, 1, 1, 0.08)
    readonly property color sidebarIndicator:   "#FFFFFF"
    readonly property color sidebarTextActive:  "#FFFFFF"
    readonly property color sidebarTextInactive:"#A1A1AA"

    // ─────────────────────────────────────────────
    // 8. PROGRESS & CHARTS
    // ─────────────────────────────────────────────
    readonly property color progressTrack: Qt.rgba(1, 1, 1, 0.08)
    readonly property color progressFill:  "#FFFFFF"
    readonly property color progressGlow:  Qt.rgba(1, 1, 1, 0.20)
    readonly property color chartPrimary:  "#FFFFFF"
    readonly property color chartSecondary:"#71717A"
    readonly property color chartTertiary: "#3F3F46"

    // ─────────────────────────────────────────────
    // 9. STATUS
    // ─────────────────────────────────────────────
    readonly property color statusSuccess: "#22C55E"
    readonly property color statusError:   "#EF4444"
    readonly property color statusWarning: "#F59E0B"
    readonly property color statusInfo:    "#E4E4E7"

    // ─────────────────────────────────────────────
    // 10. SPACING & RADII
    // ─────────────────────────────────────────────
    readonly property int spacingXXS:  2
    readonly property int spacingXS:   4
    readonly property int spacingSM:   8
    readonly property int spacingMD:   12
    readonly property int spacingLG:   16
    readonly property int spacingXL:   20
    readonly property int spacingXXL:  32
    readonly property int spacingPage: 24

    readonly property int radiusXS:   4
    readonly property int radiusSM:   6
    readonly property int radiusMD:   10
    readonly property int radiusLG:   12
    readonly property int radiusXL:   16
    readonly property int radiusCard: 12

    // ─────────────────────────────────────────────
    // 11. GLASS PARAMETER DEFAULTS
    // ─────────────────────────────────────────────
    readonly property real glassOpacityDefault:       0.12
    readonly property real glassBlurDefault:          20.0
    readonly property real glassFrostDefault:         0.50
    readonly property real glassIORDefault:           1.45
    readonly property real glassThicknessDefault:     1.0
    readonly property real glassBevelDefault:         0.5
    readonly property real glassDispersionDefault:    0.01
    readonly property real glassMergeDistanceDefault: 0.0

    // ─────────────────────────────────────────────
    // 12. ANIMATION DURATIONS
    // ─────────────────────────────────────────────
    readonly property int animFast:   100
    readonly property int animNormal: 180
    readonly property int animSlow:   300
}
