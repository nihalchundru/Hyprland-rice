import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Default output volume: click to mute, scroll to change, plus a thin meter.
Rectangle {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: (sink && sink.audio) ? sink.audio.volume : 0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : false

    // audio.volume / audio.muted are only valid while the node is bound.
    // Binding is what makes those properties readable *and* writable.
    PwObjectTracker { objects: [root.sink] }

    implicitWidth: row.implicitWidth + Theme.pad * 2
    implicitHeight: 24
    radius: 8
    color: hover.hovered ? Theme.surfaceHi : "transparent"

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        // Nerd Font glyph (nf-fa-volume_up / volume_off). If your font lacks
        // PUA glyphs this turns into a box — the percentage below still reads.
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.muted || root.volume <= 0.001 ? "\uf026" : "\uf028"
            color: root.muted ? Theme.muted : Theme.cheese
            font.family: Theme.mono
            font.pixelSize: 11
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 52
            height: 4
            radius: 2
            color: "#2effffff"

            Rectangle {
                width: parent.width * Math.min(1, Math.max(0, root.volume))
                height: parent.height
                radius: parent.radius
                color: root.muted ? Theme.muted : Theme.cheese
                Behavior on width { NumberAnimation { duration: Theme.animFast } }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            text: Math.round(root.volume * 100) + "%"
            color: Theme.muted
            font.family: Theme.mono
            font.pixelSize: 11
        }
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.sink && root.sink.audio)
                root.sink.audio.muted = !root.sink.audio.muted;
        }
        onWheel: (wheel) => {
            if (!root.sink || !root.sink.audio) {
                wheel.accepted = false;
                return;
            }
            const step = 0.05;
            const delta = wheel.angleDelta.y > 0 ? step : -step;
            root.sink.audio.volume =
                Math.min(1, Math.max(0, root.sink.audio.volume + delta));
            if (delta > 0) root.sink.audio.muted = false;
            wheel.accepted = true;
        }
    }
}
