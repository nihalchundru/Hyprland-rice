pragma Singleton
import QtQuick
import Quickshell.Hyprland

Item {
    id: service
    property int activeId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    function changeWorkspace(id) {
        Hyprland.dispatch("workspace " + id)
    }
}
