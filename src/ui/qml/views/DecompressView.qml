import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import "../"
import "../components"

/**
 * DecompressView — Archive Extraction Studio.
 * Design: Graphite Black × Neutral Gray × Crisp White.
 * Reconstructs original files from .huff archives with Adler-32 verification.
 */
Item {
    id: root

    property string selectedInputPath: ""
    property string selectedOutputPath: ""
    property bool hasCompleted: false

    FileDialog {
        id: filePicker
        title: "Select .huff Archive to Decompress"
        nameFilters: ["Huffman Archives (*.huff)", "All Files (*)"]
        onAccepted: {
            root.setInputArchive(ShrinkItEngine.cleanFilePath(selectedFile));
        }
    }

    function setInputArchive(path) {
        if (!path || path.length === 0) return;
        selectedInputPath = path;
        selectedOutputPath = ShrinkItEngine.generateDefaultOutputPath(path, false);
        hasCompleted = false;
        ShrinkItEngine.inspectFile(path);
    }

    Connections {
        target: ShrinkItEngine
        function onOperationComplete(success, message) {
            if (success) {
                root.hasCompleted = true;
                if (decompBarChart) {
                    decompBarChart.restartAnimation();
                }
            }
        }
    }

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
                margins: 24
            }
            spacing: 20

            // ── Screen Title Header ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Decompress"
                        font.pixelSize: Theme.fontSize2XL
                        font.weight: Font.Bold
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                    Text {
                        text: "Reconstruct original files from .huff archives with tree deserialization"
                        font.pixelSize: Theme.fontSizeSM
                        font.family: Theme.fontFamily
                        color: Theme.textSecondary
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 26
                    width: badgeRow.implicitWidth + 18
                    radius: Theme.radiusSM
                    color: Qt.rgba(1, 1, 1, 0.06)
                    border.color: Theme.borderMedium
                    border.width: 1

                    Row {
                        id: badgeRow
                        anchors.centerIn: parent
                        spacing: 6
                        LucideIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "shield-check"
                            size: 13
                            color: Theme.textPrimary
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Integrity Guaranteed"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                    }
                }
            }

            // ── Drag & Drop Zone ──
            Rectangle {
                id: dropZone
                Layout.fillWidth: true
                height: root.selectedInputPath.length > 0 ? 80 : 190
                radius: Theme.radiusCard
                color: dropArea.containsDrag ? Qt.rgba(1, 1, 1, 0.08) : Theme.bgGraphite
                border.color: dropArea.containsDrag ? Theme.accentWhite : Theme.borderSubtle
                border.width: dropArea.containsDrag ? 1.5 : 1

                Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                DropArea {
                    id: dropArea
                    anchors.fill: parent
                    onDropped: drop => {
                        if (drop.hasUrls && drop.urls.length > 0) {
                            root.setInputArchive(ShrinkItEngine.cleanFilePath(drop.urls[0]));
                        }
                    }
                }

                // Empty State Dropzone
                ColumnLayout {
                    visible: root.selectedInputPath.length === 0
                    anchors.centerIn: parent
                    spacing: 10

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44; height: 44

                        Rectangle {
                            anchors.centerIn: parent
                            width: 44; height: 44
                            radius: 22
                            color: Qt.rgba(1, 1, 1, 0.05)
                            border.color: Theme.borderSubtle
                            border.width: 1
                        }

                        LucideIcon {
                            anchors.centerIn: parent
                            name: "archive"
                            size: 20
                            color: Theme.textPrimary
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Drag and drop any .huff archive here"
                        font.pixelSize: Theme.fontSizeLG
                        font.weight: Font.Medium
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Extracts original byte stream with complete lossless verification"
                        font.pixelSize: Theme.fontSizeSM
                        font.family: Theme.fontFamily
                        color: Theme.textMuted
                    }

                    GlassButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Browse .huff Archive"
                        variant: "secondary"
                        iconName: "folder"
                        onClicked: filePicker.open()
                    }
                }

                // Compact drop banner
                RowLayout {
                    visible: root.selectedInputPath.length > 0
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 14

                    LucideIcon {
                        name: "check-circle"
                        size: 20
                        color: Theme.textPrimary
                    }

                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "Archive Ready for Extraction"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.Medium
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Drop a different .huff archive to replace"
                            font.pixelSize: Theme.fontSizeXS
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                        }
                    }

                    Item { Layout.fillWidth: true }

                    GlassButton {
                        text: "Change Archive"
                        variant: "secondary"
                        iconName: "folder"
                        onClicked: filePicker.open()
                    }
                }
            }

            // ── Visual Comparison Card ──
            Rectangle {
                visible: root.selectedInputPath.length > 0
                Layout.fillWidth: true
                height: 150
                radius: Theme.radiusCard
                color: Theme.bgGraphite
                border.color: Theme.borderSubtle
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    // 1. Left: Compressed Archive Card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusSM
                        color: Qt.rgba(1, 1, 1, 0.05)
                        border.color: Theme.borderMedium
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            LucideIcon {
                                name: "archive"
                                size: 30
                                color: Theme.textPrimary
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: ".HUFF ARCHIVE"
                                    font.pixelSize: 10
                                    font.letterSpacing: 0.8
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamily
                                    color: Theme.accentWhite
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: {
                                        var p = root.selectedInputPath;
                                        return p.substring(Math.max(p.lastIndexOf('/'), p.lastIndexOf('\\')) + 1);
                                    }
                                    font.pixelSize: Theme.fontSizeMD
                                    font.weight: Font.Medium
                                    font.family: Theme.fontFamily
                                    color: Theme.textPrimary
                                    elide: Text.ElideMiddle
                                }

                                Text {
                                    text: "Compressed Bitstream"
                                    font.pixelSize: Theme.fontSizeSM
                                    font.family: Theme.fontFamilyMono
                                    color: Theme.textSecondary
                                }
                            }
                        }
                    }

                    // 2. Center: Arrow
                    ColumnLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 6

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            height: 20
                            width: 98
                            radius: Theme.radiusXS
                            color: Qt.rgba(1, 1, 1, 0.06)
                            border.color: Theme.borderMedium
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "HUFFMAN DECODE"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                font.letterSpacing: 0.8
                                font.family: Theme.fontFamily
                                color: Theme.textPrimary
                            }
                        }

                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            width: 36; height: 26

                            LucideIcon {
                                anchors.centerIn: parent
                                name: "arrow-right"
                                size: 24
                                strokeWidth: 2
                                color: Theme.textPrimary
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Adler-32 Check"
                            font.pixelSize: 10
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                        }
                    }

                    // 3. Right: Restored Output Card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusSM
                        color: Qt.rgba(1, 1, 1, 0.03)
                        border.color: Theme.borderSubtle
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            LucideIcon {
                                name: "file-text"
                                size: 30
                                color: Theme.textMuted
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: "RESTORED ORIGINAL"
                                    font.pixelSize: 10
                                    font.letterSpacing: 0.8
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamily
                                    color: Theme.textMuted
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: {
                                        var p = root.selectedOutputPath;
                                        return p.substring(Math.max(p.lastIndexOf('/'), p.lastIndexOf('\\')) + 1);
                                    }
                                    font.pixelSize: Theme.fontSizeMD
                                    font.weight: Font.Medium
                                    font.family: Theme.fontFamily
                                    color: Theme.textPrimary
                                    elide: Text.ElideMiddle
                                }

                                Text {
                                    text: root.hasCompleted ? "Extracted & Verified" : "Ready to Extract"
                                    font.pixelSize: Theme.fontSizeSM
                                    font.family: Theme.fontFamily
                                    color: root.hasCompleted ? Theme.statusSuccess : Theme.textSecondary
                                }
                            }
                        }
                    }
                }
            }

            // ── Action Buttons ──
            RowLayout {
                visible: root.selectedInputPath.length > 0
                Layout.fillWidth: true
                spacing: 10

                GlassButton {
                    text: "Decompress Archive"
                    variant: "primary"
                    iconName: "archive"
                    enabled: !ShrinkItEngine.isBusy
                    onClicked: {
                        root.hasCompleted = false;
                        ShrinkItEngine.decompressFile(root.selectedInputPath, root.selectedOutputPath);
                    }
                }

                Item { Layout.fillWidth: true }

                GlassButton {
                    text: "Clear"
                    variant: "secondary"
                    iconName: "trash"
                    enabled: !ShrinkItEngine.isBusy
                    onClicked: {
                        root.selectedInputPath = "";
                        root.selectedOutputPath = "";
                        root.hasCompleted = false;
                    }
                }
            }

            // ── Progress Bar ──
            ColumnLayout {
                visible: ShrinkItEngine.isBusy
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: ShrinkItEngine.progressStage.length > 0 ? ShrinkItEngine.progressStage : "Decompressing..."
                        font.pixelSize: Theme.fontSizeSM
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Math.round(ShrinkItEngine.progress * 100) + "%"
                        font.pixelSize: Theme.fontSizeSM
                        font.weight: Font.Bold
                        font.family: Theme.fontFamilyMono
                        color: Theme.textPrimary
                    }
                }

                GlassProgressBar {
                    Layout.fillWidth: true
                    value: ShrinkItEngine.progress
                }
            }

            // ── Results Card ──
            Rectangle {
                visible: root.hasCompleted
                Layout.fillWidth: true
                implicitHeight: resultsCol.implicitHeight + 36
                radius: Theme.radiusCard
                color: Theme.bgGraphite
                border.color: Theme.borderMedium
                border.width: 1

                ColumnLayout {
                    id: resultsCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 18
                    }
                    spacing: 14

                    RowLayout {
                        spacing: 8
                        LucideIcon {
                            name: "shield-check"
                            size: 20
                            color: Theme.statusSuccess
                        }
                        Text {
                            text: "Decompression Verified — 100% Byte-for-Byte Identical Match"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.DemiBold
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                    }

                    Text {
                        text: "Restored File: " + root.selectedOutputPath
                        font.pixelSize: Theme.fontSizeSM
                        font.family: Theme.fontFamilyMono
                        color: Theme.textSilver
                        elide: Text.ElideMiddle
                    }

                    // Animated Comparison Bar Chart
                    ComparisonBarChart {
                        id: decompBarChart
                        Layout.fillWidth: true
                        height: 210
                        originalLabel: "Restored Original Size"
                        originalSize: {
                            var b = ShrinkItEngine.getFileSize(root.selectedOutputPath);
                            return b > 0 ? b : 100;
                        }
                        originalFormatted: {
                            var b = ShrinkItEngine.getFileSize(root.selectedOutputPath);
                            return ShrinkItEngine.formatBytes(b);
                        }
                        compressedLabel: "Archive Size (.huff)"
                        compressedSize: {
                            var b = ShrinkItEngine.getFileSize(root.selectedInputPath);
                            return b > 0 ? b : 50;
                        }
                        compressedFormatted: {
                            var b = ShrinkItEngine.getFileSize(root.selectedInputPath);
                            return ShrinkItEngine.formatBytes(b);
                        }
                        reductionText: {
                            var o = ShrinkItEngine.getFileSize(root.selectedOutputPath);
                            var c = ShrinkItEngine.getFileSize(root.selectedInputPath);
                            if (o > 0 && c > 0 && o > c) {
                                return "-" + ((1.0 - (c / o)) * 100).toFixed(1) + "%";
                            }
                            return "100% Match";
                        }
                        ratioText: {
                            var o = ShrinkItEngine.getFileSize(root.selectedOutputPath);
                            var c = ShrinkItEngine.getFileSize(root.selectedInputPath);
                            if (o > 0 && c > 0 && c > 0) {
                                return (o / c).toFixed(2) + "x";
                            }
                            return "1.00x";
                        }
                    }
                }
            }
        }
    }
}
