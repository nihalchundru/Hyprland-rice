import QtQuick
import "../../core"
import "../../components"
import "../../services"

Item {
    id: root

    property int cols: 3
    property int rows: 2
    property var settings: ({})
    property color accent:  Theme.accent
    property color accent2: Theme.accent2
    property color accent3: Theme.accent3

    Component.onCompleted: Stats.users++
    Component.onDestruction: Stats.users--

    readonly property bool showGrid: settings.showGrid ?? true

    Row {
        id: head
        spacing: 22

        Column {
            Txt {
                text: Math.round(Stats.cpu * 100) + "%"
                color: root.accent
                font.pixelSize: 20
                font.weight: Font.Bold
            }
            Txt { text: "CPU"; color: Theme.onSurfaceDim; font.pixelSize: 10; font.letterSpacing: 1 }
        }
        Column {
            Txt {
                text: Math.round(Stats.ram * 100) + "%"
                color: root.accent2
                font.pixelSize: 20
                font.weight: Font.Bold
            }
            Txt { text: "RAM"; color: Theme.onSurfaceDim; font.pixelSize: 10; font.letterSpacing: 1 }
        }
    }

    Canvas {
        id: cv
        anchors.top: head.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        Connections {
            target: Stats
            function onCpuHistoryChanged() { cv.requestPaint(); }
            function onRamHistoryChanged() { cv.requestPaint(); }
        }
        Connections {
            target: Theme
            function onAccentChanged()    { cv.requestPaint(); }
            function onAccent2Changed()   { cv.requestPaint(); }
            function onOnSurfaceChanged() { cv.requestPaint(); }
        }
        Connections {
            target: root
            function onShowGridChanged() { cv.requestPaint(); }
            function onAccentChanged()   { cv.requestPaint(); }
            function onAccent2Changed()  { cv.requestPaint(); }
        }

        function series(ctx, data, color, w, h) {
            const n = data.length;
            if (n < 2) return;

            const stepX = w / (Stats.historySize - 1);
            const x0 = w - (n - 1) * stepX;         // newest sample sits on the right edge
            const pad = 3;
            const pts = data.map((v, i) => ({
                x: x0 + i * stepX,
                y: pad + (1 - v) * (h - 2 * pad)
            }));

            function trace() {
                ctx.beginPath();
                ctx.moveTo(pts[0].x, pts[0].y);
                for (let i = 1; i < n - 1; i++) {
                    const mx = (pts[i].x + pts[i + 1].x) / 2;
                    const my = (pts[i].y + pts[i + 1].y) / 2;
                    ctx.quadraticCurveTo(pts[i].x, pts[i].y, mx, my);
                }
                ctx.lineTo(pts[n - 1].x, pts[n - 1].y);
            }

            // gradient fill under the line
            trace();
            ctx.lineTo(pts[n - 1].x, h);
            ctx.lineTo(pts[0].x, h);
            ctx.closePath();
            const grad = ctx.createLinearGradient(0, 0, 0, h);
            grad.addColorStop(0, Qt.alpha(color, 0.30));
            grad.addColorStop(1, Qt.alpha(color, 0.0));
            ctx.fillStyle = grad;
            ctx.fill();

            // the line itself
            trace();
            ctx.strokeStyle = color;
            ctx.lineWidth = 2;
            ctx.lineJoin = "round";
            ctx.lineCap = "round";
            ctx.stroke();
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            if (width < 2 || height < 2) return;

            if (root.showGrid) {
                ctx.strokeStyle = Qt.alpha(Theme.onSurface, 0.07);
                ctx.lineWidth = 1;
                for (let i = 1; i < 4; i++) {
                    const y = Math.round(height * i / 4) + 0.5;
                    ctx.beginPath();
                    ctx.moveTo(0, y);
                    ctx.lineTo(width, y);
                    ctx.stroke();
                }
            }

            series(ctx, Stats.ramHistory, root.accent2, width, height);
            series(ctx, Stats.cpuHistory, root.accent, width, height);
        }
    }
}