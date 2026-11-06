pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev?.isPresent ?? false
    readonly property int percent: Math.round((dev?.percentage ?? 0) * 100)
    readonly property bool charging: !!dev && (dev.state === UPowerDeviceState.Charging
                                            || dev.state === UPowerDeviceState.FullyCharged)
    readonly property bool low: present && !charging && percent <= 20
    readonly property string icon: charging ? "battery_charging_full"
                                 : percent >= 95 ? "battery_full"
                                 : "battery_" + Math.floor(percent * 7 / 100) + "_bar"
}