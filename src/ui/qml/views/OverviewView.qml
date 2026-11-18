import QtQuick
import QtQuick.Layouts
import "../"
import "../components"

/**
 * OverviewView — Comprehensive Project Overview & Compression Architecture.
 * Explains what ShrinkIt is, how the Greedy Huffman + LZ77 pipeline works,
 * typical size changes, and features an animated comparison bar graph.
 */
Item {
    id: root

    signal requestNavigate(int tabIndex)

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentCol.implicitHeight + 48
        clip: true

        ColumnLayout {
            id: contentCol
            anchors {
                left: parent.left
                right: parent.right
                margins: 28
            }
            spacing: 24

            // ── Section 1: Header ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                ColumnLayout {
                    spacing: 3
                    Text {
                        text: "Project Overview"
                        font.pixelSize: Theme.fontSize2XL
                        font.weight: Font.Bold
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                    Text {
                        text: "Lossless Compression Engine · Greedy Huffman Coding & Sliding Window LZ77"
                        font.pixelSize: Theme.fontSizeSM
                        font.family: Theme.fontFamily
                        color: Theme.textSecondary
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 8
                    GlassButton {
                        text: "Compress File"
                        variant: "primary"
                        iconName: "sparkles"
                        onClicked: root.requestNavigate(1)
                    }
                    GlassButton {
                        text: "Decompress .huff"
                        variant: "secondary"
                        iconName: "archive"
                        onClicked: root.requestNavigate(2)
                    }
                }
            }

            // ── Section 2: Center Animated Size Change Bar Graph ──
            Rectangle {
                Layout.fillWidth: true
                height: 290
                radius: Theme.radiusCard
                color: Theme.bgGraphite
                border.color: Theme.borderSubtle
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: "Average Compression Size Benchmark"
                                font.pixelSize: Theme.fontSizeMD
                                font.weight: Font.DemiBold
                                font.family: Theme.fontFamily
                                color: Theme.textPrimary
                            }
                            Text {
                                text: "Original raw byte stream vs .huff compressed archive"
                                font.pixelSize: Theme.fontSizeSM
                                font.family: Theme.fontFamily
                                color: Theme.textMuted
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Workload Switcher buttons
                        Row {
                            spacing: 6
                            Repeater {
                                model: [
                                    { label: "Text / Docs (-47%)", orig: 100, comp: 53.3, origF: "1.00 MB", compF: "0.53 MB", red: "-46.7%", rat: "1.87x" },
                                    { label: "Code / JSON (-55%)", orig: 100, comp: 45.0, origF: "1.00 MB", compF: "0.45 MB", red: "-55.0%", rat: "2.22x" },
                                    { label: "Repetitive Logs (-88%)", orig: 100, comp: 12.5, origF: "1.00 MB", compF: "0.12 MB", red: "-87.5%", rat: "8.00x" }
                                ]

                                Rectangle {
                                    id: filterBtn
                                    property bool active: benchmarkChart.selectedWorkload === index
                                    width: filterTxt.implicitWidth + 14
                                    height: 24
                                    radius: Theme.radiusXS
                                    color: active ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.04)
                                    border.color: active ? Theme.borderMedium : Theme.borderSubtle
                                    border.width: 1

                                    Text {
                                        id: filterTxt
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        font.pixelSize: 10
                                        font.weight: filterBtn.active ? Font.DemiBold : Font.Normal
                                        font.family: Theme.fontFamily
                                        color: filterBtn.active ? Theme.textPrimary : Theme.textMuted
                                    }

                                    TapHandler {
                                        onTapped: {
                                            benchmarkChart.selectedWorkload = index;
                                            benchmarkChart.originalSize = modelData.orig;
                                            benchmarkChart.compressedSize = modelData.comp;
                                            benchmarkChart.originalFormatted = modelData.origF;
                                            benchmarkChart.compressedFormatted = modelData.compF;
                                            benchmarkChart.reductionText = modelData.red;
                                            benchmarkChart.ratioText = modelData.rat;
                                            benchmarkChart.restartAnimation();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // The Animated Bar Chart
                    ComparisonBarChart {
                        id: benchmarkChart
                        property int selectedWorkload: 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        originalLabel: "Original File Size"
                        originalSize: 100
                        originalFormatted: "1.00 MB"
                        compressedLabel: "Compressed Output (.huff)"
                        compressedSize: 53.3
                        compressedFormatted: "0.53 MB"
                        reductionText: "-46.7%"
                        ratioText: "1.87x"
                    }
                }
            }

            // ── Section 3: What the Project Actually Is ──
            Rectangle {
                Layout.fillWidth: true
                radius: Theme.radiusCard
                color: Theme.bgGraphite
                border.color: Theme.borderSubtle
                border.width: 1
                implicitHeight: aboutCol.implicitHeight + 36

                ColumnLayout {
                    id: aboutCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 18
                    }
                    spacing: 12

                    RowLayout {
                        spacing: 8
                        LucideIcon { name: "info"; size: 16; color: Theme.textPrimary }
                        Text {
                            text: "What is ShrinkIt?"
                            font.pixelSize: Theme.fontSizeLG
                            font.weight: Font.DemiBold
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "ShrinkIt is a desktop file compression tool engineered for the Design and Analysis of Algorithms (DAA) curriculum. It implements optimal lossless data compression by pairing Greedy Huffman Coding with a sliding-window LZ77 dictionary matcher in modern C++17 and Qt 6. It reduces file sizes down to 0.3x – 0.7x their original size while guaranteeing 100% byte-for-byte exact restoration upon decompression."
                        font.pixelSize: Theme.fontSizeSM
                        font.family: Theme.fontFamily
                        color: Theme.textSecondary
                        wrapMode: Text.WordWrap
                        lineHeight: 1.35
                    }

                    // 3 Feature Cards
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            height: 80
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 3
                                Text { text: "100% LOSSLESS INTEGRITY"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 0.8; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "Adler-32 verification guarantees zero data loss or bit corruption."; font.pixelSize: 11; font.family: Theme.fontFamily; color: Theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 80
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 3
                                Text { text: "GREEDY MIN-HEAP MERGING"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 0.8; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "Builds optimal prefix-free binary trees in O(N log N) algorithmic time."; font.pixelSize: 11; font.family: Theme.fontFamily; color: Theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 80
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 3
                                Text { text: "ZERO FILE EXPANSION"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 0.8; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "Evaluates compression strategies; falls back to stored mode if incompressible."; font.pixelSize: 11; font.family: Theme.fontFamily; color: Theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }

            // ── Section 4: How Compression Works (Pipeline) ──
            Rectangle {
                Layout.fillWidth: true
                radius: Theme.radiusCard
                color: Theme.bgGraphite
                border.color: Theme.borderSubtle
                border.width: 1
                implicitHeight: pipelineCol.implicitHeight + 36

                ColumnLayout {
                    id: pipelineCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 18
                    }
                    spacing: 14

                    RowLayout {
                        spacing: 8
                        LucideIcon { name: "cpu"; size: 16; color: Theme.textPrimary }
                        Text {
                            text: "How the Compression Pipeline Works"
                            font.pixelSize: Theme.fontSizeLG
                            font.weight: Font.DemiBold
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                    }

                    // 4 Step Pipeline
                    GridLayout {
                        columns: width > 750 ? 4 : 2
                        rowSpacing: 10
                        columnSpacing: 10
                        Layout.fillWidth: true

                        // Step 1
                        Rectangle {
                            Layout.fillWidth: true
                            height: 110
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4
                                Text { text: "STEP 1"; font.pixelSize: 9; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textMuted }
                                Text { text: "Byte Frequency Scan"; font.pixelSize: 12; font.weight: Font.Medium; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "Counts byte occurrences across alphabet and computes Shannon Entropy."; font.pixelSize: 10; font.family: Theme.fontFamily; color: Theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }

                        // Step 2
                        Rectangle {
                            Layout.fillWidth: true
                            height: 110
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4
                                Text { text: "STEP 2"; font.pixelSize: 9; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textMuted }
                                Text { text: "LZ77 Dictionary Match"; font.pixelSize: 12; font.weight: Font.Medium; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "32 KB sliding window replaces repeated phrases with distance & length pointers."; font.pixelSize: 10; font.family: Theme.fontFamily; color: Theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }

                        // Step 3
                        Rectangle {
                            Layout.fillWidth: true
                            height: 110
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4
                                Text { text: "STEP 3"; font.pixelSize: 9; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textMuted }
                                Text { text: "Greedy Huffman Tree"; font.pixelSize: 12; font.weight: Font.Medium; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "Min-Heap merges lowest weights to assign shorter bitcodes to frequent symbols."; font.pixelSize: 10; font.family: Theme.fontFamily; color: Theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }

                        // Step 4
                        Rectangle {
                            Layout.fillWidth: true
                            height: 110
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 4
                                Text { text: "STEP 4"; font.pixelSize: 9; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textMuted }
                                Text { text: "Bitstream & Adler-32"; font.pixelSize: 12; font.weight: Font.Medium; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "Serializes compact tree topology and encoded bitstream into .huff archive."; font.pixelSize: 10; font.family: Theme.fontFamily; color: Theme.textMuted; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }

            // ── Section 5: Average Size Changes After Compression ──
            Rectangle {
                Layout.fillWidth: true
                radius: Theme.radiusCard
                color: Theme.bgGraphite
                border.color: Theme.borderSubtle
                border.width: 1
                implicitHeight: sizeChangesCol.implicitHeight + 36

                ColumnLayout {
                    id: sizeChangesCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 18
                    }
                    spacing: 12

                    RowLayout {
                        spacing: 8
                        LucideIcon { name: "bar-chart-3"; size: 16; color: Theme.textPrimary }
                        Text {
                            text: "Average File Size Changes After Compression"
                            font.pixelSize: Theme.fontSizeLG
                            font.weight: Font.DemiBold
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                    }

                    GridLayout {
                        columns: width > 750 ? 4 : 2
                        rowSpacing: 10
                        columnSpacing: 10
                        Layout.fillWidth: true

                        // Category 1
                        Rectangle {
                            Layout.fillWidth: true
                            height: 84
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 2
                                Text { text: "TEXT & MARKDOWN"; font.pixelSize: 9; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textMuted }
                                Text { text: "-45% to -55%"; font.pixelSize: 16; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "Size gets down to ~0.50x"; font.pixelSize: 10; font.family: Theme.fontFamily; color: Theme.textMuted }
                            }
                        }

                        // Category 2
                        Rectangle {
                            Layout.fillWidth: true
                            height: 84
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 2
                                Text { text: "SOURCE CODE & JSON"; font.pixelSize: 9; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textMuted }
                                Text { text: "-50% to -65%"; font.pixelSize: 16; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "Size gets down to ~0.40x"; font.pixelSize: 10; font.family: Theme.fontFamily; color: Theme.textMuted }
                            }
                        }

                        // Category 3
                        Rectangle {
                            Layout.fillWidth: true
                            height: 84
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 2
                                Text { text: "REPETITIVE LOGS"; font.pixelSize: 9; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textMuted }
                                Text { text: "-70% to -90%+"; font.pixelSize: 16; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textPrimary }
                                Text { text: "Size gets down to ~0.10x"; font.pixelSize: 10; font.family: Theme.fontFamily; color: Theme.textMuted }
                            }
                        }

                        // Category 4
                        Rectangle {
                            Layout.fillWidth: true
                            height: 84
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 2
                                Text { text: "PRE-COMPRESSED"; font.pixelSize: 9; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textMuted }
                                Text { text: "Stored Fallback"; font.pixelSize: 16; font.weight: Font.Bold; font.family: Theme.fontFamily; color: Theme.textSecondary }
                                Text { text: "Guarantees 0% expansion"; font.pixelSize: 10; font.family: Theme.fontFamily; color: Theme.textMuted }
                            }
                        }
                    }
                }
            }
        }
    }
}
