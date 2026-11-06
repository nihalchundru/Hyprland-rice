import QtQuick
import Quickshell.Services.SystemTray
import qs.components

Group {
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items
        delegate: TrayItem {}
    }
}