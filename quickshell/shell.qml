// =============================================================================
// HyDE ARM Quickshell Sidebar — Material You themed
// Toggle: qs ipc -c sidebar call toggle
// =============================================================================

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    id: root

    // ── IPC toggle ────────────────────────────────────────────────────────────
    IpcHandler {
        target: "sidebar"
        function toggle() {
            sidebarWindow.visible = !sidebarWindow.visible
        }
    }

    // ── Color state ───────────────────────────────────────────────────────────
    property var colors: ({
        bg:      "#1E1E2E",
        bg2:     "#181825",
        surface: "#313244",
        surface2:"#45475A",
        text:    "#CDD6F4",
        sub:     "#6C7086",
        accent:  "#CBA6F7",
        accent2: "#89B4FA",
        green:   "#A6E3A1",
        red:     "#F38BA8",
        yellow:  "#F9E2AF",
        teal:    "#94E2D5",
        theme:   "catppuccin"
    })

    Process {
        id: colorReader
        command: ["cat", `${Quickshell.env("HOME")}/.config/quickshell/sidebar/colors.json`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.colors = JSON.parse(this.text)
                } catch(e) {
                    console.log("Color parse error:", e)
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: colorReader.running = true
    }

    // ── System polls ──────────────────────────────────────────────────────────
    property string clockTime: "00:00"
    property string clockDate: "Monday, January 1"
    property int cpuUsage: 0
    property int ramUsage: 0
    property int diskUsage: 0
    property int volumeLevel: 50
    property string mediaTitle: "Nothing playing"
    property string mediaArtist: ""
    property string mediaStatus: "Stopped"
    property string netName: "Wired"
    property string uptimeStr: ""

    Process {
        id: procClock
        command: ["date", "+%H:%M"]
        stdout: StdioCollector { onStreamFinished: root.clockTime = this.text.trim() }
    }
    Process {
        id: procDate
        command: ["date", "+%A, %B %d"]
        stdout: StdioCollector { onStreamFinished: root.clockDate = this.text.trim() }
    }
    Process {
        id: procCpu
        command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'"]
        stdout: StdioCollector { onStreamFinished: root.cpuUsage = parseInt(this.text.trim()) || 0 }
    }
    Process {
        id: procRam
        command: ["bash", "-c", "free | awk '/Mem/{printf \"%.0f\", $3/$2*100}'"]
        stdout: StdioCollector { onStreamFinished: root.ramUsage = parseInt(this.text.trim()) || 0 }
    }
    Process {
        id: procDisk
        command: ["bash", "-c", "df / | awk 'NR==2{print int($5)}'"]
        stdout: StdioCollector { onStreamFinished: root.diskUsage = parseInt(this.text.trim()) || 0 }
    }
    Process {
        id: procVol
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f\", $2*100}'"]
        stdout: StdioCollector { onStreamFinished: root.volumeLevel = parseInt(this.text.trim()) || 0 }
    }
    Process {
        id: procTitle
        command: ["bash", "-c", "playerctl metadata title 2>/dev/null || echo 'Nothing playing'"]
        stdout: StdioCollector { onStreamFinished: root.mediaTitle = this.text.trim() || "Nothing playing" }
    }
    Process {
        id: procArtist
        command: ["bash", "-c", "playerctl metadata artist 2>/dev/null || echo ''"]
        stdout: StdioCollector { onStreamFinished: root.mediaArtist = this.text.trim() }
    }
    Process {
        id: procStatus
        command: ["bash", "-c", "playerctl status 2>/dev/null || echo 'Stopped'"]
        stdout: StdioCollector { onStreamFinished: root.mediaStatus = this.text.trim() || "Stopped" }
    }
    Process {
        id: procNet
        command: ["bash", "-c", "iwgetid -r 2>/dev/null || echo 'Wired'"]
        stdout: StdioCollector { onStreamFinished: root.netName = this.text.trim() || "Wired" }
    }
    Process {
        id: procUptime
        command: ["bash", "-c", "uptime -p | sed 's/up //'"]
        stdout: StdioCollector { onStreamFinished: root.uptimeStr = this.text.trim() }
    }

    Timer { interval: 1000;  running: true; repeat: true; triggeredOnStart: true; onTriggered: { procClock.running = true; procVol.running = true } }
    Timer { interval: 2000;  running: true; repeat: true; triggeredOnStart: true; onTriggered: { procCpu.running = true; procTitle.running = true; procArtist.running = true; procStatus.running = true } }
    Timer { interval: 5000;  running: true; repeat: true; triggeredOnStart: true; onTriggered: { procRam.running = true; procNet.running = true } }
    Timer { interval: 30000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { procDisk.running = true; procUptime.running = true; procDate.running = true } }

    // ── Action runner ─────────────────────────────────────────────────────────
    Process { id: actionProc }
    function run(cmd) {
        actionProc.command = ["bash", "-c", cmd]
        actionProc.running = true
    }

    // ── Sidebar window ────────────────────────────────────────────────────────
    PanelWindow {
        id: sidebarWindow
        visible: true
        implicitWidth: 270
        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
        }

        margins {
            top: 8
            right: 8
            bottom: 8
        }

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: root.colors.bg
            border.color: root.colors.accent
            border.width: 2
            clip: true

            Flickable {
                anchors.fill: parent
                anchors.margins: 14
                contentWidth: width
                contentHeight: mainCol.implicitHeight
                clip: true
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                ColumnLayout {
                    id: mainCol
                    width: parent.width
                    spacing: 8

                    // ── Header ────────────────────────────────────────────────
                    Text {
                        text: "  Control Center"
                        color: root.colors.accent
                        font.pixelSize: 14
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.fillWidth: true
                        bottomPadding: 8
                    }

                    // ── Clock ─────────────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        height: 90
                        radius: 12
                        color: root.colors.surface

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.clockTime
                                color: root.colors.accent
                                font.pixelSize: 38
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.clockDate
                                color: root.colors.sub
                                font.pixelSize: 12
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }

                    // ── System stats ──────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 12
                        color: root.colors.surface
                        height: statsCol.implicitHeight + 24

                        ColumnLayout {
                            id: statsCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 6

                            Text { text: "SYSTEM"; color: root.colors.sub; font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font" }

                            StatBar { label: "󰻠 CPU";  value: root.cpuUsage;  barColor: root.colors.teal;    textColor: root.colors.text; subColor: root.colors.sub; surfaceColor: root.colors.surface2 }
                            StatBar { label: "󰍛 RAM";  value: root.ramUsage;  barColor: root.colors.accent;  textColor: root.colors.text; subColor: root.colors.sub; surfaceColor: root.colors.surface2 }
                            StatBar { label: "󰋊 Disk"; value: root.diskUsage; barColor: root.colors.accent2; textColor: root.colors.text; subColor: root.colors.sub; surfaceColor: root.colors.surface2 }

                            Text {
                                text: "󰔛 " + root.uptimeStr + "   󰖩 " + root.netName
                                color: root.colors.sub
                                font.pixelSize: 10
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // ── Media player ──────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 12
                        color: root.colors.surface
                        height: mediaCol.implicitHeight + 24

                        ColumnLayout {
                            id: mediaCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 6

                            Text { text: "NOW PLAYING"; color: root.colors.sub; font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font" }

                            Text {
                                text: root.mediaTitle
                                color: root.colors.text
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: root.mediaArtist
                                color: root.colors.sub
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 8

                                SidebarButton { icon: "󰒮"; accent: root.colors.surface2; fg: root.colors.text; onClicked: root.run("playerctl previous") }
                                SidebarButton {
                                    icon: root.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                                    accent: root.colors.accent
                                    fg: root.colors.bg
                                    btnW: 44; btnH: 44
                                    onClicked: root.run("playerctl play-pause")
                                }
                                SidebarButton { icon: "󰒭"; accent: root.colors.surface2; fg: root.colors.text; onClicked: root.run("playerctl next") }
                            }
                        }
                    }

                    // ── Volume ────────────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 12
                        color: root.colors.surface
                        height: volCol.implicitHeight + 24

                        ColumnLayout {
                            id: volCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 6

                            Text { text: "VOLUME"; color: root.colors.sub; font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font" }

                            RowLayout {
                                spacing: 8
                                Text { text: "󰕿"; color: root.colors.sub; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" }
                                Slider {
                                    Layout.fillWidth: true
                                    from: 0; to: 100
                                    value: root.volumeLevel
                                    onMoved: root.run("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.round(value) + "%")

                                    background: Rectangle {
                                        x: parent.leftPadding
                                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                        width: parent.availableWidth
                                        height: 6
                                        radius: 3
                                        color: root.colors.surface2

                                        Rectangle {
                                            width: parent.parent.visualPosition * parent.width
                                            height: parent.height
                                            radius: parent.radius
                                            color: root.colors.accent
                                        }
                                    }

                                    handle: Rectangle {
                                        x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                                        width: 16; height: 16
                                        radius: 8
                                        color: root.colors.accent
                                    }
                                }
                                Text {
                                    text: root.volumeLevel + "%"
                                    color: root.colors.sub
                                    font.pixelSize: 10
                                    font.family: "JetBrainsMono Nerd Font"
                                    Layout.preferredWidth: 32
                                }
                            }
                        }
                    }

                    // ── Theme switcher ────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 12
                        color: root.colors.surface
                        height: themeCol.implicitHeight + 50

                        ColumnLayout {
                            id: themeCol
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 6

                            Text { text: "THEME"; color: root.colors.sub; font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font" }

                            Flow {
                                Layout.fillWidth: true
                                spacing: 4

                                Repeater {
                                    model: [
                                        { label: "Cat", theme: "catppuccin" },
                                        { label: "Tok", theme: "tokyonight" },
                                        { label: "Grv", theme: "gruvbox"    },
                                        { label: "Nrd", theme: "nord"       },
                                        { label: "Ros", theme: "rosepine"   },
                                        { label: "Evr", theme: "everforest" }
                                    ]

                                    Rectangle {
                                        width: 38; height: 26
                                        radius: 8
                                        color: root.colors.theme === modelData.theme
                                               ? root.colors.accent
                                               : root.colors.surface2

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.label
                                            font.pixelSize: 10
                                            font.bold: true
                                            font.family: "JetBrainsMono Nerd Font"
                                            color: root.colors.theme === modelData.theme
                                                   ? root.colors.bg
                                                   : root.colors.text
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.run(
                                                "bash ~/.config/hypr/scripts/theme-switch.sh "
                                                + modelData.theme
                                            )
                                        }

                                        Behavior on color { ColorAnimation { duration: 200 } }
                                    }
                                }
                            }
                        }
                    }

                    // ── Quick actions ─────────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 12
                        color: root.colors.surface
                        height: actionsRow.implicitHeight + 24

                        RowLayout {
                            id: actionsRow
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 12 }
                            spacing: 6

                            SidebarButton { icon: "󰹑"; accent: root.colors.surface2; fg: root.colors.text;    onClicked: root.run("grim ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png && notify-send HyDE 'Screenshot saved'") }
                            SidebarButton { icon: "󰖩"; accent: root.colors.surface2; fg: root.colors.accent2; onClicked: root.run("nm-connection-editor &") }
                            SidebarButton { icon: "󰋋"; accent: root.colors.surface2; fg: root.colors.accent;  onClicked: root.run("pavucontrol &") }
                            SidebarButton { icon: "󰸉"; accent: root.colors.surface2; fg: root.colors.teal;    onClicked: root.run("bash ~/.config/hypr/scripts/wallpaper-switcher.sh &") }
                            SidebarButton { icon: "󰐥"; accent: root.colors.red;      fg: root.colors.bg;      onClicked: root.run("bash ~/.config/hypr/scripts/powermenu.sh &") }
                        }
                    }

                    Item { Layout.preferredHeight: 4 }
                }
            }
        }
    }

    // ── Reusable components ───────────────────────────────────────────────────
    component StatBar: ColumnLayout {
        property string label: ""
        property int value: 0
        property color barColor: "#CBA6F7"
        property color textColor: "#CDD6F4"
        property color subColor: "#6C7086"
        property color surfaceColor: "#45475A"

        Layout.fillWidth: true
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: label
                color: subColor
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
                Layout.fillWidth: true
            }
            Text {
                text: value + "%"
                color: subColor
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 5
            radius: 3
            color: surfaceColor

            Rectangle {
                width: Math.max(0, Math.min(parent.width, parent.width * value / 100))
                height: parent.height
                radius: parent.radius
                color: barColor
                Behavior on width { NumberAnimation { duration: 500 } }
            }
        }
    }

    component SidebarButton: Rectangle {
        id: btn
        property string icon: ""
        property color accent: "#313244"
        property color fg: "#CDD6F4"
        property int btnW: 36
        property int btnH: 36
        signal clicked()

        width: btnW
        height: btnH
        radius: 10
        color: accent

        Text {
            anchors.centerIn: parent
            text: btn.icon
            color: btn.fg
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: btn.clicked()
            onEntered: btn.opacity = 0.8
            onExited:  btn.opacity = 1.0
        }

        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
