
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications

// ============================================================================
// ControlCenter.qml — Separate floating control-center pill
// ============================================================================

PanelWindow {
    id: panelRoot

    // ========================================================================
    // DYNAMIC COLOR PALETTE
    // ========================================================================

    property var colors: ({
        bg: "#1e1e2e",
        surface: "#313244",
        accent: "#89b4fa",
        text: "#cdd6f4",
        sub: "#a6adc8"
    })

    FileView {
        id: colorsLoadercc

        path:
            Quickshell.env("HOME") +
            "/.config/quickshell/topbar/colors.json"

        watchChanges: true

        onLoaded: {
            try {
                var parsed = JSON.parse(text)
                panelRoot.colors = parsed
            } catch (e) {
                console.log(
                    "ControlCenter: failed to parse colors.json:",
                    e
                )
            }
        }

        onLoadFailed: {
            console.log(
                "ControlCenter: colors.json fallback used:",
                error
            )
        }

        onFileChanged: reload()
    }

    function c(key) {
        return (
            panelRoot.colors &&
            panelRoot.colors[key]
        )
            ? panelRoot.colors[key]
            : "#888888"
    }

    readonly property color colorBg: c("bg")
    readonly property color colorSurface: c("surface")
    readonly property color colorAccent: c("accent")
    readonly property color colorText: c("text")
    readonly property color colorSub: c("sub")
    readonly property color colorAccentText: c("bg")
    readonly property color colorInactive: c("surface")
    readonly property color colorBorder: c("sub")

    // ========================================================================
    // STATE
    // ========================================================================

    property bool open: false
    property string view: "main"

    WlrLayershell.layer:
        WlrLayer.Overlay

    WlrLayershell.namespace:
        "qs-control-center"

    WlrLayershell.keyboardFocus:
        panelRoot.open
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

    // FLOATING WINDOW
    anchors {
        top: true
    }

    margins.top: 10

    implicitWidth: 420
    implicitHeight:
        panelRoot.open
            ? (
                panelRoot.view === "main"
                    ? 660
                    : 300
              )
            : 0

    color: "transparent"
    exclusiveZone: -1
    visible: panelRoot.open

    // ========================================================================
    // WI-FI
    // ========================================================================

    property bool wifiEnabled: false
    property string wifiSsid: ""
    property var wifiNetworks: []
    property string wifiPendingSsid: ""

    Process {
        id: wifiStatusProc

        command: [
            "bash",
            "-c",
            "nmcli radio wifi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                panelRoot.wifiEnabled =
                    text.trim() === "enabled"
            }
        }
    }

    Process {
        id: wifiSsidProc

        command: [
            "bash",
            "-c",
            "nmcli -t -f active,ssid dev wifi list 2>/dev/null | " +
            "grep '^yes:' | head -1 | cut -d: -f2"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                panelRoot.wifiSsid =
                    text.trim()
            }
        }
    }

    function toggleWifi() {
        var cmd =
            panelRoot.wifiEnabled
                ? "off"
                : "on"

        wifiToggleProc.command = [
            "bash",
            "-c",
            "nmcli radio wifi " + cmd
        ]

        wifiToggleProc.running = true

        panelRoot.wifiEnabled =
            !panelRoot.wifiEnabled
    }

    Process {
        id: wifiToggleProc
    }

    function refreshWifiList() {
        wifiListProc.command = [
            "bash",
            "-c",
            "nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE device wifi list"
        ]

        wifiListProc.running = true
    }

    Process {
        id: wifiListProc

        stdout: StdioCollector {
            onStreamFinished: {
                var lines =
                    text.trim().split("\n")

                var nets = []
                var seen = {}

                for (var i = 0; i < lines.length; i++) {
                    var parts =
                        lines[i].split(":")

                    if (parts.length < 4)
                        continue

                    var ssid =
                        parts[0]

                    if (
                        ssid.length === 0 ||
                        seen[ssid]
                    )
                        continue

                    seen[ssid] = true

                    nets.push({
                        ssid: ssid,
                        signal:
                            parseInt(
                                parts[1],
                                10
                            ) || 0,
                        secured:
                            parts[2].length > 0 &&
                            parts[2] !== "--",
                        connected:
                            parts[3] === "*",
                        connecting: false
                    })
                }

                nets.sort(
                    function(a, b) {
                        return b.signal - a.signal
                    }
                )

                panelRoot.wifiNetworks =
                    nets
            }
        }
    }

    function connectToWifi(ssid, password) {
        var idx =
            panelRoot.wifiNetworks.findIndex(
                function(n) {
                    return n.ssid === ssid
                }
            )

        if (idx >= 0) {
            var updated =
                panelRoot.wifiNetworks.slice()

            updated[idx] =
                Object.assign(
                    {},
                    updated[idx],
                    {
                        connecting: true
                    }
                )

            panelRoot.wifiNetworks =
                updated
        }

        var cmd =
            password
                ? "nmcli device wifi connect \"" +
                  ssid +
                  "\" password \"" +
                  password +
                  "\""
                : "nmcli device wifi connect \"" +
                  ssid +
                  "\""

        wifiConnectProc.command = [
            "bash",
            "-c",
            cmd
        ]

        wifiConnectProc.running = true
    }

    Process {
        id: wifiConnectProc

        stdout: StdioCollector {
            onStreamFinished:
                panelRoot.refreshWifiList()
        }

        stderr: StdioCollector {
            onStreamFinished:
                panelRoot.refreshWifiList()
        }
    }

    function onWifiRowClicked(net) {
        if (net.connected)
            return

        if (net.secured) {
            panelRoot.wifiPendingSsid =
                net.ssid

            wifiPopup.visible =
                true

            wifiPasswordField.text =
                ""

            wifiPasswordField.forceActiveFocus()
        } else {
            panelRoot.connectToWifi(
                net.ssid,
                ""
            )
        }
    }

    // ========================================================================
    // BLUETOOTH
    // ========================================================================

    property bool bluetoothEnabled: false
    property var bluetoothDevices: []

    Process {
        id: bluetoothStatusProc

        command: [
            "bash",
            "-c",
            "bluetoothctl show | grep -q 'Powered: yes' && " +
            "echo on || echo off"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                panelRoot.bluetoothEnabled =
                    text.trim() === "on"
            }
        }
    }

    function toggleBluetooth() {
        var cmd =
            panelRoot.bluetoothEnabled
                ? "off"
                : "on"

        btToggleProc.command = [
            "bash",
            "-c",
            "bluetoothctl power " + cmd
        ]

        btToggleProc.running = true

        panelRoot.bluetoothEnabled =
            !panelRoot.bluetoothEnabled
    }

    Process {
        id: btToggleProc
    }

    function refreshBluetoothList() {
        btListProc.command = [
            "bash",
            "-c",
            "bluetoothctl devices | " +
            "while read -r _ mac name; do " +
            "connected=$(bluetoothctl info \"$mac\" | " +
            "grep -q 'Connected: yes' && echo yes || echo no); " +
            "echo \"$mac|$name|$connected\"; " +
            "done"
        ]

        btListProc.running = true
    }

    Process {
        id: btListProc

        stdout: StdioCollector {
            onStreamFinished: {
                var lines =
                    text.trim().split("\n")

                var devs = []

                for (
                    var i = 0;
                    i < lines.length;
                    i++
                ) {
                    if (
                        lines[i].length === 0
                    )
                        continue

                    var parts =
                        lines[i].split("|")

                    if (parts.length < 3)
                        continue

                    devs.push({
                        mac: parts[0],
                        name: parts[1],
                        connected:
                            parts[2] === "yes",
                        connecting: false
                    })
                }

                panelRoot.bluetoothDevices =
                    devs
            }
        }
    }

    function connectToBluetooth(mac) {
        var idx =
            panelRoot.bluetoothDevices.findIndex(
                function(d) {
                    return d.mac === mac
                }
            )

        if (idx >= 0) {
            var updated =
                panelRoot.bluetoothDevices.slice()

            updated[idx] =
                Object.assign(
                    {},
                    updated[idx],
                    {
                        connecting: true
                    }
                )

            panelRoot.bluetoothDevices =
                updated
        }

        btConnectProc.command = [
            "bash",
            "-c",
            "bluetoothctl connect " + mac
        ]

        btConnectProc.running = true
    }

    Process {
        id: btConnectProc

        stdout: StdioCollector {
            onStreamFinished:
                panelRoot.refreshBluetoothList()
        }

        stderr: StdioCollector {
            onStreamFinished:
                panelRoot.refreshBluetoothList()
        }
    }

    // ========================================================================
    // FOCUS
    // ========================================================================

    property bool focusEnabled: false

    function toggleFocus() {
        var cmd =
            panelRoot.focusEnabled
                ? "dunstctl set-paused false"
                : "dunstctl set-paused true"

        focusProc.command = [
            "bash",
            "-c",
            cmd
        ]

        focusProc.running = true

        panelRoot.focusEnabled =
            !panelRoot.focusEnabled
    }

    Process {
        id: focusProc
    }

    // ========================================================================
    // GAME MODE
    // ========================================================================

    property bool gameModeEnabled: false

    function toggleGameMode() {
        var cmd =
            panelRoot.gameModeEnabled
                ? "bash " +
                  Quickshell.env("HOME") +
                  "/.config/hypr/scripts/game-mode.sh off"
                : "bash " +
                  Quickshell.env("HOME") +
                  "/.config/hypr/scripts/game-mode.sh on"

        gameModeProc.command = [
            "bash",
            "-c",
            cmd
        ]

        gameModeProc.running = true

        panelRoot.gameModeEnabled =
            !panelRoot.gameModeEnabled
    }

    Process {
        id: gameModeProc
    }

    // ========================================================================
    // NIGHT LIGHT
    // ========================================================================

    property bool nightLightEnabled: false

    function toggleNightLight() {
        var cmd =
            panelRoot.nightLightEnabled
                ? "bash " +
                  Quickshell.env("HOME") +
                  "/.config/hypr/scripts/night-light.sh off"
                : "bash " +
                  Quickshell.env("HOME") +
                  "/.config/hypr/scripts/night-light.sh on"

        nightLightProc.command = [
            "bash",
            "-c",
            cmd
        ]

        nightLightProc.running = true

        panelRoot.nightLightEnabled =
            !panelRoot.nightLightEnabled
    }

    Process {
        id: nightLightProc
    }

    // ========================================================================
    // LOCK
    // ========================================================================

    function lockScreen() {
        lockProc.command = [
            "bash",
            Quickshell.env("HOME") +
            "/.config/hypr/scripts/lock.sh"
        ]

        lockProc.running = true

        panelRoot.open = false
    }

    Process {
        id: lockProc
    }

    // ========================================================================
    // BRIGHTNESS / VOLUME
    // ========================================================================

    property real brightness: 0.7
    property real volume: 0.5
    property bool muted: false

    Process {
        id: brightnessGetProc

        command: [
            "bash",
            "-c",
            "brightnessctl -m | " +
            "awk -F, '{print $4}' | tr -d '%'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var v =
                    parseFloat(
                        text.trim()
                    )

                if (!isNaN(v))
                    panelRoot.brightness =
                        v / 100
            }
        }
    }

    function setBrightness(fraction) {
        panelRoot.brightness =
            fraction

        brightnessSetProc.command = [
            "bash",
            "-c",
            "brightnessctl set " +
            Math.round(
                fraction * 100
            ) +
            "%"
        ]

        brightnessSetProc.running =
            true
    }

    Process {
        id: brightnessSetProc
    }

    Process {
        id: volumeGetProc

        command: [
            "bash",
            "-c",
            "wpctl get-volume @DEFAULT_AUDIO_SINK@"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var m =
                    text.match(
                        /Volume:\s*([\d.]+)/
                    )

                if (m)
                    panelRoot.volume =
                        parseFloat(m[1])

                panelRoot.muted =
                    text.indexOf(
                        "MUTED"
                    ) !== -1
            }
        }
    }

    function setVolume(fraction) {
        panelRoot.volume =
            fraction

        volumeSetProc.command = [
            "bash",
            "-c",
            "wpctl set-volume " +
            "@DEFAULT_AUDIO_SINK@ " +
            fraction.toFixed(2)
        ]

        volumeSetProc.running =
            true
    }

    Process {
        id: volumeSetProc
    }

    Process {
        id: openAppProc
    }

    function openSoundSettings() {
        openAppProc.command = [
            "bash",
            "-c",
            "pavucontrol &"
        ]

        openAppProc.running = true
    }

    function openDisplaySettings() {
        openAppProc.command = [
            "bash",
            "-c",
            "nwg-displays &"
        ]

        openAppProc.running = true
    }

    // ========================================================================
    // NOTIFICATIONS
    // ========================================================================

    property var notificationList: []

    NotificationServer {
        id: notifServer

        onNotification: (notification) => {
            if (!notification)
                return

            notification.tracked =
                true

            var entry = {
                id: notification.id,
                appName:
                    notification.appName ||
                    "Notification",
                summary:
                    notification.summary || "",
                body:
                    notification.body || "",
                ref:
                    notification
            }

            panelRoot.notificationList =
                [entry].concat(
                    panelRoot.notificationList
                )
        }
    }

    function dismissNotification(entry) {
        if (
            entry.ref &&
            typeof entry.ref.dismiss ===
                "function"
        ) {
            entry.ref.dismiss()
        }

        panelRoot.notificationList =
            panelRoot.notificationList.filter(
                function(n) {
                    return n.id !== entry.id
                }
            )
    }

    function clearAllNotifications() {
        for (
            var i = 0;
            i < panelRoot.notificationList.length;
            i++
        ) {
            var n =
                panelRoot.notificationList[i]

            if (
                n.ref &&
                typeof n.ref.dismiss ===
                    "function"
            ) {
                n.ref.dismiss()
            }
        }

        panelRoot.notificationList = []
    }

    // ========================================================================
    // MAIN FLOATING PILL
    // ========================================================================

    Rectangle {
        id: card

        anchors.horizontalCenter:
            parent.horizontalCenter

        //anchors.top:
          //  parent.top

        //anchors.topMargin:
        //    0

        width:
            420

        height:
            panelRoot.open
                ? (
                    panelRoot.view === "main"
                        ? 640
                        : 280
                  )
                : 0

        radius:
            34

        color:
            "#000000"

        border.width:
            1

        border.color:
            Qt.rgba(
                panelRoot.colorText.r,
                panelRoot.colorText.g,
                panelRoot.colorText.b,
                0.08
            )

        clip:
            true

        antialiasing:
            true

        Behavior on height {
            NumberAnimation {
                duration:
                    240

                easing.type:
                    Easing.OutCubic
            }
        }

        // ====================================================================
        // CLOSE BUTTON
        // ====================================================================

        Text {
            anchors.top:
                parent.top

            anchors.right:
                parent.right

            anchors.topMargin:
                18

            anchors.rightMargin:
                20

            z:
                20

            text:
                "\uf00d"

            color:
                panelRoot.colorSub

            font.pixelSize:
                15

            font.family:
                "JetBrainsMono Nerd Font"

            MouseArea {
                anchors.fill:
                    parent

                anchors.margins:
                    -8

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    panelRoot.open =
                        false
                }
            }
        }

        // ====================================================================
        // MAIN VIEW
        // ====================================================================

        ColumnLayout {
            anchors.fill:
                parent

            anchors.margins:
                20

            spacing:
                14

            visible:
                panelRoot.view === "main"

            RowLayout {
                Layout.fillWidth:
                    true

                spacing:
                    10

                ControlTile {
                    Layout.fillWidth:
                        true

                    Layout.preferredWidth:
                        2

                    iconGlyph:
                        "󰖩"

                    title:
                        "Wi-Fi"

                    subtitle:
                        panelRoot.wifiEnabled
                            ? (
                                panelRoot.wifiSsid.length > 0
                                    ? panelRoot.wifiSsid
                                    : "On"
                              )
                            : "Off"

                    active:
                        panelRoot.wifiEnabled

                    accentColor:
                        panelRoot.colorAccent

                    onToggleClicked:
                        panelRoot.toggleWifi()

                    onTileClicked: {
                        panelRoot.refreshWifiList()
                        panelRoot.view = "wifi"
                    }
                }

                ControlTile {
                    Layout.fillWidth:
                        true

                    Layout.preferredWidth:
                        2

                    iconGlyph:
                        "󰸞"

                    title:
                        "Focus"

                    subtitle:
                        panelRoot.focusEnabled
                            ? "On"
                            : "Off"

                    active:
                        panelRoot.focusEnabled

                    accentColor:
                        panelRoot.colorAccent

                    onToggleClicked:
                        panelRoot.toggleFocus()

                    onTileClicked:
                        panelRoot.toggleFocus()
                }

                Rectangle {
                    Layout.preferredWidth:
                        64

                    Layout.preferredHeight:
                        64

                    radius:
                        32

                    color:
                        panelRoot.colorInactive

                    Text {
                        anchors.centerIn:
                            parent

                        text:
                            "󰌾"

                        color:
                            panelRoot.colorText

                        font.pixelSize:
                            20

                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        anchors.fill:
                            parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            panelRoot.lockScreen()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth:
                    true

                spacing:
                    10

                ControlTile {
                    Layout.fillWidth:
                        true

                    Layout.preferredWidth:
                        2

                    iconGlyph:
                        "󰂯"

                    title:
                        "Bluetooth"

                    subtitle:
                        panelRoot.bluetoothEnabled
                            ? "On"
                            : "Off"

                    active:
                        panelRoot.bluetoothEnabled

                    accentColor:
                        panelRoot.colorAccent

                    onToggleClicked:
                        panelRoot.toggleBluetooth()

                    onTileClicked: {
                        panelRoot.refreshBluetoothList()
                        panelRoot.view = "bluetooth"
                    }
                }

                ControlTile {
                    Layout.fillWidth:
                        true

                    Layout.preferredWidth:
                        2

                    iconGlyph:
                        "󰔑"

                    title:
                        "Game Mode"

                    subtitle:
                        panelRoot.gameModeEnabled
                            ? "On"
                            : "Off"

                    active:
                        panelRoot.gameModeEnabled

                    accentColor:
                        panelRoot.colorAccent

                    onToggleClicked:
                        panelRoot.toggleGameMode()

                    onTileClicked:
                        panelRoot.toggleGameMode()
                }

                Rectangle {
                    Layout.preferredWidth:
                        64

                    Layout.preferredHeight:
                        64

                    radius:
                        32

                    color:
                        panelRoot.nightLightEnabled
                            ? panelRoot.colorAccent
                            : panelRoot.colorInactive

                    Behavior on color {
                        ColorAnimation {
                            duration:
                                150
                        }
                    }

                    Text {
                        anchors.centerIn:
                            parent

                        text:
                            "󰖔"

                        color:
                            panelRoot.nightLightEnabled
                                ? panelRoot.colorAccentText
                                : panelRoot.colorText

                        font.pixelSize:
                            20

                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        anchors.fill:
                            parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            panelRoot.toggleNightLight()
                    }
                }
            }

            // =================================================================
            // SOUND
            // =================================================================

            ColumnLayout {
                Layout.fillWidth:
                    true

                spacing:
                    6

                RowLayout {
                    Layout.fillWidth:
                        true

                    Text {
                        text:
                            "Sound"

                        color:
                            panelRoot.colorText

                        font.pixelSize:
                            13

                        font.bold:
                            true

                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    Item {
                        Layout.fillWidth:
                            true
                    }

                    Text {
                        text:
                            "\u203a"

                        color:
                            panelRoot.colorSub

                        font.pixelSize:
                            16

                        MouseArea {
                            anchors.fill:
                                parent

                            anchors.margins:
                                -8

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                panelRoot.openSoundSettings()
                        }
                    }
                }

                Rectangle {
                    id: volTrack

                    Layout.fillWidth:
                        true

                    Layout.preferredHeight:
                        40

                    radius:
                        20

                    color:
                        panelRoot.colorSurface

                    clip:
                        true

                    Rectangle {
                        width:
                            parent.width *
                            Math.min(
                                1,
                                panelRoot.volume
                            )

                        height:
                            parent.height

                        radius:
                            20

                        color:
                            panelRoot.colorAccent

                        Behavior on width {
                            NumberAnimation {
                                duration:
                                    150
                            }
                        }
                    }

                    Text {
                        anchors.left:
                            parent.left

                        anchors.verticalCenter:
                            parent.verticalCenter

                        anchors.leftMargin:
                            14

                        text:
                            panelRoot.muted
                                ? "󰖁"
                                : "󰕾"

                        color:
                            panelRoot.colorAccentText

                        font.pixelSize:
                            16

                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        id: volArea

                        anchors.fill:
                            parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: (mouse) => {
                            panelRoot.setVolume(
                                Math.max(
                                    0,
                                    Math.min(
                                        1,
                                        mouse.x /
                                        volArea.width
                                    )
                                )
                            )
                        }
                    }
                }
            }

            // =================================================================
            // DISPLAY
            // =================================================================

            ColumnLayout {
                Layout.fillWidth:
                    true

                spacing:
                    6

                RowLayout {
                    Layout.fillWidth:
                        true

                    Text {
                        text:
                            "Display"

                        color:
                            panelRoot.colorText

                        font.pixelSize:
                            13

                        font.bold:
                            true

                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    Item {
                        Layout.fillWidth:
                            true
                    }

                    Text {
                        text:
                            "\u203a"

                        color:
                            panelRoot.colorSub

                        font.pixelSize:
                            16

                        MouseArea {
                            anchors.fill:
                                parent

                            anchors.margins:
                                -8

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                panelRoot.openDisplaySettings()
                        }
                    }
                }

                Rectangle {
                    id: brightTrack

                    Layout.fillWidth:
                        true

                    Layout.preferredHeight:
                        40

                    radius:
                        20

                    color:
                        panelRoot.colorSurface

                    clip:
                        true

                    Rectangle {
                        width:
                            parent.width *
                            panelRoot.brightness

                        height:
                            parent.height

                        radius:
                            20

                        color:
                            panelRoot.colorAccent

                        Behavior on width {
                            NumberAnimation {
                                duration:
                                    150
                            }
                        }
                    }

                    Text {
                        anchors.left:
                            parent.left

                        anchors.verticalCenter:
                            parent.verticalCenter

                        anchors.leftMargin:
                            14

                        text:
                            "󰃛"

                        color:
                            panelRoot.colorAccentText

                        font.pixelSize:
                            16

                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        id: brightArea

                        anchors.fill:
                            parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: (mouse) => {
                            panelRoot.setBrightness(
                                Math.max(
                                    0,
                                    Math.min(
                                        1,
                                        mouse.x /
                                        brightArea.width
                                    )
                                )
                            )
                        }
                    }
                }
            }

            // =================================================================
            // NOTIFICATIONS
            // =================================================================

            ColumnLayout {
                Layout.fillWidth:
                    true

                Layout.fillHeight:
                    true

                spacing:
                    8

                RowLayout {
                    Layout.fillWidth:
                        true

                    Text {
                        text:
                            "Notifications"

                        color:
                            panelRoot.colorSub

                        font.pixelSize:
                            12

                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    Item {
                        Layout.fillWidth:
                            true
                    }

                    Text {
                        text:
                            "Clear all"

                        color:
                            panelRoot.colorAccent

                        font.pixelSize:
                            12

                        font.family:
                            "JetBrainsMono Nerd Font"

                        MouseArea {
                            anchors.fill:
                                parent

                            anchors.margins:
                                -6

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                panelRoot.clearAllNotifications()
                        }
                    }
                }

                ListView {
                    Layout.fillWidth:
                        true

                    Layout.fillHeight:
                        true

                    clip:
                        true

                    spacing:
                        8

                    model:
                        panelRoot.notificationList

                    delegate: Rectangle {
                        width:
                            ListView.view.width

                        height:
                            notifCol.implicitHeight +
                            24

                        radius:
                            16

                        color:
                            panelRoot.colorSurface

                        RowLayout {
                            id: notifRow

                            anchors.fill:
                                parent

                            anchors.margins:
                                12

                            spacing:
                                10

                            Rectangle {
                                Layout.preferredWidth:
                                    36

                                Layout.preferredHeight:
                                    36

                                radius:
                                    18

                                color:
                                    panelRoot.colorAccent

                                Text {
                                    anchors.centerIn:
                                        parent

                                    text:
                                        modelData.appName.length > 0
                                            ? modelData.appName[0]
                                                .toUpperCase()
                                            : "?"

                                    color:
                                        panelRoot.colorAccentText

                                    font.pixelSize:
                                        14

                                    font.bold:
                                        true

                                    font.family:
                                        "JetBrainsMono Nerd Font"
                                }
                            }

                            ColumnLayout {
                                id: notifCol

                                Layout.fillWidth:
                                    true

                                spacing:
                                    1

                                Text {
                                    Layout.fillWidth:
                                        true

                                    text:
                                        modelData.appName

                                    color:
                                        panelRoot.colorSub

                                    font.pixelSize:
                                        10

                                    font.family:
                                        "JetBrainsMono Nerd Font"
                                }

                                Text {
                                    Layout.fillWidth:
                                        true

                                    text:
                                        modelData.summary

                                    color:
                                        panelRoot.colorText

                                    font.pixelSize:
                                        13

                                    font.bold:
                                        true

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    elide:
                                        Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth:
                                        true

                                    visible:
                                        modelData.body.length > 0

                                    text:
                                        modelData.body

                                    color:
                                        panelRoot.colorSub

                                    font.pixelSize:
                                        11

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    elide:
                                        Text.ElideRight

                                    wrapMode:
                                        Text.WordWrap

                                    maximumLineCount:
                                        2
                                }
                            }

                            Text {
                                text:
                                    "\uf00d"

                                color:
                                    panelRoot.colorSub

                                font.pixelSize:
                                    13

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                MouseArea {
                                    anchors.fill:
                                        parent

                                    anchors.margins:
                                        -8

                                    cursorShape:
                                        Qt.PointingHandCursor

                                    onClicked:
                                        panelRoot.dismissNotification(
                                            modelData
                                        )
                                }
                            }
                        }
                    }
                }
            }
        }

        // ====================================================================
        // WI-FI SUB-VIEW
        // ====================================================================

        ColumnLayout {
            anchors.fill:
                parent

            anchors.margins:
                20

            spacing:
                12

            visible:
                panelRoot.view === "wifi"

            RowLayout {
                Layout.fillWidth:
                    true

                Text {
                    text:
                        "\u2039 Wi-Fi"

                    color:
                        panelRoot.colorText

                    font.pixelSize:
                        15

                    font.bold:
                        true

                    font.family:
                        "JetBrainsMono Nerd Font"

                    MouseArea {
                        anchors.fill:
                            parent

                        anchors.margins:
                            -8

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            panelRoot.view =
                                "main"
                    }
                }

                Item {
                    Layout.fillWidth:
                        true
                }

                Text {
                    text:
                        "\u21bb"

                    color:
                        panelRoot.colorSub

                    font.pixelSize:
                        15

                    MouseArea {
                        anchors.fill:
                            parent

                        anchors.margins:
                            -8

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            panelRoot.refreshWifiList()
                    }
                }
            }

            ScrollView {
                Layout.fillWidth:
                    true

                Layout.fillHeight:
                    true

                clip:
                    true

                ColumnLayout {
                    width:
                        parent.width

                    spacing:
                        6

                    Repeater {
                        model:
                            panelRoot.wifiNetworks

                        Rectangle {
                            Layout.fillWidth:
                                true

                            Layout.preferredHeight:
                                modelData.connected
                                    ? 56
                                    : 48

                            radius:
                                12

                            color:
                                modelData.connected
                                    ? panelRoot.colorAccent
                                    : panelRoot.colorSurface

                            Behavior on Layout.preferredHeight {
                                NumberAnimation {
                                    duration:
                                        150
                                }
                            }

                            RowLayout {
                                anchors.fill:
                                    parent

                                anchors.margins:
                                    10

                                spacing:
                                    8

                                Text {
                                    Layout.fillWidth:
                                        true

                                    text:
                                        modelData.ssid +
                                        (
                                            modelData.secured
                                                ? "  󰯅"
                                                : ""
                                        )

                                    color:
                                        modelData.connected
                                            ? panelRoot.colorAccentText
                                            : panelRoot.colorText

                                    font.pixelSize:
                                        modelData.connected
                                            ? 14
                                            : 12

                                    font.bold:
                                        modelData.connected

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    elide:
                                        Text.ElideRight
                                }

                                Text {
                                    visible:
                                        modelData.connecting

                                    text:
                                        "\u21bb"

                                    color:
                                        modelData.connected
                                            ? panelRoot.colorAccentText
                                            : panelRoot.colorText

                                    font.pixelSize:
                                        14

                                    RotationAnimation on rotation {
                                        running:
                                            modelData.connecting

                                        loops:
                                            Animation.Infinite

                                        from:
                                            0

                                        to:
                                            360

                                        duration:
                                            900
                                    }
                                }

                                Text {
                                    visible:
                                        modelData.connected &&
                                        !modelData.connecting

                                    text:
                                        "\u2713"

                                    color:
                                        panelRoot.colorAccentText

                                    font.pixelSize:
                                        14

                                    font.bold:
                                        true
                                }
                            }

                            MouseArea {
                                anchors.fill:
                                    parent

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    panelRoot.onWifiRowClicked(
                                        modelData
                                    )
                            }
                        }
                    }
                }
            }
        }

        // ====================================================================
        // BLUETOOTH SUB-VIEW
        // ====================================================================

        ColumnLayout {
            anchors.fill:
                parent

            anchors.margins:
                20

            spacing:
                12

            visible:
                panelRoot.view === "bluetooth"

            RowLayout {
                Layout.fillWidth:
                    true

                Text {
                    text:
                        "\u2039 Bluetooth"

                    color:
                        panelRoot.colorText

                    font.pixelSize:
                        15

                    font.bold:
                        true

                    font.family:
                        "JetBrainsMono Nerd Font"

                    MouseArea {
                        anchors.fill:
                            parent

                        anchors.margins:
                            -8

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            panelRoot.view =
                                "main"
                    }
                }

                Item {
                    Layout.fillWidth:
                        true
                }

                Text {
                    text:
                        "\u21bb"

                    color:
                        panelRoot.colorSub

                    font.pixelSize:
                        15

                    MouseArea {
                        anchors.fill:
                            parent

                        anchors.margins:
                            -8

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            panelRoot.refreshBluetoothList()
                    }
                }
            }

            ScrollView {
                Layout.fillWidth:
                    true

                Layout.fillHeight:
                    true

                clip:
                    true

                ColumnLayout {
                    width:
                        parent.width

                    spacing:
                        6

                    Repeater {
                        model:
                            panelRoot.bluetoothDevices

                        Rectangle {
                            Layout.fillWidth:
                                true

                            Layout.preferredHeight:
                                modelData.connected
                                    ? 56
                                    : 48

                            radius:
                                12

                            color:
                                modelData.connected
                                    ? panelRoot.colorAccent
                                    : panelRoot.colorSurface

                            Behavior on Layout.preferredHeight {
                                NumberAnimation {
                                    duration:
                                        150
                                }
                            }

                            RowLayout {
                                anchors.fill:
                                    parent

                                anchors.margins:
                                    10

                                spacing:
                                    8

                                Text {
                                    Layout.fillWidth:
                                        true

                                    text:
                                        modelData.name

                                    color:
                                        modelData.connected
                                            ? panelRoot.colorAccentText
                                            : panelRoot.colorText

                                    font.pixelSize:
                                        modelData.connected
                                            ? 14
                                            : 12

                                    font.bold:
                                        modelData.connected

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    elide:
                                        Text.ElideRight
                                }

                                Text {
                                    visible:
                                        modelData.connecting

                                    text:
                                        "\u21bb"

                                    color:
                                        modelData.connected
                                            ? panelRoot.colorAccentText
                                            : panelRoot.colorText

                                    font.pixelSize:
                                        14

                                    RotationAnimation on rotation {
                                        running:
                                            modelData.connecting

                                        loops:
                                            Animation.Infinite

                                        from:
                                            0

                                        to:
                                            360

                                        duration:
                                            900
                                    }
                                }

                                Text {
                                    visible:
                                        modelData.connected &&
                                        !modelData.connecting

                                    text:
                                        "\u2713"

                                    color:
                                        panelRoot.colorAccentText

                                    font.pixelSize:
                                        14

                                    font.bold:
                                        true
                                }
                            }

                            MouseArea {
                                anchors.fill:
                                    parent

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    if (
                                        !modelData.connected
                                    )
                                        panelRoot.connectToBluetooth(
                                            modelData.mac
                                        )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ========================================================================
    // WI-FI PASSWORD POPUP
    // ========================================================================

    Rectangle {
        id: wifiPopup

        visible:
            false

        anchors.centerIn:
            card

        width:
            380

        height:
            wifiContent.implicitHeight + 48

        radius:
            32

        color:
            panelRoot.colorBg

        z:
            100

        function closeAndClear() {
            wifiPopup.visible =
                false

            wifiPasswordField.text =
                ""

            panelRoot.wifiPendingSsid =
                ""
        }

        ColumnLayout {
            id: wifiContent

            anchors.fill:
                parent

            anchors.margins:
                24

            spacing:
                16

            RowLayout {
                Layout.fillWidth:
                    true

                spacing:
                    12

                Rectangle {
                    Layout.preferredWidth:
                        40

                    Layout.preferredHeight:
                        40

                    radius:
                        20

                    color:
                        panelRoot.colorAccent

                    Text {
                        anchors.centerIn:
                            parent

                        text:
                            "󰌾"

                        color:
                            panelRoot.colorAccentText

                        font.pixelSize:
                            17

                        font.family:
                            "JetBrainsMono Nerd Font"
                    }
                }

                Text {
                    text:
                        "Wi-Fi connection"

                    color:
                        panelRoot.colorText

                    font.pixelSize:
                        17

                    font.bold:
                        true

                    font.family:
                        "JetBrainsMono Nerd Font"
                }
            }

            Rectangle {
                Layout.fillWidth:
                    true

                Layout.preferredHeight:
                    wifiInfoCol.implicitHeight + 24

                radius:
                    18

                color:
                    panelRoot.colorSurface

                ColumnLayout {
                    id: wifiInfoCol

                    anchors.fill:
                        parent

                    anchors.margins:
                        14

                    spacing:
                        4

                    Text {
                        Layout.fillWidth:
                            true

                        text:
                            "Connect to " +
                            panelRoot.wifiPendingSsid

                        color:
                            panelRoot.colorText

                        font.pixelSize:
                            13

                        font.bold:
                            true

                        font.family:
                            "JetBrainsMono Nerd Font"

                        wrapMode:
                            Text.WordWrap
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth:
                    true

                spacing:
                    6

                Text {
                    text:
                        "Password"

                    color:
                        panelRoot.colorSub

                    font.pixelSize:
                        11

                    font.family:
                        "JetBrainsMono Nerd Font"
                }

                Rectangle {
                    Layout.fillWidth:
                        true

                    Layout.preferredHeight:
                        52

                    radius:
                        26

                    color:
                        "transparent"

                    border.color:
                        wifiPasswordField.activeFocus
                            ? panelRoot.colorAccent
                            : panelRoot.colorBorder

                    border.width:
                        1.5

                    RowLayout {
                        anchors.fill:
                            parent

                        anchors.leftMargin:
                            6

                        anchors.rightMargin:
                            16

                        spacing:
                            10

                        Rectangle {
                            Layout.preferredWidth:
                                36

                            Layout.preferredHeight:
                                36

                            radius:
                                18

                            color:
                                panelRoot.colorAccent

                            Text {
                                anchors.centerIn:
                                    parent

                                text:
                                    "󰌾"

                                color:
                                    panelRoot.colorAccentText

                                font.pixelSize:
                                    14

                                font.family:
                                    "JetBrainsMono Nerd Font"
                            }
                        }

                        TextInput {
                            id: wifiPasswordField

                            Layout.fillWidth:
                                true

                            echoMode:
                                TextInput.Password

                            color:
                                panelRoot.colorText

                            font.pixelSize:
                                14

                            font.family:
                                "JetBrainsMono Nerd Font"

                            verticalAlignment:
                                TextInput.AlignVCenter

                            onAccepted:
                                wifiPopup.wifiConnect()
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth:
                    true

                spacing:
                    10

                Item {
                    Layout.fillWidth:
                        true
                }

                Text {
                    text:
                        "Cancel"

                    color:
                        panelRoot.colorSub

                    font.pixelSize:
                        13

                    font.family:
                        "JetBrainsMono Nerd Font"

                    MouseArea {
                        anchors.fill:
                            parent

                        anchors.margins:
                            -10

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            wifiPopup.closeAndClear()
                    }
                }

                Rectangle {
                    id: wifiConfirmBtn

                    Layout.preferredWidth:
                        wifiBtnText.implicitWidth + 36

                    Layout.preferredHeight:
                        40

                    radius:
                        20

                    color:
                        panelRoot.colorAccent

                    signal clicked()

                    onClicked:
                        wifiPopup.wifiConnect()

                    Text {
                        id: wifiBtnText

                        anchors.centerIn:
                            parent

                        text:
                            "Connect"

                        color:
                            panelRoot.colorAccentText

                        font.pixelSize:
                            13

                        font.bold:
                            true

                        font.family:
                            "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        anchors.fill:
                            parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            wifiConfirmBtn.clicked()
                    }
                }
            }
        }

        function wifiConnect() {
            if (
                panelRoot.wifiPendingSsid.length === 0
            )
                return

            panelRoot.connectToWifi(
                panelRoot.wifiPendingSsid,
                wifiPasswordField.text
            )

            wifiPopup.visible =
                false

            wifiPasswordField.text =
                ""

            panelRoot.wifiPendingSsid =
                ""
        }
    }

    // ========================================================================
    // CONTROL TILE
    // ========================================================================

    component ControlTile: Rectangle {
        id: tile

        property string iconGlyph: ""
        property string title: ""
        property string subtitle: ""
        property bool active: false

        property color accentColor:
            panelRoot.colorAccent

        signal toggleClicked()
        signal tileClicked()

        Layout.preferredHeight:
            64

        radius:
            20

        color:
            panelRoot.colorSurface

        RowLayout {
            anchors.fill:
                parent

            anchors.margins:
                10

            spacing:
                10

            Rectangle {
                Layout.preferredWidth:
                    40

                Layout.preferredHeight:
                    40

                radius:
                    20

                color:
                    tile.active
                        ? tile.accentColor
                        : panelRoot.colorInactive

                Behavior on color {
                    ColorAnimation {
                        duration:
                            150
                    }
                }

                Text {
                    anchors.centerIn:
                        parent

                    text:
                        tile.iconGlyph

                    color:
                        tile.active
                            ? panelRoot.colorAccentText
                            : panelRoot.colorText

                    font.pixelSize:
                        17

                    font.family:
                        "JetBrainsMono Nerd Font"
                }
            }

            ColumnLayout {
                Layout.fillWidth:
                    true

                spacing:
                    0

                Text {
                    Layout.fillWidth:
                        true

                    text:
                        tile.title

                    color:
                        panelRoot.colorText

                    font.pixelSize:
                        13

                    font.bold:
                        true

                    font.family:
                        "JetBrainsMono Nerd Font"

                    elide:
                        Text.ElideRight
                }

                Text {
                    Layout.fillWidth:
                        true

                    text:
                        tile.subtitle

                    color:
                        panelRoot.colorSub

                    font.pixelSize:
                        10

                    font.family:
                        "JetBrainsMono Nerd Font"

                    elide:
                        Text.ElideRight
                }
            }
        }

        MouseArea {
            anchors.fill:
                parent

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                tile.tileClicked()
        }
    }
}


//This one is **standalone**: it floats at the top-center with its own rounded shape and does not modify the notch/pill itself.
