import QtQuick

Item {
    id: root

    // animated copy of Pill.idleExtra so the content grows in step with the pill
    property real extra: Pill.idleExtra
    Behavior on extra { NumberAnimation { duration: Theme.animMs; easing.type: Easing.OutCubic } }

    width: Theme.idleW + extra
    height: Theme.idleH

    // phase color, same palette as the timer page
    property color accent: PomodoroService.phase === "short" ? "#30D158"
                         : PomodoroService.phase === "long"  ? "#0A84FF"
                         : "#FF9F0A"
    Behavior on accent { ColorAnimation { duration: 400 } }

    WorkspaceDots {
        anchors.left: parent.left
        anchors.leftMargin: Theme.pad
        anchors.verticalCenter: parent.verticalCenter
        size: 10
    }

    // clock + pomodoro chip, centered together as one group
    Row {
        anchors.centerIn: parent
        spacing: root.extra > 1 ? 8 : 0

        Text {
            renderType: Text.NativeRendering
            id: clockText
            anchors.verticalCenter: parent.verticalCenter
            text: ClockFmt.time(Pill.now)
            color: Theme.text
            font.family: Theme.fontDisplay
            font.pixelSize: Math.round(Theme.px(15))
            font.weight: Font.Medium
        }

        Item {
            id: chip
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(0, root.extra - 8)
            height: 22
            opacity: Math.min(1, root.extra / Pill.pomoW)
            visible: opacity > 0.01
            // only clip while the chip is still growing in
            clip: root.extra < Pill.pomoW - 1

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                opacity: PomodoroService.running ? 1 : 0.6
                Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }

                // ring: full at the start of a phase, empties as time runs out
                Canvas {
                    id: ring
                    width: 22
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter

                    property real p: PomodoroService.progress
                    property color col: root.accent

                    onPChanged: requestPaint()
                    onColChanged: requestPaint()
                    Component.onCompleted: requestPaint()

                    function rgba(cc, a) {
                        return "rgba(" + Math.round(cc.r * 255) + "," + Math.round(cc.g * 255) + ","
                             + Math.round(cc.b * 255) + "," + a + ")";
                    }

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        const c = width / 2;
                        const r = 7.5;
                        const a0 = -Math.PI / 2;
                        ctx.lineCap = "round";

                        // track
                        ctx.lineWidth = 2.4;
                        ctx.strokeStyle = "rgba(255,255,255,0.14)";
                        ctx.beginPath();
                        ctx.arc(c, c, r, 0, Math.PI * 2);
                        ctx.stroke();

                        const left = 1 - p;
                        if (left <= 0.001) return;
                        const a1 = a0 + Math.PI * 2 * left;

                        // soft glow
                        ctx.lineWidth = 7;
                        ctx.strokeStyle = rgba(col, 0.12);
                        ctx.beginPath();
                        ctx.arc(c, c, r, a0, a1);
                        ctx.stroke();

                        ctx.lineWidth = 4.6;
                        ctx.strokeStyle = rgba(col, 0.22);
                        ctx.beginPath();
                        ctx.arc(c, c, r, a0, a1);
                        ctx.stroke();

                        // main arc
                        ctx.lineWidth = 2.4;
                        ctx.strokeStyle = col.toString();
                        ctx.beginPath();
                        ctx.arc(c, c, r, a0, a1);
                        ctx.stroke();
                    }
                }

                Text {
                    renderType: Text.NativeRendering
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    text: PomodoroService.timeText
                    color: Theme.text
                    font.family: Theme.fontDisplay
                    font.pixelSize: Math.round(Theme.px(13))
                    font.weight: Font.Medium
                }
            }

            // click the chip to open the timer
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: Pill.open("pomodoro", true)
            }
        }
    }

    Row {
        id: cluster
        anchors.right: parent.right
        anchors.rightMargin: Theme.pad
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        SignalBars {}
        BatteryIcon {}
    }

    MouseArea {
        anchors.fill: cluster
        anchors.margins: -8
        cursorShape: Qt.PointingHandCursor
        onClicked: Pill.open("control", true)
    }
}