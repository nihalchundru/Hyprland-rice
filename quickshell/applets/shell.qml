import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // Keep alive
    PanelWindow {
        visible: false
        WlrLayershell.namespace: "qs-applets-daemon"
        width: 1; height: 1
    }

    Process { id: runProc; command: []; running: false }
    function run(cmd) { runProc.command = ["bash", "-c", cmd]; runProc.running = true }

    // Current state readers
    property string activeBar:        "waybar"
    property string activeLayout:     "hyde-default"
    property string pickerStyle:      "compact"
    property string transition:       "grow"
    property string transitionDur:    "1.8"
    property string nightShift:       "off"
    property string cornerStyle:      "rounded"
    property string powermenuLayout:  "sidebar"
    property string rofiLayout:       "ml4w"
    property string matugenScheme:    "scheme-tonal-spot"

    function loadState() {
        stateProc.running = true
    }

    Process {
        id: stateProc
        command: ["bash", "-c", [
            "echo BAR=$(cat ~/.config/hypr/bar/active-bar 2>/dev/null || echo waybar)",
            "echo LAYOUT=$(cat ~/.config/waybar/current-layout 2>/dev/null || echo hyde-default)",
            "echo PICKER=$(cat ~/.config/rofi/picker-style 2>/dev/null || echo compact)",
            "echo TRANS=$(cat ~/.config/hypr/themes/wall-transition 2>/dev/null || echo grow)",
            "echo DUR=$(cat ~/.config/hypr/themes/wall-transition-duration 2>/dev/null || echo 1.8)",
            "echo NIGHT=$(cat ~/.config/hypr/themes/night-shift-state 2>/dev/null || echo off)",
            "echo ROFI=$(cat ~/.config/rofi/current-layout 2>/dev/null || echo ml4w)",
            "echo SCHEME=$(cat ~/.config/hypr/themes/matugen-scheme-type 2>/dev/null || echo scheme-tonal-spot)"
        ].join("; ")]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of this.text.trim().split("\n")) {
                    const [k, v] = line.split("=")
                    if (k === "BAR")    root.activeBar       = v || "waybar"
                    if (k === "LAYOUT") root.activeLayout    = v || "hyde-default"
                    if (k === "PICKER") root.pickerStyle     = v || "compact"
                    if (k === "TRANS")  root.transition      = v || "grow"
                    if (k === "DUR")    root.transitionDur   = v || "1.8"
                    if (k === "NIGHT")  root.nightShift      = v || "off"
                    if (k === "ROFI")   root.rofiLayout      = v || "ml4w"
                    if (k === "SCHEME") root.matugenScheme   = v || "scheme-tonal-spot"
                }
            }
        }
    }

    // ── Bar Switcher ──────────────────────────────────────────────────────────
    IpcHandler {
        target: "bar-switcher"
        function toggle(): void {
            root.loadState()
            barSwitcher.current = root.activeBar
            barSwitcher.open()
        }
    }
    AppletList {
        id: barSwitcher
        title: "Active Bar"; icon: ""
        options: [
            { value: "waybar",      label: "Waybar",      icon: "󰖟", desc: "Highly customizable GTK bar" },
            { value: "hyprpanel",   label: "HyprPanel",   icon: "󰒓", desc: "Hyprland native panel" },
            { value: "pill",  label: "Quickshell",  icon: "󰘔", desc: "QML-powered shell" },
        ]
        onOptionSelected: value => {
            root.activeBar = value
            root.run("echo '" + value + "' > ~/.config/hypr/bar/active-bar && bash ~/.config/hypr/scripts/bar-launch.sh '" + value + "'")
        }
    }

