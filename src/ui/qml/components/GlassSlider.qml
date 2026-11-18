import QtQuick
import QtQuick.Controls.Basic
import "../"

/**
 * GlassSlider — Cherry Red slider for Liquid Lab glass settings.
 */
Slider {
    id: root

    implicitHeight: 28
    implicitWidth: 180

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        width: root.availableWidth
        height: 4
        radius: 2
        color: Theme.progressTrack

        // Filled portion
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: Theme.progressFill
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        width: 18
        height: 18
        radius: 9

        color: root.pressed ? Theme.accentRedHigh : Theme.accentRed
        border.color: Qt.rgba(1, 1, 1, 0.20)
        border.width: 1

        // Glow ring
        Rectangle {
            anchors.centerIn: parent
            width: 28
            height: 28
            radius: 14
            color: "transparent"
            border.color: Qt.rgba(0.76, 0.094, 0.227, root.hovered ? 0.45 : 0.0)
            border.width: 1
            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
        }

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }
}
