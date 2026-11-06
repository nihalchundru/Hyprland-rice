pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property var devices: Bluetooth.devices.values
    readonly property var connectedDevices: devices.filter(d => d.connected)

    function toggle() { if (adapter) adapter.enabled = !adapter.enabled }
    readonly property string icon: !enabled ? "bluetooth_disabled" : connectedDevices.length > 0 ? "bluetooth_connected" : "bluetooth"
}
