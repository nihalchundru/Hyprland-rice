pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property string active: ""      // "" | "launcher" | "theme" | "wallpaper"

    function toggle(name) { active = active === name ? "" : name }
    function open(name)   { active = name }
    function close()      { active = "" }
}