import QtQuick

// Audio visualizer renderer — every style uses plain QML items (no Canvas,
// which doesn't composite reliably on some setups).
//   bars / mirror / area / spectrum : vertical bars in a Row
//   blocks                           : stacked cells
//   dots                             : rising circles
//   line / wave                      : connected line segments (rotated rects)
//   circle / radial                  : rotated spokes around a center
Item {
    id: root
    property var smooth: []   // smoothed 0..1 values, reassigned each frame so bindings update
    property var peaks: []    // falling peak values
    readonly property var s: Config.s

    readonly property bool useBars: ["bars", "mirror", "blocks", "dots", "area", "spectrum"].includes(s.style)
    readonly property bool useSegments: s.style === "line" || s.style === "wave"
    readonly property bool useRadial: s.style === "circle" || s.style === "radial"
    readonly property int count: smooth.length
    readonly property real slot: count > 0 ? width / count : 1
    readonly property real bw: Math.max(1, slot * s.barWidth)

    // ---- color helpers (hex strings only; never hand a QML color object to JS) ----
    function hexA() { return s.colorSource === "custom" ? s.customA : Colors.primary.toString(); }
    function hexB() { return s.colorSource === "custom" ? s.customB : Colors.secondary.toString(); }
    function rgb(h) {
        h = String(h).replace("#", "");
        if (h.length === 3) h = h.replace(/(.)/g, "$1$1");
        if (h.length >= 6) return [parseInt(h.slice(0,2),16), parseInt(h.slice(2,4),16), parseInt(h.slice(4,6),16)];
        return [255,255,255];
    }
    function mix(a, b, t) {
        const A = rgb(a), B = rgb(b);
        const r = Math.round(A[0]+(B[0]-A[0])*t), g = Math.round(A[1]+(B[1]-A[1])*t), bl = Math.round(A[2]+(B[2]-A[2])*t);
        return "#" + [r,g,bl].map(x => x.toString(16).padStart(2,"0")).join("");
    }
    function hslHex(h) {
        const sat = 0.8, l = 0.6;
        const f = n => { const k = (n + h * 12) % 12; const a = sat * Math.min(l, 1 - l); return l - a * Math.max(-1, Math.min(k - 3, 9 - k)); };
        const to = x => Math.round(x * 255).toString(16).padStart(2, "0");
        return "#" + to(f(0)) + to(f(8)) + to(f(4));
    }
    function barColor(i, v) {
        const n = Math.max(2, root.count);
        const t = n > 1 ? i / (n - 1) : 0;
        const mode = s.colorMode;
        if (mode === "solid") return hexA();
        if (mode === "rainbow") return hslHex((t + s.rotation / 360) % 1);
        if (mode === "palette") {
            const p = Colors.palette;
            if (p.length === 0) return hexA();
            const f = t * (p.length - 1);
            const i0 = Math.floor(f), i1 = Math.min(p.length - 1, i0 + 1);
            return mix(p[i0], p[i1], f - i0);
        }
        if (mode === "height") return mix(hexA(), Colors.error.toString(), Math.min(1, v * 1.2));
        return hexA();
    }
    function barTop(i, v) { return s.colorMode === "gradient" ? (s.reverse ? hexB() : hexA()) : barColor(i, v); }
    function barBot(i, v) { return s.colorMode === "gradient" ? (s.reverse ? hexA() : hexB()) : barColor(i, v); }

    function val(i) {
        const j = s.reverse ? root.count - 1 - i : i;
        return Math.max(s.minHeight, smooth[j] || 0);
    }
    function peakVal(i) {
        const j = s.reverse ? root.count - 1 - i : i;
        return peaks[j] || 0;
    }

    // ---- smoothing timer ----
    Timer {
        interval: 1000 / Math.max(10, s.framerate)
        running: s.enabled && root.visible
        repeat: true
        onTriggered: {
            const t = Cava.values, n = t.length;
            const n2 = n === 0 ? Math.max(2, s.bars) : n; // placeholder while cava is silent
            const prevS = root.smooth, prevP = root.peaks;
            const newS = new Array(n2), newP = new Array(n2);
            const k = 1 - s.smoothing * 0.9;
            for (let i = 0; i < n2; i++) {
                const v = n === 0 ? 0.06 : Math.min(1, (t[i] || 0) * s.sensitivity);
                const pr = prevS[i] || 0;
                newS[i] = pr + (v - pr) * k;
                const pp = prevP[i] || 0;
                newP[i] = newS[i] > pp ? newS[i] : Math.max(0, pp - 0.008);
            }
            root.smooth = newS;
            root.peaks = newP;
        }
    }

    // ================= Row of vertical bars: bars/mirror/area/spectrum/blocks/dots =================
    Row {
        id: rectRow
        anchors.fill: parent
        visible: root.useBars
        clip: true
        Repeater {
            model: root.count
            delegate: Item {
                id: cell
                required property int index
                readonly property real v: root.val(index)
                readonly property real barW: (s.style === "area" || s.style === "spectrum") ? root.slot : root.bw
                readonly property real blockStep: s.blockSize + Math.max(1, s.blockSize * 0.25)
                readonly property int blockCount: Math.max(0, Math.floor(v * parent.height / blockStep))
                readonly property bool mirrored: s.style === "mirror" || s.style === "spectrum"
                width: root.slot
                height: parent.height

                // main bar
                Rectangle {
                    id: bar
                    visible: s.style === "bars" || s.style === "mirror" || s.style === "area" || s.style === "spectrum"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: mirrored ? undefined : parent.bottom
                    anchors.verticalCenter: mirrored ? parent.verticalCenter : undefined
                    width: barW
                    height: v * parent.height
                    radius: (s.style === "area" || s.style === "spectrum") ? 0 : (s.roundness > 0.05 ? Math.min(barW / 2, barW * s.roundness) : 0)
                    opacity: s.opacity
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: root.barTop(cell.index, v) }
                        GradientStop { position: 1.0; color: root.barBot(cell.index, v) }
                    }
                    Behavior on height { NumberAnimation { duration: 40; easing.type: Easing.OutCubic } }
                }

                // blocks: a stack of small rounded cells
                Column {
                    visible: s.style === "blocks"
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Math.max(1, s.blockSize * 0.25)
                    Repeater {
                        model: cell.blockCount
                        Rectangle {
                            width: root.bw
                            height: s.blockSize
                            radius: Math.min(s.blockSize / 2, 2)
                            color: root.barTop(cell.index, cell.v)
                        }
                    }
                }

                // dots: a single circle that rises with the value
                Rectangle {
                    visible: s.style === "dots"
                    width: root.bw
                    height: width
                    radius: width / 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    y: -v * parent.height + height / 2
                    color: root.barTop(cell.index, v)
                    Behavior on y { NumberAnimation { duration: 60; easing.type: Easing.OutCubic } }
                }

                // falling peak cap (bars / mirror)
                Rectangle {
                    visible: s.peaks && (s.style === "bars" || s.style === "mirror")
                    width: barW
                    height: 3
                    radius: 1.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    y: -(mirrored ? root.peakVal(index) * parent.height / 2 : root.peakVal(index) * parent.height) - 4
                    color: Colors.foreground.toString()
                    Behavior on y { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }
                }
            }
        }
    }

    // ================= line / wave: connected segments (rotated rectangles) =================
    Item {
        id: lineHost
        anchors.fill: parent
        visible: root.useSegments
        clip: true
        function px(i) { return (i + 0.5) * root.slot; }
        function py(i) {
            const v = root.val(i);
            if (s.style === "wave") return height / 2 - (v * height / 2) * (i % 2 ? 1 : -1);
            return height - v * height;
        }
        Repeater {
            model: Math.max(0, root.count - 1)
            delegate: Rectangle {
                required property int index
                readonly property real mx: (lineHost.px(index) + lineHost.px(index + 1)) / 2
                readonly property real my: (lineHost.py(index) + lineHost.py(index + 1)) / 2
                readonly property real dx: lineHost.px(index + 1) - lineHost.px(index)
                readonly property real dy: lineHost.py(index + 1) - lineHost.py(index)
                readonly property real len: Math.hypot(dx, dy)
                x: mx - width / 2
                y: my - height / 2
                width: Math.max(1, s.lineWidth)
                height: len
                rotation: Math.atan2(dy, dx) * 180 / Math.PI
                color: root.barColor(index, root.val(index))
                Behavior on height { NumberAnimation { duration: 20; easing.type: Easing.OutCubic } }
            }
        }
    }

    // ================= circle / radial: rotated spokes around a center =================
    Item {
        id: radialHost
        anchors.fill: parent
        visible: root.useRadial
        Repeater {
            model: root.count
            delegate: Item {
                required property int index
                anchors.centerIn: parent
                readonly property real rad: Math.min(parent.width, parent.height) / 2
                readonly property real r0: rad * s.innerRadius
                readonly property real ext: rad - r0
                readonly property real midR: r0 + ext * 0.5
                readonly property real spokeW: s.style === "circle"
                    ? Math.max(Math.PI * 2 * midR / root.count, s.lineWidth)
                    : Math.max(1, (Math.PI * 2 * r0 / Math.max(1, root.count)) * s.barWidth)
                width: spokeW
                height: rad * 2
                rotation: s.rotation + index * 360 / Math.max(1, root.count)
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: rad + r0
                    width: parent.width
                    height: root.val(index) * ext
                    radius: s.style === "circle" ? parent.width / 2 : (s.roundness > 0.3 ? parent.width / 2 : 0)
                    color: root.barColor(index, root.val(index))
                    Behavior on height { NumberAnimation { duration: 20; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
