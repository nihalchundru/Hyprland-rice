import QtQuick
import qs.tokens
import qs.services
import qs.components

// size 2x2 = art pill + controls + progress; 2x1 = compact. Shows "No media playing" when idle.
TileBase {
    id: t
    readonly property bool full: cfg.size !== "2x1"
    function fmt(s) { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }

    // ---------- full layout
    Item {
        visible: t.full
        anchors.fill: parent
        Item {
            x: 14; y: 14; width: parent.width - 28; height: 112
            Rectangle { anchors.fill: parent; radius: height / 2; color: Qt.alpha(t.accent, 0.22) }
            RoundedImage { id: art; anchors.fill: parent; radius: height / 2; source: Media.has ? Media.art : "" }
            Icon { visible: !art.ready; anchors.centerIn: parent; anchors.verticalCenterOffset: -12; name: Media.has ? "music_note" : "music_off"; size: 40; fill: 1; color: t.accent }
            Rectangle {
                visible: art.ready
                anchors.fill: parent; radius: height / 2
                gradient: Gradient { GradientStop { position: 0.4; color: "transparent" } GradientStop { position: 1.0; color: "#aa000000" } }
            }
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom; anchors.bottomMargin: 10
                width: parent.width - 60
                M3Text { width: parent.width; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; text: Media.has ? Media.title : "No media playing"; role: ({ size: 15, line: 20, weight: Font.Bold, tracking: 0 }); color: art.ready ? "white" : t.fg }
                M3Text { width: parent.width; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; text: Media.has ? Media.artist : "Start a player to see it here"; role: M3Type.labelSmall; color: art.ready ? "#ddffffff" : t.fg; opacity: art.ready ? 1 : 0.7 }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 134
            spacing: 14
            M3Button { anchors.verticalCenter: parent.verticalCenter; icon: "skip_previous"; variant: "tonal"; size: "s"; enabled: Media.has; onClicked: Media.previous() }
            Item {
                width: 64; height: 64
                opacity: Media.has ? 1 : 0.4
                MorphShape { size: 64; shape: Media.playing ? "softBurst" : "circle"; color: t.accent }
                Icon { anchors.centerIn: parent; name: Media.playing ? "pause" : "play_arrow"; size: 30; fill: 1; color: t.onAccent }
                MouseArea { anchors.fill: parent; enabled: Media.has; cursorShape: Qt.PointingHandCursor; onClicked: Media.toggle() }
            }
            M3Button { anchors.verticalCenter: parent.verticalCenter; icon: "skip_next"; variant: "tonal"; size: "s"; enabled: Media.has; onClicked: Media.next() }
        }
        Item {
            id: seek
            visible: Media.has && t.cfg.showProgress !== false
            x: 18; y: 209; width: parent.width - 36; height: 22
            readonly property real frac: sma.pressed ? Math.max(0, Math.min(1, sma.mouseX / width)) : Media.progress
            M3Progress { anchors.verticalCenter: parent.verticalCenter; width: parent.width; thickness: 5; amplitude: 3; wavelength: 36; wavy: Media.playing; value: seek.frac; showStop: false; animate: !sma.pressed; activeColor: t.accent; trackColor: Qt.alpha(t.fg, 0.2) }
            Rectangle { anchors.verticalCenter: parent.verticalCenter; width: sma.pressed ? 3 : 4; height: 20; radius: 2; color: t.accent; x: Math.max(0, Math.min(seek.width - width, seek.frac * seek.width - width / 2)) }
            MouseArea { id: sma; anchors.fill: parent; enabled: Media.canSeek; onReleased: Media.seek(Math.max(0, Math.min(1, mouseX / width))) }
        }
        M3Text { visible: seek.visible; anchors.horizontalCenter: parent.horizontalCenter; y: 232; text: t.fmt(Media.position) + " / " + t.fmt(Media.length); role: M3Type.labelSmall; color: t.fg }
    }

    // ---------- compact layout
    Item {
        visible: !t.full
        anchors.fill: parent
        Item {
            x: 14; y: 14; width: 96; height: 96
            Rectangle { anchors.fill: parent; radius: 30; color: Qt.alpha(t.accent, 0.22) }
            RoundedImage { id: cart; anchors.fill: parent; radius: 30; source: Media.has ? Media.art : "" }
            Icon { visible: !cart.ready; anchors.centerIn: parent; name: Media.has ? "music_note" : "music_off"; size: 36; fill: 1; color: t.accent }
        }
        Column {
            x: 124; y: 18; width: parent.width - 138; spacing: 0
            M3Text { width: parent.width; elide: Text.ElideRight; text: Media.has ? Media.title : "No media playing"; role: M3Type.titleSmall; color: t.fg }
            M3Text { width: parent.width; elide: Text.ElideRight; text: Media.has ? Media.artist : "Start a player"; role: M3Type.bodySmall; color: t.fg; opacity: 0.75 }
        }
        Row {
            x: 118; y: 68; spacing: 4
            M3Button { icon: "skip_previous"; variant: "text"; size: "s"; enabled: Media.has; onClicked: Media.previous() }
            M3Button { icon: Media.playing ? "pause" : "play_arrow"; variant: "filled"; size: "s"; round: !Media.playing; enabled: Media.has; onClicked: Media.toggle() }
            M3Button { icon: "skip_next"; variant: "text"; size: "s"; enabled: Media.has; onClicked: Media.next() }
        }
    }
}
