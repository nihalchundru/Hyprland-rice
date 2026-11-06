import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import qs.config
import qs.theme
import qs.components

Group {
    visible: (ToplevelManager.activeToplevel?.title ?? "") !== ""

    M3Text {
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        Layout.preferredWidth: Math.min(implicitWidth, Config.bar.titleMaxWidth)
        text: ToplevelManager.activeToplevel?.title ?? ""
        role: "labelLarge"
        color: Colors.onSurfaceVariant
    }
}