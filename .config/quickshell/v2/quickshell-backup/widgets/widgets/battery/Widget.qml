import QtQuick
import Quickshell.Services.UPower
import "../../core"
import "../../components"

Item {
    id: root

    property int cols: 3
    property int rows: 1
    property var settings: ({})
    property color accent:  Theme.accent
    property color accent2: Theme.accent2
    property color accent3: Theme.accent3

    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev !== null && dev.isPresent
    readonly property real pct: present ? dev.percentage : 0     // 0..1
    readonly property bool charging: present && dev.state === UPowerDeviceState.Charging
    readonly property bool full: present && dev.state === UPowerDeviceState.FullyCharged
    readonly property bool low: present && !charging && !full && pct <= 0.15
    readonly property bool warning: present && !charging && !full && pct <= 0.30

    readonly property color valueColor:
        low ? Theme.danger : warning ? Theme.warn : charging ? root.accent : Theme.onSurface
    readonly property color barColor:
        low ? Theme.danger : warning ? Theme.warn : root.accent

    function statusLabel() {
        if (!present) return "No battery";
        if (full) return "Fully charged";
        if (charging) return "Charging";
        const s = dev.timeToEmpty;
        if (s > 0) {
            const h = Math.floor(s / 3600);
            const m = Math.round((s % 3600) / 60);
            return (h > 0 ? h + "h " : "") + m + "m left";
        }
        return "On battery";
    }
    readonly property string status: statusLabel()

    Column {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 8

        Item {
            width: parent.width
            height: pctText.height

            Txt {
                id: pctText
                text: root.present ? Math.round(root.pct * 100) + "%" : "—"
                color: root.valueColor
                font.pixelSize: root.height * 0.55
                font.weight: Font.Bold
            }
            Txt {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.status
                color: Theme.onSurfaceDim
                font.pixelSize: 12
            }
        }

        Rectangle {
            width: parent.width
            height: 4
            radius: 2
            color: Theme.track

            Rectangle {
                width: parent.width * root.pct
                height: parent.height
                radius: 2
                color: root.barColor
                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            }
        }
    }
}