import QtQuick
import "../"

/**
 * GlassMaterial — Liquid Glass surface component.
 * Palette: Graphite Black base with neutral white/silver specular reflections.
 */
Item {
    id: root

    property string variant: "dark"   // "dark" | "mid" | "card" | "sidebar" | "button"
    property real cherryIntensity: 0.0
    property real opacityOverride: 0.0
    property real blurOverride: 0.0
    property bool showEdgeGlow: false
    property real radius: Theme.radiusMD

    // Background fill
    Rectangle {
        id: glassBody
        anchors.fill: parent
        radius: root.radius

        color: {
            switch (root.variant) {
            case "sidebar":  return Theme.sidebarBg
            case "mid":      return Theme.glassBgMid
            case "card":     return Theme.bgGraphite
            case "button":   return Theme.btnSecondaryBg
            default:         return Theme.glassBgDark
            }
        }

        // Frost / specular overlay
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Theme.glassFrostOverlay
        }
    }

    // Outer border
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.width: 1
        border.color: Theme.borderSubtle
    }

    // Top subtle specular highlight
    Rectangle {
        id: edgeGlow
        visible: root.showEdgeGlow
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 1
        radius: root.radius
        color: Qt.rgba(1, 1, 1, 0.14)
    }
}
