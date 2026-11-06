pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery (UPower) + power profiles.
Singleton {
    id: root
    readonly property var dev: UPower.displayDevice
    readonly property bool hasBattery: dev?.ready && dev?.isLaptopBattery
    readonly property real percent: dev?.percentage ?? 0          // 0..1
    readonly property bool charging: dev?.state === UPowerDeviceState.Charging || dev?.state === UPowerDeviceState.FullyCharged
    readonly property bool low: hasBattery && !charging && percent <= 0.2
    readonly property real secondsLeft: charging ? (dev?.timeToFull ?? 0) : (dev?.timeToEmpty ?? 0)
    readonly property string icon: {
        if (!hasBattery) return "power";
        if (charging) return "battery_charging_full";
        const l = Math.round(percent * 6);
        return ["battery_0_bar","battery_1_bar","battery_2_bar","battery_3_bar","battery_4_bar","battery_5_bar","battery_full"][l];
    }

    // profile: PowerProfile.PowerSaver / Balanced / Performance
    readonly property int profile: PowerProfiles.profile
    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile
    readonly property string profileName: profile === PowerProfile.PowerSaver ? "Power saver" : profile === PowerProfile.Performance ? "Performance" : "Balanced"
    readonly property string profileIcon: profile === PowerProfile.PowerSaver ? "eco" : profile === PowerProfile.Performance ? "bolt" : "balance"
    function setProfile(p) { PowerProfiles.profile = p }
    function cycleProfile() {
        const order = hasPerformance ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance] : [PowerProfile.PowerSaver, PowerProfile.Balanced];
        setProfile(order[(order.indexOf(profile) + 1) % order.length]);
    }
}
