import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

// ============================================================================
// Notch.qml — qs-notch-v2
//
// Closed state: thin pill showing just the time.
// Expanded state (click/hover anywhere on the shape): wide pill containing
//   media mini-widget | clock | weather + mini calendar | location | expand-arrow
//
// This is the MAIN NOTCH SHAPE only. It emits signals for the pieces that
// expand into their own separate panels (full media panel, weather panel,
// control center, etc) — those are built as separate files that hook into
// these signals rather than being implemented inline here.
// ============================================================================

PanelWindow {
    id: notchRoot

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-notch"

    anchors { top: true; left: true; right: true }
    color: "transparent"

    // Reserve real screen space equal to the CLOSED pill's height, so
    // other windows don't render underneath/behind the notch. The expanded
    // state deliberately does NOT grow this — it's drawn on the Overlay
    // layer and is meant to overlap other windows temporarily, not push
    // them down every time you hover.
    exclusiveZone: 25

    // The window itself stays a CONSTANT height — tall enough to fit the
    // expanded shape. Only the inner Rectangle (`shape` below) animates its
    // own width/height within that fixed window. If the window itself
    // resized (open ? 90 : 34), the layer-shell surface would snap to the
    // new size instantly with no animation, clipping off whatever the
    // inner Rectangle was mid-transition into — which is why nothing
    // appeared to animate before.
    height: 110

    mask: Region {
        item: shape
    }

    property bool open: false
    function toggle() { open = !open }

    // Signals other files (full media panel, weather panel, control center)
    // can connect to
    signal mediaExpandRequested()
    signal weatherExpandRequested()
    signal controlCenterRequested()

    // ------------------------------------------------------------------
    // Colors — reads the unified colors.json (matugen/iris/static themes
    // all write to this same file). Falls back to a default palette if
    // the file doesn't exist yet or fails to parse.
    // ------------------------------------------------------------------
    property var colors: ({
        bg: "#1e1e2e",
        surface: "#313244",
        accent: "#89b4fa",
        text: "#cdd6f4",
        sub: "#a6adc8",
        purple: "#cba6f7",
        orange: "#fab387"
    })

    // Guard against the object being momentarily undefined on the very
    // first evaluation tick (before FileView resolves) — every color
    // usage below should call c("key") instead of colors.key directly.
    function c(key) {
        return (notchRoot.colors && notchRoot.colors[key]) ? notchRoot.colors[key] : "#888888"
    }

    FileView {
        id: colorsFile
        // Colors come from the topbar config's colors.json, not this config's
        // own folder — this notch is a separate qs config living in ~/.config/quickshell/bar,
        // but shares the same color source as ~/.config/quickshell/topbar.
        path: Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"
        watchChanges: true
        onLoaded: {
            try {
                var parsed = JSON.parse(text())
                notchRoot.colors = parsed
            } catch (e) {
                console.log("Notch: failed to parse colors.json, using fallback:", e)
            }
        }
        onLoadFailed: (error) => {
            // Missing/unreadable file must never block the notch from rendering —
            // fall back to the default palette above.
            console.log("Notch: colors.json load failed, using fallback:", error)
        }
        onFileChanged: reload()
    }

    // ------------------------------------------------------------------
    // Live clock — plain Timer + Date, no optional Quickshell service
    // dependency (Quickshell.Services.SystemClock isn't present on every
    // install, so this avoids relying on it at all).
    // ------------------------------------------------------------------
    property date now: new Date()
    property string timeStr: Qt.formatTime(now, "h:mm AP")

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: notchRoot.now = new Date()
    }

    // ------------------------------------------------------------------
    // Live weather (via wttr.in — no API key needed).
    // Location is auto-detected from the VM's public IP — omitting the
    // city from the URL tells wttr.in to geolocate the request itself,
    // so this follows wherever the machine actually is instead of being
    // hardcoded to one city.
    // ------------------------------------------------------------------
    property string location: "Locating…"
    property string weatherTemp: "--"
    property string weatherDesc: "--"
    property string weatherIcon: "󰖙"

    function weatherIconFor(desc) {
        var d = desc.toLowerCase()
        if (d.indexOf("thunder") !== -1) return "󰖓"
        if (d.indexOf("snow") !== -1)     return "󰖘"
        if (d.indexOf("rain") !== -1 || d.indexOf("drizzle") !== -1) return "󰖗"
        if (d.indexOf("cloud") !== -1 || d.indexOf("overcast") !== -1) return "󰖐"
        if (d.indexOf("clear") !== -1 || d.indexOf("sunny") !== -1) return "󰖙"
        return "󰖕"
    }

    Process {
        id: weatherProc
        // No city in the path → wttr.in geolocates by request IP.
        // %l = detected location name, %t = temp, %C = condition text.
        command: ["bash", "-c", "curl -s 'wttr.in/?format=%l|%t|%C'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("|")
                if (parts.length === 3) {
                    notchRoot.location = parts[0].trim()
                    notchRoot.weatherTemp = parts[1].replace("+", "").trim()
                    notchRoot.weatherDesc = parts[2].trim()
                    notchRoot.weatherIcon = notchRoot.weatherIconFor(parts[2])
                }
            }
        }
    }

    Timer {
        interval: 15 * 60 * 1000   // refresh every 15 min
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherProc.running = true
    }

    // ------------------------------------------------------------------
    // Live media via Mpris
    // ------------------------------------------------------------------
    property var activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    property bool isPlaying: activePlayer !== null && activePlayer.playbackState === MprisPlaybackState.Playing
    property string trackTitle: activePlayer ? activePlayer.trackTitle : ""
    property string trackArtUrl: activePlayer ? activePlayer.trackArtUrl : ""
    property real trackPosition: activePlayer ? activePlayer.position : 0
    property real trackLength: (activePlayer && activePlayer.length > 0) ? activePlayer.length : 1

    function togglePlay() { if (activePlayer) activePlayer.togglePlaying() }
    function prevTrack()  { if (activePlayer) activePlayer.previous() }
    function nextTrack()  { if (activePlayer) activePlayer.next() }

    // ------------------------------------------------------------------
    // Mini calendar strip — 2 days either side of today, today highlighted
    // ------------------------------------------------------------------
    function calendarDays() {
        var days = []
        var today = new Date(notchRoot.now)
        for (var i = -2; i <= 2; i++) {
            var d = new Date(today)
            d.setDate(today.getDate() + i)
            days.push({ num: d.getDate(), isToday: i === 0 })
        }
        return days
    }

    // ====================================================================
    // VISUAL SHAPE
    // ====================================================================
    Rectangle {
        id: shape
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        // Expanded width now hugs the RowLayout's actual content instead of
        // a hardcoded number — no more dead space once the arrow spacer
        // is removed. +20 accounts for the RowLayout's own anchors.margins.
        width:  notchRoot.open ? (expandedRow.implicitWidth + 20) : 110
        height: notchRoot.open ? 110 : 30
        color:  "#000000"
        antialiasing: true
        clip: true

        // A real notch sits flush against the top edge of the screen —
        // only the BOTTOM corners are rounded, top stays flat. (Requires
        // Qt 6.7+ for per-corner radius; if your Qt is older than that,
        // tell me and I'll swap this for a manual path/mask instead.)
        radius: 0
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: notchRoot.open ? 28 : 20
        bottomRightRadius: notchRoot.open ? 28 : 20

        Behavior on width  { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
        Behavior on bottomLeftRadius  { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Behavior on bottomRightRadius { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Hover opens/closes the notch — no click needed. HoverHandler sits
        // alongside the other MouseAreas (media buttons, weather arrow)
        // rather than blocking them, since it only tracks hover, not clicks.
        HoverHandler {
            onHoveredChanged: notchRoot.open = hovered
        }

        // ---------------- CLOSED STATE ----------------
        Text {
            anchors.centerIn: parent
            visible: !notchRoot.open
            text: notchRoot.timeStr
            color: notchRoot.c("text")
            font.pixelSize: 17
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }

        // ---------------- EXPANDED STATE ----------------
        RowLayout {
            id: expandedRow
            anchors.fill: parent
            anchors.margins: 10
            spacing: 14
            visible: notchRoot.open
            opacity: notchRoot.open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 180 } }

            // ----- Media mini-widget -----
            Rectangle {
                id: mediaBox
                Layout.preferredWidth: 190
                Layout.fillHeight: true
                radius: 18
                color: notchRoot.c("surface")
                // NOTE: plain `clip: true` on a Rectangle only clips children
                // to the bounding BOX, not the rounded shape — that's what
                // caused the square artifact poking out of the rounded
                // corners. `mediaBoxContent` below is masked with an
                // OpacityMask instead, same technique as the wallpaper
                // switcher's thumbnail masking.

                Item {
                    id: mediaBoxContent
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: mediaBoxContent.width
                            height: mediaBoxContent.height
                            radius: 18
                        }
                    }

                    // Blurred album art background
                    Image {
                        id: artImg
                        anchors.fill: parent
                        source: notchRoot.trackArtUrl.length > 0 ? notchRoot.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                        asynchronous: true
                    }
                    FastBlur {
                        anchors.fill: parent
                        source: artImg
                        radius: 48
                        visible: notchRoot.trackArtUrl.length > 0
                    }
                    // Darken overlay so text stays legible over any art
                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(0, 0, 0, 0.35)
                    }
                }

                // Click the box itself (not the transport buttons) → expand
                // into the full media panel (built separately).
                MouseArea {
                    anchors.fill: parent
                    z: -1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notchRoot.mediaExpandRequested()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: notchRoot.trackTitle.length > 0 ? notchRoot.trackTitle : "Not playing"
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12

                        Text {
                            text: "󰒮"
                            color: "#ffffff"
                            font.pixelSize: 17
                            font.family: "JetBrainsMono Nerd Font"
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: notchRoot.prevTrack() }
                        }
                        Text {
                            text: notchRoot.isPlaying ? "󰏤" : "󰐊"
                            color: "#ffffff"
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: notchRoot.togglePlay() }
                        }
                        Text {
                            text: "󰒭"
                            color: "#ffffff"
                            font.pixelSize: 17
                            font.family: "JetBrainsMono Nerd Font"
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: notchRoot.nextTrack() }
                        }
                    }

                    // Progress underline
                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: 2
                        color: Qt.rgba(1, 1, 1, 0.25)

                        Rectangle {
                            width: parent.width * Math.min(1, notchRoot.trackPosition / notchRoot.trackLength)
                            height: parent.height
                            radius: 2
                            color: notchRoot.c("accent")
                            Behavior on width { NumberAnimation { duration: 400 } }
                        }
                    }
                }
            }

            // ----- Clock -----
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: notchRoot.timeStr
                color: notchRoot.c("text")
                font.pixelSize: 22
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }

            // ----- Weather + mini calendar -----
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                RowLayout {
                    spacing: 4
                    Text { text: notchRoot.weatherIcon; font.pixelSize: 18; color: notchRoot.c("text"); font.family: "JetBrainsMono Nerd Font" }
                    Text { text: notchRoot.weatherTemp; font.pixelSize: 16; color: notchRoot.c("text"); font.family: "JetBrainsMono Nerd Font" }
                    Text { text: notchRoot.weatherDesc; font.pixelSize: 13; color: notchRoot.c("sub"); font.family: "JetBrainsMono Nerd Font" }
                }

                Text {
                    text: Qt.formatDate(notchRoot.now, "ddd d")
                    font.pixelSize: 13
                    color: notchRoot.c("sub")
                    font.family: "JetBrainsMono Nerd Font"
                }

                RowLayout {
                    spacing: 4
                    Repeater {
                        model: notchRoot.calendarDays()
                        Rectangle {
                            width: 20; height: 22
                            radius: 7
                            color: modelData.isToday ? "#FF5000" : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: modelData.num
                                font.pixelSize: 11
                                color: modelData.isToday ? notchRoot.c("bg") : notchRoot.c("sub")
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                }
            }

            // ----- Location -----
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: notchRoot.location
                font.pixelSize: 13
                color: notchRoot.c("sub")
                font.family: "JetBrainsMono Nerd Font"
            }

            // ----- Weather expand arrow → full weather panel (built separately) -----
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "󰅂"
                font.pixelSize: 20
                color: notchRoot.c("sub")
                font.family: "JetBrainsMono Nerd Font"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notchRoot.weatherExpandRequested()
                }
            }

            // ----- Control center button → control center panel (built separately) -----
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "\u2699" // standard gear symbol — safe, no PUA guessing
                font.pixelSize: 16
                color: notchRoot.c("sub")
                font.family: "JetBrainsMono Nerd Font"
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notchRoot.controlCenterRequested()
                }
            }
        }
    }
}
