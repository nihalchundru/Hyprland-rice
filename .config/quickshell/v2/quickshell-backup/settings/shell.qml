import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    PanelWindow {
        visible: false
        WlrLayershell.namespace: "qs-settings-daemon"
        width: 1; height: 1
    }

    property var colors: ({
        bg: "#1E1E2E", surface: "#313244", surface2: "#45475A",
        text: "#CDD6F4", sub: "#6C7086", accent: "#CBA6F7",
        accent2: "#89B4FA", green: "#A6E3A1", red: "#F38BA8", yellow: "#F9E2AF"
    })

    Process {
        id: colorReader
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"]
        stdout: StdioCollector {
            onStreamFinished: { try { root.colors = JSON.parse(this.text) } catch(e) {} }
        }
        running: true
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: colorReader.running = true }

    Process { id: runProc; running: false }
    function run(cmd) { runProc.command = ["bash","-c",cmd]; runProc.running = true }

    // ── State ─────────────────────────────────────────────────────────────────
    property string activeTheme:     "catppuccin"
    property string activeBar:       "waybar"
    property string activeLayout:    "hyde-default"
    property string pickerStyle:     "compact"
    property string cornerStyle:     "rounded"
    property string nightShift:      "off"
    property string transition:      "grow"
    property string transitionDur:   "1.8"
    property string lockscreen:      "hyprlock"
    property string idleTimeout:     "300"
    property string matugenScheme:   "scheme-tonal-spot"
    property string activeShell:     "hyde"
    property var    themes:          []

    Process {
        id: stateLoader
        command: ["bash", "-c", [
            "echo THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin)",
            "echo BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)",
            "echo LAYOUT=$(cat ~/.config/waybar/current-layout 2>/dev/null || echo hyde-default)",
            "echo PICKER=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)",
            "echo NIGHT=$(cat ~/.config/hypr/themes/night-shift-state 2>/dev/null || echo off)",
            "echo TRANS=$(cat ~/.config/hypr/themes/wall-transition 2>/dev/null || echo grow)",
            "echo DUR=$(cat ~/.config/hypr/themes/wall-transition-duration 2>/dev/null || echo 1.8)",
            "echo LOCK=$(cat ~/.config/hypr/active-lockscreen 2>/dev/null || echo hyprlock)",
            "echo IDLE=$(awk '/^[[:space:]]*timeout[[:space:]]*=/{print $3; exit}' ~/.config/hypr/hypridle.conf 2>/dev/null || echo 300)",
            "echo SCHEME=$(cat ~/.config/hypr/themes/matugen-scheme-type 2>/dev/null || echo scheme-tonal-spot)",
            "echo CORNER=$(hyprctl getoption decoration.rounding 2>/dev/null | awk '/^int:/{print ($2 > 0) ? \"rounded\" : \"sharp\"}')"
        ].join("; ")]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of this.text.trim().split("\n")) {
                    const eq = line.indexOf("=")
                    if (eq < 0) continue
                    const k = line.slice(0, eq)
                    const v = line.slice(eq + 1).trim()
                    if (k === "THEME")  root.activeTheme   = v
                    if (k === "BAR")    root.activeBar     = v
                    if (k === "LAYOUT") root.activeLayout  = v
                    if (k === "PICKER") root.pickerStyle   = v
                    if (k === "NIGHT")  root.nightShift    = v
                    if (k === "TRANS")  root.transition    = v
                    if (k === "DUR")    root.transitionDur = v
                    if (k === "LOCK")   root.lockscreen    = v
                    if (k === "IDLE")   root.idleTimeout   = v
                    if (k === "SCHEME") root.matugenScheme = v
                    if (k === "CORNER") root.cornerStyle   = v
                }
            }
        }
    }

    // Load themes from themes.json
    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/theme-switcher/themes.json"
        onTextChanged: {
            try { root.themes = JSON.parse(this.text()) } catch(e) {}
        }
    }

    function idleLabel(val) {
        const n = parseInt(val)
        if (n >= 99999999) return "Never"
        if (n < 60) return n + " Seconds"
        if (n === 60)   return "1 Minute"
        if (n === 120)  return "2 Minutes"
        if (n === 300)  return "5 Minutes"
        if (n === 600)  return "10 Minutes"
        if (n === 900)  return "15 Minutes"
        if (n === 1800) return "30 Minutes"
        return Math.round(n/60) + " Minutes"
    }

    IpcHandler {
        target: "settings"
        function toggle(): void {
            if (settingsWindow.visible) {
                settingsWindow.visible = false
            } else {
                stateLoader.running = true
                settingsWindow.visible = true
                sidebar.currentSection = "appearance"
            }
        }
    }

    PanelWindow {
        id: settingsWindow
        visible: false
        focusable: true
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "qs-settings"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }

        Keys.onEscapePressed: settingsWindow.visible = false

        MouseArea {
            anchors.fill: parent
            onClicked: settingsWindow.visible = false
            Rectangle { anchors.fill: parent; color: Qt.rgba(0,0,0,0.55) }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 1000; height: 620
            radius: 20
            color: root.colors.bg
            border.color: root.colors.accent
            border.width: 1
            antialiasing: true
            Behavior on color        { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            MouseArea { anchors.fill: parent; onClicked: e => e.accepted = true }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ── Sidebar ───────────────────────────────────────────────────
                Rectangle {
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    color: root.colors.surface
                    radius: 20

                    // Only round left side
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        width: 100
                        color: parent.color
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 2

                        // Header
                        Text {
                            text: "⚙  Settings"
                            color: root.colors.accent
                            font.pixelSize: 16; font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                            Layout.bottomMargin: 12
                            leftPadding: 4
                        }

                        Repeater {
                            model: [
                                { id: "appearance", icon: "󰟡", label: "Appearance" },
                                { id: "bar",        icon: "",  label: "Bar" },
                                { id: "wallpaper",  icon: "󰸉", label: "Wallpaper" },
                                { id: "transitions",icon: "󰑓", label: "Transitions" },
                                { id: "display",    icon: "󰍹", label: "Display" },
                                { id: "system",     icon: "",  label: "System" },
                                { id: "about",      icon: "󰋖", label: "About" },
                            ]
                            Rectangle {
                                Layout.fillWidth: true
                                height: 40; radius: 10
                                color: sidebar.currentSection === modelData.id
                                    ? root.colors.surface2 : "transparent"
                                Behavior on color { ColorAnimation { duration: 120 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    Rectangle {
                                        width: 3; height: 20; radius: 2
                                        color: sidebar.currentSection === modelData.id
                                            ? root.colors.accent : "transparent"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    Text {
                                        text: modelData.icon
                                        color: sidebar.currentSection === modelData.id
                                            ? root.colors.accent : root.colors.sub
                                        font.pixelSize: 15
                                        font.family: "JetBrainsMono Nerd Font"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }
                                    Text {
                                        text: modelData.label
                                        color: sidebar.currentSection === modelData.id
                                            ? root.colors.text : root.colors.sub
                                        font.pixelSize: 12
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.bold: sidebar.currentSection === modelData.id
                                        Layout.fillWidth: true
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: sidebar.currentSection = modelData.id
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Close button
                        Rectangle {
                            Layout.fillWidth: true
                            height: 36; radius: 10
                            color: closeHov.containsMouse
                                ? Qt.rgba(
                                    parseInt(root.colors.red.slice(1,3),16)/255,
                                    parseInt(root.colors.red.slice(3,5),16)/255,
                                    parseInt(root.colors.red.slice(5,7),16)/255,
                                    0.15) : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            RowLayout {
                                anchors.centerIn: parent; spacing: 8
                                Text { text: "✕"; color: root.colors.red; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: "Close"; color: root.colors.red; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            }
                            MouseArea { id: closeHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: settingsWindow.visible = false }
                        }
                    }

                    QtObject { id: sidebar; property string currentSection: "appearance" }
                }

                // ── Content area ──────────────────────────────────────────────
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: contentCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: contentCol
                        width: 5000
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 20
                        spacing: 20
//                        topPadding: 16
//                        bottomPadding: 16

                        // ══ APPEARANCE ════════════════════════════════════════
                        SettingsGroup {
                            visible: sidebar.currentSection === "appearance"
                            title: "󰟡  Appearance"
                            colors: root.colors

                            // Theme grid
                            SettingsLabel { text: "Theme"; colors: root.colors }
                            Flow {
                                Layout.fillWidth: true
                                spacing: 8
                                Repeater {
                                    model: root.themes
                                    Rectangle {
                                        id: themeCard
                                        required property var modelData
                                        required property int index
                                        width: 120; height: 72; radius: 12
                                        color: modelData.bgBase || "#1E1E2E"
                                        border.color: root.activeTheme === modelData.name
                                            ? (modelData.accentPrimary || root.colors.accent)
                                            : "transparent"
                                        border.width: root.activeTheme === modelData.name ? 2 : 0
                                        Behavior on border.color { ColorAnimation { duration: 150 } }
                                        scale: themeHov.containsMouse ? 1.04 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 4

                                            Text {
                                                text: modelData.name || ""
                                                color: modelData.textPrimary || "#CDD6F4"
                                                font.pixelSize: 10; font.bold: true
                                                font.family: "JetBrainsMono Nerd Font"
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                            Row {
                                                spacing: 4
                                                Repeater {
                                                    model: [
                                                        modelData.accentPrimary,
                                                        modelData.accentGreen,
                                                        modelData.accentRed,
                                                        modelData.accentOrange
                                                    ]
                                                    Rectangle {
                                                        required property var modelData
                                                        width: 16; height: 16; radius: 8
                                                        color: modelData || "#888"
                                                    }
                                                }
                                            }
                                        }

                                        // Active checkmark
                                        Rectangle {
                                            anchors.top: parent.top
                                            anchors.right: parent.right
                                            anchors.margins: 4
                                            width: 18; height: 18; radius: 9
                                            color: themeCard.modelData.accentPrimary || root.colors.accent
                                            visible: root.activeTheme === themeCard.modelData.name
                                            Text { anchors.centerIn: parent; text: "✓"; color: themeCard.modelData.bgBase || "#1E1E2E"; font.pixelSize: 10; font.bold: true }
                                        }

                                        MouseArea {
                                            id: themeHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.activeTheme = themeCard.modelData.name
                                                root.run("bash ~/.config/hypr/scripts/theme-switch.sh " + themeCard.modelData.name)
                                            }
                                        }
                                    }
                                }
                            }

                            // Light/dark toggle
                            SettingsLabel { text: "Light / Dark Mode"; colors: root.colors }
                            SettingsRow {
                                label: "Toggle for gruvbox, nord, solarized"
                                colors: root.colors
                                control: Rectangle {
                                    width: 10; height: 32; radius: 8
                                    color: root.colors.accent
                                    Text { anchors.centerIn: parent; text: "Toggle Mode"; color: root.colors.bg; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.run("bash ~/.config/hypr/scripts/theme-mode-switcher.sh") }
                                }
                            }

                            // Corner style
                            SettingsLabel { text: "Corner Style"; colors: root.colors }
                            OptionRow {
                                colors: root.colors
                                current: root.cornerStyle
                                options: [
                                    { value: "rounded", label: "Rounded" },
                                    { value: "sharp",   label: "Sharp" }
                                ]
                                onSelected: v => {
                                    root.cornerStyle = v
                                    root.run("bash ~/.config/hypr/scripts/corner-switcher.sh " + v)
                                }
                            }
                        }

                        // ══ BAR ═══════════════════════════════════════════════
                        SettingsGroup {
                            visible: sidebar.currentSection === "bar"
                            title: "  Bar"
                            colors: root.colors

                            SettingsLabel { text: "Active Bar"; colors: root.colors }
                            OptionRow {
                                colors: root.colors; current: root.activeBar
                                options: [
                                    { value: "waybar",     label: "Waybar" },
                                    { value: "hyprpanel",  label: "HyprPanel" },
                                    { value: "quickshell", label: "Quickshell" },
                                ]
                                onSelected: v => {
                                    root.activeBar = v
                                    root.run("echo " + v + " > ~/.config/hypr/bar/active-bar && bash ~/.config/hypr/scripts/bar-launch.sh " + v)
                                }
                            }
                            // Quickshell layouts
                            SettingsLabel {
                                text: "Quickshell Layout"
                                colors: root.colors
                                visible: root.activeBar === "quickshell" || root.activeBar === "notch"
                            }
                            OptionRow {
                                colors: root.colors; current: root.activeBar
                                options: [
                                    { value: "quickshell", label: "Pill" },
                                    { value: "notch", label: "Notch" },
                                ]
                                onSelected: v => {
                                    root.activeBar = v
                                    root.run("echo " + v + " > ~/.config/hypr/bar/active-bar && bash ~/.config/hypr/scripts/qs-bar-layout-switch.sh " + v)
                                }
                            }
                            // Waybar layouts
                            SettingsLabel {
                                text: "Waybar Layout"
                                colors: root.colors
                                visible: root.activeBar === "waybar"
                            }
                            Flow {
                                visible: root.activeBar === "waybar"
                                Layout.fillWidth: true; spacing: 6
                                Repeater {
                                    model: ["hyde-default","minimal","topbar","custom","custom2",
                                            "dock","glass-center","islands","dots","omarchy",
                                            "omarchy2","gradient-pill","wal","polybar-classic"]
                                    Rectangle {
                                        required property string modelData
                                        height: 32; radius: 8
                                        width: layoutLbl.width + 20
                                        color: root.activeLayout === modelData
                                            ? root.colors.accent : root.colors.surface
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Text {
                                            id: layoutLbl
                                            anchors.centerIn: parent
                                            text: modelData
                                            color: root.activeLayout === parent.modelData
                                                ? root.colors.bg : root.colors.text
                                            font.pixelSize: 11
                                            font.family: "JetBrainsMono Nerd Font"
                                        }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.activeLayout = parent.modelData
                                                root.run(
                                                    "echo " + parent.modelData + " > ~/.config/waybar/current-layout && " +
                                                    "pkill waybar 2>/dev/null; sleep 0.3; " +
                                                    "waybar -c ~/.config/waybar/layouts/" + parent.modelData + ".jsonc " +
                                                    "-s ~/.config/waybar/layouts/" + parent.modelData + ".css &"
                                                )
                                            }
                                        }
                                    }
                                }
                            }

                            // Picker style
                            SettingsLabel { text: "Picker Style"; colors: root.colors }
                            OptionRow {
                                colors: root.colors; current: root.pickerStyle
                                options: [
                                    { value: "compact",    label: "Compact" },
                                    { value: "hyde",       label: "HyDE" },
                                    { value: "walker",     label: "Walker" },
                                    { value: "quickshell", label: "Quickshell" },
                                ]
                                onSelected: v => {
                                    root.pickerStyle = v
                                    root.run("echo " + v + " > ~/.config/rofi/picker-style")
                                }
                            }
                        }

                        // ══ WALLPAPER ══════════════════════════════════════════
                        SettingsGroup {
                            visible: sidebar.currentSection === "wallpaper"
                            title: "󰸉  Wallpaper"
                            colors: root.colors

                            SettingsLabel { text: "Current Theme Wallpapers"; colors: root.colors }

                            // Wallpaper grid
                            property var wallpapers: []
                            property bool wallsLoaded: false

                            Process {
                                id: wallScanner
                                command: ["bash", "-c",
                                    "THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo catppuccin); " +
                                    "find ~/.config/hypr/wallpapers/$THEME -type f \\( -iname '*.png' -o -iname '*.jpg' \\) 2>/dev/null | sort | head -50"
                                ]
                                stdout: SplitParser {
                                    onRead: data => {
                                        const p = data.trim()
                                        if (p) wallGroup.wallpapers = [...wallGroup.wallpapers, p]
                                    }
                                }
                            }

                            Component.onCompleted: wallScanner.running = true

                            id: wallGroup

                            GridView {
                                Layout.fillWidth: true
                                height: Math.ceil(wallGroup.wallpapers.length / 3) * 120 + 8
                                cellWidth:  Math.floor(parent.width / 3)
                                cellHeight: 120
                                model: wallGroup.wallpapers
                                interactive: false

                                delegate: Item {
                                    required property string modelData
                                    width: GridView.view.cellWidth
                                    height: GridView.view.cellHeight

                                    Rectangle {
                                        anchors.fill: parent; anchors.margins: 4; radius: 10
                                        color: root.colors.surface; clip: true

                                        Image {
                                            anchors.fill: parent; anchors.margins: 2
                                            source: "file://" + modelData
                                            fillMode: Image.PreserveAspectCrop
                                            smooth: true; mipmap: true; asynchronous: true
                                        }

                                        // Label
                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left; anchors.right: parent.right
                                            height: 22; color: Qt.rgba(0,0,0,0.6)
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.split("/").pop()
                                                color: "#fff"; font.pixelSize: 9
                                                font.family: "JetBrainsMono Nerd Font"
                                                elide: Text.ElideMiddle; width: parent.width - 8
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: root.run("bash ~/.config/hypr/scripts/set-wallpaper.sh " + modelData)
                                        }
                                    }
                                }
                            }
                        }

                        // ══ TRANSITIONS ════════════════════════════════════════
                        SettingsGroup {
                            visible: sidebar.currentSection === "transitions"
                            title: "󰑓  Transitions"
                            colors: root.colors

                            SettingsLabel { text: "Transition Style"; colors: root.colors }
                            OptionRow {
                                colors: root.colors; current: root.transition
                                options: [
                                    { value: "grow",  label: "Grow"  },
                                    { value: "wave",  label: "Wave"  },
                                    { value: "wipe",  label: "Wipe"  },
                                    { value: "fade",  label: "Fade"  },
                                    { value: "outer", label: "Outer" },
                                ]
                                onSelected: v => {
                                    root.transition = v
                                    root.run("echo " + v + " > ~/.config/hypr/themes/wall-transition")
                                }
                            }

                            SettingsLabel { text: "Transition Duration"; colors: root.colors }
                            OptionRow {
                                colors: root.colors; current: root.transitionDur
                                options: [
                                    { value: "0.5", label: "0.5s" },
                                    { value: "1.0", label: "1.0s" },
                                    { value: "1.8", label: "1.8s" },
                                    { value: "2.5", label: "2.5s" },
                                    { value: "4.0", label: "4.0s" },
                                ]
                                onSelected: v => {
                                    root.transitionDur = v
                                    root.run("echo " + v + " > ~/.config/hypr/themes/wall-transition-duration")
                                }
                            }
                        }

                        // ══ DISPLAY ════════════════════════════════════════════
                        SettingsGroup {
                            visible: sidebar.currentSection === "display"
                            title: "󰍹  Display"
                            colors: root.colors

                            SettingsLabel { text: "Night Shift"; colors: root.colors }
                            OptionRow {
                                colors: root.colors; current: root.nightShift
                                options: [
                                    { value: "off",    label: "Off"    },
                                    { value: "warm",   label: "Warm"   },
                                    { value: "warmer", label: "Warmer" },
                                    { value: "night",  label: "Night"  },
                                ]
                                onSelected: v => {
                                    root.nightShift = v
                                    root.run("bash ~/.config/hypr/scripts/night-shift.sh " + v)
                                }
                            }

                            // Matugen scheme — only when matugen theme active
                            SettingsLabel {
                                text: "Matugen Palette Scheme"
                                colors: root.colors
                                visible: root.activeTheme === "matugen"
                            }
                            Flow {
                                visible: root.activeTheme === "matugen"
                                Layout.fillWidth: true; spacing: 6
                                Repeater {
                                    model: ["tonal-spot","content","expressive","fidelity",
                                            "fruit-salad","monochrome","neutral","rainbow","vibrant"]
                                    Rectangle {
                                        required property string modelData
                                        height: 32; radius: 8
                                        width: schemeLbl.width + 20
                                        color: root.matugenScheme === "scheme-" + modelData
                                            ? root.colors.accent : root.colors.surface
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Text {
                                            id: schemeLbl
                                            anchors.centerIn: parent
                                            text: modelData
                                            color: root.matugenScheme === "scheme-" + parent.modelData
                                                ? root.colors.bg : root.colors.text
                                            font.pixelSize: 11
                                            font.family: "JetBrainsMono Nerd Font"
                                        }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                const scheme = "scheme-" + parent.modelData
                                                root.matugenScheme = scheme
                                                root.run("echo " + scheme + " > ~/.config/hypr/themes/matugen-scheme-type && bash ~/.config/hypr/scripts/matugen-mode-switcher.sh " + scheme)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ══ SYSTEM ════════════════════════════════════════════
                        SettingsGroup {
                            visible: sidebar.currentSection === "system"
                            title: "  System"
                            colors: root.colors

                            // Lock screen
                            SettingsLabel { text: "Lock Screen"; colors: root.colors }
                            OptionRow {
                                colors: root.colors; current: root.lockscreen
                                options: [
                                    { value: "hyprlock",   label: "Hyprlock" },
                                    { value: "quickshell", label: "Quickshell" },
                                ]
                                onSelected: v => {
                                    root.lockscreen = v
                                    root.run("echo " + v + " > ~/.config/hypr/active-lockscreen && notify-send 'HyDE' 'Lock screen → " + v + "' -t 2000")
                                }
                            }

                            // Idle timeout
                            SettingsLabel { text: "Idle Timeout"; colors: root.colors }
                            OptionRow {
                                colors: root.colors; current: root.idleTimeout
                                options: [
                                    { value: "30",       label: "30s"  },
                                    { value: "60",       label: "1m"   },
                                    { value: "120",      label: "2m"   },
                                    { value: "300",      label: "5m"   },
                                    { value: "600",      label: "10m"  },
                                    { value: "900",      label: "15m"  },
                                    { value: "1800",     label: "30m"  },
                                    { value: "99999999", label: "Never"},
                                ]
                                onSelected: v => {
                                    root.idleTimeout = v
                                    const display = parseInt(v) + 60
                                    root.run(
                                        "awk -v lock=" + v + " -v display=" + display + " '" +
                                        "BEGIN{count=0} /^[[:space:]]*timeout[[:space:]]*=/{count++; if(count==1) sub(/[0-9]+/,lock); else if(count==2) sub(/[0-9]+/,display)} {print}' " +
                                        "~/.config/hypr/hypridle.conf > /tmp/hypridle.tmp && " +
                                        "mv /tmp/hypridle.tmp ~/.config/hypr/hypridle.conf && " +
                                        "pkill hypridle; hypridle &"
                                    )
                                }
                            }

                            // Shell switch
                            SettingsLabel { text: "Shell"; colors: root.colors }
                            OptionRow {
                                colors: root.colors; current: "hyde"
                                options: [
                                    { value: "hyde",   label: "HyDE ARM" },
                                    { value: "ambxst", label: "Ambxst"   },
                                ]
                                onSelected: v => {
                                    root.run("bash ~/.config/hypr/scripts/shell-switch.sh " + v)
                                    settingsWindow.visible = false
                                }
                            }

                            // Reload
                            SettingsRow {
                                label: "Reload Hyprland"; colors: root.colors
                                control: Rectangle {
                                    width: 100; height: 32; radius: 8
                                    color: reloadHov.containsMouse
                                        ? root.colors.accent : root.colors.surface
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Text { anchors.centerIn: parent; text: "Reload"; color: reloadHov.containsMouse ? root.colors.bg : root.colors.text; font.pixelSize: 11; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                                    MouseArea { id: reloadHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.run("hyprctl reload") }
                                }
                            }
                        }

                        // ══ ABOUT ══════════════════════════════════════════════
                        SettingsGroup {
                            visible: sidebar.currentSection === "about"
                            title: "󰋖  About"
                            colors: root.colors

                            // Logo + name
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 8

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "󰣇"
                                    color: root.colors.accent
                                    font.pixelSize: 64
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "HyDE ARM"
                                    color: root.colors.text
                                    font.pixelSize: 24; font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Hyprland rice for Arch Linux ARM"
                                    color: root.colors.sub
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                            }

                            Rectangle { Layout.fillWidth: true; height: 1; color: root.colors.surface }

                            Repeater {
                                model: [
                                    { label: "Theme",    value: root.activeTheme },
                                    { label: "Bar",      value: root.activeBar },
                                    { label: "Platform", value: "Arch Linux ARM (aarch64)" },
                                    { label: "WM",       value: "Hyprland" },
                                    { label: "Shell",    value: "fish" },
                                ]
                                SettingsRow {
                                    required property var modelData
                                    label: modelData.label; colors: root.colors
                                    control: Text {
                                        text: modelData.value
                                        color: root.colors.accent
                                        font.pixelSize: 12
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Reusable components ───────────────────────────────────────────────────
    component SettingsGroup: ColumnLayout {
        property string title: ""
        property var colors
        default property alias content: grpCol.data
        Layout.fillWidth: true
        spacing: 12

        Text {
            text: title
            color: colors.accent
            font.pixelSize: 16; font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: colors.surface }

        ColumnLayout {
            id: grpCol
            Layout.fillWidth: true
            spacing: 10
        }
    }

    component SettingsLabel: Text {
        property var colors
        color: colors.sub
        font.pixelSize: 11; font.bold: true
        font.family: "JetBrainsMono Nerd Font"
        font.letterSpacing: 1.2
        text: ""
    }

    component SettingsRow: RowLayout {
        property string label: ""
        property var colors
        property alias control: controlSlot.data
        Layout.fillWidth: true

        Text {
            text: label
            color: colors.text
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
            Layout.fillWidth: true
        }
        Item { id: controlSlot }
    }

  component OptionRow: RowLayout {
    id: optionRow

    property var colors
    property string current: ""
    property var options: []
    signal selected(string value)

    Layout.fillWidth: true
    spacing: 6

        Repeater {
            model: options
            Rectangle {
                required property var modelData
                height: 32; radius: 8
                width: optLbl.width + 20
                color: parent.current === modelData.value
                    ? parent.colors.accent : parent.colors.surface
                Behavior on color { ColorAnimation { duration: 150 } }
                Text {
                    id: optLbl
                    anchors.centerIn: parent
                    text: modelData.label
                    color: parent.parent.current === parent.modelData.value
                        ? parent.parent.colors.bg : parent.parent.colors.text
                    font.pixelSize: 11; font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: optionRow.selected(modelData.value)
                }
            }
        }
    }
}
