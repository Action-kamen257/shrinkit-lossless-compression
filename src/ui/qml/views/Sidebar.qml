import QtQuick
import QtQuick.Layouts
import "../"
import "../components"

/**
 * Sidebar — Black translucent navigation panel.
 *
 * Active item: Cherry Red indicator + brighter glass bg + white text.
 * Inactive items: Muted silver text.
 */
Item {
    id: root

    property int currentIndex: 0
    signal itemSelected(int index)

    width: 220

    // Sidebar glass surface
    GlassMaterial {
        anchors.fill: parent
        variant: "sidebar"
        radius: 0
        showEdgeGlow: false
    }

    // Right border separator
    Rectangle {
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: 1
        color: Theme.sidebarBd
    }

    ColumnLayout {
        anchors {
            fill: parent
            topMargin: Theme.spacingXL
            bottomMargin: Theme.spacingLG
            leftMargin: Theme.spacingMD
            rightMargin: Theme.spacingMD
        }
        spacing: 2

        // App logo / title
        Row {
            spacing: Theme.spacingSM
            Layout.leftMargin: Theme.spacingSM
            Layout.bottomMargin: Theme.spacingXL

            // Cherry Red accent dot
            Rectangle {
                width: 8; height: 8; radius: 4
                color: Theme.accentRed
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "SHRINKIT"
                font.pixelSize: Theme.fontSizeLG
                font.weight: Theme.fontWeightBold
                font.letterSpacing: 2.5
                color: Theme.textPrimary
            }
        }

        // Navigation items
        Repeater {
            model: [
                { label: "Dashboard",  icon: "⊞" },
                { label: "Compress",   icon: "⬇" },
                { label: "Decompress", icon: "⬆" },
                { label: "Algorithm",  icon: "⌥" },
                { label: "Liquid Lab", icon: "◈" }
            ]

            delegate: Item {
                Layout.fillWidth: true
                height: 44

                // Active glass bg
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSM
                    color: root.currentIndex === index
                               ? Theme.sidebarItemActive
                               : hoverArea.containsMouse ? Theme.stateHover : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }

                // Cherry Red left indicator bar
                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                        topMargin: 8
                        bottomMargin: 8
                    }
                    width: 3
                    radius: 1.5
                    color: Theme.sidebarIndicator
                    visible: root.currentIndex === index
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                }

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 10
                    }
                    spacing: Theme.spacingMD

                    Text {
                        text: modelData.icon
                        font.pixelSize: Theme.fontSizeLG
                        color: root.currentIndex === index ? Theme.accentRedHigh : Theme.textSecondary
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    Text {
                        text: modelData.label
                        font.pixelSize: Theme.fontSizeMD
                        font.weight: root.currentIndex === index
                                         ? Theme.fontWeightSemibold
                                         : Theme.fontWeightNormal
                        color: root.currentIndex === index
                                   ? Theme.sidebarTextActive
                                   : Theme.sidebarTextInactive
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on font.weight { NumberAnimation { duration: Theme.animFast } }
                    }
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.itemSelected(index)
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Version tag
        Text {
            text: "v1.0.0 · ShrinkIt"
            font.pixelSize: Theme.fontSizeXS
            color: Theme.textMuted
            Layout.leftMargin: Theme.spacingSM
        }
    }
}
