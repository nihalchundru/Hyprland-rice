pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev !== null && dev.isLaptopBattery
    readonly property real percentage: present ? dev.percentage : 0   // 0..1
    readonly property bool charging: present && dev.state === UPowerDeviceState.Charging
    readonly property bool full: present && dev.state === UPowerDeviceState.FullyCharged
    readonly property bool low: present && !charging && percentage <= 0.15
    readonly property real secondsLeft: present ? (charging ? dev.timeToFull : dev.timeToEmpty) : 0
    readonly property bool onBattery: UPower.onBattery
    readonly property string icon: !present ? "battery_unknown" : charging ? "battery_charging_full" : percentage >= 0.95 ? "battery_full" : "battery_" + Math.min(6, Math.floor(percentage * 7)) + "_bar"
}
