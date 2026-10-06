import QtQuick
import Quickshell.Hyprland

Row {
    id: root

    property real size: 10
    property int count: 5
    readonly property int active: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    spacing: Math.round(size * 0.5)

    Repeater {
        model: root.count

        Rectangle {
            required property int index
            readonly property bool on: root.active === index + 1

            width: on ? root.size * 1.7 : root.size * 0.75
            height: root.size
            radius: height / 2
            color: on ? Theme.accent : Theme.faint

            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
}
