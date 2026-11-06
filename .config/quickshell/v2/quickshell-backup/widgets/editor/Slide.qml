import QtQuick
import "../core"
import "../components"

Item {
    id: s

    property string label: ""
    property real value: 0
    property real from: 0
    property real to: 1
    property real step: 0.01
    property real displayScale: 1
    property int decimals: 0
    property string suffix: ""
    signal edited(real v)

    readonly property real frac:
        to > from ? Math.max(0, Math.min(1, (value - from) / (to - from))) : 0

    implicitHeight: 46

    Txt {
        anchors.left: parent.left
        anchors.top: parent.top
        text: s.label
        color: Theme.onSurfaceDim
        font.pixelSize: 12
    }
    Txt {
        anchors.right: parent.right
        anchors.top: parent.top
        text: (s.value * s.displayScale).toFixed(s.decimals) + s.suffix
        font.weight: Font.Bold
        font.pixelSize: 12
    }

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        height: 6
        radius: 3
        color: Theme.track

        Rectangle {
            width: track.width * s.frac
            height: parent.height
            radius: 3
            color: Theme.accent
        }
        Rectangle {
            x: track.width * s.frac - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            radius: 8
            color: Theme.accent
            border.width: 2
            border.color: Theme.card
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 28
        preventStealing: true
        cursorShape: Qt.PointingHandCursor

        function pick(mx) {
            const f = Math.max(0, Math.min(1, mx / width));
            let v = s.from + f * (s.to - s.from);
            v = s.from + Math.round((v - s.from) / s.step) * s.step;
            v = Math.round(v * 10000) / 10000;
            if (Math.abs(v - s.value) > 1e-9) s.edited(v);
        }
        onPressed: m => pick(m.x)
        onPositionChanged: m => { if (pressed) pick(m.x); }
    }
}