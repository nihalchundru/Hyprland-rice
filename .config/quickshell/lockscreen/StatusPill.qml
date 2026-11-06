import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire

// Material 3 Status Glanceables (Top-Right)
// - Battery status & percentage (with charging bolt, hidden on desktops)
// - Audio volume & mute indicator (via Pipewire)
// - Network connectivity indicator
Item {
    id: root

    implicitWidth: pill.width
    implicitHeight: pill.height

    // --- Battery ---
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery !== null && battery.isRechargeable
    readonly property real batteryPct: hasBattery ?
        (battery.percentage <= 1.0 ? battery.percentage * 100 : battery.percentage) : 100
    readonly property bool isCharging: hasBattery &&
        (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge)

    // --- Volume ---
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool hasAudio: sink !== null && sink.audio !== null
    readonly property real volumeLevel: hasAudio ? sink.audio.volume * 100 : 0
    readonly property bool isMuted: hasAudio ? sink.audio.muted : false

    // --- Network (check every 15s) ---
    property string networkName: ""
    property bool isConnected: false

    Process {
        id: netCheck
        command: ["sh", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2 || ip route 2>/dev/null | grep -q default && echo 'Connected' || echo ''"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim();
                root.isConnected = s.length > 0;
                root.networkName = s;
            }
        }
    }

    Process {
        id: volCmd
        running: false
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: netCheck.running = true
    }

    Rectangle {
        id: pill
        width: row.implicitWidth + 28
        height: 52
        radius: height / 2
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.75)
        border.width: 1
        border.color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.12)

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 16

            // --- Network Item ---
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                Canvas {
                    width: 18
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = root.isConnected ? Colors.teal : Colors.sub;
                        ctx.lineWidth = 2;
                        ctx.lineCap = "round";

                        // WiFi arcs
                        ctx.beginPath();
                        ctx.arc(9, 13, 10, -0.75 * Math.PI, -0.25 * Math.PI, false);
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.arc(9, 13, 6, -0.75 * Math.PI, -0.25 * Math.PI, false);
                        ctx.stroke();

                        // Dot
                        ctx.fillStyle = ctx.strokeStyle;
                        ctx.beginPath();
                        ctx.arc(9, 13, 1.8, 0, 2 * Math.PI);
                        ctx.fill();
                    }

                    Connections {
                        target: root
                        function onIsConnectedChanged() { row.children[0].children[0].requestPaint(); }
                    }
                }

                Text {
                    text: root.networkName !== "" && root.networkName !== "Connected" ?
                        root.networkName : (root.isConnected ? "Online" : "Offline")
                    color: root.isConnected ? Colors.text : Colors.sub
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            // Divider
            Rectangle {
                width: 1
                height: 16
                color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.15)
                anchors.verticalCenter: parent.verticalCenter
            }

            // --- Volume Item (Scroll to adjust, click to mute) ---
            Item {
                id: volumeContainer
                implicitWidth: volRow.implicitWidth + 12
                implicitHeight: 32
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: volArea.containsMouse ? Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.12) : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Row {
                    id: volRow
                    spacing: 6
                    anchors.centerIn: parent

                    Canvas {
                        id: volCanvas
                        width: 18
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = root.isMuted ? Colors.sub : Colors.text;
                            ctx.strokeStyle = ctx.fillStyle;
                            ctx.lineWidth = 1.8;
                            ctx.lineCap = "round";

                            // Speaker body
                            ctx.beginPath();
                            ctx.moveTo(3, 6);
                            ctx.lineTo(6, 6);
                            ctx.lineTo(10, 3);
                            ctx.lineTo(10, 15);
                            ctx.lineTo(6, 12);
                            ctx.lineTo(3, 12);
                            ctx.closePath();
                            ctx.fill();

                            if (root.isMuted) {
                                // Mute diagonal line
                                ctx.strokeStyle = Colors.red;
                                ctx.beginPath();
                                ctx.moveTo(12, 5);
                                ctx.lineTo(16, 13);
                                ctx.moveTo(16, 5);
                                ctx.lineTo(12, 13);
                                ctx.stroke();
                            } else {
                                // Sound arc
                                ctx.beginPath();
                                ctx.arc(9, 9, 5, -0.3 * Math.PI, 0.3 * Math.PI, false);
                                ctx.stroke();
                            }
                        }

                        Connections {
                            target: root
                            function onIsMutedChanged() { volCanvas.requestPaint(); }
                            function onVolumeLevelChanged() { volCanvas.requestPaint(); }
                        }
                    }

                    Text {
                        text: root.isMuted ? "Muted" : Math.round(root.volumeLevel) + "%"
                        color: root.isMuted ? Colors.sub : Colors.text
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: volArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onWheel: wheel => {
                        const step = wheel.angleDelta.y > 0 ? "5%+" : "5%-";
                        volCmd.command = ["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", step];
                        volCmd.running = true;
                    }
                    onClicked: {
                        volCmd.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"];
                        volCmd.running = true;
                    }
                }
            }

            // --- Battery Item (shown if device has a battery) ---
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                visible: root.hasBattery

                // Divider before battery
                Rectangle {
                    width: 1
                    height: 16
                    color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.15)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Canvas {
                    id: batCanvas
                    width: 22
                    height: 14
                    anchors.verticalCenter: parent.verticalCenter
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = root.batteryPct <= 20 ? Colors.red : Colors.text;
                        ctx.lineWidth = 1.5;

                        // Battery body
                        ctx.strokeRect(1, 1, 16, 12);

                        // Terminal nipple
                        ctx.fillStyle = ctx.strokeStyle;
                        ctx.fillRect(17.5, 4.5, 2, 5);

                        // Level fill
                        const fillWidth = Math.max(0, Math.min(13, (root.batteryPct / 100) * 13));
                        ctx.fillStyle = root.isCharging ? Colors.accent
                                      : root.batteryPct <= 20 ? Colors.red
                                      : Colors.text;
                        ctx.fillRect(2.5, 2.5, fillWidth, 9);
                    }

                    Connections {
                        target: root
                        function onBatteryPctChanged() { batCanvas.requestPaint(); }
                        function onIsChargingChanged() { batCanvas.requestPaint(); }
                    }
                }

                Text {
                    text: (root.isCharging ? "⚡ " : "") + Math.round(root.batteryPct) + "%"
                    color: root.batteryPct <= 20 ? Colors.red : Colors.text
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
