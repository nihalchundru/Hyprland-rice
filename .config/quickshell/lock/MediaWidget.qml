import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Now playing: artwork disc cased in the Material 3 "very sunny" shape, with
// each transport control in its own pill underneath.
Item {
    id: root

    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool hasPlayer: root.player !== null
    readonly property bool playing: root.hasPlayer ? root.player.isPlaying : false

    visible: root.hasPlayer
    implicitWidth: 208
    implicitHeight: column.implicitHeight

    // Controls use geometric glyphs (U+25C0 / U+25B6 / U+25AE) rather than Nerd
    // Font codepoints, so they render on any stock font.
    readonly property string iconPrev: "◀◀"
    readonly property string iconNext: "▶▶"
    readonly property string iconPlay: "▶"
    readonly property string iconPause: "▮▮"

    Column {
        id: column

        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        // ---- very sunny casing with the artwork on it ----------------------
        Item {
            id: disc

            anchors.horizontalCenter: parent.horizontalCenter
            width: 168
            height: 168

            M3Shape {
                anchors.fill: parent
                kind: "very_sunny"
                fillColor: M3Theme.palette.tertiaryContainer
            }

            // The artwork sits inside a circle, and a square inscribed in a
            // circle (side = diameter / sqrt 2) fits without overflowing -- so
            // no mask is needed. Qt 6 has no simple way to clip an item to a
            // Shape, which is why it's done geometrically instead.
            M3Shape {
                anchors.centerIn: parent
                width: disc.width * 0.60
                height: width
                kind: "circle"
                fillColor: M3Theme.palette.surfaceContainerHighest
            }

            Image {
                id: art

                anchors.centerIn: parent
                width: disc.width * 0.56
                height: width
                source: root.hasPlayer ? root.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
                visible: source !== ""
            }

            Text {
                anchors.centerIn: parent
                visible: !art.visible
                text: "♪"
                color: M3Theme.palette.onSurfaceVariant
                font.pixelSize: disc.width * 0.22
            }
        }

        // ---- track info ----------------------------------------------------
        Column {
            width: parent.width
            spacing: 2

            Text {
                width: parent.width
                text: root.hasPlayer
                    ? (root.player.trackTitle !== "" ? root.player.trackTitle : "Unknown Title")
                    : ""
                color: M3Theme.palette.onSurface
                font.family: M3Theme.font
                font.pixelSize: M3Theme.titleMedium
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.hasPlayer ? root.player.trackArtist : ""
                color: M3Theme.palette.onSurfaceVariant
                font.family: M3Theme.font
                font.pixelSize: M3Theme.bodySmall
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        // ---- one pill per control -----------------------------------------
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            ShapeButton {
                icon: root.iconPrev
                enabled: root.hasPlayer && root.player.canGoPrevious
                onActivated: if (root.player) root.player.previous()
            }

            ShapeButton {
                icon: root.playing ? root.iconPause : root.iconPlay
                tonal: true
                enabled: root.hasPlayer && root.player.canTogglePlaying
                onActivated: if (root.player) root.player.togglePlaying()
            }

            ShapeButton {
                icon: root.iconNext
                enabled: root.hasPlayer && root.player.canGoNext
                onActivated: if (root.player) root.player.next()
            }
        }
    }
}
