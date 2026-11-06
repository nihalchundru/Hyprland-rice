import QtQuick
import qs.tokens
import qs.services
import qs.components

// Music visualizer driven by cava. Styles: bars, mirror, wave, radial. Everything is configurable per widget.
TileBase {
    id: t
    readonly property string kind: cfg.style || "bars"
    readonly property int n: Math.max(4, Math.min(64, Math.round(cfg.bars || 32)))
    readonly property bool bgOn: cfg.showBg === true
    property var disp: new Array(64).fill(0)
    color: bgOn ? (customBg ? cfg.bgHex : Widgets.bg(cfg.color)) : "transparent"

    function mix(a, b, f) { return Qt.rgba(a.r + (b.r - a.r) * f, a.g + (b.g - a.g) * f, a.b + (b.b - a.b) * f, 1) }

    function step() {
        const v = Cava.values, gain = cfg.sensitivity || 1
        const sm = cfg.smoothing !== undefined ? cfg.smoothing : 0.6
        const up = 0.8 - 0.45 * sm, down = 0.4 - 0.33 * sm
        for (let j = 0; j < n; j++) {
            const a = Math.floor(j * v.length / n), b = Math.max(a + 1, Math.floor((j + 1) * v.length / n))
            let m = 0
            for (let k = a; k < b && k < v.length; k++) if (v[k] > m) m = v[k]
            const target = Math.min(1, m * gain)
            disp[j] += (target - disp[j]) * (target > disp[j] ? up : down)
        }
        canvas.requestPaint()
    }

    FrameAnimation { running: t.visible && Cava.running; onTriggered: t.step() }

    Canvas {
        id: canvas
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections { target: t; function onCfgChanged() { canvas.requestPaint() } }
        Connections { target: M3Colors; function onPrimaryChanged() { canvas.requestPaint() } }

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const W = width, H = height, N = t.n, g = t.cfg.gap !== undefined ? t.cfg.gap : 4
            const mode = t.cfg.colorMode || "accent"
            const colorAt = j => {
                switch (mode) {
                case "rainbow": return Qt.hsla(j / N, 0.65, 0.65, 1)
                case "gradient": return t.mix(t.accent, M3Colors.tertiary, j / Math.max(1, N - 1))
                case "fg": return t.fg
                default: return t.accent
                }
            }
            const d = t.disp

            if (t.kind === "wave") {
                const pts = []
                for (let j = 0; j < N; j++) pts.push({ x: j * W / Math.max(1, N - 1), y: H - Math.max(2, d[j] * H) })
                const grad = ctx.createLinearGradient(0, 0, W, 0)
                for (let s = 0; s <= 6; s++) grad.addColorStop(s / 6, colorAt(Math.round(s / 6 * (N - 1))))
                ctx.lineWidth = t.cfg.thickness || 3
                ctx.lineCap = "round"; ctx.lineJoin = "round"
                ctx.beginPath()
                ctx.moveTo(pts[0].x, pts[0].y)
                for (let j = 1; j < N; j++) ctx.quadraticCurveTo(pts[j - 1].x, pts[j - 1].y, (pts[j - 1].x + pts[j].x) / 2, (pts[j - 1].y + pts[j].y) / 2)
                ctx.lineTo(pts[N - 1].x, pts[N - 1].y)
                ctx.strokeStyle = grad
                ctx.stroke()
                ctx.lineTo(W, H); ctx.lineTo(0, H); ctx.closePath()
                ctx.globalAlpha = 0.22
                ctx.fillStyle = grad
                ctx.fill()
            } else if (t.kind === "radial") {
                const cx = W / 2, cy = H / 2, R = Math.min(W, H) / 2, r0 = R * 0.42, maxLen = R * 0.55
                ctx.lineCap = "round"
                ctx.lineWidth = Math.max(2, Math.min(10, 2 * Math.PI * r0 / N - g / 2))
                for (let j = 0; j < N; j++) {
                    const ang = j / N * 2 * Math.PI - Math.PI / 2, len = Math.max(3, d[j] * maxLen)
                    ctx.strokeStyle = colorAt(j)
                    ctx.beginPath()
                    ctx.moveTo(cx + Math.cos(ang) * r0, cy + Math.sin(ang) * r0)
                    ctx.lineTo(cx + Math.cos(ang) * (r0 + len), cy + Math.sin(ang) * (r0 + len))
                    ctx.stroke()
                }
            } else {
                const bw = Math.max(1, (W - g * (N - 1)) / N), minH = 3
                for (let j = 0; j < N; j++) {
                    const h = Math.max(minH, d[j] * H), x = j * (bw + g)
                    ctx.fillStyle = colorAt(j)
                    ctx.beginPath()
                    ctx.roundedRect(x, t.kind === "mirror" ? (H - h) / 2 : H - h, bw, h, bw / 2, bw / 2)
                    ctx.fill()
                }
            }
        }
    }

    M3Text {
        visible: Cava.failed
        anchors.centerIn: parent
        width: parent.width - 24
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: "cava did not start. Install cava, then press Restart in the widget settings."
        role: M3Type.labelMedium
        color: t.fg
    }
}
