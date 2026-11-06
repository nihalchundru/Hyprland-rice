import QtQuick
import QtQuick.Effects
import Quickshell.Hyprland

// Workspace dots. Three states: the active workspace (accent colour, with a glow),
// workspaces that have windows (a tinted colour) and empty ones (dim grey).
Row {
    id: root

    property real size: 10
    property int count: 5
    readonly property int active: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    // workspace id -> true, for every workspace that has at least one window
    readonly property var occupied: {
        const o = {};
        Hyprland.toplevels.values.forEach(t => { if (t.workspace) o[t.workspace.id] = true; });
        return o;
    }

    spacing: Math.round(size * 0.5)

    Repeater {
        model: root.count

        Rectangle {
            id: dot
            required property int index
            readonly property bool on: root.active === index + 1
            readonly property bool hasWindows: !!root.occupied[index + 1]

            width: on ? root.size * 1.7 : root.size * 0.75
            height: root.size
            radius: height / 2
            color: on ? Theme.accent : (hasWindows ? Theme.occupied : Theme.faint)

            // radiant glow behind the active dot: a blurred copy of it in the accent colour
            Item {
                z: -1
                visible: dot.on
                anchors.centerIn: parent
                width: dot.width + 40
                height: dot.height + 40
                opacity: 0.9
                layer.enabled: visible
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blurMax: 44
                    blur: 1.0
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: dot.width
                    height: dot.height
                    radius: height / 2
                    color: Theme.accent
                }
            }

            Behavior on width { NumberAnimation { duration: Theme.ms(220); easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
        }
    }
}
