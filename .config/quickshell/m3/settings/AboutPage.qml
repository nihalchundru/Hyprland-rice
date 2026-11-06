import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.tokens
import qs.services
import qs.components
import qs.panel

Page {
    id: page
    property var info: []
    onActiveChanged: if (active) probe.running = true
    Process {
        id: probe
        command: ["sh", "-c", 'echo "$(whoami)@$(hostname)"; uname -sr; qs --version 2>/dev/null | head -1; hyprctl version 2>/dev/null | head -1; uptime -p']
        stdout: StdioCollector { onStreamFinished: page.info = text.trim().split("\n") }
    }
    SScroll {
        SCard {
            title: "System"
            Repeater {
                model: ["User", "Kernel", "Quickshell", "Hyprland", "Uptime"]
                SRow {
                    id: ar
                    required property string modelData
                    required property int index
                    title: modelData
                    M3Text { width: 360; height: 32; horizontalAlignment: Text.AlignRight; elide: Text.ElideRight; text: page.info[ar.index] || "..."; role: M3Type.bodyMedium; color: M3Colors.fgSurfaceVariant }
                }
            }
        }
        SCard {
            title: "Material 3 shell"
            SRow { icon: "folder"; title: "Open config folder"; sub: "~/.config/quickshell/m3"; M3Button { text: "Open"; variant: "tonal"; onClicked: Quickshell.execDetached(["xdg-open", Quickshell.env("HOME") + "/.config/quickshell/m3"]) } }
            SRow { icon: "edit_note"; title: "Edit config.json"; M3Button { text: "Open"; variant: "tonal"; onClicked: Quickshell.execDetached(["xdg-open", Quickshell.env("HOME") + "/.config/quickshell/m3/config.json"]) } }
            SRow { icon: "refresh"; title: "Reload shell"; M3Button { text: "Reload"; variant: "filled"; onClicked: Quickshell.reload(true) } }
        }
    }
}
