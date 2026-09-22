import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    IpcHandler {
        target: "notch"
        function toggleLauncher()  { appLauncher.toggle() }
        function toggleTheme()     { themeSwitcher.toggle() }
        function toggleWallpaper() { wallpaperSwitcher.toggle() }
        function toggleControl()   { controlPanel.toggle() }
    }
    // ── Colors ────────────────────────────────────────────────────────────────
    property var colors: ({
        bg: "#1E1E2E", surface: "#313244", surface2: "#45475A",
        text: "#CDD6F4", sub: "#6C7086", accent: "#CBA6F7",
        accent2: "#89B4FA", green: "#A6E3A1", red: "#F38BA8",
        yellow: "#F9E2AF", teal: "#94E2D5", theme: "catppuccin"
    })

    Process {
        id: colorReader
        command: ["cat", Quickshell.env("HOME") +
            "/.config/quickshell/topbar/colors.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.colors = JSON.parse(this.text) } catch(e) {}
            }
        }
        running: true
    }
    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: colorReader.running = true
    }

    // ── IPC — same targets as pill bar so keybinds work with both ────────────
//    IpcHandler {
  //      target: "notch"
    //    function toggleTheme():     void { themePopup.toggle()     }
      //  function toggleWallpaper(): void { wallpaperPopup.toggle() }
        //function toggleLauncher():  void { launcherPopup.toggle()  }
        //function toggleSidebar():   void { sidebar.toggle()        }
      //  function toggleControl():   void { controlPopup.toggle()   }
    //}

    // ── Clock ─────────────────────────────────────────────────────────────────
    property string clockTime: "00:00"
    property string clockDate: "Mon Jan 01"
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            const d = new Date()
            root.clockTime = Qt.formatDateTime(d, "hh:mm AP")
            root.clockDate = Qt.formatDateTime(d, "ddd MMM dd")
        }
    }

    // ── Active window ─────────────────────────────────────────────────────────
    property string activeWindow: ""
    Process {
        id: windowPoller
        command: ["bash", "-c",
            "hyprctl activewindow -j 2>/dev/null | " +
            "python3 -c \"import json,sys; " +
            "d=json.load(sys.stdin); " +
            "t=d.get('title',''); " +
            "print(t[:32]+'…' if len(t)>32 else t)\" 2>/dev/null || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: { root.activeWindow = this.text.trim() }
        }
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: windowPoller.running = true }

    // ── Workspaces ────────────────────────────────────────────────────────────
    property var workspaces: [1,2,3,4,5]
    property int activeWs: 1
    Process {
        id: wsPoller
        command: ["bash", "-c",
            "hyprctl activeworkspace -j 2>/dev/null | " +
            "python3 -c \"import json,sys; print(json.load(sys.stdin)['id'])\" 2>/dev/null || echo 1"]
        stdout: StdioCollector {
            onStreamFinished: { root.activeWs = parseInt(this.text.trim()) || 1 }
        }
    }
    Timer { interval: 500; running: true; repeat: true; onTriggered: wsPoller.running = true }

    Process { id: actionProc }
    function run(cmd) { actionProc.command = ["bash","-c",cmd]; actionProc.running = true }

    // ── NOTCH WINDOW ──────────────────────────────────────────────────────────
    PanelWindow {
        id: notchWindow
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "qs-notch"
        exclusiveZone: notch.expandedHeight

        // Only anchor top+horizontal center — not full width
        anchors { top: true }
        implicitWidth:  notch.notchWidth
        implicitHeight: notch.expandedHeight + 2

        // Center horizontally via margins
        WlrLayershell.margins {
            left:  (Screen.width  - notch.notchWidth)  / 2
            right: (Screen.width  - notch.notchWidth)  / 2
        }

        property bool hovered: false
        property bool expanded: hovered || anyPopupOpen

        property bool anyPopupOpen: false

        Rectangle {
            id: notch
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            // Notch dimensions
            property int notchWidth:    440
            property int collapsedHeight: 32
            property int expandedHeight:  72

            width:  notchWidth
            height: notchWindow.expanded ? expandedHeight : collapsedHeight

            // Notch shape — rounded bottom corners only (flat top)
            radius: 10

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 10
                color: parent.color
            }

            // Custom bottom-rounded shape via layer
            layer.enabled: true

            color: Qt.rgba(
                parseInt(root.colors.bg.slice(1,3), 16) / 255,
                parseInt(root.colors.bg.slice(3,5), 16) / 255,
                parseInt(root.colors.bg.slice(5,7), 16) / 255,
                0.96)

            Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            Behavior on color  { ColorAnimation  { duration: 200 } }

            // Bottom-left and bottom-right rounded corners via two rectangles
            // that clip the sharp top corners
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left:   parent.left
                anchors.right:  parent.right
                height: 20
                radius: 16
                color:  parent.color
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            // ── COLLAPSED VIEW — clock + workspace dots ────────────────────────
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin:  14
                anchors.rightMargin: 14
                spacing: 0
                opacity: notchWindow.expanded ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 150 } }
                visible: opacity > 0

                // Clock
                Text {
                    text: root.clockTime
                    color: root.colors.text
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }

                Item { Layout.fillWidth: true }

                // Workspace dots
                Row {
                    spacing: 6
                    Repeater {
                        model: 5
                        Rectangle {
                            width:  root.activeWs === (index + 1) ? 18 : 6
                            height: 6
                            radius: 3
                            color:  root.activeWs === (index + 1)
                                ? root.colors.accent
                                : root.colors.surface2
                            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation  { duration: 200 } }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.run("hyprctl dispatch workspace " + (index + 1))
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Active window title (truncated)
                Text {
                    text: root.activeWindow
                    color: root.colors.sub
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                    font.italic: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    Layout.maximumWidth: 120
                }
            }

            // ── EXPANDED VIEW ─────────────────────────────────────────────────
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6
                opacity: notchWindow.expanded ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
                visible: opacity > 0

                // Top row: clock + workspace pills + date
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Clock
                    Text {
                        text: root.clockTime
                        color: root.colors.accent
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    // Workspace pills
                    Row {
                        spacing: 4
                        Layout.alignment: Qt.AlignVCenter
                        Repeater {
                            model: 5
                            Rectangle {
                                width:  root.activeWs === (index + 1) ? 28 : 20
                                height: 20
                                radius: 10
                                color:  root.activeWs === (index + 1)
                                    ? root.colors.accent
                                    : root.colors.surface
                                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                Behavior on color { ColorAnimation  { duration: 200 } }
                                Text {
                                    anchors.centerIn: parent
                                    text: (index + 1).toString()
                                    color: root.activeWs === (index + 1)
                                        ? root.colors.bg : root.colors.sub
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.run("hyprctl dispatch workspace " + (index + 1))
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Date
                    Text {
                        text: root.clockDate
                        color: root.colors.sub
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                // Bottom row: action buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // App launcher
                    NotchBtn {
                        icon: "󰣇"; tip: "Launcher"
                        colors: root.colors
                        onActivated: root.run("bash ~/.config/hypr/scripts/launcher.sh")
                    }

                    // Theme
                    NotchBtn {
                        icon: "󰟡"; tip: "Theme"
                        colors: root.colors
                        onActivated: root.run("bash ~/.config/hypr/scripts/theme-switch.sh")
                    }

                    // Wallpaper
                    NotchBtn {
                        icon: "󰸉"; tip: "Wallpaper"
                        colors: root.colors
                        onActivated: root.run("bash ~/.config/hypr/scripts/wallpaper-switcher.sh")
                    }

                    Item { Layout.fillWidth: true }

                    // Active window
                    Text {
                        text: root.activeWindow
                        color: root.colors.sub
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                        font.italic: true
                        elide: Text.ElideRight
                        Layout.maximumWidth: 160
                    }

                    Item { Layout.fillWidth: true }

                    // Main menu
                    NotchBtn {
                        icon: "󰒓"; tip: "Menu"
                        colors: root.colors
                        onActivated: root.run("bash ~/.config/hypr/scripts/main-menu.sh")
                    }

                    // Night shift
                    NotchBtn {
                        icon: "󰛨"; tip: "Night Shift"
                        colors: root.colors
                        onActivated: root.run("bash ~/.config/hypr/scripts/night-shift.sh")
                    }

                    // Lock
                    NotchBtn {
                        icon: "󰍃"; tip: "Lock"
                        colors: root.colors
                        onActivated: root.run("bash ~/.config/hypr/scripts/lock.sh")
                    }
                }
            }

            // Hover detection
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onEntered: notchWindow.hovered = true
                onExited:  notchWindow.hovered = false
                onClicked: mouse => mouse.accepted = false
            }
        }

        // ── Notch side extensions (the "ears" that hug the screen edge) ───────
        // Left ear
        Rectangle {
            anchors.top:   notch.top
            anchors.right: notch.left
            width:  24
            height: notch.collapsedHeight
            color:  notch.color
            Behavior on color { ColorAnimation { duration: 200 } }
            // Rounded right side to blend into notch
            Rectangle {
                anchors.top:    parent.top
                anchors.right:  parent.right
                anchors.bottom: parent.bottom
                width: 12
                color: parent.color
            }
        }

        // Right ear
        Rectangle {
            anchors.top:  notch.top
            anchors.left: notch.right
            width:  24
            height: notch.collapsedHeight
            color:  notch.color
            Behavior on color { ColorAnimation { duration: 200 } }
            Rectangle {
                anchors.top:    parent.top
                anchors.left:   parent.left
                anchors.bottom: parent.bottom
                width: 12
                color: parent.color
            }
        }
    }

    // ── Reusable notch button ─────────────────────────────────────────────────
    component NotchBtn: Rectangle {
        property string icon: ""
        property string tip: ""
        property var colors
        signal activated()

        width: 32; height: 32; radius: 8
        color: btnHov.containsMouse
            ? Qt.rgba(
                parseInt(colors.accent.slice(1,3),16)/255,
                parseInt(colors.accent.slice(3,5),16)/255,
                parseInt(colors.accent.slice(5,7),16)/255,
                0.2)
            : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: icon
            color: btnHov.containsMouse ? colors.accent : colors.sub
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        // Tooltip
        Rectangle {
            anchors.top: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 4
            width: tipText.width + 12; height: 20; radius: 6
            color: colors.surface
            visible: btnHov.containsMouse && tip !== ""
            z: 999
            Text {
                id: tipText
                anchors.centerIn: parent
                text: tip
                color: colors.text
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
            }
        }

        MouseArea {
            id: btnHov
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: activated()
        }
    }

   // Bar {
     //   colors: root.colors
       // clockTime: root.clockTime
       // clockDate: root.clockDate
   // }

    ThemeSwitcher {
        id: themeSwitcher
        colors: root.colors
        palettes: root.palettes
    }

    WallpaperSwitcher {
        id: wallpaperSwitcher
        colors: root.colors
    }

    ControlPanel {
        id: controlPanel
        colors: root.colors
    }

    AppLauncher {
        id: appLauncher
        colors: root.colors
    }
}

