import QtQuick
import QtQuick.Layouts
import "../"
import "../components"

/**
 * AlgorithmView — Visualizes the Greedy Huffman Algorithm step trace
 * and the generated prefix-free codebook.
 */
Item {
    id: root

    property var stats: ShrinkItEngine.lastStats

    ColumnLayout {
        anchors {
            fill: parent
            margins: Theme.spacingPage
        }
        spacing: Theme.spacingXL

        // Header
        ColumnLayout {
            spacing: 2
            Text {
                text: "Algorithm Trace"
                font.pixelSize: Theme.fontSize2XL
                font.weight: Theme.fontWeightBold
                color: Theme.textPrimary
            }
            Text {
                text: "Greedy Huffman Coding — Min-Heap merge steps and prefix-free codebook"
                font.pixelSize: Theme.fontSizeSM
                color: Theme.textSecondary
            }
        }

        // Info row
        RowLayout {
            spacing: Theme.spacingLG

            Repeater {
                model: [
                    { lbl: "UNIQUE SYMBOLS",   val: stats && stats.uniqueSymbolCount ? stats.uniqueSymbolCount : "—",           red: false },
                    { lbl: "GREEDY MERGES",    val: stats && stats.greedyStepsCount  ? stats.greedyStepsCount  : "—",           red: true  },
                    { lbl: "TREE HEIGHT",      val: stats && stats.treeHeight        ? stats.treeHeight        : "—",           red: false },
                    { lbl: "CODE RANGE",       val: stats && stats.minCodeLength && stats.maxCodeLength
                                                    ? stats.minCodeLength + " – " + stats.maxCodeLength + " bits" : "—",       red: false }
                ]

                delegate: GlassCard {
                    implicitWidth: 170
                    implicitHeight: 80
                    cherryIntensity: modelData.red ? 0.5 : 0.0

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 2
                        Text { text: modelData.lbl; font.pixelSize: Theme.fontSizeXS; font.letterSpacing: 1.1; color: Theme.textSecondary }
                        Text {
                            text: modelData.val.toString()
                            font.pixelSize: Theme.fontSizeXL
                            font.weight: Theme.fontWeightBold
                            color: modelData.red ? Theme.accentRed : Theme.textPrimary
                        }
                    }
                }
            }
        }

        // Split: greedy steps (left) + codebook (right)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingLG

            // ── Greedy merge steps ──
            GlassCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "GREEDY MERGE TRACE (Min-Heap Extractions)"

                ListView {
                    anchors.fill: parent
                    model: stats && stats.greedySteps ? stats.greedySteps : []
                    clip: true
                    spacing: 4

                    delegate: Item {
                        width: parent ? parent.width : 0
                        height: 52

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusXS
                            color: Qt.rgba(1,1,1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1
                        }

                        ColumnLayout {
                            anchors {
                                fill: parent; margins: Theme.spacingSM
                            }
                            spacing: 2

                            RowLayout {
                                Text {
                                    text: "Step " + modelData.stepNumber
                                    font.pixelSize: Theme.fontSizeXS
                                    font.weight: Theme.fontWeightSemibold
                                    color: Theme.accentRed
                                    font.letterSpacing: 0.6
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "freq: " + modelData.mergedFrequency
                                    font.pixelSize: Theme.fontSizeXS
                                    color: Theme.textMuted
                                }
                            }

                            Text {
                                text: "← " + modelData.leftChild + "   +   " + modelData.rightChild + " →"
                                font.pixelSize: Theme.fontSizeXS
                                color: Theme.textSecondary
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Empty state
                    Text {
                        anchors.centerIn: parent
                        visible: (stats === undefined || stats === null || !stats.greedySteps || stats.greedySteps.length === 0)
                        text: "Compress a file to see the\ngreedy algorithm trace here"
                        font.pixelSize: Theme.fontSizeMD
                        color: Theme.textMuted
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // ── Huffman Codebook ──
            GlassCard {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                title: "HUFFMAN CODEBOOK (Prefix-Free)"

                ListView {
                    anchors.fill: parent
                    model: stats && stats.symbolFrequencies ? stats.symbolFrequencies : []
                    clip: true
                    spacing: 2

                    header: Row {
                        width: parent ? parent.width : 0
                        height: 24
                        Text { width: 50;  text: "BYTE";  font.pixelSize: Theme.fontSizeXS; color: Theme.textMuted; font.letterSpacing: 0.8 }
                        Text { width: 70;  text: "FREQ";  font.pixelSize: Theme.fontSizeXS; color: Theme.textMuted; font.letterSpacing: 0.8 }
                        Text { width: 30;  text: "LEN";   font.pixelSize: Theme.fontSizeXS; color: Theme.textMuted; font.letterSpacing: 0.8 }
                        Text { text: "CODE (bits)"; font.pixelSize: Theme.fontSizeXS; color: Theme.textMuted; font.letterSpacing: 0.8 }
                    }

                    delegate: Row {
                        width: parent ? parent.width : 0
                        height: 22

                        Rectangle {
                            anchors.fill: parent
                            color: index % 2 === 0 ? Qt.rgba(1,1,1,0.02) : "transparent"
                        }

                        Text {
                            width: 50
                            text: modelData.symbol === "."
                                      ? ("0x" + modelData.byte.toString(16).toUpperCase().padStart(2,"0"))
                                      : ("'" + modelData.symbol + "'")
                            font.pixelSize: Theme.fontSizeXS
                            font.family: "monospace"
                            color: index < 3 ? Theme.accentRed : Theme.textSilver
                        }
                        Text { width: 70;  text: modelData.frequency; font.pixelSize: Theme.fontSizeXS; color: Theme.textSecondary; font.family: "monospace" }
                        Text { width: 30;  text: modelData.codeLength; font.pixelSize: Theme.fontSizeXS; color: Theme.textMuted }
                        Text {
                            text: modelData.code
                            font.pixelSize: Theme.fontSizeXS
                            font.family: "monospace"
                            color: index === 0 ? Theme.accentRed
                                 : index < 3   ? Theme.accentRedHigh
                                               : Theme.textMuted
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: (stats === undefined || !stats.symbolFrequencies || stats.symbolFrequencies.length === 0)
                        text: "No codebook yet.\nRun compression first."
                        font.pixelSize: Theme.fontSizeMD
                        color: Theme.textMuted
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
