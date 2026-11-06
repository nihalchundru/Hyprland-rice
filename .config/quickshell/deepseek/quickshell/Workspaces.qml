import Quickshell
import Quickshell.Hyprland
import QtQuick

// Workspace chips for the monitor this bar is on.
// Hyprland.workspaces is an ObjectModel<HyprlandWorkspace>, so Repeater hands
// each workspace to the delegate as `modelData`.
Row {
    id: root

    property var monitor: null
    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: chip

            required property var modelData

            // Compare by monitor *name* ("DP-1", "eDP-1", ...) rather than
            // object identity. Hyprland.monitorFor() and a workspace's
            // `monitor` are not guaranteed to be the same JS object, and an
            // identity check that fails does so silently -- as an empty
            // workspace row. Falls back to showing everything if the monitor
            // hasn't resolved yet.
            readonly property bool onThisMonitor: {
                if (!root.monitor) return true;
                const mon = modelData.monitor;
                if (!mon) return false;
                return mon.name === root.monitor.name;
            }
            readonly property bool isFocused: modelData.focused

            // Row skips invisible children when laying out, so filtering here
            // costs no horizontal space.
            visible: onThisMonitor
            implicitWidth: Math.max(21, name.implicitWidth + 14)
            implicitHeight: 22
            radius: 7
            color: isFocused ? Theme.tomato : (modelData.active ? Theme.surfaceHi : "transparent")
            border.width: 1
            border.color: modelData.urgent ? Theme.cheese : Theme.line

            Behavior on color { ColorAnimation { duration: Theme.animMed } }

            Text {
                id: name
                anchors.centerIn: parent
                text: chip.modelData.name
                color: chip.isFocused ? "#ffffff" : Theme.muted
                font.family: Theme.mono
                font.pixelSize: 11
                font.bold: chip.isFocused
            }

            // little marker when a client on this workspace is fullscreen
            Rectangle {
                width: 4
                height: 4
                radius: 2
                color: Theme.cheese
                visible: chip.modelData.hasFullscreen
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: 3
                    rightMargin: 3
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: chip.modelData.activate()
            }
        }
    }
}
