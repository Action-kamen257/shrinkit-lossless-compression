import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import "../"
import "../components"

/**
 * CompressView — Modern File Compression Studio.
 * Design: Graphite Black × Neutral Gray × Crisp White.
 * Features: Drag & Drop zone, Big File -> Arrow -> Small File live preview,
 * and high-contrast execution controls.
 */
Item {
    id: root

    property string selectedInputPath: ""
    property string selectedOutputPath: ""
    property bool hasCompleted: false

    FileDialog {
        id: filePicker
        title: "Select File to Compress"
        onAccepted: {
            root.setInputFile(ShrinkItEngine.cleanFilePath(selectedFile));
        }
    }

    function setInputFile(path) {
        if (!path || path.length === 0) return;
        selectedInputPath = path;
        selectedOutputPath = ShrinkItEngine.generateDefaultOutputPath(path, true);
        hasCompleted = false;
        ShrinkItEngine.analyzeFile(path);
    }

    Connections {
        target: ShrinkItEngine
        function onOperationComplete(success, message) {
            if (success) {
                root.hasCompleted = true;
                if (compBarChart) {
                    compBarChart.restartAnimation();
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
                        text: "Compress"
                        font.pixelSize: Theme.fontSize2XL
                        font.weight: Font.Bold
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }
                    Text {
                        text: "Greedy Huffman Coding & Sliding Window LZ77 Lossless Compression"
                        font.pixelSize: Theme.fontSizeSM
                        font.family: Theme.fontFamily
                        color: Theme.textSecondary
                    }
                }

                Item { Layout.fillWidth: true }

                // Lossless badge
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
                            text: "Adler-32 Lossless"
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
                            root.setInputFile(ShrinkItEngine.cleanFilePath(drop.urls[0]));
                        }
                    }
                }

                // Empty Dropzone State
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
                            name: "upload-cloud"
                            size: 20
                            color: Theme.textPrimary
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Drag and drop any file to compress"
                        font.pixelSize: Theme.fontSizeLG
                        font.weight: Font.Medium
                        font.family: Theme.fontFamily
                        color: Theme.textPrimary
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Supports text, binary, documents, images, and source code"
                        font.pixelSize: Theme.fontSizeSM
                        font.family: Theme.fontFamily
                        color: Theme.textMuted
                    }

                    GlassButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Browse Files"
                        variant: "secondary"
                        iconName: "folder"
                        onClicked: filePicker.open()
                    }
                }

                // Compact drop banner when file is selected
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
                            text: "File Ready for Compression"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.Medium
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Drop a different file to replace"
                            font.pixelSize: Theme.fontSizeXS
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                        }
                    }

                    Item { Layout.fillWidth: true }

                    GlassButton {
                        text: "Change File"
                        variant: "secondary"
                        iconName: "folder"
                        onClicked: filePicker.open()
                    }
                }
            }

            // ── Big File -> Arrow -> Small File Visualizer Card ──
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

                    // 1. Left: Big File
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
                                    text: "ORIGINAL RAW FILE"
                                    font.pixelSize: 10
                                    font.letterSpacing: 0.8
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamily
                                    color: Theme.textMuted
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
                                    text: {
                                        var stats = ShrinkItEngine.lastStats;
                                        if (stats && stats.originalSize !== undefined) {
                                            return ShrinkItEngine.formatBytes(stats.originalSize);
                                        }
                                        return "Calculating...";
                                    }
                                    font.pixelSize: Theme.fontSizeSM
                                    font.family: Theme.fontFamilyMono
                                    color: Theme.textSecondary
                                }
                            }
                        }
                    }

                    // 2. Center: Arrow & Algorithm Pill
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
                                text: "GREEDY HUFFMAN"
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
                            text: "Target: ≤ 0.7x"
                            font.pixelSize: 10
                            font.family: Theme.fontFamily
                            color: Theme.textMuted
                        }
                    }

                    // 3. Right: Small File (.huff)
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
                                    text: "COMPRESSED ARCHIVE"
                                    font.pixelSize: 10
                                    font.letterSpacing: 0.8
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamily
                                    color: Theme.accentWhite
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
                                    text: {
                                        var stats = ShrinkItEngine.lastStats;
                                        if (root.hasCompleted && stats && stats.compressedSize !== undefined) {
                                            return ShrinkItEngine.formatBytes(stats.compressedSize) + " (Done)";
                                        }
                                        return ".huff Container";
                                    }
                                    font.pixelSize: Theme.fontSizeSM
                                    font.family: Theme.fontFamilyMono
                                    color: Theme.accentWhite
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
                    text: "Compress Now"
                    variant: "primary"
                    iconName: "sparkles"
                    enabled: !ShrinkItEngine.isBusy
                    onClicked: {
                        root.hasCompleted = false;
                        ShrinkItEngine.compressFile(root.selectedInputPath, root.selectedOutputPath);
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
                        text: ShrinkItEngine.progressStage.length > 0 ? ShrinkItEngine.progressStage : "Processing..."
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
                            name: "check-circle"
                            size: 18
                            color: Theme.statusSuccess
                        }
                        Text {
                            text: "Compression Complete — 100% Lossless Exact Match"
                            font.pixelSize: Theme.fontSizeMD
                            font.weight: Font.DemiBold
                            font.family: Theme.fontFamily
                            color: Theme.textPrimary
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Adler-32: " + (ShrinkItEngine.lastStats.checksumHex ? ShrinkItEngine.lastStats.checksumHex : "OK")
                            font.pixelSize: Theme.fontSizeXS
                            font.family: Theme.fontFamilyMono
                            color: Theme.textMuted
                        }
                    }

                    // Stat Metrics Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // Stat 1: Space Savings
                        Rectangle {
                            Layout.fillWidth: true
                            height: 54
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "SPACE SAVINGS"
                                    font.pixelSize: 9
                                    font.letterSpacing: 0.8
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamily
                                    color: Theme.textMuted
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: {
                                        var s = ShrinkItEngine.lastStats;
                                        var sav = (s && s.spaceSavingPercent !== undefined) ? s.spaceSavingPercent : ((s && s.spaceSavings !== undefined) ? s.spaceSavings : 0.0);
                                        return sav.toFixed(1) + "%";
                                    }
                                    font.pixelSize: 17
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamily
                                    color: Theme.accentWhite
                                }
                            }
                        }

                        // Stat 2: Ratio
                        Rectangle {
                            Layout.fillWidth: true
                            height: 54
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "RATIO"
                                    font.pixelSize: 9
                                    font.letterSpacing: 0.8
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamily
                                    color: Theme.textMuted
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: {
                                        var s = ShrinkItEngine.lastStats;
                                        var r = (s && s.compressionRatio !== undefined) ? s.compressionRatio : 1.0;
                                        return r.toFixed(2) + "x";
                                    }
                                    font.pixelSize: 17
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamily
                                    color: Theme.textPrimary
                                }
                            }
                        }

                        // Stat 3: Elapsed Time
                        Rectangle {
                            Layout.fillWidth: true
                            height: 54
                            radius: Theme.radiusSM
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Theme.borderSubtle
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "ELAPSED TIME"
                                    font.pixelSize: 9
                                    font.letterSpacing: 0.8
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamily
                                    color: Theme.textMuted
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: {
                                        var s = ShrinkItEngine.lastStats;
                                        var t = (s && s.processingTimeMs !== undefined) ? s.processingTimeMs : ((s && s.compressionTimeMs !== undefined) ? s.compressionTimeMs : 0.0);
                                        return t.toFixed(1) + " ms";
                                    }
                                    font.pixelSize: 17
                                    font.weight: Font.Bold
                                    font.family: Theme.fontFamilyMono
                                    color: Theme.textSilver
                                }
                            }
                        }
                    }

                    // Animated Comparison Bar Chart
                    ComparisonBarChart {
                        id: compBarChart
                        Layout.fillWidth: true
                        height: 210
                        originalLabel: "Original File"
                        originalSize: {
                            var s = ShrinkItEngine.lastStats;
                            return (s && s.originalSizeBytes) ? s.originalSizeBytes : ((s && s.originalSize) ? s.originalSize : 100);
                        }
                        originalFormatted: {
                            var s = ShrinkItEngine.lastStats;
                            if (s && s.originalSizeFormatted) return s.originalSizeFormatted;
                            var bytes = (s && s.originalSizeBytes) ? s.originalSizeBytes : ((s && s.originalSize) ? s.originalSize : ShrinkItEngine.getFileSize(root.selectedInputPath));
                            return ShrinkItEngine.formatBytes(bytes);
                        }
                        compressedLabel: "Compressed Output (.huff)"
                        compressedSize: {
                            var s = ShrinkItEngine.lastStats;
                            return (s && s.compressedSizeBytes) ? s.compressedSizeBytes : ((s && s.compressedSize) ? s.compressedSize : 50);
                        }
                        compressedFormatted: {
                            var s = ShrinkItEngine.lastStats;
                            if (s && s.compressedSizeFormatted) return s.compressedSizeFormatted;
                            var bytes = (s && s.compressedSizeBytes) ? s.compressedSizeBytes : ((s && s.compressedSize) ? s.compressedSize : ShrinkItEngine.getFileSize(root.selectedOutputPath));
                            return ShrinkItEngine.formatBytes(bytes);
                        }
                        reductionText: {
                            var s = ShrinkItEngine.lastStats;
                            var sav = (s && s.spaceSavingPercent !== undefined) ? s.spaceSavingPercent : ((s && s.spaceSavings !== undefined) ? s.spaceSavings : 0.0);
                            return "-" + sav.toFixed(1) + "%";
                        }
                        ratioText: {
                            var s = ShrinkItEngine.lastStats;
                            var r = (s && s.compressionRatio !== undefined) ? s.compressionRatio : 1.0;
                            return r.toFixed(2) + "x";
                        }
                    }
                }
            }
        }
    }
}
