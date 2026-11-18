import QtQuick
import QtQuick.Controls.Basic
import "../"

/**
 * GlassToggle — Cherry Red themed toggle switch.
 */
Switch {
    id: root

    implicitWidth: 48
    implicitHeight: 26

    indicator: Rectangle {
        x: root.leftPadding
        y: (parent.height - height) / 2
        width: 46
        height: 24
        radius: 12
        color: root.checked ? Qt.rgba(0.76, 0.094, 0.227, 0.80) : Qt.rgba(1,1,1,0.10)
        border.color: root.checked ? Theme.accentRed : Theme.borderSubtle
        border.width: 1

        Rectangle {
            x: root.checked ? parent.width - width - 3 : 3
            y: (parent.height - height) / 2
            width: 18
            height: 18
            radius: 9
            color: root.checked ? "#FFFFFF" : Theme.textSecondary

            Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }

    contentItem: Item {}
}
