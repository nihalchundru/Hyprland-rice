import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.services
import qs.components

Page {
    function fmt(s) { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }

    ColumnLayout {
        visible: !Media.has
        anchors.centerIn: parent
        spacing: 14
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 120; Layout.preferredHeight: 120
            MorphShape { size: 120; shape: "softBurst"; color: M3Colors.secondaryContainer }
            Icon { anchors.centerIn: parent; name: "music_off"; size: 48; fill: 1; color: M3Colors.fgSecondaryContainer }
        }
        M3Text { Layout.alignment: Qt.AlignHCenter; text: "Nothing playing"; role: M3Type.titleLarge }
        M3Text { Layout.alignment: Qt.AlignHCenter; text: "Start a player and it shows up here"; role: M3Type.bodyMedium; color: M3Colors.fgSurfaceVariant }
    }

    RowLayout {
        visible: Media.has
        anchors.fill: parent
        spacing: 36

        Item {
            Layout.preferredWidth: 360; Layout.preferredHeight: 360
            Layout.alignment: Qt.AlignVCenter
            RoundedImage { id: art; anchors.fill: parent; radius: 56; source: Media.art }
            MorphShape { visible: !art.ready; size: 360; shape: Media.playing ? "cookie12Sided" : "circle"; color: M3Colors.tertiaryContainer }
            Icon { visible: !art.ready; anchors.centerIn: parent; name: "music_note"; size: 120; fill: 1; color: M3Colors.fgTertiaryContainer }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 12

            M3Text { Layout.fillWidth: true; text: Media.title; role: M3Type.headlineMedium; wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight }
            M3Text { Layout.fillWidth: true; text: Media.artist; role: M3Type.titleMedium; color: M3Colors.fgSurfaceVariant; elide: Text.ElideRight }
            M3Text { Layout.fillWidth: true; visible: text !== ""; text: Media.album; role: M3Type.bodyMedium; color: M3Colors.fgSurfaceVariant; elide: Text.ElideRight }

            Item {   // wavy seek bar: drag or click to seek, wave animates while playing
                id: seek
                Layout.fillWidth: true
                Layout.topMargin: 16
                Layout.preferredHeight: 36
                readonly property real frac: ma.pressed ? Math.max(0, Math.min(1, ma.mouseX / width)) : Media.progress
                M3Progress {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    value: seek.frac
                    wavy: Media.playing
                    thickness: 6; amplitude: 4; wavelength: 44
                    animate: !ma.pressed
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: ma.pressed ? 3 : 5; height: 30; radius: 2.5
                    x: Math.max(0, Math.min(seek.width - width, seek.frac * seek.width - width / 2))
                    color: M3Colors.primary
                    SpatialBehavior on width {}
                }
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    enabled: Media.canSeek
                    cursorShape: Qt.PointingHandCursor
                    onReleased: Media.seek(Math.max(0, Math.min(1, mouseX / width)))
                }
            }
            RowLayout {
                Layout.fillWidth: true
                M3Text { text: fmt(Media.position); role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant }
                Item { Layout.fillWidth: true }
                M3Text { text: fmt(Media.length); role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                M3Button { visible: Media.shuffleSupported; icon: "shuffle"; variant: Media.shuffle ? "filled" : "tonal"; onClicked: Media.toggleShuffle() }
                M3Button { icon: "skip_previous"; variant: "tonal"; size: "m"; onClicked: Media.previous() }
                M3Button { icon: Media.playing ? "pause" : "play_arrow"; variant: "filled"; size: "l"; round: !Media.playing; onClicked: Media.toggle() }
                M3Button { icon: "skip_next"; variant: "tonal"; size: "m"; onClicked: Media.next() }
                M3Button { visible: Media.loopSupported; icon: Media.loopIcon; variant: Media.loopIcon === "repeat" ? "tonal" : "filled"; onClicked: Media.cycleLoop() }
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 8
                visible: Media.players.length > 1
                spacing: 8
                Repeater {
                    model: Media.players
                    M3Chip {
                        required property var modelData
                        text: modelData.identity
                        icon: "play_circle"
                        kind: "assist"
                        selected: modelData === Media.active
                        onClicked: Media.select(modelData)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 8
                M3Button { icon: Audio.icon; variant: "text"; size: "s"; onClicked: Audio.toggleMute() }
                M3Slider { id: vol; Layout.fillWidth: true; value: Audio.volume; onMoved: v => Audio.setVolume(v) }
                Binding { target: vol; property: "value"; value: Audio.volume }
                M3Text { Layout.preferredWidth: 40; text: Math.round(Audio.volume * 100) + "%"; role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant; horizontalAlignment: Text.AlignRight }
            }
        }
    }
}
