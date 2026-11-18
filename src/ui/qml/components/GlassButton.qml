import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../"

/**
 * GlassButton — High-Contrast Minimalist Button Component.
 * Supports primary (solid white / dark text) and secondary (graphite glass) variants.
 */
Button {
    id: root

    property string variant: "primary"
    property string iconName: ""
    property real iconSize: 15

    implicitHeight: 36
    implicitWidth: Math.max(90, btnRow.implicitWidth + 28)

    background: Rectangle {
        radius: Theme.radiusSM

        color: {
            if (!root.enabled) return Qt.rgba(1, 1, 1, 0.04)

            switch (root.variant) {
            case "primary":
                if (root.pressed) return Theme.btnPrimaryBgPrs
                if (root.hovered) return Theme.btnPrimaryBgHov
                return Theme.btnPrimaryBg

            case "destructive":
                if (root.hovered || root.pressed) return Qt.rgba(0.50, 0.12, 0.15, 0.90)
                return Theme.btnDestructiveBg

            default: // "secondary"
                if (root.pressed) return Qt.rgba(1, 1, 1, 0.10)
                if (root.hovered) return Theme.btnSecondaryBgHov
                return Theme.btnSecondaryBg
            }
        }

        border.width: 1
        border.color: {
            if (!root.enabled) return Theme.borderSubtle
            switch (root.variant) {
            case "primary":     return root.hovered ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.20)
            case "destructive": return Theme.btnDestructiveBd
            default:            return root.hovered ? Theme.borderFocus : Theme.btnSecondaryBd
            }
        }

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }

    contentItem: Row {
        id: btnRow
        spacing: 7
        anchors.centerIn: parent

        LucideIcon {
            visible: root.iconName.length > 0
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            size: root.iconSize
            color: !root.enabled
                   ? Theme.textMuted
                   : (root.variant === "primary" ? Theme.btnPrimaryText : Theme.textPrimary)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.pixelSize: Theme.fontSizeSM
            font.weight: Font.Medium
            font.family: Theme.fontFamily
            color: !root.enabled
                   ? Theme.textMuted
                   : (root.variant === "primary" ? Theme.btnPrimaryText : Theme.textPrimary)

            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
    }

    opacity: enabled ? 1.0 : 0.40
}
