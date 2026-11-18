import QtQuick
import QtQuick.Layouts
import "../"
import "../components"

/**
 * LiquidLabView — Runtime glass design system configuration panel.
 * All parameters feed directly into GlassMaterial via ShrinkItEngine properties.
 * Cherry Red sliders, toggles, and selection indicators throughout.
 */
Item {
    id: root

    ColumnLayout {
        anchors {
            fill: parent
            margins: Theme.spacingPage
        }
        spacing: Theme.spacingXL

        // Header
        ColumnLayout {
            spacing: 2
            Text {
                text: "Liquid Lab"
                font.pixelSize: Theme.fontSize2XL
                font.weight: Theme.fontWeightBold
                color: Theme.textPrimary
            }
            Text {
                text: "Runtime glass design system configuration — all changes apply instantly"
                font.pixelSize: Theme.fontSizeSM
                color: Theme.textSecondary
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingXL

            // ── Controls ──
            ColumnLayout {
                Layout.preferredWidth: 380
                Layout.fillHeight: true
                spacing: Theme.spacingLG

                Repeater {
                    model: [
                        { key: "opacity",       label: "Opacity",        min: 0.02, max: 0.95, decimals: 2, unit: "" },
                        { key: "blur",          label: "Blur Radius",    min: 0.0,  max: 64.0, decimals: 1, unit: " px" },
                        { key: "frost",         label: "Frost Amount",   min: 0.0,  max: 1.0,  decimals: 2, unit: "" },
                        { key: "ior",           label: "IOR (Refraction)",min:1.0,  max: 2.5,  decimals: 2, unit: "" },
                        { key: "thickness",     label: "Thickness",      min: 0.1,  max: 4.0,  decimals: 2, unit: "" },
                        { key: "bevel",         label: "Bevel",          min: 0.0,  max: 2.0,  decimals: 2, unit: "" },
                        { key: "dispersion",    label: "Dispersion",     min: 0.0,  max: 0.15, decimals: 3, unit: "" },
                        { key: "mergeDistance", label: "Merge Distance", min: 0.0,  max: 1.0,  decimals: 2, unit: "" }
                    ]

                    delegate: GlassCard {
                        Layout.fillWidth: true
                        implicitHeight: 72
                        cherryIntensity: 0.0

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 4

                            RowLayout {
                                Text {
                                    text: modelData.label
                                    font.pixelSize: Theme.fontSizeSM
                                    font.weight: Theme.fontWeightMedium
                                    color: Theme.textSilver
                                    Layout.fillWidth: true
                                }
                                Text {
                                    id: valLabel
                                    font.pixelSize: Theme.fontSizeSM
                                    font.weight: Theme.fontWeightSemibold
                                    font.family: "monospace"
                                    color: Theme.accentRed
                                    text: {
                                        switch(modelData.key) {
                                        case "opacity":       return ShrinkItEngine.glassOpacity.toFixed(modelData.decimals) + modelData.unit
                                        case "blur":          return ShrinkItEngine.glassBlur.toFixed(modelData.decimals) + modelData.unit
                                        case "frost":         return ShrinkItEngine.glassFrost.toFixed(modelData.decimals)
                                        case "ior":           return ShrinkItEngine.glassIOR.toFixed(modelData.decimals)
                                        case "thickness":     return ShrinkItEngine.glassThickness.toFixed(modelData.decimals)
                                        case "bevel":         return ShrinkItEngine.glassBevel.toFixed(modelData.decimals)
                                        case "dispersion":    return ShrinkItEngine.glassDispersion.toFixed(modelData.decimals)
                                        case "mergeDistance": return ShrinkItEngine.glassMergeDistance.toFixed(modelData.decimals)
                                        default: return "—"
                                        }
                                    }
                                }
                            }

                            GlassSlider {
                                Layout.fillWidth: true
                                from: modelData.min
                                to:   modelData.max
                                stepSize: Math.pow(10, -modelData.decimals)
                                value: {
                                    switch(modelData.key) {
                                    case "opacity":       return ShrinkItEngine.glassOpacity
                                    case "blur":          return ShrinkItEngine.glassBlur
                                    case "frost":         return ShrinkItEngine.glassFrost
                                    case "ior":           return ShrinkItEngine.glassIOR
                                    case "thickness":     return ShrinkItEngine.glassThickness
                                    case "bevel":         return ShrinkItEngine.glassBevel
                                    case "dispersion":    return ShrinkItEngine.glassDispersion
                                    case "mergeDistance": return ShrinkItEngine.glassMergeDistance
                                    default: return 0
                                    }
                                }
                                onMoved: {
                                    switch(modelData.key) {
                                    case "opacity":       ShrinkItEngine.glassOpacity = value; break
                                    case "blur":          ShrinkItEngine.glassBlur = value; break
                                    case "frost":         ShrinkItEngine.glassFrost = value; break
                                    case "ior":           ShrinkItEngine.glassIOR = value; break
                                    case "thickness":     ShrinkItEngine.glassThickness = value; break
                                    case "bevel":         ShrinkItEngine.glassBevel = value; break
                                    case "dispersion":    ShrinkItEngine.glassDispersion = value; break
                                    case "mergeDistance": ShrinkItEngine.glassMergeDistance = value; break
                                    }
                                }
                            }
                        }
                    }
                }

                GlassButton {
                    text: "↺  Reset to Defaults"
                    variant: "secondary"
                    onClicked: ShrinkItEngine.resetGlassDefaults()
                }
            }

            // ── Live glass preview cards ──
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.spacingLG

                Text {
                    text: "LIVE PREVIEW"
                    font.pixelSize: Theme.fontSizeXS
                    font.letterSpacing: 1.4
                    color: Theme.textSecondary
                }

                Repeater {
                    model: [
                        { label: "Dark Glass Panel",    variant: "dark",    cherry: 0.0, glow: false },
                        { label: "Card Surface",        variant: "card",    cherry: 0.3, glow: false },
                        { label: "Cherry Accent Glass", variant: "card",    cherry: 0.8, glow: true  },
                        { label: "Button Surface",      variant: "button",  cherry: 0.0, glow: false }
                    ]

                    delegate: Item {
                        Layout.fillWidth: true
                        implicitHeight: 70

                        GlassMaterial {
                            anchors.fill: parent
                            variant: modelData.variant
                            radius: Theme.radiusCard
                            cherryIntensity: modelData.cherry
                            showEdgeGlow: modelData.glow
                        }

                        RowLayout {
                            anchors {
                                fill: parent; leftMargin: Theme.spacingLG; rightMargin: Theme.spacingLG
                            }

                            Text {
                                text: modelData.label
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Theme.fontWeightMedium
                                color: Theme.textSilver
                            }

                            Item { Layout.fillWidth: true }

                            // Cherry intensity badge
                            Rectangle {
                                visible: modelData.cherry > 0
                                height: 22; radius: 11
                                width: cherryLabel.implicitWidth + 16
                                color: Qt.rgba(0.76, 0.094, 0.227, 0.22)
                                border.color: Theme.accentRed
                                border.width: 1

                                Text {
                                    id: cherryLabel
                                    anchors.centerIn: parent
                                    text: "Cherry ×" + modelData.cherry.toFixed(1)
                                    font.pixelSize: Theme.fontSizeXS
                                    color: Theme.accentRedHigh
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
