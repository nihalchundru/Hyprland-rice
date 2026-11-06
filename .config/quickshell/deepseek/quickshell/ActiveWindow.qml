import Quickshell
import Quickshell.Hyprland
import QtQuick

// Title of the focused window, elided so a long title can't push the
// clock off centre.
Item {
    id: root

    readonly property var toplevel: Hyprland.activeToplevel

    implicitWidth: Math.min(label.implicitWidth + 16, 340)
    implicitHeight: 24

    Text {
        id: label
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
        text: root.toplevel && root.toplevel.title !== "" ? root.toplevel.title : "desktop"
        color: Theme.muted
        font.family: Theme.sans
        font.pixelSize: Theme.fontPx
    }
}
