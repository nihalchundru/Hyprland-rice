import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

// ============================================================================
// ControlCenter.qml — qs-control-center
//
// Opens from the notch's gear button (Notch.controlCenterRequested → wired
// up in shell.qml). Top row: Wi-Fi / Bluetooth / Focus toggles + a mini
// media widget. Below: brightness + volume sliders. Clicking the Wi-Fi or
// Bluetooth toggle's LABEL (not the switch itself) swaps the card's content
// into that device's list view, matching your sketch's flow — this is all
// one panel/window with an internal "view" state, not separate popups,
// since visually it's the same card growing/changing rather than a new
// window appearing.
//
// HEAVY ASSUMPTIONS FLAGGED THROUGHOUT — Wi-Fi is done via `nmcli`,
// Bluetooth via `bluetoothctl`, "Focus" via a guessed dunst command. These
// are the standard tools for the job on Arch, but the exact output format
// of `nmcli`/`bluetoothctl` can vary by version, and this almost certainly
// needs a round of real-device testing/iteration, same as the media panel
// did with its icon codepoints and position handling.
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

    // Reused from Notch.qml via shell.qml — same player, no double polling
    property var player: null
    property string trackTitle: player ? player.trackTitle : ""
    property bool isPlaying: player !== null && player.playbackState === MprisPlaybackState.Playing
    function togglePlay() { if (player) player.togglePlaying() }

    property bool open: false
    // "main" | "wifi" | "bluetooth"
    property string view: "main"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-control-center"

    anchors { top: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: -1
    height: 620
    visible: open

    onOpenChanged: {
        if (open) {
            view = "main"
            wifiStatusProc.running = true
            bluetoothStatusProc.running = true
            brightnessGetProc.running = true
            volumeGetProc.running = true
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: panelRoot.open = false
    }

    // ------------------------------------------------------------------
    // Wi-Fi (via nmcli)
    // ------------------------------------------------------------------
    property bool wifiEnabled: false
    property var wifiNetworks: []       // [{ ssid, signal, secured, connected, connecting }]
    property string wifiPendingSsid: "" // network awaiting a password via the auth popup

    Process {
        id: wifiStatusProc
        command: ["bash", "-c", "nmcli radio wifi"]
        stdout: StdioCollector {
            onStreamFinished: panelRoot.wifiEnabled = text.trim() === "enabled"
        }
    }

    function toggleWifi() {
        var cmd = panelRoot.wifiEnabled ? "off" : "on"
        wifiToggleProc.command = ["bash", "-c", "nmcli radio wifi " + cmd]
        wifiToggleProc.running = true
        panelRoot.wifiEnabled = !panelRoot.wifiEnabled // optimistic
    }
    Process { id: wifiToggleProc }

    function refreshWifiList() {
        // -t = terse/parseable, -f = fields. ASSUMPTION: this exact field
        // order/format is standard nmcli, but double-check against your
        // actual nmcli version if this comes back empty or malformed.
        wifiListProc.command = ["bash", "-c",
            "nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE device wifi list"]
        wifiListProc.running = true
    }

    Process {
        id: wifiListProc
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var nets = []
                var seen = {}
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":")
                    if (parts.length < 4) continue
                    var ssid = parts[0]
                    if (ssid.length === 0 || seen[ssid]) continue
                    seen[ssid] = true
                    nets.push({
                        ssid: ssid,
                        signal: parseInt(parts[1], 10) || 0,
                        secured: parts[2].length > 0 && parts[2] !== "--",
                        connected: parts[3] === "*",
                        connecting: false
                    })
                }
                nets.sort(function(a, b) { return b.signal - a.signal })
                panelRoot.wifiNetworks = nets
            }
        }
    }

    function connectToWifi(ssid, password) {
        var idx = panelRoot.wifiNetworks.findIndex(function(n) { return n.ssid === ssid })
        if (idx >= 0) {
            var updated = panelRoot.wifiNetworks.slice()
            updated[idx] = Object.assign({}, updated[idx], { connecting: true })
            panelRoot.wifiNetworks = updated
        }
        var cmd = password
            ? "nmcli device wifi connect \"" + ssid + "\" password \"" + password + "\""
            : "nmcli device wifi connect \"" + ssid + "\""
        wifiConnectProc.command = ["bash", "-c", cmd]
        wifiConnectProc.running = true
    }

    Process {
        id: wifiConnectProc
        stdout: StdioCollector { onStreamFinished: panelRoot.refreshWifiList() }
        stderr: StdioCollector { onStreamFinished: panelRoot.refreshWifiList() }
    }

    function onWifiRowClicked(net) {
        if (net.connected) return
        if (net.secured) {
            panelRoot.wifiPendingSsid = net.ssid
            authPopup.visible = true
        } else {
            panelRoot.connectToWifi(net.ssid, "")
        }
    }

    // ------------------------------------------------------------------
    // Bluetooth (via bluetoothctl)
    // ------------------------------------------------------------------
    property bool bluetoothEnabled: false
    property var bluetoothDevices: []   // [{ mac, name, connected, connecting }]

    Process {
        id: bluetoothStatusProc
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"]
        stdout: StdioCollector {
            onStreamFinished: panelRoot.bluetoothEnabled = text.trim() === "on"
        }
    }

    function toggleBluetooth() {
        var cmd = panelRoot.bluetoothEnabled ? "off" : "on"
        btToggleProc.command = ["bash", "-c", "bluetoothctl power " + cmd]
        btToggleProc.running = true
        panelRoot.bluetoothEnabled = !panelRoot.bluetoothEnabled // optimistic
    }
    Process { id: btToggleProc }

    function refreshBluetoothList() {
        // ASSUMPTION: parsing `bluetoothctl devices` (paired/known devices)
        // rather than a live scan — a live `scan on` requires listening to
        // streamed output over time, which is a bigger lift than a first
        // pass warrants. This will show paired devices only, not nearby
        // unpaired ones. Tell me if you specifically need scan-and-pair.
        btListProc.command = ["bash", "-c",
            "bluetoothctl devices | while read -r _ mac name; do " +
            "connected=$(bluetoothctl info \"$mac\" | grep -q 'Connected: yes' && echo yes || echo no); " +
            "echo \"$mac|$name|$connected\"; done"]
        btListProc.running = true
    }

    Process {
        id: btListProc
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var devs = []
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].length === 0) continue
                    var parts = lines[i].split("|")
                    if (parts.length < 3) continue
                    devs.push({
                        mac: parts[0],
                        name: parts[1],
                        connected: parts[2] === "yes",
                        connecting: false
                    })
                }
                panelRoot.bluetoothDevices = devs
            }
        }
    }

    function connectToBluetooth(mac) {
        var idx = panelRoot.bluetoothDevices.findIndex(function(d) { return d.mac === mac })
        if (idx >= 0) {
            var updated = panelRoot.bluetoothDevices.slice()
            updated[idx] = Object.assign({}, updated[idx], { connecting: true })
            panelRoot.bluetoothDevices = updated
        }
        btConnectProc.command = ["bash", "-c", "bluetoothctl connect " + mac]
        btConnectProc.running = true
    }
    Process {
        id: btConnectProc
        stdout: StdioCollector { onStreamFinished: panelRoot.refreshBluetoothList() }
        stderr: StdioCollector { onStreamFinished: panelRoot.refreshBluetoothList() }
    }

    // ------------------------------------------------------------------
    // Focus (Do Not Disturb) — ASSUMPTION: dunst as the notification
    // daemon, since that's the common pairing with Hyprland rices. If
    // you're using mako or something else, tell me and I'll swap the
    // command.
    // ------------------------------------------------------------------
    property bool focusEnabled: false
    function toggleFocus() {
        var cmd = panelRoot.focusEnabled ? "dunstctl set-paused false" : "dunstctl set-paused true"
        focusProc.command = ["bash", "-c", cmd]
        focusProc.running = true
        panelRoot.focusEnabled = !panelRoot.focusEnabled
    }
    Process { id: focusProc }

    // ------------------------------------------------------------------
    // Brightness (via brightnessctl) and volume (via wpctl / PipeWire)
    // ------------------------------------------------------------------
    property real brightness: 0.7 // 0..1
    property real volume: 0.5     // 0..1
    property bool muted: false

    Process {
        id: brightnessGetProc
        command: ["bash", "-c", "brightnessctl -m | awk -F, '{print $4}' | tr -d '%'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var v = parseFloat(text.trim())
                if (!isNaN(v)) panelRoot.brightness = v / 100
            }
        }
    }
    function setBrightness(fraction) {
        panelRoot.brightness = fraction
        brightnessSetProc.command = ["bash", "-c", "brightnessctl set " + Math.round(fraction * 100) + "%"]
        brightnessSetProc.running = true
    }
    Process { id: brightnessSetProc }

    Process {
        id: volumeGetProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Typical output: "Volume: 0.45" or "Volume: 0.45 [MUTED]"
                var m = text.match(/Volume:\s*([\d.]+)/)
                if (m) panelRoot.volume = parseFloat(m[1])
                panelRoot.muted = text.indexOf("MUTED") !== -1
            }
        }
    }
    function setVolume(fraction) {
        panelRoot.volume = fraction
        volumeSetProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + fraction.toFixed(2)]
        volumeSetProc.running = true
    }
    Process { id: volumeSetProc }

    // ====================================================================
    // CARD
    // ====================================================================
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 0
        width: 400
        height: panelRoot.open ? (panelRoot.view === "main" ? 380 : 560) : 0
        radius: 26 // fallback for older Qt without per-corner radius support
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: 26
        bottomRightRadius: 26
        color: "#000000"
        clip: true
        antialiasing: true

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea { anchors.fill: parent; onClicked: {} } // swallow clicks

        // Close button — always visible regardless of which sub-view is showing
        Text {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 16
            z: 20
            text: "\uf00d"
            color: panelRoot.c("sub")
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: panelRoot.open = false
            }
        }

        // ---------------- MAIN VIEW ----------------
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            visible: panelRoot.view === "main"

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Wi-Fi toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 16
                    color: panelRoot.wifiEnabled ? panelRoot.c("accent") : panelRoot.c("surface")
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        Text { text: "󰖩"; font.pixelSize: 18; color: panelRoot.wifiEnabled ? panelRoot.c("bg") : "#ffffff"; font.family: "JetBrainsMono Nerd Font" }
                        Text { text: "Wi-Fi"; font.pixelSize: 10; color: panelRoot.wifiEnabled ? panelRoot.c("bg") : "#cccccc"; font.family: "JetBrainsMono Nerd Font" }
                    }
                    // Tap the icon area toggles on/off; tap here (label row) opens the list.
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panelRoot.toggleWifi()
                        onPressAndHold: { panelRoot.refreshWifiList(); panelRoot.view = "wifi" }
                    }
                    // Small chevron in the corner opens the list explicitly (avoids relying on press-and-hold alone)
                    Text {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 4
                        text: "\u203a"
                        font.pixelSize: 12
                        color: panelRoot.wifiEnabled ? panelRoot.c("bg") : panelRoot.c("sub")
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { panelRoot.refreshWifiList(); panelRoot.view = "wifi" }
                        }
                    }
                }

                // Bluetooth toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 16
                    color: panelRoot.bluetoothEnabled ? panelRoot.c("accent") : panelRoot.c("surface")
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        Text { text: "󰂯"; font.pixelSize: 18; color: panelRoot.bluetoothEnabled ? panelRoot.c("bg") : "#ffffff"; font.family: "JetBrainsMono Nerd Font" }
                        Text { text: "Bluetooth"; font.pixelSize: 10; color: panelRoot.bluetoothEnabled ? panelRoot.c("bg") : "#cccccc"; font.family: "JetBrainsMono Nerd Font" }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panelRoot.toggleBluetooth()
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 4
                        text: "\u203a"
                        font.pixelSize: 12
                        color: panelRoot.bluetoothEnabled ? panelRoot.c("bg") : panelRoot.c("sub")
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { panelRoot.refreshBluetoothList(); panelRoot.view = "bluetooth" }
                        }
                    }
                }

                // Focus toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 16
                    color: panelRoot.focusEnabled ? panelRoot.c("accent") : panelRoot.c("surface")
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 2
                        Text { text: "󰸞"; font.pixelSize: 18; color: panelRoot.focusEnabled ? panelRoot.c("bg") : "#ffffff"; font.family: "JetBrainsMono Nerd Font" }
                        Text { text: "Focus"; font.pixelSize: 10; color: panelRoot.focusEnabled ? panelRoot.c("bg") : "#cccccc"; font.family: "JetBrainsMono Nerd Font" }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.toggleFocus() }
                }
            }

            // Mini media widget
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 16
                color: panelRoot.c("surface")
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    Text {
                        Layout.fillWidth: true
                        text: panelRoot.trackTitle.length > 0 ? panelRoot.trackTitle : "Not playing"
                        color: panelRoot.c("text")
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                        elide: Text.ElideRight
                    }
                    Text {
                        text: panelRoot.isPlaying ? "󰏤" : "󰐊"
                        color: panelRoot.c("text")
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                        MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.togglePlay() }
                    }
                }
            }

            // Brightness slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    spacing: 8
                    Text { text: "\u2600"; color: panelRoot.c("sub"); font.pixelSize: 14 } // standard sun symbol
                    Rectangle {
                        id: brightTrack
                        Layout.fillWidth: true
                        height: 8
                        radius: 4
                        color: panelRoot.c("surface")
                        Rectangle {
                            width: parent.width * panelRoot.brightness
                            height: parent.height
                            radius: 4
                            color: panelRoot.c("accent")
                        }
                        MouseArea {
                            id: brightArea
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => panelRoot.setBrightness(Math.max(0, Math.min(1, mouse.x / brightArea.width)))
                        }
                    }
                }
            }

            // Volume slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    spacing: 8
                    Text { text: panelRoot.muted ? "🔇" : "🔊"; color: panelRoot.c("sub"); font.pixelSize: 14 } // standard speaker symbols
                    Rectangle {
                        id: volTrack
                        Layout.fillWidth: true
                        height: 8
                        radius: 4
                        color: panelRoot.c("surface")
                        Rectangle {
                            width: parent.width * Math.min(1, panelRoot.volume)
                            height: parent.height
                            radius: 4
                            color: panelRoot.c("accent")
                        }
                        MouseArea {
                            id: volArea
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => panelRoot.setVolume(Math.max(0, Math.min(1, mouse.x / volArea.width)))
                        }
                    }
                }
            }
        }

        // ---------------- WI-FI SUB-VIEW ----------------
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            visible: panelRoot.view === "wifi"

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "\u2039 Wi-Fi"
                    color: panelRoot.c("text")
                    font.pixelSize: 15
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.view = "main" }
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "\u21bb" // refresh
                    color: panelRoot.c("sub")
                    font.pixelSize: 15
                    MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.refreshWifiList() }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ColumnLayout {
                    width: parent.width
                    spacing: 6
                    Repeater {
                        model: panelRoot.wifiNetworks
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: modelData.connected ? 56 : 48
                            radius: 12
                            color: modelData.connected ? panelRoot.c("accent") : panelRoot.c("surface")
                            Behavior on Layout.preferredHeight { NumberAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.ssid + (modelData.secured ? "  󰯅" : "")
                                    color: modelData.connected ? panelRoot.c("bg") : panelRoot.c("text")
                                    font.pixelSize: modelData.connected ? 14 : 12
                                    font.bold: modelData.connected
                                    font.family: "JetBrainsMono Nerd Font"
                                    elide: Text.ElideRight
                                }
                                Text {
                                    visible: modelData.connecting
                                    text: "\u21bb"
                                    color: panelRoot.c("bg")
                                    font.pixelSize: 14
                                    RotationAnimation on rotation {
                                        running: modelData.connecting
                                        loops: Animation.Infinite
                                        from: 0; to: 360
                                        duration: 900
                                    }
                                }
                                Text {
                                    visible: modelData.connected && !modelData.connecting
                                    text: "\u2713"
                                    color: panelRoot.c("bg")
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: panelRoot.onWifiRowClicked(modelData)
                            }
                        }
                    }
                }
            }
        }

        // ---------------- BLUETOOTH SUB-VIEW ----------------
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            visible: panelRoot.view === "bluetooth"

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "\u2039 Bluetooth"
                    color: panelRoot.c("text")
                    font.pixelSize: 15
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.view = "main" }
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "\u21bb"
                    color: panelRoot.c("sub")
                    font.pixelSize: 15
                    MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: panelRoot.refreshBluetoothList() }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ColumnLayout {
                    width: parent.width
                    spacing: 6
                    Repeater {
                        model: panelRoot.bluetoothDevices
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: modelData.connected ? 56 : 48
                            radius: 12
                            color: modelData.connected ? panelRoot.c("accent") : panelRoot.c("surface")
                            Behavior on Layout.preferredHeight { NumberAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: modelData.connected ? panelRoot.c("bg") : panelRoot.c("text")
                                    font.pixelSize: modelData.connected ? 14 : 12
                                    font.bold: modelData.connected
                                    font.family: "JetBrainsMono Nerd Font"
                                    elide: Text.ElideRight
                                }
                                Text {
                                    visible: modelData.connecting
                                    text: "\u21bb"
                                    color: panelRoot.c("bg")
                                    font.pixelSize: 14
                                    RotationAnimation on rotation {
                                        running: modelData.connecting
                                        loops: Animation.Infinite
                                        from: 0; to: 360
                                        duration: 900
                                    }
                                }
                                Text {
                                    visible: modelData.connected && !modelData.connecting
                                    text: "\u2713"
                                    color: panelRoot.c("bg")
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (!modelData.connected) panelRoot.connectToBluetooth(modelData.mac)
                            }
                        }
                    }
                }
            }
        }
    }

    // ====================================================================
    // AUTH POPUP — shown when a secured Wi-Fi network needing a password
    // is tapped. Simple overlay centered on the panel, not a separate
    // window, since it's short-lived and tied entirely to this panel's
    // own state.
    // ====================================================================
    Rectangle {
        id: authPopup
        visible: false
        anchors.centerIn: card
        width: 300
        height: 160
        radius: 20
        color: panelRoot.c("surface")
        border.color: panelRoot.c("accent")
        border.width: 1
        z: 10

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Text {
                text: "Connect to " + panelRoot.wifiPendingSsid
                color: panelRoot.c("text")
                font.pixelSize: 13
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Password"
                onAccepted: authConfirmBtn.clicked()
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                Text {
                    text: "Cancel"
                    color: panelRoot.c("sub")
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { authPopup.visible = false; passwordField.text = "" }
                    }
                }
                Rectangle {
                    id: authConfirmBtn
                    width: 90; height: 32
                    radius: 10
                    color: panelRoot.c("accent")
                    signal clicked()
                    onClicked: {
                        panelRoot.connectToWifi(panelRoot.wifiPendingSsid, passwordField.text)
                        authPopup.visible = false
                        passwordField.text = ""
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: panelRoot.c("bg")
                        font.pixelSize: 12
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: authConfirmBtn.clicked() }
                }
            }
        }
    }
}
