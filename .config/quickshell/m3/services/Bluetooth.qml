pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property var devices: adapter?.devices?.values ?? []
    readonly property var connectedDevices: devices.filter(d => d.connected)
    readonly property string icon: !enabled ? "bluetooth_disabled" : connectedDevices.length > 0 ? "bluetooth_connected" : "bluetooth"
    readonly property string summary: !enabled ? "Off" : connectedDevices.length > 0 ? connectedDevices[0].name + (connectedDevices.length > 1 ? " +" + (connectedDevices.length - 1) : "") : "On"

    function setEnabled(on) { if (adapter) adapter.enabled = on }
    function toggle() { setEnabled(!enabled) }
    function setScanning(on) { if (adapter) adapter.discovering = on }
    function toggleDevice(d) { d.connected ? d.disconnect() : d.connect() }
}
