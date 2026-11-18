import QtQuick

/**
 * LucideIcon — Crisp vector icon component reproducing Lucide icon specifications:
 * 24x24 grid coordinate space, stroke width 2, rounded caps and joins.
 * Perfectly matches Apple & GlassyUI minimalist design.
 */
Item {
    id: root

    property string name: "file"
    property real size: 20
    property color color: "#FFFFFF"
    property real strokeWidth: 2.0

    implicitWidth: size
    implicitHeight: size

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        renderTarget: Canvas.Image

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var scale = root.size / 24.0;
            ctx.scale(scale, scale);

            ctx.strokeStyle = root.color;
            ctx.fillStyle = "transparent";
            ctx.lineWidth = root.strokeWidth;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            var n = root.name;

            if (n === "file" || n === "file-text") {
                ctx.beginPath();
                ctx.moveTo(14, 2);
                ctx.lineTo(6, 2);
                ctx.arcTo(4, 2, 4, 4, 2);
                ctx.lineTo(4, 20);
                ctx.arcTo(4, 22, 6, 22, 2);
                ctx.lineTo(18, 22);
                ctx.arcTo(20, 22, 20, 20, 2);
                ctx.lineTo(20, 8);
                ctx.closePath();
                ctx.moveTo(14, 2);
                ctx.lineTo(14, 8);
                ctx.lineTo(20, 8);
                if (n === "file-text") {
                    ctx.moveTo(8, 13);
                    ctx.lineTo(16, 13);
                    ctx.moveTo(8, 17);
                    ctx.lineTo(14, 17);
                }
                ctx.stroke();
            }
            else if (n === "search") {
                // Lucide search
                ctx.beginPath();
                ctx.arc(11, 11, 7, 0, 2 * Math.PI);
                ctx.moveTo(16.5, 16.5);
                ctx.lineTo(21, 21);
                ctx.stroke();
            }
            else if (n === "bell") {
                // Lucide bell
                ctx.beginPath();
                ctx.moveTo(6, 18);
                ctx.lineTo(18, 18);
                ctx.moveTo(18, 18);
                ctx.arcTo(19, 18, 19, 17, 1);
                ctx.lineTo(18, 14);
                ctx.bezierCurveTo(18, 10, 16, 7, 13, 6.2);
                ctx.lineTo(13, 5);
                ctx.arcTo(13, 3, 11, 3, 1.5);
                ctx.arcTo(11, 5, 11, 5, 1.5);
                ctx.lineTo(11, 6.2);
                ctx.bezierCurveTo(8, 7, 6, 10, 6, 14);
                ctx.lineTo(5, 17);
                ctx.arcTo(5, 18, 6, 18, 1);
                ctx.moveTo(10, 18);
                ctx.arcTo(10, 21, 12, 21, 2);
                ctx.arcTo(14, 21, 14, 18, 2);
                ctx.stroke();
            }
            else if (n === "users") {
                // Lucide users
                ctx.beginPath();
                // Front user
                ctx.arc(9, 7, 4, 0, 2 * Math.PI);
                ctx.moveTo(3, 21);
                ctx.bezierCurveTo(3, 17, 6, 15, 9, 15);
                ctx.bezierCurveTo(12, 15, 15, 17, 15, 21);
                // Back user
                ctx.moveTo(16, 3.1);
                ctx.bezierCurveTo(17.2, 3.8, 18, 5.3, 18, 7);
                ctx.bezierCurveTo(18, 8.7, 17.2, 10.2, 16, 10.9);
                ctx.moveTo(18, 15);
                ctx.bezierCurveTo(20, 15.5, 21, 17, 21, 21);
                ctx.stroke();
            }
            else if (n === "clipboard-list") {
                // Lucide clipboard-list
                ctx.beginPath();
                // Clipboard clip
                ctx.rect(9, 2, 6, 4);
                // Board
                ctx.moveTo(9, 4);
                ctx.lineTo(6, 4);
                ctx.arcTo(4, 4, 4, 6, 2);
                ctx.lineTo(4, 20);
                ctx.arcTo(4, 22, 6, 22, 2);
                ctx.lineTo(18, 22);
                ctx.arcTo(20, 22, 20, 20, 2);
                ctx.lineTo(20, 6);
                ctx.arcTo(20, 4, 18, 4, 2);
                ctx.lineTo(15, 4);
                // List items
                ctx.moveTo(8, 11); ctx.lineTo(8.01, 11);
                ctx.moveTo(11, 11); ctx.lineTo(16, 11);
                ctx.moveTo(8, 16); ctx.lineTo(8.01, 16);
                ctx.moveTo(11, 16); ctx.lineTo(16, 16);
                ctx.stroke();
            }
            else if (n === "bar-chart-3" || n === "bar-chart-2" || n === "activity") {
                ctx.beginPath();
                ctx.moveTo(3, 3);
                ctx.lineTo(3, 20);
                ctx.arcTo(3, 21, 4, 21, 1);
                ctx.lineTo(21, 21);
                // 3 bars
                ctx.moveTo(8, 17); ctx.lineTo(8, 11);
                ctx.moveTo(13, 17); ctx.lineTo(13, 7);
                ctx.moveTo(18, 17); ctx.lineTo(18, 13);
                ctx.stroke();
            }
            else if (n === "panel-left" || n === "sidebar-trigger") {
                // Lucide panel-left
                ctx.beginPath();
                ctx.rect(3, 3, 18, 18);
                ctx.moveTo(9, 3);
                ctx.lineTo(9, 21);
                ctx.stroke();
            }
            else if (n === "archive") {
                ctx.beginPath();
                ctx.rect(3, 3, 18, 4);
                ctx.moveTo(4, 7);
                ctx.lineTo(4, 19);
                ctx.arcTo(4, 21, 6, 21, 2);
                ctx.lineTo(18, 21);
                ctx.arcTo(20, 21, 20, 19, 2);
                ctx.lineTo(20, 7);
                ctx.moveTo(10, 12);
                ctx.lineTo(14, 12);
                ctx.stroke();
            }
            else if (n === "arrow-right") {
                ctx.beginPath();
                ctx.moveTo(5, 12);
                ctx.lineTo(19, 12);
                ctx.moveTo(12, 5);
                ctx.lineTo(19, 12);
                ctx.lineTo(12, 19);
                ctx.stroke();
            }
            else if (n === "arrow-down") {
                ctx.beginPath();
                ctx.moveTo(12, 5);
                ctx.lineTo(12, 19);
                ctx.moveTo(19, 12);
                ctx.lineTo(12, 19);
                ctx.lineTo(5, 12);
                ctx.stroke();
            }
            else if (n === "upload-cloud" || n === "upload") {
                ctx.beginPath();
                ctx.moveTo(4, 14.8);
                ctx.arc(8, 15, 4, 1.3, -1.0, true);
                ctx.arc(13, 9, 5, 3.1, -0.4, false);
                ctx.arc(18, 14, 3, 3.8, 0.9, false);
                ctx.moveTo(12, 12);
                ctx.lineTo(12, 21);
                ctx.moveTo(8, 16);
                ctx.lineTo(12, 12);
                ctx.lineTo(16, 16);
                ctx.stroke();
            }
            else if (n === "check" || n === "check-circle") {
                ctx.beginPath();
                if (n === "check-circle") {
                    ctx.arc(12, 12, 10, 0, 2 * Math.PI);
                }
                ctx.moveTo(8, 12);
                ctx.lineTo(11, 15);
                ctx.lineTo(16, 9);
                ctx.stroke();
            }
            else if (n === "sparkles") {
                ctx.beginPath();
                ctx.moveTo(12, 2);
                ctx.bezierCurveTo(12, 6, 14, 8, 18, 9);
                ctx.bezierCurveTo(14, 10, 12, 12, 12, 16);
                ctx.bezierCurveTo(12, 12, 10, 10, 6, 9);
                ctx.bezierCurveTo(10, 8, 12, 6, 12, 2);
                ctx.moveTo(19, 16);
                ctx.lineTo(20, 18);
                ctx.lineTo(22, 19);
                ctx.lineTo(20, 20);
                ctx.lineTo(19, 22);
                ctx.lineTo(18, 20);
                ctx.lineTo(16, 19);
                ctx.lineTo(18, 18);
                ctx.closePath();
                ctx.stroke();
            }
            else if (n === "folder" || n === "folder-open") {
                ctx.beginPath();
                ctx.moveTo(4, 20);
                ctx.arcTo(2, 20, 2, 18, 2);
                ctx.lineTo(2, 6);
                ctx.arcTo(2, 4, 4, 4, 2);
                ctx.lineTo(9, 4);
                ctx.lineTo(11, 7);
                ctx.lineTo(20, 7);
                ctx.arcTo(22, 7, 22, 9, 2);
                ctx.lineTo(22, 18);
                ctx.arcTo(22, 20, 20, 20, 2);
                ctx.closePath();
                ctx.stroke();
            }
            else if (n === "shield-check") {
                ctx.beginPath();
                ctx.moveTo(12, 22);
                ctx.bezierCurveTo(7, 19, 4, 14, 4, 8);
                ctx.lineTo(12, 2);
                ctx.lineTo(20, 8);
                ctx.bezierCurveTo(20, 14, 17, 19, 12, 22);
                ctx.moveTo(9, 12);
                ctx.lineTo(11, 14);
                ctx.lineTo(15, 10);
                ctx.stroke();
            }
            else if (n === "info") {
                ctx.beginPath();
                ctx.arc(12, 12, 10, 0, 2 * Math.PI);
                ctx.moveTo(12, 16);
                ctx.lineTo(12, 12);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(12, 8, 1, 0, 2 * Math.PI);
                ctx.fillStyle = root.color;
                ctx.fill();
            }
            else if (n === "x" || n === "trash") {
                ctx.beginPath();
                ctx.moveTo(18, 6);
                ctx.lineTo(6, 18);
                ctx.moveTo(6, 6);
                ctx.lineTo(18, 18);
                ctx.stroke();
            }
            else if (n === "cpu") {
                ctx.beginPath();
                ctx.rect(7, 7, 10, 10);
                ctx.moveTo(9, 7); ctx.lineTo(9, 4);
                ctx.moveTo(12, 7); ctx.lineTo(12, 4);
                ctx.moveTo(15, 7); ctx.lineTo(15, 4);
                ctx.moveTo(9, 20); ctx.lineTo(9, 17);
                ctx.moveTo(12, 20); ctx.lineTo(12, 17);
                ctx.moveTo(15, 20); ctx.lineTo(15, 17);
                ctx.moveTo(7, 9); ctx.lineTo(4, 9);
                ctx.moveTo(7, 12); ctx.lineTo(4, 12);
                ctx.moveTo(7, 15); ctx.lineTo(4, 15);
                ctx.moveTo(17, 9); ctx.lineTo(20, 9);
                ctx.moveTo(17, 12); ctx.lineTo(20, 12);
                ctx.moveTo(17, 15); ctx.lineTo(20, 15);
                ctx.stroke();
            }
            else if (n === "tree" || n === "layers") {
                ctx.beginPath();
                ctx.moveTo(2, 7);  ctx.lineTo(12, 2);  ctx.lineTo(22, 7);
                ctx.lineTo(12, 12); ctx.closePath();
                ctx.moveTo(2, 12); ctx.lineTo(12, 17); ctx.lineTo(22, 12);
                ctx.moveTo(2, 17); ctx.lineTo(12, 22); ctx.lineTo(22, 17);
                ctx.stroke();
            }
            else {
                ctx.beginPath();
                ctx.arc(12, 12, 4, 0, 2 * Math.PI);
                ctx.stroke();
            }
        }
    }

    onColorChanged: canvas.requestPaint()
    onNameChanged: canvas.requestPaint()
    onSizeChanged: canvas.requestPaint()
    onStrokeWidthChanged: canvas.requestPaint()
}
