import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: cpRoot
    property var colors
    property bool open: false

    function toggle() {
        open = !open
        if (open) {
            wifiCheck.running = true
            btCheck.running = true
            volCheck.running = true
            briCheck.running = true
            titleCheck.running = true
            artistCheck.running = true
            statusCheck.running = true
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-control"

    anchors { top: true; left: true; right: true }
    implicitHeight: 450
    color: "transparent"
    exclusiveZone: -1
    visible: open

    property bool wifiOn: true
    property bool btOn: false
    property int volumeLevel: 50
    property int brightnessLevel: 80
    property string mediaTitle: "Nothing playing"
    property string mediaArtist: ""
    property string mediaStatus: "Stopped"

    Process {
        id: wifiCheck
        command: ["bash", "-c", "nmcli radio wifi"]
        stdout: StdioCollector { onStreamFinished: cpRoot.wifiOn = this.text.trim() === "enabled" }
    }
    Process {
        id: btCheck
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo on || echo off"]
        stdout: StdioCollector { onStreamFinished: cpRoot.btOn = this.text.trim() === "on" }
    }
    Process {
        id: volCheck
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f\", $2*100}'"]
        stdout: StdioCollector { onStreamFinished: cpRoot.volumeLevel = parseInt(this.text.trim()) || 0 }
    }
    Process {
        id: briCheck
        command: ["bash", "-c", "brightnessctl get 2>/dev/null && brightnessctl max 2>/dev/null || printf '1\\n1\\n'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 2) {
                    var cur = parseInt(lines[0]) || 1
                    var max = parseInt(lines[1]) || 1
                    cpRoot.brightnessLevel = Math.round((cur / max) * 100)
                }
            }
        }
    }
    Process {
        id: titleCheck
        command: ["bash", "-c", "playerctl metadata title 2>/dev/null || echo 'Nothing playing'"]
        stdout: StdioCollector { onStreamFinished: cpRoot.mediaTitle = this.text.trim() || "Nothing playing" }
    }
    Process {
        id: artistCheck
        command: ["bash", "-c", "playerctl metadata artist 2>/dev/null || echo ''"]
        stdout: StdioCollector { onStreamFinished: cpRoot.mediaArtist = this.text.trim() }
    }
    Process {
        id: statusCheck
        command: ["bash", "-c", "playerctl status 2>/dev/null || echo 'Stopped'"]
        stdout: StdioCollector { onStreamFinished: cpRoot.mediaStatus = this.text.trim() || "Stopped" }
    }

    Process { id: actionProc }
    function run(cmd) {
        actionProc.command = ["bash", "-c", cmd]
        actionProc.running = true
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 6
        width: cpRoot.open ? 320 : 130
        height: cpRoot.open ? 400 : 28
        radius: 16
        color: cpRoot.colors.bg
        border.color: cpRoot.colors.accent
        border.width: 1
        clip: false
        antialiasing: true

        Behavior on width  { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        RowLayout {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 6
            height: 22
            Text {
                text: "󰒓 Quick Settings"
                color: cpRoot.colors.accent
                font.bold: true
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 36
            anchors.margins: 14
            spacing: 8
            opacity: cpRoot.open ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 150 } }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 56
                    radius: 16
                    color: cpRoot.wifiOn ? cpRoot.colors.accent : cpRoot.colors.surface
                    Behavior on color { ColorAnimation { duration: 150 } }

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10
                        spacing: 0
                        Text { text: "󰖩"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.wifiOn ? cpRoot.colors.bg : cpRoot.colors.text }
                        Text { text: cpRoot.wifiOn ? "Wi-Fi On" : "Wi-Fi Off"; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.wifiOn ? cpRoot.colors.bg : cpRoot.colors.sub }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cpRoot.wifiOn = !cpRoot.wifiOn
                            cpRoot.run("nmcli radio wifi " + (cpRoot.wifiOn ? "on" : "off"))
                            propagateComposedEvents: true  // but let children (sliders) handle their own events
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 56
                    radius: 16
                    color: cpRoot.btOn ? cpRoot.colors.accent : cpRoot.colors.surface
                    Behavior on color { ColorAnimation { duration: 150 } }

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10
                        spacing: 0
                        Text { text: "󰂯"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.btOn ? cpRoot.colors.bg : cpRoot.colors.text }
                        Text { text: cpRoot.btOn ? "BT On" : "BT Off"; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.btOn ? cpRoot.colors.bg : cpRoot.colors.sub }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cpRoot.btOn = !cpRoot.btOn
                            cpRoot.run("bluetoothctl power " + (cpRoot.btOn ? "on" : "off"))
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 16
                color: cpRoot.colors.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text { text: "󰕾"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.colors.accent }

                    Slider {
                        z: 1
                        Layout.fillWidth: true
                        from: 0; to: 100
                        value: cpRoot.volumeLevel
                        live: true                    // add this
                        wheelEnabled: true            // add this
                        onMoved: cpRoot.run("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.round(value) + "%")

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: parent.availableWidth
                            height: 6
                            radius: 3
                            color: cpRoot.colors.surface2
                            Rectangle {
                                width: parent.parent.visualPosition * parent.width
                                height: parent.height
                                radius: parent.radius
                                color: cpRoot.colors.accent
                            }
                        }
                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: 16; height: 16; radius: 8
                            color: cpRoot.colors.accent
                        }
                    }

                    Text {
                        text: cpRoot.volumeLevel + "%"
                        color: cpRoot.colors.sub
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.preferredWidth: 32
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 16
                color: cpRoot.colors.surface

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text { text: "󰃟"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.colors.yellow }

                    Slider {
                        Layout.fillWidth: true
                        from: 0; to: 100
                        value: cpRoot.brightnessLevel
                        live: true                    // add this
                        wheelEnabled: true            // add this
                        onMoved: cpRoot.run("brightnessctl set " + Math.round(value) + "% 2>/dev/null")

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: parent.availableWidth
                            height: 6
                            radius: 3
                            color: cpRoot.colors.surface2
                            Rectangle {
                                width: parent.parent.visualPosition * parent.width
                                height: parent.height
                                radius: parent.radius
                                color: cpRoot.colors.yellow
                            }
                        }
                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: 16; height: 16; radius: 8
                            color: cpRoot.colors.yellow
                        }
                    }

                    Text {
                        text: cpRoot.brightnessLevel + "%"
                        color: cpRoot.colors.sub
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.preferredWidth: 32
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: 16
                    color: cpRoot.colors.surface
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "󰍃"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.colors.text }
                        Text { text: "Lock"; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.colors.text }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cpRoot.run("bash ~/.config/hypr/scripts/lock.sh") }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: 16
                    color: cpRoot.colors.surface
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "󰒲"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.colors.text }
                        Text { text: "DND"; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.colors.text }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cpRoot.run("swaync-client -d -sw") }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 16
                color: cpRoot.colors.surface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    Text { text: "NOW PLAYING"; color: cpRoot.colors.sub; font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    Text {
                        text: cpRoot.mediaTitle
                        color: cpRoot.colors.text
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Text {
                        text: cpRoot.mediaArtist
                        color: cpRoot.colors.sub
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 14
                        Text {
                            text: "󰒮"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.colors.text
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cpRoot.run("playerctl previous") }
                        }
                        Text {
                            text: cpRoot.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                            font.pixelSize: 22; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.colors.accent
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cpRoot.run("playerctl play-pause") }
                        }
                        Text {
                            text: "󰒭"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; color: cpRoot.colors.text
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cpRoot.run("playerctl next") }
                        }
                    }
                }
            }
        }
    }
}
