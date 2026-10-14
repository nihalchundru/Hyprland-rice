import QtQuick
import Quickshell.Services.UPower

// Hidden automatically on machines without a battery.
Item {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev !== null && dev.isPresent
    readonly property real level: {
        if (!present) return 0;
        const p = dev.percentage;
        return Math.max(0, Math.min(1, p > 1 ? p / 100 : p));
    }
    readonly property bool charging: present && dev.state === UPowerDeviceState.Charging
    readonly property color fill: (level < 0.15 && !charging) ? Theme.red : Theme.accent

    visible: present
    width: 35
    height: 14

    Rectangle {
        id: shellRect
        width: 30
        height: 14
        radius: Theme.r(5)
        color: Theme.tileHi

        Rectangle {
            x: 0
            width: Math.max(10, parent.width * root.level)
            height: parent.height
            radius: Theme.r(5)
            color: root.fill
            Behavior on width { NumberAnimation { duration: Theme.ms(300); easing.type: Easing.OutCubic } }
        }
    }

    Rectangle {
        x: 31
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: 6
        radius: Theme.r(1.5)
        color: root.fill
    }
}
