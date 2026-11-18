import QtQuick
import QtQuick.Controls.Basic
import "../"

/**
 * GlassProgressBar — Minimalist Monochrome Progress Bar.
 * Clean white progress fill on graphite zinc track.
 */
ProgressBar {
    id: root

    property string label: ""

    implicitHeight: 6
    implicitWidth: 200

    background: Rectangle {
        implicitHeight: root.implicitHeight
        color: Qt.rgba(1, 1, 1, 0.08)
        radius: height / 2
    }

    contentItem: Item {
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: height / 2
            color: Theme.accentWhite

            Behavior on width { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
        }
    }
}
