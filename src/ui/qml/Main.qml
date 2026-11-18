import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import "."
import "./views"
import "./components"

/**
 * Main.qml — Application Root Window.
 * Design: High-contrast Graphite Black × Neutral Gray × Crisp White.
 * Layout: Collapsible Sidebar + Minimalist Precision Header + Dynamic Page Stack.
 */
Window {
    id: appWindow

    minimumWidth:  980
    minimumHeight: 680
    width:  1200
    height: 780
    visible: true
    title:   "ShrinkIt — Lossless Huffman Studio"
    color:   Theme.bgPrimary

    // Current page: 0 = Overview, 1 = Compress, 2 = Decompress
    property int currentPage: 0
    property bool sidebarCollapsed: false

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ══════════════════════════════════════════════
        // 1. APPSIDEBAR (Collapsible)
        // ══════════════════════════════════════════════
        AppSidebar {
            id: appSidebar
            Layout.fillHeight: true
            currentIndex: appWindow.currentPage
            collapsed: appWindow.sidebarCollapsed
            onItemSelected: index => appWindow.currentPage = index
        }

        // ══════════════════════════════════════════════
        // 2. SIDEBAR INSET (Header + Main Content)
        // ══════════════════════════════════════════════
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ── Minimalist Header ──
            Rectangle {
                Layout.fillWidth: true
                height: 54
                color: Theme.bgGraphite
                border.color: Theme.borderSubtle
                border.width: 1

                // Bottom hairline border
                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                    height: 1
                    color: Theme.borderSubtle
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 14

                    // 2.1 Sidebar Toggle Button
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        width: 32; height: 32
                        radius: Theme.radiusSM
                        color: triggerHover.hovered ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                        border.color: triggerHover.hovered ? Theme.borderMedium : "transparent"
                        border.width: 1

                        LucideIcon {
                            anchors.centerIn: parent
                            name: "panel-left"
                            size: 16
                            color: triggerHover.hovered ? Theme.textPrimary : Theme.textSecondary
                        }

                        HoverHandler { id: triggerHover }
                        TapHandler { onTapped: appWindow.sidebarCollapsed = !appWindow.sidebarCollapsed }
                    }

                    // 2.2 Section Title
                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: {
                            switch (appWindow.currentPage) {
                            case 1:  return "Compress Studio"
                            case 2:  return "Decompress Archive"
                            default: return "Project Overview"
                            }
                        }
                        font.pixelSize: Theme.fontSizeLG
                        font.weight: Font.DemiBold
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }

                    Item { Layout.fillWidth: true }

                    // Engine Badge
                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        height: 26
                        width: badgeRow.implicitWidth + 18
                        radius: Theme.radiusSM
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.color: Theme.borderSubtle
                        border.width: 1

                        RowLayout {
                            id: badgeRow
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                width: 6; height: 6
                                radius: 3
                                color: Theme.accentWhite
                            }

                            Text {
                                text: "Lossless Engine Active"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                font.family: Theme.fontFamily
                                color: Theme.textSecondary
                            }
                        }
                    }
                }
            }

            // ── Main Page Content Stack ──
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                StackLayout {
                    id: mainPages
                    anchors.fill: parent
                    currentIndex: appWindow.currentPage

                    // Page 0: Project Overview
                    OverviewView {
                        onRequestNavigate: tabIndex => appWindow.currentPage = tabIndex
                    }

                    // Page 1: Compress View
                    CompressView { objectName: "compressView" }

                    // Page 2: Decompress View
                    DecompressView { objectName: "decompressView" }
                }
            }
        }
    }
}
