import QtQuick
import QtQuick.Layouts
import "../"

/**
 * GlassSegmentedControl — Precision Segmented Navigation Bar.
 * Clean monochrome styling: dark graphite track, elevated selection pill, crisp text.
 */
Item {
    id: root

    property var items: ["Overview", "Compress", "Decompress", "DAA Tree"]
    property var icons: ["bar-chart-3", "sparkles", "archive", "cpu"]
    property int currentIndex: 0

    signal tabSelected(int index)

    implicitWidth: tabRow.implicitWidth + 8
    implicitHeight: 34

    // Capsule track
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusMD
        color: Qt.rgba(1, 1, 1, 0.04)
        border.color: Theme.borderSubtle
        border.width: 1
    }

    // Active sliding selection pill
    Rectangle {
        id: selectionPill
        y: 3
        height: root.height - 6
        radius: Theme.radiusSM
        color: Qt.rgba(1, 1, 1, 0.12)
        border.color: Theme.borderMedium
        border.width: 1

        Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
    }

    // Tab items
    Row {
        id: tabRow
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            id: repeater
            model: root.items

            Item {
                id: tabItem
                property int itemIndex: index
                property bool isSelected: root.currentIndex === index

                width: tabLabel.implicitWidth + 30
                height: root.height - 6

                onIsSelectedChanged: {
                    if (isSelected) {
                        selectionPill.x = mapToItem(root, 0, 0).x;
                        selectionPill.width = width;
                    }
                }

                Component.onCompleted: {
                    if (isSelected) {
                        selectionPill.x = mapToItem(root, 0, 0).x;
                        selectionPill.width = width;
                    }
                }

                HoverHandler { id: itemHover }

                TapHandler {
                    onTapped: {
                        root.currentIndex = itemIndex;
                        root.tabSelected(itemIndex);
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    LucideIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: root.icons[index] ? root.icons[index] : "file"
                        size: 14
                        color: tabItem.isSelected ? Theme.textPrimary : (itemHover.hovered ? Theme.textPrimary : Theme.textSecondary)
                    }

                    Text {
                        id: tabLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData
                        font.pixelSize: Theme.fontSizeSM
                        font.weight: tabItem.isSelected ? Font.Medium : Font.Normal
                        font.family: Theme.fontFamily
                        color: tabItem.isSelected ? Theme.textPrimary : (itemHover.hovered ? Theme.textPrimary : Theme.textSecondary)
                    }
                }
            }
        }
    }

    onCurrentIndexChanged: {
        var item = repeater.itemAt(root.currentIndex);
        if (item) {
            selectionPill.x = item.mapToItem(root, 0, 0).x;
            selectionPill.width = item.width;
        }
    }
}
