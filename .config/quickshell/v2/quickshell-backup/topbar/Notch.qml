
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
// Notification state temporarily replaces the normal notch content.
//
// This is the MAIN NOTCH SHAPE only. It emits signals for the pieces that
// expand into their own separate panels (full media panel, weather panel,
// control center, etc) — those are built as separate files that hook into
// these signals rather than being implemented inline here.
// ============================================================================

PanelWindow {
    id: notchRoot

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-bar"

    anchors { top: true; left: true; right: true }
    color: "transparent"

    // Reserve real screen space equal to the CLOSED pill's height PLUS its
    // top gap (now that it floats instead of sitting flush against the
    // bezel), so other windows don't render underneath/behind it.
    exclusiveZone: 34

    // The window itself stays a CONSTANT height — tall enough to fit the
    // expanded shape PLUS its top gap (118), with a little headroom.
    // Only the inner Rectangle (`shape` below) animates its own
    // width/height within that fixed window.
    height: 120

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
    // Notifications
    // ------------------------------------------------------------------

    property var notifications: null

    readonly property var currentNotification:
        notifications
        ? notifications.currentNotification
        : null

    readonly property bool notificationVisible:
        currentNotification !== null

    // ------------------------------------------------------------------
    // Colors — reads the unified colors.json
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

    function c(key) {
        return (notchRoot.colors && notchRoot.colors[key])
            ? notchRoot.colors[key]
            : "#888888"
    }

    FileView {
        id: colorsFile

        path: Quickshell.env("HOME") +
              "/.config/quickshell/topbar/colors.json"

        watchChanges: true

        onLoaded: {
            try {
                var parsed = JSON.parse(text())
                notchRoot.colors = parsed
            } catch (e) {
                console.log(
                    "Notch: failed to parse colors.json, using fallback:",
                    e
                )
            }
        }

        onLoadFailed: (error) => {
            console.log(
                "Notch: colors.json load failed, using fallback:",
                error
            )
        }

        onFileChanged: reload()
    }

    // ------------------------------------------------------------------
    // Live clock
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
    // Live weather
    // ------------------------------------------------------------------

    property string location: "Locating…"
    property string weatherTemp: "--"
    property string weatherDesc: "--"
    property string weatherIcon: "󰖙"

    function weatherIconFor(desc) {
        var d = desc.toLowerCase()

        if (d.indexOf("thunder") !== -1)
            return "󰖓"

        if (d.indexOf("snow") !== -1)
            return "󰖘"

        if (
            d.indexOf("rain") !== -1 ||
            d.indexOf("drizzle") !== -1
        )
            return "󰖗"

        if (
            d.indexOf("cloud") !== -1 ||
            d.indexOf("overcast") !== -1
        )
            return "󰖐"

        if (
            d.indexOf("clear") !== -1 ||
            d.indexOf("sunny") !== -1
        )
            return "󰖙"

        return "󰖕"
    }

    Process {
        id: weatherProc

        command: [
            "bash",
            "-c",
            "curl -s 'wttr.in/?format=%l|%t|%C'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("|")

                if (parts.length === 3) {
                    notchRoot.location = parts[0].trim()
                    notchRoot.weatherTemp =
                        parts[1].replace("+", "").trim()
                    notchRoot.weatherDesc =
                        parts[2].trim()
                    notchRoot.weatherIcon =
                        notchRoot.weatherIconFor(parts[2])
                }
            }
        }
    }

    Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: weatherProc.running = true
    }

    // ------------------------------------------------------------------
    // Live media via Mpris
    // ------------------------------------------------------------------

    property var activePlayer:
        Mpris.players.values.length > 0
        ? Mpris.players.values[0]
        : null

    property bool isPlaying:
        activePlayer !== null &&
        activePlayer.playbackState === MprisPlaybackState.Playing

    property string trackTitle:
        activePlayer ? activePlayer.trackTitle : ""

    property string trackArtUrl:
        activePlayer ? activePlayer.trackArtUrl : ""

    property real trackPosition:
        activePlayer ? activePlayer.position : 0

    property real trackLength:
        (activePlayer && activePlayer.length > 0)
        ? activePlayer.length
        : 1

    function togglePlay() {
        if (activePlayer)
            activePlayer.togglePlaying()
    }

    function prevTrack() {
        if (activePlayer)
            activePlayer.previous()
    }

    function nextTrack() {
        if (activePlayer)
            activePlayer.next()
    }

    // ------------------------------------------------------------------
    // Mini calendar strip
    // ------------------------------------------------------------------

    function calendarDays() {
        var days = []
        var today = new Date(notchRoot.now)

        for (var i = -2; i <= 2; i++) {
            var d = new Date(today)
            d.setDate(today.getDate() + i)

            days.push({
                num: d.getDate(),
                isToday: i === 0
            })
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
        anchors.topMargin: 8

        width:
            notchRoot.notificationVisible
            ? 430
            : notchRoot.open
              ? (expandedRow.implicitWidth + 20)
              : 110

        height:
            notchRoot.notificationVisible
            ? 96
            : notchRoot.open
              ? 110
              : 30

        color: "#000000"
        antialiasing: true
        clip: true

        radius:
            notchRoot.notificationVisible
            ? 28
            : notchRoot.open
              ? 28
              : 20

        Behavior on width {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        // ================================================================
        // Notification state
        // ================================================================

        Item {
            id: notificationContent

            anchors.fill: parent
            visible: notchRoot.notificationVisible
            opacity: visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }

            // Notification icon
            Rectangle {
                id: notificationIcon

                width: 58
                height: 58

                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                radius: width / 2
                color: notchRoot.c("accent")

                Text {
                    anchors.centerIn: parent

                    text:
                        notchRoot.currentNotification &&
                        notchRoot.currentNotification.summary
                        ? notchRoot.currentNotification
                            .summary
                            .charAt(0)
                            .toUpperCase()
                        : "󰂚"

                    color: notchRoot.c("bg")
                    font.pixelSize: 25
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // Notification text
            ColumnLayout {
                anchors.left: notificationIcon.right
                anchors.leftMargin: 14
                anchors.right: notificationClose.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                spacing: 2

                Text {
                    Layout.fillWidth: true

                    text:
                        notchRoot.currentNotification &&
                        notchRoot.currentNotification.appName
                        ? notchRoot.currentNotification.appName
                        : "Notification"

                    color: notchRoot.c("sub")
                    font.pixelSize: 10
                    font.family: "JetBrainsMono Nerd Font"

                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true

                    text:
                        notchRoot.currentNotification &&
                        notchRoot.currentNotification.summary
                        ? notchRoot.currentNotification.summary
                        : ""

                    color: "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"

                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true

                    text:
                        notchRoot.currentNotification &&
                        notchRoot.currentNotification.body
                        ? notchRoot.currentNotification.body
                        : ""

                    color: notchRoot.c("sub")
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"

                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
            }

            // Dismiss button
            Text {
                id: notificationClose

                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter

                text: "󰅖"
                color: notchRoot.c("sub")
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (notchRoot.notifications)
                            notchRoot.notifications.dismissCurrent()
                    }
                }
            }
        }

        // ================================================================
        // Hover opens/closes the normal notch
        // ================================================================

        HoverHandler {
            enabled: !notchRoot.notificationVisible

            onHoveredChanged: {
                notchRoot.open = hovered
            }
        }

        // ================================================================
        // CLOSED STATE
        // ================================================================

        Text {
            anchors.centerIn: parent

            visible:
                !notchRoot.open &&
                !notchRoot.notificationVisible

            text: notchRoot.timeStr
            color: notchRoot.c("text")
            font.pixelSize: 17
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }

        // ================================================================
        // EXPANDED STATE
        // ================================================================

        RowLayout {
            id: expandedRow

            anchors.fill: parent
            anchors.margins: 10

            spacing: 14

            visible:
                notchRoot.open &&
                !notchRoot.notificationVisible

            opacity:
                notchRoot.open &&
                !notchRoot.notificationVisible
                ? 1
                : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }

            // ----- Media mini-widget -----

            Rectangle {
                id: mediaBox

                Layout.preferredWidth: 190
                Layout.fillHeight: true

                radius: 18
                color: notchRoot.c("surface")

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

                    Image {
                        id: artImg

                        anchors.fill: parent

                        source:
                            notchRoot.trackArtUrl.length > 0
                            ? notchRoot.trackArtUrl
                            : ""

                        fillMode: Image.PreserveAspectCrop
                        visible: false
                        asynchronous: true
                    }

                    FastBlur {
                        anchors.fill: parent

                        source: artImg
                        radius: 48

                        visible:
                            notchRoot.trackArtUrl.length > 0
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(0, 0, 0, 0.35)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1

                    cursorShape: Qt.PointingHandCursor

                    onClicked:
                        notchRoot.mediaExpandRequested()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    spacing: 6

                    Text {
                        Layout.fillWidth: true

                        text:
                            notchRoot.trackTitle.length > 0
                            ? notchRoot.trackTitle
                            : "Not playing"

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

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    notchRoot.prevTrack()
                            }
                        }

                        Text {
                            text:
                                notchRoot.isPlaying
                                ? "󰏤"
                                : "󰐊"

                            color: "#ffffff"
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    notchRoot.togglePlay()
                            }
                        }

                        Text {
                            text: "󰒭"
                            color: "#ffffff"
                            font.pixelSize: 17
                            font.family: "JetBrainsMono Nerd Font"

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    notchRoot.nextTrack()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        height: 3
                        radius: 2

                        color:
                            Qt.rgba(1, 1, 1, 0.25)

                        Rectangle {
                            width:
                                parent.width *
                                Math.min(
                                    1,
                                    notchRoot.trackPosition /
                                    notchRoot.trackLength
                                )

                            height: parent.height
                            radius: 2

                            color: notchRoot.c("accent")

                            Behavior on width {
                                NumberAnimation {
                                    duration: 400
                                }
                            }
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

                    Text {
                        text: notchRoot.weatherIcon
                        font.pixelSize: 18
                        color: notchRoot.c("text")
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: notchRoot.weatherTemp
                        font.pixelSize: 16
                        color: notchRoot.c("text")
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        text: notchRoot.weatherDesc
                        font.pixelSize: 13
                        color: notchRoot.c("sub")
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                Text {
                    text:
                        Qt.formatDate(
                            notchRoot.now,
                            "ddd d"
                        )

                    font.pixelSize: 13
                    color: notchRoot.c("sub")
                    font.family: "JetBrainsMono Nerd Font"
                }

                RowLayout {
                    spacing: 4

                    Repeater {
                        model: notchRoot.calendarDays()

                        Rectangle {
                            width: 20
                            height: 22

                            radius: 7

                            color:
                                modelData.isToday
                                ? "#FF5000"
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: modelData.num

                                font.pixelSize: 11

                                color:
                                    modelData.isToday
                                    ? notchRoot.c("bg")
                                    : notchRoot.c("sub")

                                font.family:
                                    "JetBrainsMono Nerd Font"
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

            // ----- Weather expand arrow -----

            Text {
                Layout.alignment: Qt.AlignVCenter

                text: "󰅂"

                font.pixelSize: 20
                color: notchRoot.c("sub")
                font.family: "JetBrainsMono Nerd Font"

                MouseArea {
                    anchors.fill: parent

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        notchRoot.weatherExpandRequested()
                }
            }

            // ----- Control center button -----

            Text {
                Layout.alignment: Qt.AlignVCenter

                text: "\u2699"

                font.pixelSize: 16
                color: notchRoot.c("sub")
                font.family: "JetBrainsMono Nerd Font"

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        notchRoot.controlCenterRequested()
                }
            }
        }
    }

    // ====================================================================
    // Notification state tracking
    // ====================================================================

    Connections {
        target: notchRoot.notifications

        function onCurrentNotificationChanged() {
            if (notchRoot.currentNotification) {
                notchRoot.open = false
            }
        }
    }
}

