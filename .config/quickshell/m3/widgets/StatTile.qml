import QtQuick
import qs.tokens
import qs.services
import qs.components

// cpu / ram / disk / battery: a blob that fills up with the level.
TileBase {
    id: t
    readonly property string kind: cfg.type || "cpu"
    readonly property var info: {
        switch (kind) {
        case "ram": return { label: "RAM", icon: "memory", v: SysStats.mem, ok: true }
        case "disk": return { label: "Disk", icon: "storage", v: SysStats.disk, ok: true }
        case "battery": return { label: Battery.charging ? "Charging" : "Battery", icon: Battery.present ? Battery.icon : "battery_unknown", v: Battery.percentage, ok: Battery.present }
        default: return { label: "CPU", icon: "speed", v: SysStats.cpu, ok: true }
        }
    }
    readonly property string blob: cfg.shape || "circle"

    Column {
        anchors.centerIn: parent
        spacing: 6
        Item {
            width: 60; height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            MorphShape { size: 60; shape: t.blob; color: Qt.alpha(t.accent, 0.3) }
            Item {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * (t.info.ok ? Math.max(0, Math.min(1, t.info.v)) : 0)
                clip: true
                SpatialBehavior on height {}
                MorphShape { anchors.bottom: parent.bottom; size: 60; shape: t.blob; color: t.accent }
            }
            Icon { anchors.centerIn: parent; name: t.info.icon; size: 26; fill: 1; color: t.onAccent }
        }
        M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: t.info.ok ? Math.round(t.info.v * 100) + "%" : "--"; role: ({ size: 24, line: 28, weight: Font.Bold, tracking: 0 }); color: t.fg }
        M3Text { anchors.horizontalCenter: parent.horizontalCenter; text: t.info.label; role: M3Type.labelMedium; color: t.fg; opacity: 0.7 }
    }
}
