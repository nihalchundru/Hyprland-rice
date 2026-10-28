import QtQuick

// Settings row: label + live value, thin slider underneath.
Item {
    id: root

    property var def: ({})
    property bool first: false

    readonly property real value: Settings.get(def.key)
    readonly property real frac: def.max > def.min
        ? Math.max(0, Math.min(1, (value - def.min) / (def.max - def.min))) : 0

    width: parent ? parent.width : 0
    height: 70

    function snap(raw) {
        const steps = Math.round((raw - def.min) / def.step);
        return Math.max(def.min, Math.min(def.max, def.min + steps * def.step));
    }

    Rectangle {
        visible: !root.first
        x: 16
        width: parent.width - 32
        height: 1
        color: Theme.mix(Theme.body, Theme.text, 0.07)
    }

    Text {
        x: 16
        y: 14
        text: root.def.label || ""
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(15)
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 16
        y: 15
        text: Math.round(root.value) + (root.def.unit ? " " + root.def.unit : "")
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(14)
    }

    Item {
        id: track
        x: 16
        y: 42
        width: parent.width - 32
        height: 18

        readonly property real knob: 16

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 4
            radius: Theme.r(2)
            color: Theme.mix(Theme.body, Theme.text, 0.10)
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: knobRect.x + track.knob / 2
            height: 4
            radius: Theme.r(2)
            color: Theme.accent
        }

        Rectangle {
            id: knobRect
            anchors.verticalCenter: parent.verticalCenter
            x: root.frac * (track.width - track.knob)
            width: track.knob
            height: track.knob
            radius: track.knob / 2
            color: Theme.knob
            border.width: 2
            border.color: Theme.accent
        }

        MouseArea {
            anchors.fill: parent
            anchors.topMargin: -8
            anchors.bottomMargin: -8
            cursorShape: Qt.PointingHandCursor

            function setFrom(mx) {
                const f = Math.max(0, Math.min(1, (mx - track.knob / 2) / (track.width - track.knob)));
                Settings.set(root.def.key, root.snap(root.def.min + f * (root.def.max - root.def.min)));
            }
            onPressed: mouse => setFrom(mouse.x)
            onPositionChanged: mouse => { if (pressed) setFrom(mouse.x); }
        }
    }
}
