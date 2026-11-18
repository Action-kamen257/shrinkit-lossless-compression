import QtQuick
import QtQuick.Layouts
import "../"

/**
 * GlassCard — A dark translucent glass card container.
 * Used for stat panels, info blocks and dashboard cards.
 */
Item {
    id: root

    property string title: ""
    property real cherryIntensity: 0.0
    property bool showEdgeGlow: false
    property real radius: Theme.radiusCard
    default property alias content: contentArea.data

    implicitWidth:  220
    implicitHeight: 140

    GlassMaterial {
        anchors.fill: parent
        variant: "card"
        radius: root.radius
        cherryIntensity: root.cherryIntensity
        showEdgeGlow: root.showEdgeGlow
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: Theme.spacingLG
        }
        spacing: Theme.spacingSM

        // Optional card title
        Text {
            visible: root.title.length > 0
            text: root.title
            font.pixelSize: Theme.fontSizeSM
            font.weight: Theme.fontWeightSemibold
            color: Theme.textSecondary
            font.letterSpacing: 0.8
        }

        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
