import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris

// Material 3 Now Playing Card (MPRIS)
// - Album art masked into an M3 9-sided cookie shape (Cookie9Sided)
// - Card outer container shaped into an M3 8-lobed cookie/clover (Clover8Leaf)
// - Track title, artist, interactive scrubber, and playback controls
// - Gracefully expands when media is playing, collapses to 0 height when inactive
Item {
    id: root

    property string artShape: "Cookie9Sided"
    property string cardShape: "Clover8Leaf"

    // Pick active player: prefer Playing player, else one with track title
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

    readonly property bool hasMedia: activePlayer !== null && (
        (activePlayer.trackTitle && activePlayer.trackTitle.length > 0) ||
        activePlayer.playbackState === MprisPlaybackState.Playing
    )

    readonly property bool isPlaying: activePlayer !== null &&
        activePlayer.playbackState === MprisPlaybackState.Playing

    readonly property string titleText: activePlayer && activePlayer.trackTitle ?
        activePlayer.trackTitle : "Unknown Track"

    readonly property string artistText: {
        if (!activePlayer) return "";
        if (activePlayer.trackArtists && activePlayer.trackArtists.length > 0) {
            return activePlayer.trackArtists.join(", ");
        }
        return activePlayer.trackArtist || "";
    }

    readonly property real trackLength: activePlayer && activePlayer.length > 0 ?
        activePlayer.length : 0

    // Local position tracker for smooth progress bar updates while playing
    property real currentPos: activePlayer ? (activePlayer.position || 0) : 0
    Timer {
        interval: 1000
        running: root.isPlaying && root.visible
        repeat: true
        onTriggered: {
            if (root.activePlayer) {
                root.currentPos = root.activePlayer.position || (root.currentPos + 1);
            }
        }
    }
    Connections {
        target: root.activePlayer
        function onPositionChanged() {
            if (root.activePlayer) root.currentPos = root.activePlayer.position;
        }
    }

    function formatTime(sec) {
        if (!sec || isNaN(sec) || sec < 0) return "0:00";
        const m = Math.floor(sec / 60);
        const s = Math.floor(sec % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    implicitWidth: 480
    implicitHeight: cardHeight
    readonly property real cardHeight: hasMedia ? 144 : 0

    visible: height > 0
    clip: false

    Behavior on height {
        NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    opacity: hasMedia ? 1.0 : 0.0

    // --- Clean Material 3 Pill Card Background ---
    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: 32
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.85)
        border.width: 1
        border.color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.12)
    }

    // --- Card Content ---
    Row {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 22
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        spacing: 16

        // --- Album Art Masked to 9-Sided Cookie (Cookie9Sided) ---
        Item {
            id: artContainer
            width: 96
            height: 96
            anchors.verticalCenter: parent.verticalCenter

            // 1. Fallback 9-sided cookie shape when art is not loaded or missing
            MShape {
                id: fallbackShape
                anchors.fill: parent
                size: parent.width
                shape: root.artShape
                color: Qt.darker(Colors.surface, 1.25)
                visible: !artEffect.visible

                Text {
                    anchors.centerIn: parent
                    text: "󰎆"
                    font.pixelSize: 32
                    color: Colors.accent
                }
            }

            // 2. Source Image (buffered with layer.enabled)
            Image {
                id: artImage
                anchors.fill: parent
                source: root.activePlayer && root.activePlayer.trackArtUrl ?
                    root.activePlayer.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                layer.enabled: true
                visible: false
            }

            // 3. Mask Shape: 9-sided cookie (buffered with layer.enabled)
            Item {
                id: artMask
                anchors.fill: parent
                layer.enabled: true
                visible: false

                MShape {
                    anchors.fill: parent
                    size: parent.width
                    shape: root.artShape
                    color: "white"
                }
            }

            // 4. Cut Album Art into the 9-sided cookie shape
            MultiEffect {
                id: artEffect
                anchors.fill: parent
                source: artImage
                maskSource: artMask
                maskEnabled: true
                visible: artImage.status === Image.Ready && artImage.source != ""
            }

            // 5. Subtle contour rim for the cookie art
            MShape {
                anchors.fill: parent
                size: parent.width
                shape: root.artShape
                color: "transparent"
                opacity: 0.5
            }
        }

        // --- Track Info + Scrubber + Controls ---
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - artContainer.width - parent.spacing
            spacing: 5

            // Titles
            Column {
                width: parent.width
                spacing: 1

                Text {
                    width: parent.width
                    text: root.titleText
                    color: Colors.text
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: root.artistText
                    color: Colors.sub
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    visible: text.length > 0
                }
            }

            // Progress Bar
            Column {
                width: parent.width
                spacing: 2
                visible: root.trackLength > 0

                // Scrubber line
                Rectangle {
                    id: progressTrack
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Qt.rgba(Colors.sub.r, Colors.sub.g, Colors.sub.b, 0.35)

                    readonly property real progress: root.trackLength > 0 ?
                        Math.min(1.0, Math.max(0.0, root.currentPos / root.trackLength)) : 0

                    Rectangle {
                        height: parent.height
                        width: parent.width * progressTrack.progress
                        radius: 2
                        color: Colors.accent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (root.activePlayer && root.trackLength > 0) {
                                const pct = Math.max(0, Math.min(1, mouse.x / width));
                                const targetPos = pct * root.trackLength;
                                root.currentPos = targetPos;
                                if (root.activePlayer.setPosition) {
                                    root.activePlayer.setPosition(targetPos);
                                }
                            }
                        }
                    }
                }

                // Timestamp labels
                Row {
                    width: parent.width
                    Item {
                        width: parent.width - durationText.implicitWidth
                        height: 12
                        Text {
                            text: root.formatTime(root.currentPos)
                            color: Colors.sub
                            font.pixelSize: 10
                        }
                    }
                    Text {
                        id: durationText
                        text: root.formatTime(root.trackLength)
                        color: Colors.sub
                        font.pixelSize: 10
                    }
                }
            }

            // Controls Row (Previous, Play/Pause, Next)
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18

                // Previous Button
                Item {
                    width: 28
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: prevArea.containsMouse ? 1.0 : 0.75
                    scale: prevArea.containsPress ? 0.9 : 1.0

                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Canvas {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = Colors.text;
                            // Left bar
                            ctx.fillRect(1, 2, 2.5, 12);
                            // Left triangle
                            ctx.beginPath();
                            ctx.moveTo(14, 2);
                            ctx.lineTo(4.5, 8);
                            ctx.lineTo(14, 14);
                            ctx.closePath();
                            ctx.fill();
                        }
                    }

                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.activePlayer && root.activePlayer.canGoPrevious) {
                                root.activePlayer.previous();
                            }
                        }
                    }
                }

                // Play / Pause Circle
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: playArea.containsPress ? Qt.darker(Colors.accent, 1.15)
                         : playArea.containsMouse ? Qt.lighter(Colors.accent, 1.1)
                         : Colors.accent
                    anchors.verticalCenter: parent.verticalCenter
                    scale: playArea.containsPress ? 0.92 : (playArea.containsMouse ? 1.05 : 1.0)

                    Behavior on scale { NumberAnimation { duration: 120 } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Canvas {
                        id: playPauseCanvas
                        anchors.centerIn: parent
                        width: 18
                        height: 18

                        Connections {
                            target: root
                            function onIsPlayingChanged() {
                                playPauseCanvas.requestPaint();
                            }
                        }

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = Colors.bg;

                            if (root.isPlaying) {
                                // Pause bars
                                ctx.fillRect(4, 3, 3.5, 12);
                                ctx.fillRect(10.5, 3, 3.5, 12);
                            } else {
                                // Play triangle
                                ctx.beginPath();
                                ctx.moveTo(5, 3);
                                ctx.lineTo(15, 9);
                                ctx.lineTo(5, 15);
                                ctx.closePath();
                                ctx.fill();
                            }
                        }
                    }

                    MouseArea {
                        id: playArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!root.activePlayer) return;
                            if (root.isPlaying) {
                                root.activePlayer.pause();
                            } else {
                                root.activePlayer.play();
                            }
                        }
                    }
                }

                // Next Button
                Item {
                    width: 28
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: nextArea.containsMouse ? 1.0 : 0.75
                    scale: nextArea.containsPress ? 0.9 : 1.0

                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Canvas {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = Colors.text;
                            // Right triangle
                            ctx.beginPath();
                            ctx.moveTo(2, 2);
                            ctx.lineTo(11.5, 8);
                            ctx.lineTo(2, 14);
                            ctx.closePath();
                            ctx.fill();
                            // Right bar
                            ctx.fillRect(12.5, 2, 2.5, 12);
                        }
                    }

                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.activePlayer && root.activePlayer.canGoNext) {
                                root.activePlayer.next();
                            }
                        }
                    }
                }
            }
        }
    }
}
