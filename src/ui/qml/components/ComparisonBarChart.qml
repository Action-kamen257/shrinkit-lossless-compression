import QtQuick
import QtQuick.Layouts
import "../"

/**
 * ComparisonBarChart — Standard Cartesian bar chart for file size comparison.
 * Features:
 * - Real Cartesian grid with horizontal guide lines and Y-axis scale.
 * - Solid, thicker bars sitting flush on the 0% baseline with clean rounded tops.
 * - Monospace value labels above each bar and X-axis labels below.
 * - Top legend & reduction badge.
 */
Item {
    id: root

    // Comparison values
    property string originalLabel: "Original File"
    property real originalSize: 100.0
    property string originalFormatted: "1.00 MB"

    property string compressedLabel: "Compressed (.huff)"
    property real compressedSize: 53.3
    property string compressedFormatted: "0.53 MB"

    property string reductionText: "-46.7%"
    property string ratioText: "1.87x"
    property bool showSavingsBadge: true
    property bool drawBackground: false

    property string xAxisOriginalLabel: "Original"
    property string xAxisCompressedLabel: "Compressed"

    // Dynamic maximum value for proportional scaling
    readonly property real maxChartVal: Math.max(root.originalSize, root.compressedSize)

    // Standard bar dimensions (solid & thick)
    property real barWidth: 64
    property real chartHeight: 125

    // Animation progress 0.0 -> 1.0
    property real animProgress: 0.0

    implicitWidth: 440
    implicitHeight: 220

    function restartAnimation() {
        animProgress = 0.0;
        growAnim.restart();
    }

    NumberAnimation {
        id: growAnim
        target: root
        property: "animProgress"
        from: 0.0
        to: 1.0
        duration: 750
        easing.type: Easing.OutCubic
        running: true
    }

    Component.onCompleted: restartAnimation()

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusCard
        color: root.drawBackground ? Qt.rgba(1, 1, 1, 0.02) : "transparent"
        border.color: root.drawBackground ? Theme.borderSubtle : "transparent"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // 1. Top Header: Legend & Savings Tag
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                // Legend 1: Original
                RowLayout {
                    spacing: 6
                    Rectangle {
                        width: 9; height: 9; radius: 2
                        color: "#52525B" // Zinc 600
                    }
                    Text {
                        text: root.originalLabel
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        color: Theme.textSecondary
                    }
                }

                // Legend 2: Compressed
                RowLayout {
                    spacing: 6
                    Rectangle {
                        width: 9; height: 9; radius: 2
                        color: "#FFFFFF"
                    }
                    Text {
                        text: root.compressedLabel
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                }

                Item { Layout.fillWidth: true }

                // Savings Badge
                Rectangle {
                    visible: root.showSavingsBadge
                    height: 22
                    width: badgeTxt.implicitWidth + 14
                    radius: Theme.radiusXS
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.color: Theme.borderMedium
                    border.width: 1

                    Text {
                        id: badgeTxt
                        anchors.centerIn: parent
                        text: root.reductionText + " (" + root.ratioText + ")"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.family: Theme.fontFamilyMono
                        color: Theme.accentWhite
                    }
                }
            }

            // 2. Cartesian Chart Plot Area
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Item {
                    id: plotCanvas
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 60, 360)
                    height: root.chartHeight

                    // 2.1 Horizontal Grid Lines & Y-Axis Labels
                    Repeater {
                        model: [
                            { yRel: 0.00, label: "100%" },
                            { yRel: 0.25, label: "75%" },
                            { yRel: 0.50, label: "50%" },
                            { yRel: 0.75, label: "25%" },
                            { yRel: 1.00, label: "0%" }
                        ]

                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            y: Math.round(plotCanvas.height * modelData.yRel)
                            height: 1

                            // Y-Axis tick label on the left
                            Text {
                                anchors.right: parent.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                font.pixelSize: 9
                                font.family: Theme.fontFamilyMono
                                color: Theme.textMuted
                            }

                            // Grid Line
                            Rectangle {
                                anchors.fill: parent
                                color: modelData.yRel === 1.00 ? Theme.borderMedium : Qt.rgba(1, 1, 1, 0.07)
                                height: modelData.yRel === 1.00 ? 1.5 : 1
                            }
                        }
                    }

                    // 2.2 The Bars (Grouped & centered on plotCanvas)
                    Row {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 48

                        // ── Left: Original Bar Group ──
                        Item {
                            width: root.barWidth
                            height: plotCanvas.height

                            // Formatted size on top
                            Text {
                                anchors.bottom: origBarItem.top
                                anchors.bottomMargin: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.originalFormatted
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                font.family: Theme.fontFamilyMono
                                color: Theme.textSecondary
                            }

                            // The Bar
                            Item {
                                id: origBarItem
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: root.barWidth
                                height: {
                                    if (root.maxChartVal <= 0 || root.originalSize <= 0) return 4;
                                    var rel = root.originalSize / root.maxChartVal;
                                    return Math.max(4, plotCanvas.height * Math.min(1.0, rel) * root.animProgress);
                                }

                                Rectangle {
                                    id: origRect
                                    anchors.fill: parent
                                    radius: 6
                                    color: "#52525B" // Zinc 600

                                    // Square bottom flush with baseline
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: Math.min(parent.height, 6)
                                        color: origRect.color
                                    }

                                    // Top highlight rim
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 1.5
                                        radius: 6
                                        color: "#71717A"
                                    }
                                }
                            }

                            // Label below baseline (X-Axis)
                            Text {
                                anchors.top: parent.bottom
                                anchors.topMargin: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.xAxisOriginalLabel
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                font.family: Theme.fontFamily
                                color: Theme.textMuted
                            }
                        }

                        // ── Right: Compressed Bar Group ──
                        Item {
                            width: root.barWidth
                            height: plotCanvas.height

                            // Formatted size on top
                            Text {
                                anchors.bottom: compBarItem.top
                                anchors.bottomMargin: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.compressedFormatted
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                font.family: Theme.fontFamilyMono
                                color: Theme.accentWhite
                            }

                            // The Bar
                            Item {
                                id: compBarItem
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: root.barWidth
                                height: {
                                    if (root.maxChartVal <= 0 || root.compressedSize <= 0) return 4;
                                    var rel = root.compressedSize / root.maxChartVal;
                                    return Math.max(4, plotCanvas.height * Math.min(1.0, rel) * root.animProgress);
                                }

                                Rectangle {
                                    id: compRect
                                    anchors.fill: parent
                                    radius: 6
                                    color: "#FFFFFF" // Pure White

                                    // Square bottom flush with baseline
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: Math.min(parent.height, 6)
                                        color: compRect.color
                                    }
                                }
                            }

                            // Label below baseline (X-Axis)
                            Text {
                                anchors.top: parent.bottom
                                anchors.topMargin: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.xAxisCompressedLabel
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                font.family: Theme.fontFamily
                                color: Theme.textPrimary
                            }
                        }
                    }
                }
            }
        }
    }
}
