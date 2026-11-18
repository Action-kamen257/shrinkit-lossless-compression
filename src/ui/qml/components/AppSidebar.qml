import QtQuick
import QtQuick.Layouts
import "../"

/**
 * AppSidebar — Collapsible Sidebar in Graphite Black, Gray, and White.
 * Navigation: Overview, Compress File, Decompress Archive.
 */
Rectangle {
    id: root

    property int currentIndex: 0
    property bool collapsed: false
    signal itemSelected(int index)

    width: collapsed ? 0 : 230
    visible: width > 0
    color: Theme.sidebarBg
    border.color: Theme.borderSubtle
    border.width: 1

    Behavior on width { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

    // Right hairline border
    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: 1
        color: Theme.borderSubtle
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 16

        // 1. Sidebar Brand Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ShrinkItLogo {
                logoScale: 0.82
                animated: false
            }
        }

        // Horizontal divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.borderSubtle
        }

        // Section label
        Text {
            text: "WORKSPACE"
            font.pixelSize: 10
            font.letterSpacing: 1.2
            font.weight: Font.Bold
            font.family: Theme.fontFamily
            color: Theme.textMuted
            Layout.leftMargin: 8
        }

        // 2. Navigation Items List (Overview, Compress, Decompress)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Repeater {
                model: [
                    { label: "Overview", icon: "bar-chart-3" },
                    { label: "Compress File", icon: "sparkles" },
                    { label: "Decompress Archive", icon: "archive" }
                ]

                Rectangle {
                    id: navItem
                    Layout.fillWidth: true
                    height: 38
                    radius: Theme.radiusSM
                    property bool isSelected: root.currentIndex === index

                    color: isSelected
                           ? Qt.rgba(1, 1, 1, 0.08)
                           : (itemMouse.hovered ? Qt.rgba(1, 1, 1, 0.04) : "transparent")
                    border.color: isSelected ? Theme.borderMedium : "transparent"
                    border.width: 1

                    // Left Indicator
                    Rectangle {
                        visible: navItem.isSelected
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 2
                        }
                        width: 3
                        height: 18
                        radius: 1.5
                        color: Theme.accentWhite
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        LucideIcon {
                            name: modelData.icon
                            size: 15
                            color: navItem.isSelected
                                   ? Theme.textPrimary
                                   : (itemMouse.hovered ? Theme.textPrimary : Theme.textSecondary)
                        }

                        Text {
                            text: modelData.label
                            font.pixelSize: 13
                            font.weight: navItem.isSelected ? Font.Medium : Font.Normal
                            font.family: Theme.fontFamily
                            color: navItem.isSelected
                                   ? Theme.textPrimary
                                   : (itemMouse.hovered ? Theme.textPrimary : Theme.textSecondary)
                            Layout.fillWidth: true
                        }
                    }

                    HoverHandler { id: itemMouse }

                    TapHandler {
                        onTapped: {
                            root.currentIndex = index;
                            root.itemSelected(index);
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
