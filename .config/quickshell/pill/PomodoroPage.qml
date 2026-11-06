import QtQuick

Item {
    id: root
    width: 360
    height: 400

    // current phase color, taken from the theme; fades smoothly when the phase changes
    property color accent: PomodoroService.phaseColor
    Behavior on accent { ColorAnimation { duration: 450; easing.type: Easing.OutCubic } }

    // Theme.text at a given opacity, used for tracks, buttons and chips
    function tint(a) {
        return Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, a);
    }

    // true while the "set your own timer" panel is open
    property bool editing: false

    // leaving the page closes the editor
    Connections {
        target: Pill
        function onModeChanged() { if (Pill.mode !== "pomodoro") root.editing = false; }
    }

    // dots fill up toward the long break; all four stay lit during it
    readonly property int filledDots: PomodoroService.phase === "long"
        ? PomodoroService.longEvery
        : PomodoroService.sessions % PomodoroService.longEvery

    readonly property string phaseLabel: editing ? "SET YOUR TIMER"
        : PomodoroService.phase === "focus" ? "FOCUS"
        : PomodoroService.phase === "short" ? "SHORT BREAK"
        : PomodoroService.phase === "long" ? "LONG BREAK"
        : "READY TO FOCUS"

    // ── round icon button (reset / play / pause / skip / tune) ────
    component IconBtn: Item {
        id: btn
        property string kind: "play"
        property real d: 48
        property color fillColor: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.14)
        property color iconColor: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.92)
        signal clicked()

        width: d
        height: d
        scale: ma.pressed ? 0.92 : 1
        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: btn.fillColor
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Theme.text
            opacity: ma.containsMouse ? 0.10 : 0
            Behavior on opacity { NumberAnimation { duration: 140 } }
        }

        Canvas {
            id: cv
            anchors.fill: parent
            property color fg: btn.iconColor
            onFgChanged: requestPaint()
            Component.onCompleted: requestPaint()
            Connections {
                target: btn
                function onKindChanged() { cv.requestPaint(); }
            }

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const s = width;
                ctx.fillStyle = fg;
                ctx.strokeStyle = fg;
                ctx.lineWidth = 2.2;
                ctx.lineCap = "round";

                if (btn.kind === "play") {
                    ctx.beginPath();
                    ctx.moveTo(s * 0.40, s * 0.28);
                    ctx.lineTo(s * 0.74, s * 0.50);
                    ctx.lineTo(s * 0.40, s * 0.72);
                    ctx.closePath();
                    ctx.fill();
                } else if (btn.kind === "pause") {
                    ctx.fillRect(s * 0.33, s * 0.29, s * 0.12, s * 0.42);
                    ctx.fillRect(s * 0.55, s * 0.29, s * 0.12, s * 0.42);
                } else if (btn.kind === "skip") {
                    ctx.beginPath();
                    ctx.moveTo(s * 0.32, s * 0.30);
                    ctx.lineTo(s * 0.62, s * 0.50);
                    ctx.lineTo(s * 0.32, s * 0.70);
                    ctx.closePath();
                    ctx.fill();
                    ctx.fillRect(s * 0.66, s * 0.30, s * 0.08, s * 0.40);
                } else if (btn.kind === "reset") {
                    const c = s / 2;
                    const r = s * 0.20;
                    const a0 = -Math.PI * 0.35;
                    ctx.beginPath();
                    ctx.arc(c, c, r, a0, a0 + Math.PI * 1.6);
                    ctx.stroke();
                    const px = c + r * Math.cos(a0);
                    const py = c + r * Math.sin(a0);
                    ctx.beginPath();
                    ctx.moveTo(px + s * 0.10, py - s * 0.01);
                    ctx.lineTo(px - s * 0.02, py - s * 0.09);
                    ctx.lineTo(px - s * 0.02, py + s * 0.07);
                    ctx.closePath();
                    ctx.fill();
                } else if (btn.kind === "tune") {
                    // three sliders
                    const ys = [0.32, 0.50, 0.68];
                    const ks = [0.40, 0.62, 0.46];
                    ctx.lineWidth = 1.8;
                    for (let i = 0; i < 3; i++) {
                        ctx.beginPath();
                        ctx.moveTo(s * 0.28, s * ys[i]);
                        ctx.lineTo(s * 0.72, s * ys[i]);
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(s * ks[i], s * ys[i], s * 0.06, 0, Math.PI * 2);
                        ctx.fill();
                    }
                }
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    // ── header: phase label + edit button ─────────────────────────
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 26
        text: root.phaseLabel
        color: (PomodoroService.active && !root.editing) ? root.accent : Theme.dim
        renderType: Text.NativeRendering
        font.family: Theme.fontFamily
        font.pixelSize: Math.round(Theme.px(12))
        font.weight: Font.DemiBold
        font.letterSpacing: 1.6
        Behavior on color { ColorAnimation { duration: 300 } }
    }

    IconBtn {
        kind: "tune"
        d: 34
        x: root.width - width - 22
        y: 18
        fillColor: root.editing ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.25)
                                : root.tint(0.12)
        iconColor: root.editing ? root.accent : root.tint(0.85)
        onClicked: root.editing = !root.editing
    }

    // ── the glowing ring + time ───────────────────────────────────
    Item {
        id: ringBox
        width: 210
        height: 210
        anchors.horizontalCenter: parent.horizontalCenter
        y: 56
        opacity: root.editing ? 0 : 1
        visible: opacity > 0.01
        scale: root.editing ? 0.94 : 1
        Behavior on opacity { NumberAnimation { duration: 220 } }
        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        Canvas {
            id: bigRing
            anchors.fill: parent

            property real p: PomodoroService.progress
            property color col: root.accent
            property color trk: Theme.text

            // breathing glow while the timer runs
            property real pulse: 1.0
            // glow strength: pulses when running, dim when paused
            readonly property real k: PomodoroService.running ? pulse
                                    : PomodoroService.active ? 0.5 : 0.7

            onPChanged: requestPaint()
            onColChanged: requestPaint()
            onTrkChanged: requestPaint()
            onKChanged: requestPaint()
            Component.onCompleted: requestPaint()

            SequentialAnimation {
                running: PomodoroService.running && root.visible
                loops: Animation.Infinite
                NumberAnimation { target: bigRing; property: "pulse"; from: 0.7; to: 1.0; duration: 1400; easing.type: Easing.InOutSine }
                NumberAnimation { target: bigRing; property: "pulse"; from: 1.0; to: 0.7; duration: 1400; easing.type: Easing.InOutSine }
            }

            function rgba(cc, a) {
                return "rgba(" + Math.round(cc.r * 255) + "," + Math.round(cc.g * 255) + ","
                     + Math.round(cc.b * 255) + "," + a + ")";
            }

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const c = width / 2;
                const r = c - 22;
                const a0 = -Math.PI / 2;
                ctx.lineCap = "round";

                // faint inner light, like the ring is lit from within
                const inner = ctx.createRadialGradient(c, c, r * 0.45, c, c, r);
                inner.addColorStop(0, rgba(col, 0));
                inner.addColorStop(1, rgba(col, 0.10 * k));
                ctx.fillStyle = inner;
                ctx.beginPath();
                ctx.arc(c, c, r, 0, Math.PI * 2);
                ctx.fill();

                // track
                ctx.lineWidth = 9;
                ctx.strokeStyle = rgba(trk, 0.09);
                ctx.beginPath();
                ctx.arc(c, c, r, 0, Math.PI * 2);
                ctx.stroke();

                const left = 1 - p;
                if (left <= 0.001) return;
                const a1 = a0 + Math.PI * 2 * left;

                // halo: wide soft strokes that stack into a smooth falloff
                const halo = [[36, 0.030], [30, 0.050], [24, 0.080], [18, 0.125], [13, 0.18]];
                for (let i = 0; i < halo.length; i++) {
                    ctx.lineWidth = halo[i][0];
                    ctx.strokeStyle = rgba(col, halo[i][1] * k);
                    ctx.beginPath();
                    ctx.arc(c, c, r, a0, a1);
                    ctx.stroke();
                }

                // main arc: lighter at the top-left, full color at the bottom-right
                const g = ctx.createLinearGradient(0, 0, width, height);
                g.addColorStop(0, Qt.lighter(col, 1.35).toString());
                g.addColorStop(1, col.toString());
                ctx.lineWidth = 9;
                ctx.strokeStyle = g;
                ctx.beginPath();
                ctx.arc(c, c, r, a0, a1);
                ctx.stroke();

                // bright glowing tip where the arc ends
                const tx = c + r * Math.cos(a1);
                const ty = c + r * Math.sin(a1);
                const tip = ctx.createRadialGradient(tx, ty, 0, tx, ty, 26);
                tip.addColorStop(0, rgba(col, 0.75 * k));
                tip.addColorStop(0.4, rgba(col, 0.25 * k));
                tip.addColorStop(1, rgba(col, 0));
                ctx.fillStyle = tip;
                ctx.beginPath();
                ctx.arc(tx, ty, 26, 0, Math.PI * 2);
                ctx.fill();

                ctx.fillStyle = rgba(Qt.lighter(col, 1.6), 0.95);
                ctx.beginPath();
                ctx.arc(tx, ty, 3.6, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        Text {
            anchors.centerIn: parent
            text: PomodoroService.timeText
            color: Theme.text
            opacity: (!PomodoroService.active || PomodoroService.running) ? 1 : 0.55
            Behavior on opacity { NumberAnimation { duration: 250 } }
            renderType: Text.NativeRendering
            font.family: Theme.fontDisplay
            font.pixelSize: Math.round(Theme.px(46))
            font.weight: Font.Light
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 56
            opacity: PomodoroService.active && !PomodoroService.running ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 250 } }
            text: "Paused"
            color: Theme.dim
            renderType: Text.NativeRendering
            font.family: Theme.fontFamily
            font.pixelSize: Math.round(Theme.px(12))
        }
    }

    // ── custom timer panel ────────────────────────────────────────
    Item {
        id: editor
        width: 296
        height: 210
        anchors.horizontalCenter: parent.horizontalCenter
        y: 62
        opacity: root.editing ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 220 } }

        // the three length rows: label on the left, - value + on the right
        Repeater {
            model: [
                { label: "Focus",       which: "focus", lo: 1, hi: 180, top: 0 },
                { label: "Short break", which: "short", lo: 1, hi: 60,  top: 94 },
                { label: "Long break",  which: "long",  lo: 1, hi: 90,  top: 144 }
            ]

            Item {
                id: row
                required property var modelData

                readonly property int val: modelData.which === "focus" ? PomodoroService.focusMins
                                         : modelData.which === "short" ? PomodoroService.shortMins
                                         : PomodoroService.longMins

                function setTo(v) {
                    const n = Math.max(modelData.lo, Math.min(modelData.hi, v));
                    if (modelData.which === "focus") PomodoroService.setFocus(n);
                    else if (modelData.which === "short") PomodoroService.setShort(n);
                    else PomodoroService.setLong(n);
                }

                y: modelData.top
                width: 296
                height: 40

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.label
                    color: Theme.text
                    renderType: Text.NativeRendering
                    font.family: Theme.fontFamily
                    font.pixelSize: Math.round(Theme.px(15))
                }

                // minus button (hold to keep stepping)
                Rectangle {
                    id: minusBtn
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.width - 34 - 6 - 64 - 6 - 34
                    width: 34
                    height: 34
                    radius: 17
                    color: root.tint(minusMa.containsMouse ? 0.22 : 0.14)
                    scale: minusMa.pressed ? 0.9 : 1
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 12
                        height: 2
                        radius: 1
                        color: Theme.text
                    }

                    Timer { id: minusRep; interval: 90; repeat: true; onTriggered: row.setTo(row.val - 1) }
                    Timer { id: minusHold; interval: 380; onTriggered: minusRep.start() }

                    MouseArea {
                        id: minusMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: { row.setTo(row.val - 1); minusHold.start(); }
                        onReleased: { minusHold.stop(); minusRep.stop(); }
                        onCanceled: { minusHold.stop(); minusRep.stop(); }
                    }
                }

                Text {
                    x: parent.width - 34 - 6 - 64
                    width: 64
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: row.val + " min"
                    color: Theme.text
                    renderType: Text.NativeRendering
                    font.family: Theme.fontDisplay
                    font.pixelSize: Math.round(Theme.px(15))
                    font.weight: Font.Medium
                }

                // plus button (hold to keep stepping)
                Rectangle {
                    id: plusBtn
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.width - 34
                    width: 34
                    height: 34
                    radius: 17
                    color: root.tint(plusMa.containsMouse ? 0.22 : 0.14)
                    scale: plusMa.pressed ? 0.9 : 1
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 12
                        height: 2
                        radius: 1
                        color: Theme.text
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: 2
                        height: 12
                        radius: 1
                        color: Theme.text
                    }

                    Timer { id: plusRep; interval: 90; repeat: true; onTriggered: row.setTo(row.val + 1) }
                    Timer { id: plusHold; interval: 380; onTriggered: plusRep.start() }

                    MouseArea {
                        id: plusMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: { row.setTo(row.val + 1); plusHold.start(); }
                        onReleased: { plusHold.stop(); plusRep.stop(); }
                        onCanceled: { plusHold.stop(); plusRep.stop(); }
                    }
                }
            }
        }

        // quick focus presets
        Row {
            y: 46
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: [15, 25, 45, 60]
                Rectangle {
                    required property int modelData
                    readonly property bool on: PomodoroService.focusMins === modelData
                    width: 62
                    height: 28
                    radius: 14
                    color: on ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.25)
                              : root.tint(pma.containsMouse ? 0.16 : 0.10)
                    Behavior on color { ColorAnimation { duration: 140 } }

                    Text {
                        anchors.centerIn: parent
                        text: modelData + "m"
                        color: parent.on ? root.accent : Theme.text
                        renderType: Text.NativeRendering
                        font.family: Theme.fontFamily
                        font.pixelSize: Math.round(Theme.px(13))
                        font.weight: Font.Medium
                    }
                    MouseArea {
                        id: pma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PomodoroService.setFocus(modelData)
                    }
                }
            }
        }
    }

    // ── controls ──────────────────────────────────────────────────
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 290
        spacing: 22
        opacity: root.editing ? 0 : 1
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 200 } }

        IconBtn {
            kind: "reset"
            d: 46
            anchors.verticalCenter: parent.verticalCenter
            onClicked: PomodoroService.reset()
        }

        IconBtn {
            kind: PomodoroService.running ? "pause" : "play"
            d: 62
            fillColor: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.22)
            iconColor: root.accent
            anchors.verticalCenter: parent.verticalCenter
            onClicked: PomodoroService.toggle()
        }

        IconBtn {
            kind: "skip"
            d: 46
            anchors.verticalCenter: parent.verticalCenter
            onClicked: PomodoroService.skip()
        }
    }

    // Done button while editing
    Rectangle {
        width: 200
        height: 46
        radius: 23
        anchors.horizontalCenter: parent.horizontalCenter
        y: 298
        opacity: root.editing ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 200 } }
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, doneMa.containsMouse ? 0.32 : 0.22)
        scale: doneMa.pressed ? 0.96 : 1
        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

        Text {
            anchors.centerIn: parent
            text: "Done"
            color: root.accent
            renderType: Text.NativeRendering
            font.family: Theme.fontFamily
            font.pixelSize: Math.round(Theme.px(15))
            font.weight: Font.DemiBold
        }
        MouseArea {
            id: doneMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.editing = false
        }
    }

    // ── session dots ──────────────────────────────────────────────
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 370
        spacing: 10
        opacity: root.editing ? 0 : 1
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Repeater {
            model: PomodoroService.longEvery
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: index < root.filledDots ? root.accent : root.tint(0.18)
                scale: index < root.filledDots ? 1.15 : 1
                Behavior on color { ColorAnimation { duration: 300 } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            }
        }
    }
}