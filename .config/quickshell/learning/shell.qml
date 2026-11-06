import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Effects

PanelWindow {
    id: win

    anchors.top: true
    color: "transparent"

    // Window is sized for the biggest state; the mask means only the pill
    // itself catches the mouse, so the empty area never blocks clicks.
    implicitWidth: 480
    implicitHeight: 380
    exclusiveZone: 50
    mask: Region { item: pill }

    // ---- palette (swap these for your colors.json later) ----
    QtObject {
        id: theme
        readonly property color bg: "#040e0d"
        readonly property color accent: "#3dd1b0"
        readonly property string font: "Google Sans Flex"
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // ---- audio level (real data needs `cava`: sudo pacman -S cava) ----
    property real level: 0           // 0..1 from cava
    property bool cavaLive: false    // flips true once cava actually sends data
    property real fakeLevel: 0       // fallback pulse if cava isn't there
    readonly property real orbLevel: media.playing ? (cavaLive ? level : fakeLevel) : 0

    property int dbgCount: 0
    Timer {
        id: liveTimer
        interval: 1500
        onTriggered: win.cavaLive = false
    }

    Process {
        id: cava
        running: media.playing   // only listen while something is playing
        command: ["bash", "-c",
            // reuse the [input] section of your own cava config (so it listens to the same source as
            // your visualizer), then add the tiny 1-bar output config this pill needs
            "{ printf '[general]\\nbars=2\\nframerate=60\\n[output]\\nmethod=raw\\nraw_target=/dev/stdout\\ndata_format=ascii\\nascii_max_range=100\\n'; "
            + "awk '/^\\[input\\]/{f=1;print;next} /^\\[/{f=0} f' ~/.config/cava/config 2>/dev/null; } > /tmp/pill-cava.conf; "
            + "exec cava -p /tmp/pill-cava.conf"]

        stdout: SplitParser {
            onRead: data => {
                // stereo gives two values like "12;34;" -> use the louder channel
                const nums = data.split(";").map(x => parseInt(x)).filter(x => !isNaN(x))
                const v = nums.length > 0 ? Math.max(...nums) : NaN
                if (win.dbgCount < 5) { console.log("pill: cava data:", data); win.dbgCount++ }
                if (!isNaN(v)) {
                    // trust cava only while it reports real signal; if it goes quiet for
                    // 1.5s (e.g. wrong audio source) the fallback pulse takes over again
                    if (v > 3) { win.cavaLive = true; liveTimer.restart() }
                    win.level = Math.min(1, Math.pow(v / 100, 0.6) * 1.15)
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.warn("pill: cava stderr:", data)
        }
        onStarted: { win.dbgCount = 0; console.log("pill: cava started") }
        onExited: (code, status) => console.log("pill: cava exited", code, status)
        onRunningChanged: if (!running) { win.level = 0; win.cavaLive = false }
    }

    SequentialAnimation on fakeLevel {
        running: media.playing && !win.cavaLive
        loops: Animation.Infinite
        NumberAnimation { to: 0.8; duration: 380; easing.type: Easing.OutQuad }
        NumberAnimation { to: 0.15; duration: 520; easing.type: Easing.InOutQuad }
    }

    // Circle with a music note and a ring that grows/brightens with `level`.
    // (Inline components can't see outer ids, so colors are passed in.)
    component MusicOrb: Item {
        id: orb
        property real size: 24
        property real level: 0
        property bool active: false
        property color accent: "#3dd1b0"
        property color back: "#040e0d"
        property string artSource: ""
        readonly property bool hasArt: artSource !== "" && art.status === Image.Ready

        width: size
        height: size

        Rectangle {
            anchors.centerIn: parent
            width: orb.size * (1.14 + 0.3 * orb.level)
            height: width
            radius: width / 2
            color: "transparent"
            border.width: Math.max(1.5, orb.size * 0.05)
            border.color: orb.accent
            opacity: orb.active ? 0.35 + 0.65 * orb.level : 0

            Behavior on width        { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
            Behavior on opacity      { NumberAnimation { duration: 90 } }
            Behavior on border.color { ColorAnimation  { duration: 250; easing.type: Easing.OutBack } }
        }

        Rectangle {
            anchors.centerIn: parent
            width: orb.size
            height: width
            radius: width / 2
            color: orb.accent
            scale: 1 + 0.06 * orb.level

            Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation  { duration: 250; easing.type: Easing.OutBack } }

            Text {
                anchors.centerIn: parent
                text: "♪"
                font.pixelSize: orb.size * 0.55
                color: orb.back
                Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutBack } }
            }
        }

        // album art, cropped to a circle; covers the note once it has loaded
        Item {
            anchors.centerIn: parent
            width: orb.size
            height: width
            scale: 1 + 0.06 * orb.level
            visible: orb.hasArt

            Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

            Image {
                id: art
                anchors.fill: parent
                source: orb.artSource
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 256
                sourceSize.height: 256
                visible: false
            }
            Item {
                id: artMask
                anchors.fill: parent
                layer.enabled: true
                visible: false
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                }
            }
            MultiEffect {
                anchors.fill: parent
                source: art
                maskEnabled: true
                maskSource: artMask
            }
        }
    }

    Rectangle {
        id: pill

        property bool open: false
        property int page: 0   // 0 = calendar, 1 = media
        readonly property bool hovered: hover.hovered
        readonly property bool bright: hovered && !open
        readonly property color fg: bright ? theme.bg : theme.accent
        readonly property int pageCount: 2
        // pill grows a bit while music plays to make room for the orb
        readonly property int idleW: media.playing ? 156 : 120
        readonly property int hoverW: media.playing ? 230 : 200
        readonly property int leftPad: media.playing ? 48 : 30

        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        width: open ? 360 : hovered ? hoverW : idleW
        height: open ? 304 : hovered ? 60 : 40
        radius: Math.min(height / 2, 28)
        color: bright ? theme.accent : theme.bg

        Behavior on width  { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        Behavior on color  { ColorAnimation  { duration: 250; easing.type: Easing.OutBack } }

        HoverHandler {
            id: hover
            onHoveredChanged: if (!hovered) pill.open = false
        }

        Item {
            id: content
            anchors.fill: parent
            clip: true

            // ---- header: time + date (tap here to open/close) ----
            Item {
                id: header
                width: parent.width
                height: Math.min(pill.height, 60)

                // Only the header toggles, so tapping the calendar
                // (arrows, days) doesn't close the pill.
                TapHandler {
                    onTapped: pill.open = !pill.open
                }

                Text {
                    text: Qt.formatTime(clock.date, "hh:mm AP")
                    font.family: theme.font
                    font.pixelSize: 15
                    color: pill.fg

                    x: pill.hovered || pill.open ? pill.leftPad : (pill.idleW - width) / 2 + (media.playing ? 12 : 0)
                    y: (header.height - height) / 2

                    Behavior on x     { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation  { duration: 250; easing.type: Easing.OutBack } }
                }

                Text {
                    text: Qt.formatDate(clock.date, "MMM. d")
                    font.family: theme.font
                    font.pixelSize: 15
                    color: pill.fg

                    anchors.right: parent.right
                    anchors.rightMargin: 30
                    y: (header.height - height) / 2
                    opacity: pill.hovered || pill.open ? 1 : 0

                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Behavior on color   { ColorAnimation  { duration: 250; easing.type: Easing.OutBack } }
                }

                // small reactive music icon, only while something plays
                MusicOrb {
                    size: 20
                    x: 12
                    y: (header.height - height) / 2
                    accent: pill.fg
                    back: pill.bright ? theme.accent : theme.bg
                    artSource: media.player ? media.player.trackArtUrl : ""
                    active: media.playing
                    level: win.orbLevel
                    opacity: media.playing ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
            }

            // ---- open state, page 2: media player (MPRIS) ----
            Item {
                id: media
                anchors.top: header.bottom
                anchors.topMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                width: 308
                height: 212
                opacity: pill.open && pill.page === 1 ? 1 : 0
                visible: opacity > 0

                Behavior on opacity { NumberAnimation { duration: 200 } }

                // prefer whichever player is actually playing, else the first one
                readonly property var player: {
                    const list = Mpris.players.values
                    return list.find(p => p.playbackState === MprisPlaybackState.Playing) ?? list[0] ?? null
                }
                readonly property bool playing: player !== null
                                                && player.playbackState === MprisPlaybackState.Playing
                readonly property real progress: player !== null && player.length > 0
                                                 ? Math.min(1, player.position / player.length) : 0

                // position doesn't tick by itself, so nudge it once a second while playing
                Timer {
                    interval: 1000
                    repeat: true
                    running: media.playing && media.visible
                    onTriggered: media.player.positionChanged()
                }

                Text {
                    anchors.centerIn: parent
                    visible: media.player === null
                    text: "Nothing playing"
                    font.family: theme.font
                    font.pixelSize: 15
                    color: theme.accent
                    opacity: 0.6
                }

                Item {
                    anchors.fill: parent
                    visible: media.player !== null

                    MusicOrb {
                        size: 64
                        x: 14
                        y: 14
                        accent: theme.accent
                        back: theme.bg
                        artSource: media.player ? media.player.trackArtUrl : ""
                        active: media.playing
                        level: win.orbLevel
                    }

                    Text {
                        x: 104
                        y: 26
                        width: parent.width - 104
                        text: media.player ? media.player.trackTitle : ""
                        elide: Text.ElideRight
                        font.family: theme.font
                        font.pixelSize: 18
                        color: theme.accent
                    }

                    Text {
                        x: 104
                        y: 56
                        width: parent.width - 104
                        text: media.player ? media.player.trackArtist : ""
                        elide: Text.ElideRight
                        font.family: theme.font
                        font.pixelSize: 14
                        color: theme.accent
                        opacity: 0.6
                    }

                    // progress bar: faint track + solid fill
                    Rectangle {
                        id: bar
                        x: 8
                        y: 104
                        width: parent.width - 16
                        height: 4
                        radius: 2
                        color: theme.accent
                        opacity: 0.25
                    }
                    Rectangle {
                        x: bar.x
                        y: bar.y
                        height: 4
                        radius: 2
                        color: theme.accent
                        width: bar.width * media.progress
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 126
                        spacing: 24

                        Item {
                            width: 44
                            height: 56
                            Text {
                                anchors.centerIn: parent
                                text: "⏮"
                                font.pixelSize: 22
                                color: theme.accent
                                opacity: media.player && media.player.canGoPrevious ? 1 : 0.3
                            }
                            TapHandler {
                                onTapped: if (media.player && media.player.canGoPrevious) media.player.previous()
                            }
                        }

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 28
                            color: theme.accent
                            Text {
                                anchors.centerIn: parent
                                text: media.playing ? "⏸" : "▶"
                                font.pixelSize: 22
                                color: theme.bg
                            }
                            TapHandler {
                                onTapped: if (media.player) media.player.togglePlaying()
                            }
                        }

                        Item {
                            width: 44
                            height: 56
                            Text {
                                anchors.centerIn: parent
                                text: "⏭"
                                font.pixelSize: 22
                                color: theme.accent
                                opacity: media.player && media.player.canGoNext ? 1 : 0.3
                            }
                            TapHandler {
                                onTapped: if (media.player && media.player.canGoNext) media.player.next()
                            }
                        }
                    }
                }
            }

            // ---- page dots (open state only) ----
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                opacity: pill.open ? 1 : 0
                visible: opacity > 0

                Behavior on opacity { NumberAnimation { duration: 200 } }

                // previous page
                Item {
                    width: 28
                    height: 24
                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        font.family: theme.font
                        font.pixelSize: 20
                        color: theme.accent
                    }
                    TapHandler { onTapped: pill.page = (pill.page + pill.pageCount - 1) % pill.pageCount }
                }

                Repeater {
                    model: pill.pageCount
                    delegate: Item {
                        id: dotItem
                        required property int index
                        width: 24
                        height: 24

                        Rectangle {
                            anchors.centerIn: parent
                            width: 8
                            height: 8
                            radius: 4
                            color: theme.accent
                            opacity: pill.page === dotItem.index ? 1 : 0.3
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }
                        TapHandler { onTapped: pill.page = dotItem.index }
                    }
                }

                // next page
                Item {
                    width: 28
                    height: 24
                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        font.family: theme.font
                        font.pixelSize: 20
                        color: theme.accent
                    }
                    TapHandler { onTapped: pill.page = (pill.page + 1) % pill.pageCount }
                }
            }

            // ---- open state, page 1: custom month calendar ----
            Item {
                id: calendar
                anchors.top: header.bottom
                anchors.topMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                width: 308
                height: col.implicitHeight
                opacity: pill.open && pill.page === 0 ? 1 : 0
                visible: opacity > 0

                Behavior on opacity { NumberAnimation { duration: 200 } }

                // month being shown (0-based month, like JavaScript)
                property int viewYear: clock.date.getFullYear()
                property int viewMonth: clock.date.getMonth()

                // weekday of the 1st (0 = Sunday) and how many days the month has
                readonly property int firstDay: new Date(viewYear, viewMonth, 1).getDay()
                readonly property int daysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()

                function shift(delta) {
                    // new Date() normalizes overflow (month 12 -> next January)
                    const d = new Date(viewYear, viewMonth + delta, 1)
                    viewYear = d.getFullYear()
                    viewMonth = d.getMonth()
                }

                function jumpToToday() {
                    viewYear = clock.date.getFullYear()
                    viewMonth = clock.date.getMonth()
                }

                // always start on the current month when the pill opens
                Connections {
                    target: pill
                    function onOpenChanged() {
                        if (pill.open) calendar.jumpToToday()
                    }
                }

                Column {
                    id: col
                    width: parent.width
                    spacing: 4

                    // month navigation row
                    Item {
                        width: parent.width
                        height: 28

                        Item {
                            id: prev
                            anchors.left: parent.left
                            width: 36; height: parent.height
                            Text {
                                anchors.centerIn: parent
                                text: "‹"
                                font.family: theme.font
                                font.pixelSize: 22
                                color: theme.accent
                            }
                            TapHandler { onTapped: calendar.shift(-1) }
                        }

                        // tap the title to jump back to today's month
                        Item {
                            anchors.centerIn: parent
                            width: title.width + 16
                            height: parent.height
                            Text {
                                id: title
                                anchors.centerIn: parent
                                text: Qt.formatDate(new Date(calendar.viewYear, calendar.viewMonth, 1), "MMMM yyyy")
                                font.family: theme.font
                                font.pixelSize: 15
                                color: theme.accent
                            }
                            TapHandler { onTapped: calendar.jumpToToday() }
                        }

                        Item {
                            id: next
                            anchors.right: parent.right
                            width: 36; height: parent.height
                            Text {
                                anchors.centerIn: parent
                                text: "›"
                                font.family: theme.font
                                font.pixelSize: 22
                                color: theme.accent
                            }
                            TapHandler { onTapped: calendar.shift(1) }
                        }
                    }

                    // weekday labels
                    Row {
                        Repeater {
                            model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                            delegate: Text {
                                required property string modelData
                                width: 44
                                height: 20
                                text: modelData
                                horizontalAlignment: Text.AlignHCenter
                                font.family: theme.font
                                font.pixelSize: 12
                                color: theme.accent
                                opacity: 0.6
                            }
                        }
                    }

                    // 6 weeks x 7 days = 42 cells
                    Grid {
                        columns: 7

                        Repeater {
                            model: 42
                            delegate: Item {
                                id: cell
                                required property int index

                                // the real date this cell represents (spills into neighbouring months)
                                readonly property var d: new Date(calendar.viewYear, calendar.viewMonth, index - calendar.firstDay + 1)
                                readonly property bool inMonth: index >= calendar.firstDay
                                                                && index < calendar.firstDay + calendar.daysInMonth
                                readonly property bool isToday:
                                    d.getDate() === clock.date.getDate()
                                    && d.getMonth() === clock.date.getMonth()
                                    && d.getFullYear() === clock.date.getFullYear()

                                width: 44
                                height: 26

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 26; height: 26
                                    radius: width / 2
                                    color: theme.accent
                                    visible: cell.isToday
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: cell.d.getDate()
                                    font.family: theme.font
                                    font.pixelSize: 13
                                    color: cell.isToday ? theme.bg : theme.accent
                                    opacity: cell.inMonth ? 1 : 0.25
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
