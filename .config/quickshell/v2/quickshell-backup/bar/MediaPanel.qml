import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris

// ============================================================================
// MediaPanel.qml — qs-media
//
// The full media panel. Opens when the notch's mini media widget is clicked
// (Notch.mediaExpandRequested → wired up in shell.qml). Does NOT poll MPRIS
// itself — it receives the same `player` object the notch is already
// tracking, passed in from shell.qml, so there's only one MPRIS listener
// for the whole shell.
// ============================================================================

PanelWindow {
    id: panelRoot

    property var colors: ({
        bg: "#1e1e2e",
        surface: "#313244",
        accent: "#89b4fa",
        text: "#cdd6f4",
        sub: "#a6adc8"
    })
    function c(key) {
        return (panelRoot.colors && panelRoot.colors[key]) ? panelRoot.colors[key] : "#888888"
    }

    // Passed in from shell.qml — the SAME Mpris player Notch.qml tracks.
    property var player: null
    property bool open: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-media"

    anchors { top: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: -1
    height: 480
    visible: open

    // ------------------------------------------------------------------
    // Derived track info. Guarded with `player &&` everywhere since the
    // player can disappear mid-panel-open (app closed, etc).
    // ------------------------------------------------------------------
    property string title:  player ? player.trackTitle : ""
    // ASSUMPTION: artist property name — Quickshell's Mpris player exposes
    // this as `trackArtist` on most builds. If this shows blank on yours,
    // tell me what property actually holds it and I'll fix the binding.
    property string artist: (player && player.trackArtist) ? player.trackArtist : ""
    property string artUrl: player ? player.trackArtUrl : ""
    property bool playing: player !== null && player.playbackState === MprisPlaybackState.Playing

    // ------------------------------------------------------------------
    // Position/length handling — MPRIS does NOT stream position updates
    // continuously; `player.position` is a snapshot taken at the moment
    // something else changes (seek, play/pause, track change), not a
    // live-ticking value. Binding the progress bar directly to it is why
    // it froze for a second then jumped. Instead: keep our own locally-
    // ticking `displayPosition`, resynced from the real player whenever
    // it actually reports a change, plus a periodic resync to correct
    // drift. `length` is kept "sticky" (last known good value) instead
    // of falling back to 1 the instant it reads 0 — a transient 0 during
    // a metadata refresh was making the bar render as fully filled.
    // ------------------------------------------------------------------
    property real length: 1
    property real displayPosition: 0

    onPlayerChanged: {
        if (player) {
            if (player.length > 0) length = player.length
            displayPosition = player.position
        }
    }

    Connections {
        target: panelRoot.player
        enabled: panelRoot.player !== null
        function onLengthChanged()   { if (panelRoot.player.length > 0) panelRoot.length = panelRoot.player.length }
        function onPositionChanged() { panelRoot.displayPosition = panelRoot.player.position }
    }

    // Smooth local ticking between real MPRIS snapshots
    Timer {
        interval: 250
        running: panelRoot.open && panelRoot.playing
        repeat: true
        onTriggered: panelRoot.displayPosition = Math.min(panelRoot.length, panelRoot.displayPosition + 0.25)
    }
    // Periodic resync to correct any drift from the local ticker
    Timer {
        interval: 3000
        running: panelRoot.open && panelRoot.playing
        repeat: true
        onTriggered: if (panelRoot.player) panelRoot.displayPosition = panelRoot.player.position
    }

    // Shuffle/repeat are best-effort — not every MPRIS player implements
    // them, and Quickshell's Mpris wrapper may or may not expose setters.
    // Guarded so a missing property/function never throws, it just no-ops.
    property bool shuffleOn: !!(player && player.shuffle)
    property int  loopStatus: player ? player.loopStatus : 0 // 0 None, 1 Track, 2 Playlist — guessed enum shape

    function togglePlay() { if (player) player.togglePlaying() }
    function prevTrack()  { if (player) player.previous() }
    function nextTrack()  { if (player) player.next() }
    function toggleShuffle() {
        if (player && typeof player.setShuffle === "function") player.setShuffle(!player.shuffle)
    }
    function cycleRepeat() {
        if (player && typeof player.setLoopStatus === "function") {
            var next = (panelRoot.loopStatus + 1) % 3
            player.setLoopStatus(next)
        }
    }
    function seekTo(fraction) {
        var target = fraction * panelRoot.length
        panelRoot.displayPosition = target // optimistic UI update, don't wait for the real snapshot
        if (player && typeof player.setPosition === "function") player.setPosition(target)
    }

    function formatTime(seconds) {
        var s = Math.max(0, Math.floor(seconds))
        var m = Math.floor(s / 60)
        var r = s % 60
        return m + ":" + (r < 10 ? "0" : "") + r
    }

    // Click anywhere outside the card closes the panel.
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: panelRoot.open = false
    }

    // ====================================================================
    // CARD
    // ====================================================================
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 0
        width: 380
        height: panelRoot.open ? 440 : 0
        radius: 26 // fallback for older Qt without per-corner radius support
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: 26
        bottomRightRadius: 26
        color: panelRoot.c("bg")
        clip: true
        antialiasing: true

        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Swallow clicks so they don't bubble to the close-on-outside-click
        // MouseArea behind the card.
        MouseArea { anchors.fill: parent; onClicked: {} }

        // ---------------- Blurred album-art background ----------------
        Item {
            id: bgMask
            anchors.fill: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: bgMask.width; height: bgMask.height
                    topLeftRadius: 0; topRightRadius: 0
                    bottomLeftRadius: 26; bottomRightRadius: 26
                }
            }

            Image {
                id: bgArt
                anchors.fill: parent
                source: panelRoot.artUrl.length > 0 ? panelRoot.artUrl : ""
                fillMode: Image.PreserveAspectCrop
                visible: false
                asynchronous: true
            }
            FastBlur {
                anchors.fill: parent
                source: bgArt
                radius: 64
                visible: panelRoot.artUrl.length > 0
            }
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.45)
            }
        }

        // ---------------- Foreground content ----------------
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 18

            // Close button
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                Text {
                    text: "\uf00d" // nf-fa-times
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8 // bigger hit target than the glyph itself
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panelRoot.open = false
                    }
                }
            }

            // Sharp album art thumbnail
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 180
                Layout.preferredHeight: 180
                radius: 20
                color: panelRoot.c("surface")
                clip: true

                Item {
                    id: artMask
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle { width: artMask.width; height: artMask.height; radius: 20 }
                    }
                    Image {
                        anchors.fill: parent
                        source: panelRoot.artUrl.length > 0 ? panelRoot.artUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        Rectangle {
                            anchors.fill: parent
                            visible: parent.status !== Image.Ready
                            color: panelRoot.c("surface")
                            Text {
                                anchors.centerIn: parent
                                text: "♪" // standard music-note symbol, placeholder while no art / not playing
                                color: panelRoot.c("sub")
                                font.pixelSize: 48
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                }
            }

            // Title / artist
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: panelRoot.title.length > 0 ? panelRoot.title : "Not playing"
                    color: "#ffffff"
                    font.pixelSize: 18
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    visible: panelRoot.artist.length > 0
                    text: panelRoot.artist
                    color: "#cccccc"
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                }
            }

            // Seekable progress bar
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Rectangle {
                    id: track
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Qt.rgba(1, 1, 1, 0.25)

                    Rectangle {
                        width: track.width * Math.min(1, panelRoot.displayPosition / panelRoot.length)
                        height: parent.height
                        radius: 3
                        color: panelRoot.c("accent")
                        // No Behavior here — the local ticker above already advances this
                        // every 250ms, a smoothing Behavior on top just adds lag/overshoot.
                    }

                    MouseArea {
                        id: seekArea
                        anchors.fill: parent
                        anchors.margins: -6 // easier to grab
                        cursorShape: Qt.PointingHandCursor
                        // NOTE: use seekArea's OWN width here, not track.width — the
                        // negative margin makes this MouseArea wider than `track`,
                        // so measuring against track.width was reading mouse.x in
                        // the wrong coordinate frame and threw the seek off.
                        onClicked: (mouse) => panelRoot.seekTo(Math.max(0, Math.min(1, mouse.x / seekArea.width)))
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: panelRoot.formatTime(panelRoot.displayPosition)
                        color: "#cccccc"
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: panelRoot.formatTime(panelRoot.length)
                        color: "#cccccc"
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            // Transport controls
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 26

                Text {
                    text: "⇄" // standard "two arrows" symbol for shuffle
                    color: panelRoot.shuffleOn ? panelRoot.c("accent") : "#cccccc"
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                    MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.toggleShuffle() }
                }
                Text {
                    text: "󰒮" // prev — same confirmed glyph as Notch.qml
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.family: "JetBrainsMono Nerd Font"
                    MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.prevTrack() }
                }

                // Big play/pause circle
                Rectangle {
                    width: 56; height: 56
                    radius: 28
                    color: panelRoot.c("accent")
                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: panelRoot.playing ? 0 : 2 // optical centering for the play glyph
                        text: panelRoot.playing ? "pause" : "play_arrow" // same confirmed glyphs as Notch.qml
                        color: panelRoot.c("bg")
                        font.pixelSize: 24
                        font.family: "Material Symbols Rounded"
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.togglePlay() }
                }

                Text {
                    text: "󰒭" // next — same confirmed glyph as Notch.qml
                    color: "#ffffff"
                    font.pixelSize: 22
                    font.family: "JetBrainsMono Nerd Font"
                    MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.nextTrack() }
                }
                Text {
                    text: "↻" // standard repeat-arrow symbol (color alone now distinguishes repeat-one, see comment below)
                    color: panelRoot.loopStatus !== 0 ? panelRoot.c("accent") : "#cccccc"
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                    MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.cycleRepeat() }
                }
            }
        }
    }
}
