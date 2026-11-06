import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "."

// Central Horizontal Floating Deck:
// - Left: M3 Cookie-masked Album Art with spinning vinyl ring
// - Center: Track Info (Title, Artist, Controls, live MPRIS + playerctl bindings)
// - Right: Stacked Bold Clock & Date
Rectangle {
    id: root

    // --- Clock State ---
    property date now: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    readonly property int rawHour: now.getHours()
    readonly property int hour12: rawHour % 12 === 0 ? 12 : rawHour % 12
    readonly property string minuteText: now.getMinutes().toString().padStart(2, "0")
    readonly property string dateStr: {
        const months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        return now.getDate() + " " + months[now.getMonth()];
    }

    // --- Live MPRIS & Playerctl Media Integration ---
    readonly property var playersList: Mpris.players.values
    property int pollTick: 0

    // Poll to keep reactive bindings fresh
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.pollTick++;
            if (!playerctlProc.running) playerctlProc.running = true;
        }
    }

    // playerctl CLI active monitor
    property string cliStatus: ""
    property string cliTitle: ""
    property string cliArtist: ""
    property string cliArtUrl: ""

    Process {
        id: playerctlProc
        command: ["sh", "-c", "playerctl metadata --format '{{status}}|||{{title}}|||{{artist}}|||{{mpris:artUrl}}' 2>/dev/null || echo ''"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim();
                if (s.includes("|||")) {
                    const parts = s.split("|||");
                    root.cliStatus = (parts[0] || "").trim();
                    root.cliTitle = (parts[1] || "").trim();
                    root.cliArtist = (parts[2] || "").trim();
                    root.cliArtUrl = (parts[3] || "").trim();
                } else if (s === "") {
                    root.cliStatus = "";
                    root.cliTitle = "";
                    root.cliArtist = "";
                    root.cliArtUrl = "";
                }
            }
        }
    }

    Process {
        id: cmdProc
        running: false
    }

    function runCmd(cmd) {
        cmdProc.command = cmd;
        cmdProc.running = true;
        playerctlProc.running = true;
    }

    readonly property var activePlayer: {
        const dummy = root.pollTick; // force dependency on tick
        if (!playersList || playersList.length === 0) return null;
        for (let i = 0; i < playersList.length; i++) {
            const p = playersList[i];
            if (p && p.playbackState === MprisPlaybackState.Playing) return p;
        }
        for (let i = 0; i < playersList.length; i++) {
            const p = playersList[i];
            if (p && p.trackTitle && p.trackTitle.length > 0) return p;
        }
        return playersList[0] || null;
    }

    readonly property bool isPlaying: {
        if (activePlayer && activePlayer.playbackState === MprisPlaybackState.Playing) return true;
        return root.cliStatus.toLowerCase() === "playing";
    }

    readonly property bool hasMedia: {
        if (activePlayer && ((activePlayer.trackTitle && activePlayer.trackTitle.length > 0) || activePlayer.playbackState === MprisPlaybackState.Playing)) return true;
        return root.cliTitle.length > 0 || root.cliStatus.toLowerCase() === "playing";
    }

    readonly property string trackTitle: {
        if (activePlayer && activePlayer.trackTitle && activePlayer.trackTitle.length > 0) {
            return activePlayer.trackTitle;
        }
        if (root.cliTitle.length > 0) {
            return root.cliTitle;
        }
        return hasMedia ? "Unknown Title" : "No Media Playing";
    }

    readonly property string trackArtist: {
        if (activePlayer) {
            if (activePlayer.trackArtists && activePlayer.trackArtists.length > 0) {
                return activePlayer.trackArtists.join(", ");
            }
            if (activePlayer.trackArtist && activePlayer.trackArtist.length > 0) {
                return activePlayer.trackArtist;
            }
        }
        if (root.cliArtist.length > 0) {
            return root.cliArtist;
        }
        return hasMedia ? "Unknown Artist" : "Nothing playing right now";
    }

    function normalizeArtUrl(url) {
        if (!url || url.length === 0) return "";
        if (url.startsWith("/")) return "file://" + url;
        return url;
    }

    readonly property string artUrl: {
        if (activePlayer && activePlayer.trackArtUrl && activePlayer.trackArtUrl.length > 0) {
            return normalizeArtUrl(activePlayer.trackArtUrl);
        }
        if (root.cliArtUrl.length > 0) {
            return normalizeArtUrl(root.cliArtUrl);
        }
        return "";
    }

    function togglePlay() {
        if (root.activePlayer) {
            if (root.isPlaying) root.activePlayer.pause();
            else root.activePlayer.play();
        } else {
            runCmd(["playerctl", "play-pause"]);
        }
    }

    function doNext() {
        if (root.activePlayer && root.activePlayer.canGoNext) {
            root.activePlayer.next();
        } else {
            runCmd(["playerctl", "next"]);
        }
    }

    function doPrev() {
        if (root.activePlayer && root.activePlayer.canGoPrevious) {
            root.activePlayer.previous();
        } else {
            runCmd(["playerctl", "previous"]);
        }
    }

    implicitWidth: 760
    implicitHeight: 230
    radius: 28
    color: Colors.cardBg
    border.width: 1.5
    border.color: Colors.cardBorder

    Row {
        anchors.fill: parent
        anchors.margins: 26
        spacing: 24

        // ================= 1. LEFT: Scallop Album Art =================
        Item {
            id: artBox
            width: 178
            height: 178
            anchors.verticalCenter: parent.verticalCenter

            // Scallop Shape Mask
            Canvas {
                id: scallopMask
                anchors.fill: parent
                visible: false
                layer.enabled: true
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const cx = width / 2;
                    const cy = height / 2;
                    const R0 = width * 0.40;
                    const A = width * 0.055;
                    const lobes = 12;

                    ctx.beginPath();
                    for (let a = 0; a <= 2 * Math.PI; a += 0.02) {
                        const r = R0 + A * Math.cos(lobes * a);
                        const x = cx + r * Math.cos(a);
                        const y = cy + r * Math.sin(a);
                        if (a === 0) ctx.moveTo(x, y);
                        else ctx.lineTo(x, y);
                    }
                    ctx.closePath();
                    ctx.fillStyle = "white";
                    ctx.fill();
                }
            }

            // Raw Artwork Container
            Item {
                id: rawArtContainer
                anchors.fill: parent
                visible: false
                layer.enabled: true

                // Rotating Vinyl / Artwork when playing
                property real vinylAngle: 0
                rotation: vinylAngle
                NumberAnimation on vinylAngle {
                    from: 0; to: 360; duration: 20000; loops: Animation.Infinite
                    running: root.isPlaying
                }

                // Default Stylized Vinyl Graphic
                Rectangle {
                    anchors.fill: parent
                    color: "#18141f"

                    // Vinyl Grooves
                    Repeater {
                        model: [30, 48, 66]
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width - modelData * 2
                            height: width
                            radius: width / 2
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.08)
                        }
                    }

                    // Center Pink Accent Hub
                    Rectangle {
                        anchors.centerIn: parent
                        width: 48
                        height: 48
                        radius: 24
                        color: Colors.accent

                        Text {
                            anchors.centerIn: parent
                            text: "♪"
                            color: Colors.bg
                            font.pixelSize: 22
                            font.bold: true
                        }
                    }
                }

                // Live Album Art Image
                Image {
                    id: albumImg
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready && root.artUrl.length > 0
                }
            }

            // Masked Output
            MultiEffect {
                anchors.fill: parent
                source: rawArtContainer
                maskEnabled: true
                maskSource: scallopMask
            }

            // Glowing Outer Scallop Border
            Canvas {
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const cx = width / 2;
                    const cy = height / 2;
                    const R0 = width * 0.40;
                    const A = width * 0.055;
                    const lobes = 12;

                    ctx.beginPath();
                    for (let a = 0; a <= 2 * Math.PI; a += 0.02) {
                        const r = R0 + A * Math.cos(lobes * a);
                        const x = cx + r * Math.cos(a);
                        const y = cy + r * Math.sin(a);
                        if (a === 0) ctx.moveTo(x, y);
                        else ctx.lineTo(x, y);
                    }
                    ctx.closePath();
                    ctx.strokeStyle = Colors.accent;
                    ctx.lineWidth = 2.0;
                    ctx.stroke();
                }
            }
        }

        // ================= 2. CENTER: Now Playing & Controls =================
        Column {
            id: infoCol
            width: parent.width - artBox.width - clockCol.width - 72
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            // Overline chip: NOW PLAYING / PAUSED / MEDIA
            Text {
                text: root.isPlaying ? "NOW PLAYING" : (root.hasMedia ? "PAUSED" : "MEDIA")
                color: root.isPlaying ? Colors.accent : Colors.sub
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 2.0
            }

            // Track Title
            Text {
                width: parent.width
                text: root.trackTitle
                color: Colors.text
                font.pixelSize: 22
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            // Artist Name
            Text {
                width: parent.width
                text: root.trackArtist
                color: Colors.sub
                font.pixelSize: 14
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Item { height: 4; width: 1 }

            // Controls Row
            Row {
                spacing: 20
                anchors.left: parent.left

                // Prev Button
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "⏮"
                        color: Colors.text
                        font.pixelSize: 15
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.doPrev()
                    }
                }

                // Play / Pause Prominent Circle
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: playMouse.containsMouse ? Qt.lighter(Colors.accent, 1.1) : Colors.accent
                    anchors.verticalCenter: parent.verticalCenter
                    scale: playMouse.containsPress ? 0.92 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: root.isPlaying ? "⏸" : "▶"
                        color: Colors.bg
                        font.pixelSize: 16
                        font.bold: true
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.togglePlay()
                    }
                }

                // Next Button
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "⏭"
                        color: Colors.text
                        font.pixelSize: 15
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.doNext()
                    }
                }
            }
        }

        // ================= 3. RIGHT: Stacked Clock & Date =================
        Column {
            id: clockCol
            width: 140
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            // Stacked Digits
            Text {
                anchors.right: parent.right
                text: root.hour12.toString().padStart(2, "0")
                color: Colors.text
                font.pixelSize: 52
                font.weight: Font.Bold
                font.letterSpacing: -1.0
            }

            Text {
                anchors.right: parent.right
                text: root.minuteText
                color: Colors.text
                font.pixelSize: 52
                font.weight: Font.Bold
                font.letterSpacing: -1.0
            }

            // Uppercase Date below
            Text {
                anchors.right: parent.right
                anchors.topMargin: 4
                text: root.dateStr
                color: Colors.sub
                font.pixelSize: 11
                font.weight: Font.Bold
                font.letterSpacing: 1.5
            }
        }
    }
}
