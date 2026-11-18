import QtQuick
import "../"

/**
 * ShrinkItLogo — Vector rendering of the ShrinkIt application logo:
 * Big File on the left, crisp arrow in the center, small .huff file on the right.
 * Palette: Graphite Black, Silver, and Pure White.
 */
Item {
    id: root

    property real logoScale: 1.0
    property bool animated: false

    implicitWidth: 150 * logoScale
    implicitHeight: 40 * logoScale

    Row {
        anchors.centerIn: parent
        spacing: 10 * root.logoScale

        // 1. Big File Icon (Left)
        Item {
            width: 24 * root.logoScale
            height: 32 * root.logoScale
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: 3 * root.logoScale
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.18)
                border.width: 1

                // Folded corner
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: 7 * root.logoScale
                    height: 7 * root.logoScale
                    radius: 1 * root.logoScale
                    color: Qt.rgba(1, 1, 1, 0.12)
                    border.color: Qt.rgba(1, 1, 1, 0.22)
                    border.width: 0.5
                }

                // File content lines
                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        topMargin: 10 * root.logoScale
                        leftMargin: 4 * root.logoScale
                        rightMargin: 4 * root.logoScale
                    }
                    spacing: 2 * root.logoScale

                    Rectangle { width: parent.width * 0.70; height: 1.5 * root.logoScale; radius: 1; color: Qt.rgba(1, 1, 1, 0.35) }
                    Rectangle { width: parent.width * 0.85; height: 1.5 * root.logoScale; radius: 1; color: Qt.rgba(1, 1, 1, 0.20) }
                    Rectangle { width: parent.width * 0.50; height: 1.5 * root.logoScale; radius: 1; color: Qt.rgba(1, 1, 1, 0.20) }
                }
            }
        }

        // 2. Crisp Arrow pointing right (Center)
        Item {
            width: 22 * root.logoScale
            height: 16 * root.logoScale
            anchors.verticalCenter: parent.verticalCenter

            Canvas {
                id: arrowCanvas
                anchors.fill: parent
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    var w = width;
                    var h = height;
                    var cy = h / 2;

                    ctx.strokeStyle = "#FFFFFF";
                    ctx.lineWidth = 1.8 * root.logoScale;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";

                    ctx.beginPath();
                    ctx.moveTo(2 * root.logoScale, cy);
                    ctx.lineTo(w - 3 * root.logoScale, cy);

                    // Arrowhead
                    ctx.moveTo(w - 8 * root.logoScale, cy - 4 * root.logoScale);
                    ctx.lineTo(w - 2 * root.logoScale, cy);
                    ctx.lineTo(w - 8 * root.logoScale, cy + 4 * root.logoScale);
                    ctx.stroke();
                }
            }
        }

        // 3. Small File Icon (Right)
        Item {
            width: 17 * root.logoScale
            height: 23 * root.logoScale
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: 2.5 * root.logoScale
                color: Qt.rgba(1, 1, 1, 0.08)
                border.color: Theme.accentWhite
                border.width: 1

                // Small folded corner
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: 5 * root.logoScale
                    height: 5 * root.logoScale
                    radius: 1 * root.logoScale
                    color: Qt.rgba(1, 1, 1, 0.22)
                }

                // .huff indicator badge
                Rectangle {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 2 * root.logoScale
                    width: parent.width - 4 * root.logoScale
                    height: 8 * root.logoScale
                    radius: 1.5 * root.logoScale
                    color: Theme.accentWhite

                    Text {
                        anchors.centerIn: parent
                        text: "H"
                        font.pixelSize: 6 * root.logoScale
                        font.weight: Font.Bold
                        font.family: Theme.fontFamily
                        color: "#09090B"
                    }
                }
            }
        }

        // 4. Logo Typography
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: "Shrink"
                font.pixelSize: 16 * root.logoScale
                font.weight: Font.DemiBold
                font.family: Theme.fontFamily
                color: Theme.textPrimary
            }
            Text {
                text: "It"
                font.pixelSize: 16 * root.logoScale
                font.weight: Font.Bold
                font.family: Theme.fontFamily
                color: Theme.textSecondary
            }
        }
    }
}
