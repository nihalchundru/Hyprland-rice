pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    readonly property var items: SystemTray.items.values
    readonly property int count: items.length
}
