import QtQuick
import qs.services
import qs.components

Group {
    IconButton {
        icon: "palette"
        size: 28
        iconSize: 18
        checkable: true
        checked: Panels.active === "theme"
        onClicked: Panels.toggle("theme")
    }
    IconButton {
        icon: "wallpaper"
        size: 28
        iconSize: 18
        checkable: true
        checked: Panels.active === "wallpaper"
        onClicked: Panels.toggle("wallpaper")
    }
}