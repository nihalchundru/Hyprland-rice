import QtQuick
import Quickshell
import Quickshell.Io
Item {
    id: root
    visible: false
    property color base:     "#1e1e2e"
    property color mantle:   "#181825"
    property color crust:    "#11111b"
    property color text:     "#cdd6f4"
    property color subtext0: "#a6adc8"
    property color subtext1: "#bac2de"
    property color surface0: "#313244"
    property color surface1: "#45475a"
    property color surface2: "#585b70"
    property color overlay0: "#6c7086"
    property color overlay1: "#7f849c"
    property color overlay2: "#9399b2"
    property color blue:     "#89b4fa"
    property color sapphire: "#74c7ec"
    property color peach:    "#fab387"
    property color green:    "#a6e3a1"
    property color red:      "#f38ba8"
    property color mauve:    "#cba6f7"
    property color pink:     "#f5c2e7"
    property color yellow:   "#f9e2af"
    property color maroon:   "#eba0ac"
    property color teal:     "#94e2d5"

    // Bridge: reads your existing colors.json and maps to catppuccin-style names
    Process {
        id: colorReader
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/topbar/colors.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let c = JSON.parse(this.text.trim())
                    if (c.bg)      root.base     = c.bg
                    if (c.bg2)     root.mantle   = c.bg2
                    if (c.surface) root.surface0 = c.surface
                    if (c.surface2)root.surface1 = c.surface2
                    if (c.text)    root.text     = c.text
                    if (c.sub)     root.subtext0 = c.sub
                    if (c.accent)  root.mauve    = c.accent
                    if (c.accent2) root.blue     = c.accent2
                    if (c.green)   root.green    = c.green
                    if (c.red)     root.red      = c.red
                    if (c.yellow)  root.yellow   = c.yellow
                    if (c.teal)    root.teal     = c.teal
                    // Also write /tmp/qs_colors.json for compatibility
                    // with any other components that read it
                } catch(e) {}
            }
        }
        running: true
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: colorReader.running = true }
}
