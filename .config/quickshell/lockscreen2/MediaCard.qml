import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Bottom-Left: Media Card for lockscreen2
Rectangle {
    id: root

    readonly property var playersList: Mpris.players.values
    readonly property var activePlayer: {
        if (!playersList || playersList.length === 0) return null;
        for (let i = 0; i < playersList.length; i++) {
            const p = playersList[i];
            if (p.playbackState === MprisPlaybackState.Playing) return p;
        }
        for (let i = 0; i < playersList.length; i++) {
            const p = playersList[i];
            if (p.trackTitle && p.trackTitle.length > 0) return p;
        }
        return playersList[0] || null;
    }

    readonly property bool isPlaying: activePlayer !== null &&
        activePlayer.playbackState === MprisPlaybackState.Playing

    readonly property string titleText: activePlayer && activePlayer.trackTitle ?
        activePlayer.trackTitle : "Nothing Playing"

    readonly property string artistText: {
        if (!activePlayer) return "No Player Active";
        if (activePlayer.trackArtists && activePlayer.trackArtists.length > 0) {
            return activePlayer.trackArtists.join(", ");
        }
        return activePlayer.trackArtist || "Unknown Artist";
    }

    implicitWidth: 260
    implicitHeight: 115
    radius: 18
    color: Colors.cardBg
    border.width: 1
    border.color: Colors.cardBorder
    clip: true

    // Background Album Art with blur and scrim
    Image {
        id: bgArt
        anchors.fill: parent
        source: root.activePlayer && root.activePlayer.trackArtUrl ? root.activePlayer.trackArtUrl : ""
        fillMode: Image.PreserveAspectCrop
        opacity: 0.18
        visible: status === Image.Ready
    }

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 6

        Text {
            text: "Now playing"
            color: Colors.red
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 0.2
        }

        Column {
            width: parent.width
            spacing: 2

            Text {
                width: parent.width
                text: root.titleText
                color: Colors.text
                font.pixelSize: 14
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.artistText
                color: Colors.sub
                font.pixelSize: 11
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }

        // Playback Controls Row
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            // Prev
            Item {
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                Canvas {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = Colors.sub;
                        ctx.fillRect(1, 2, 2, 10);
                        ctx.beginPath();
                        ctx.moveTo(12, 2);
                        ctx.lineTo(4, 7);
                        ctx.lineTo(12, 12);
                        ctx.fill();
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.activePlayer && root.activePlayer.canGoPrevious) root.activePlayer.previous()
                }
            }

            // Play / Pause Circle
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: Colors.accent
                anchors.verticalCenter: parent.verticalCenter

                Canvas {
                    id: playCanvas
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    Connections {
                        target: root
                        function onIsPlayingChanged() { playCanvas.requestPaint(); }
                    }
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = Colors.bg;
                        if (root.isPlaying) {
                            ctx.fillRect(3, 2, 2.5, 10);
                            ctx.fillRect(8.5, 2, 2.5, 10);
                        } else {
                            ctx.beginPath();
                            ctx.moveTo(4, 2);
                            ctx.lineTo(12, 7);
                            ctx.lineTo(4, 12);
                            ctx.fill();
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!root.activePlayer) return;
                        if (root.isPlaying) root.activePlayer.pause();
                        else root.activePlayer.play();
                    }
                }
            }

            // Next
            Item {
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                Canvas {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = Colors.sub;
                        ctx.beginPath();
                        ctx.moveTo(2, 2);
                        ctx.lineTo(10, 7);
                        ctx.lineTo(2, 12);
                        ctx.fill();
                        ctx.fillRect(11, 2, 2, 10);
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.activePlayer && root.activePlayer.canGoNext) root.activePlayer.next()
                }
            }
        }
    }
}