// ── Layout Switcher (bar-aware) ───────────────────────────────────────────
IpcHandler {
    target: "layout-switcher"
    
    function toggle(): void {
        root.loadState()
        
        if (root.activeBar === "waybar") {
            layoutSwitcher.current = root.activeLayout
            layoutSwitcher.open()
        } else if (root.activeBar === "quickshell" || root.activeBar === "notch" || root.activeBar === "pill" || root.activeBar === "island" ) {
            qsLayoutSwitcher.current = root.activeBar
            qsLayoutSwitcher.open()
        } else {
            root.run("notify-send 'HyDE' 'HyprPanel has no layout options' -t 2000")
        }
    }
}

   

    // Waybar layout switcher
    AppletList {
        id: layoutSwitcher
        title: "Waybar Layout"; icon: "󰿬"
        options: [
            { value: "hyde-default",    label: "HyDE Default",   desc: "Classic HyDE style" },
            { value: "minimal",         label: "Minimal",         desc: "Clean and simple" },
            { value: "topbar",          label: "Top Bar",         desc: "Full width top bar" },
            { value: "custom",          label: "Custom",          desc: "Custom layout" },
            { value: "custom2",         label: "Custom 2",        desc: "Second custom layout" },
            { value: "dock",            label: "Dock",            desc: "macOS-style dock" },
            { value: "glass-center",    label: "Glass Center",    desc: "Centered glass bar" },
            { value: "islands",         label: "Islands",         desc: "Floating islands" },
            { value: "dots",            label: "Dots",            desc: "Dots style" },
            { value: "omarchy",         label: "Omarchy",         desc: "Omarchy/illogical style" },
            { value: "omarchy2",        label: "Omarchy 2",       desc: "Omarchy variant 2" },
            { value: "gradient-pill",   label: "Gradient Pill",   desc: "Floating gradient pill" },
            { value: "wal",             label: "Wal",             desc: "Pywal-inspired islands" },
            { value: "polybar-classic", label: "Polybar Classic", desc: "Classic polybar style" },
        ]
        onOptionSelected: value => {
            root.activeLayout = value
            root.run("echo waybar > ~/.config/hypr/bar/active-bar && " +
                "echo '" + value + "' > ~/.config/waybar/current-layout && " +
                "pkill waybar 2>/dev/null; sleep 0.3; " +
                "waybar -c ~/.config/waybar/layouts/" + value + ".jsonc " +
                "-s ~/.config/waybar/layouts/" + value + ".css &"
            )
        }
    }

    // Quickshell layout switcher (pill vs notch)
    AppletList {
        id: qsLayoutSwitcher
        title: "Quickshell Layout"; icon: "󰘔"
        options: [
            { value: "pill", label: "Pill Bar",  icon: "󰊓", desc: "Floating pill at top" },
            { value: "notch",      label: "Notch Bar", icon: "󰄛", desc: "Apple notch style" },
            { value: "island", label: "Island Bar", icon: "󰄛", desc: "Island Bar" },
        ]
        onOptionSelected: value => {
            root.activeBar = value
            root.activeBar = value
            root.run("bash ~/.config/hypr/scripts/qs-bar-layout-switch.sh '" + value + "'")
        }

    // ── Picker Style ──────────────────────────────────────────────────────────
    IpcHandler {
        target: "picker-style"
        function toggle(): void {
            root.loadState()
            pickerStyleSwitcher.current = root.pickerStyle
            pickerStyleSwitcher.open()
        }
    }
    AppletList {
        id: pickerStyleSwitcher
        title: "Picker Style"; icon: "󰍉"
        options: [
            { value: "compact",    label: "Compact",    icon: "", desc: "Rofi list/grid style" },
            { value: "hyde",       label: "HyDE",       icon: "󰣇", desc: "HyDE fullscreen horizontal" },
            //{ value: "walker",     label: "Walker",     icon: "", desc: "Walker launcher" },
            { value: "quickshell", label: "Quickshell", icon: "󰘔", desc: "Quickshell native pickers" },
        ]
        onOptionSelected: value => {
            root.pickerStyle = value
            root.run("echo '" + value + "' > ~/.config/rofi/picker-style && notify-send 'HyDE' 'Picker Style → " + value + "' -t 2000")
        }
    }

    // ── Transition Style ──────────────────────────────────────────────────────
    IpcHandler {
        target: "transition-style"
        function toggle(): void {
            root.loadState()
            transitionSwitcher.current = root.transition
            transitionSwitcher.open()
        }
    }
    AppletList {
        id: transitionSwitcher
        title: "Transition Style"; icon: "󰑓"
        options: [
            { value: "grow",  label: "Grow",  icon: "󰊓", desc: "Expands from center outward" },
            { value: "wave",  label: "Wave",  icon: "󰇘", desc: "Liquid wave across screen" },
            { value: "wipe",  label: "Wipe",  icon: "󰇝", desc: "Sleek diagonal wipe" },
            { value: "fade",  label: "Fade",  icon: "󰘓", desc: "Smooth crossfade" },
            { value: "outer", label: "Outer", icon: "󰊐", desc: "Implodes from edges inward" },
        ]
        onOptionSelected: value => {
            root.transition = value
            root.run("echo '" + value + "' > ~/.config/hypr/themes/wall-transition && notify-send 'HyDE' 'Transition → " + value + "' -t 1500")
        }
    }

    // ── Transition Duration ───────────────────────────────────────────────────
    IpcHandler {
        target: "transition-duration"
        function toggle(): void {
            root.loadState()
            durationSwitcher.current = root.transitionDur
            durationSwitcher.open()
        }
    }
    AppletList {
        id: durationSwitcher
        title: "Transition Duration"; icon: "󰔛"
        options: [
            { value: "0.5", label: "0.5s", icon: "󰓅", desc: "Instant — snappy" },
            { value: "1.0", label: "1.0s", icon: "󰓅", desc: "Fast" },
            { value: "1.8", label: "1.8s", icon: "󰓅", desc: "Smooth — default" },
            { value: "2.5", label: "2.5s", icon: "󰓅", desc: "Slow and cinematic" },
            { value: "4.0", label: "4.0s", icon: "󰓅", desc: "Very slow and dreamy" },
        ]
        onOptionSelected: value => {
            root.transitionDur = value
            root.run("echo '" + value + "' > ~/.config/hypr/themes/wall-transition-duration && notify-send 'HyDE' 'Duration → " + value + "s' -t 1500")
        }
    }

    // ── Night Shift ───────────────────────────────────────────────────────────
    IpcHandler {
        target: "night-shift"
        function toggle(): void {
            root.loadState()
            nightShiftSwitcher.current = root.nightShift
            nightShiftSwitcher.open()
        }
    }
    AppletList {
        id: nightShiftSwitcher
        title: "Night Shift"; icon: "󰛨"
        options: [
            { value: "off",    label: "Off",    icon: "󰖨", desc: "No filter" },
            { value: "warm",   label: "Warm",   icon: "󰛨", desc: "4500K — slightly warm" },
            { value: "warmer", label: "Warmer", icon: "󰛨", desc: "3500K — warm" },
            { value: "night",  label: "Night",  icon: "󰌖", desc: "2700K — night mode" },
        ]
        onOptionSelected: value => {
            root.nightShift = value
            root.run("bash ~/.config/hypr/scripts/night-shift.sh '" + value + "'")
        }
    }

    // ── Corner Style ──────────────────────────────────────────────────────────
    IpcHandler {
        target: "corner-style"
        function toggle(): void {
            cornerSwitcher.open()
        }
    }
    AppletList {
        id: cornerSwitcher
        title: "Corner Style"; icon: "󰁊"
        options: [
            { value: "rounded", label: "Rounded", icon: "󰁊", desc: "Smooth rounded corners" },
            { value: "sharp",   label: "Sharp",   icon: "󰁌", desc: "Sharp square corners" },
        ]
        onOptionSelected: value => {
            root.run("bash ~/.config/hypr/scripts/corner-switcher.sh '" + value + "'")
        }
    }

    // ── Powermenu Layout ──────────────────────────────────────────────────────
    IpcHandler {
        target: "powermenu-layout"
        function toggle(): void {
            powermenuSwitcher.open()
        }
    }
    AppletList {
        id: powermenuSwitcher
        title: "Powermenu Layout"; icon: "⏻"
        options: [
            { value: "sidebar",     label: "Sidebar",     icon: "", desc: "Wallpaper sidebar + circles" },
            { value: "fullscreen",  label: "Fullscreen",  icon: "", desc: "Fullscreen giant circles" },
        ]
        onOptionSelected: value => {
            root.run("echo '" + value + "' > ~/.config/hypr/themes/powermenu-layout && notify-send 'HyDE' 'Powermenu → " + value + "' -t 1500")
        }
    }

    // ── Rofi Layout ───────────────────────────────────────────────────────────
    IpcHandler {
        target: "rofi-layout"
        function toggle(): void {
            root.loadState()
            rofiSwitcher.current = root.rofiLayout
            rofiSwitcher.open()
        }
    }
    AppletList {
        id: rofiSwitcher
        title: "Rofi Layout"; icon: ""
        options: [
            { value: "ml4w",        label: "ML4W",        desc: "Two-panel style" },
            { value: "compact",     label: "Compact",     desc: "Top pill style" },
            { value: "adi1090x",    label: "Adi1090x",    desc: "Image header style" },
            { value: "grid",        label: "Grid",        desc: "6-column icon grid" },
            { value: "simple-grid", label: "Simple Grid", desc: "3x3 minimal grid" },
        ]
        onOptionSelected: value => {
            root.rofiLayout = value
            root.run("echo '" + value + "' > ~/.config/rofi/current-layout && notify-send 'HyDE' 'Rofi Layout → " + value + "' -t 1500")
        }
    }

    // ── Matugen Scheme ────────────────────────────────────────────────────────
    IpcHandler {
        target: "matugen-scheme"
        function toggle(): void {
            root.loadState()
            matugenSwitcher.current = root.matugenScheme
            matugenSwitcher.open()
        }
    }
    AppletList {
        id: matugenSwitcher
        title: "Matugen Palette"; icon: "󰟡"
        options: [
            { value: "scheme-tonal-spot",  label: "Tonal Spot",  desc: "Material You default" },
            { value: "scheme-content",     label: "Content",     desc: "Matches wallpaper closely" },
            { value: "scheme-expressive",  label: "Expressive",  desc: "Colorful high contrast" },
            { value: "scheme-fidelity",    label: "Fidelity",    desc: "High fidelity to source" },
            { value: "scheme-fruit-salad", label: "Fruit Salad", desc: "Playful mixed palette" },
            { value: "scheme-monochrome",  label: "Monochrome",  desc: "Single hue variations" },
            { value: "scheme-neutral",     label: "Neutral",     desc: "Muted understated tones" },
            { value: "scheme-rainbow",     label: "Rainbow",     desc: "Full spectrum" },
            { value: "scheme-vibrant",     label: "Vibrant",     desc: "Maximum saturation" },
        ]
        onOptionSelected: value => {
            root.matugenScheme = value
            root.run("bash ~/.config/hypr/scripts/matugen-mode-switcher.sh '" + value + "'")
        }
    }
}
}
