import QtQuick
import QtQuick.Effects
import Quickshell.Services.Mpris
import "../../core"
import "../../components"

Item {
    id: root

    property int cols: 2
    property int rows: 3
    property var settings: ({})
    property color accent:  Theme.accent
    property color accent2: Theme.accent2
    property color accent3: Theme.accent3

    // ---------- which player ----------
    readonly property var player: pick()

    function pick() {
        const want = (settings.player ?? "").toLowerCase().trim();
        const list = Mpris.players.values;
        let first = null;
        for (let i = 0; i < list.length; i++) {
            const p = list[i];
            if (want !== "") {
                const id = (p.identity ?? "").toLowerCase();
                const bus = (p.dbusName ?? "").toLowerCase();
                if (id.indexOf(want) < 0 && bus.indexOf(want) < 0) continue;
            }
            if (p.isPlaying) return p;
            if (first === null) first = p;
        }
        return first;
    }

    // MPRIS positions don't tick on their own
    Timer {
        interval: 1000
        repeat: true
        running: root.player !== null && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    // ---------- derived ----------
    readonly property bool wide: cols >= 4 && rows <= 2
    readonly property real artH: wide ? height : height - info.height - 10
    readonly property bool showArt: artH >= 44 && (settings.showArt ?? true)
    readonly property real frac:
        player && player.length > 0 ? Math.max(0, Math.min(1, player.position / player.length)) : 0

    function fmt(s) {
        s = Math.max(0, Math.floor(s));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    component RoundBtn: Rectangle {
        id: rb
        property string kind: "play"
        property bool primary: false
        property color accent: Theme.accent
        signal clicked()

        width: primary ? 36 : 32
        height: width
        radius: width / 2
        opacity: enabled ? 1 : 0.4
        color: primary ? accent
             : ma.containsMouse ? Qt.lighter(Theme.cardAlt, 1.15) : Theme.cardAlt
        Behavior on color { ColorAnimation { duration: 120 } }

        Glyph {
            anchors.centerIn: parent
            width: 14
            height: 14
            kind: rb.kind
            color: rb.primary ? Theme.onAccent : Theme.onSurface
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            enabled: rb.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: rb.clicked()
        }
    }

    // ---------- album art ----------
    Item {
        id: art
        visible: root.showArt
        x: 0
        y: 0
        width: root.wide ? root.height : root.width
        height: root.wide ? root.height : Math.max(0, root.artH)

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Theme.cardAlt

            Txt {
                anchors.centerIn: parent
                visible: img.status !== Image.Ready
                text: "♪"
                color: Theme.onSurfaceDim
                font.pixelSize: Math.min(parent.width, parent.height) * 0.4
            }
        }

        Image {
            id: img
            anchors.fill: parent
            source: root.player?.trackArtUrl ?? ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: 320
            sourceSize.height: 320

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: mask
            }
        }

        Item {
            id: mask
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Rectangle { anchors.fill: parent; radius: 14 }
        }
    }

    // ---------- info + controls ----------
    Column {
        id: info
        x: (root.wide && root.showArt) ? root.height + 14 : 0
        width: root.width - x
        y: (root.wide || !root.showArt) ? (root.height - height) / 2 : root.height - height
        spacing: 5

        Txt {
            width: info.width
            text: root.player ? (root.player.trackTitle || "Unknown title") : "Nothing playing"
            font.pixelSize: 14
            font.weight: Font.Bold
            elide: Text.ElideRight
        }
        Txt {
            width: info.width
            text: root.player ? (root.player.trackArtist || root.player.identity || "") : "Start a player to see it here"
            color: Theme.onSurfaceDim
            font.pixelSize: 11
            elide: Text.ElideRight
        }

        // seek bar
        Item {
            width: info.width
            height: 16

            Rectangle {
                id: bar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 4
                radius: 2
                color: Theme.track

                Rectangle {
                    width: bar.width * root.frac
                    height: parent.height
                    radius: 2
                    color: root.accent
                }
            }
            MouseArea {
                anchors.fill: parent
                enabled: root.player !== null && root.player.canSeek && root.player.length > 0
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: m => {
                    root.player.position = Math.max(0, Math.min(1, m.x / width)) * root.player.length;
                }
            }
        }

        Item {
            width: info.width
            height: 12

            Txt {
                anchors.left: parent.left
                text: root.player ? root.fmt(root.player.position) : "0:00"
                color: Theme.onSurfaceDim
                font.pixelSize: 10
            }
            Txt {
                anchors.right: parent.right
                text: root.player ? root.fmt(root.player.length) : "0:00"
                color: Theme.onSurfaceDim
                font.pixelSize: 10
            }
        }

        Item {
            width: info.width
            height: 38

            Row {
                anchors.centerIn: parent
                spacing: 10

                RoundBtn {
                    anchors.verticalCenter: parent.verticalCenter
                    kind: "prev"
                    enabled: root.player !== null && root.player.canGoPrevious
                    onClicked: root.player.previous()
                }
                RoundBtn {
                    anchors.verticalCenter: parent.verticalCenter
                    accent: root.accent
                    kind: root.player && root.player.isPlaying ? "pause" : "play"
                    enabled: root.player !== null && root.player.canTogglePlaying
                    onClicked: root.player.togglePlaying()
                }
                RoundBtn {
                    anchors.verticalCenter: parent.verticalCenter
                    kind: "next"
                    enabled: root.player !== null && root.player.canGoNext
                    onClicked: root.player.next()
                }
            }
        }
    }
}