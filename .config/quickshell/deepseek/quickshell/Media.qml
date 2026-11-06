import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Now-playing pill. Hidden entirely when nothing is on the bus, so it costs
// no space until a player shows up.
Rectangle {
    id: root

    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool playing: root.player ? root.player.isPlaying : false

    visible: root.player !== null
    implicitWidth: visible ? row.implicitWidth + Theme.pad * 2 : 0
    implicitHeight: 24
    radius: 8
    color: hover.hovered ? Theme.surfaceHi : "transparent"

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text {
            anchors.verticalCenter: parent.verticalCenter
            // U+23F8 / U+25B6 — plain Unicode so they survive any font
            text: root.playing ? "❚❚" : "▶"
            color: Theme.tomato
            font.pixelSize: 10
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 200)
            elide: Text.ElideRight
            text: {
                if (!root.player) return "";
                const title = root.player.trackTitle || "Unknown Title";
                const artist = root.player.trackArtist;
                return artist ? title + "  ·  " + artist : title;
            }
            color: Theme.cream
            font.family: Theme.sans
            font.pixelSize: Theme.fontPx
        }
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (root.player && root.player.canTogglePlaying)
                root.player.togglePlaying();
        }
    }
}
