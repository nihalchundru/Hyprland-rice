import QtQuick
import qs.tokens
import qs.services
import qs.components

TileBase {
    id: t
    readonly property string target: (cfg.target || "USD").toUpperCase()
    M3Text { x: 18; y: 14; text: "Rates"; role: M3Type.labelMedium; color: t.fg; opacity: 0.75 }
    M3Text { x: 18; y: 30; text: "to " + t.target; role: ({ size: 14, line: 18, weight: Font.Bold, tracking: 0 }); color: t.fg }
    MorphShape { x: t.width - 66; y: 12; size: 50; shape: t.cfg.shape || "pill"; color: t.accent }
    Icon { x: t.width - 54; y: 24; name: "payments"; size: 26; fill: 1; color: t.onAccent }
    Column {
        x: 18; anchors.bottom: parent.bottom; anchors.bottomMargin: 14
        width: parent.width - 36
        spacing: 2
        Repeater {
            model: [t.cfg.from1 || "EUR", t.cfg.from2 || "GBP"]
            Item {
                required property string modelData
                width: parent.width; height: 22
                M3Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: modelData.toUpperCase(); role: M3Type.titleSmall; color: t.fg; opacity: 0.7 }
                M3Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: Currency.fmt(Currency.rate(modelData, t.target)); role: ({ size: 16, line: 22, weight: Font.Bold, tracking: 0 }); color: t.fg }
            }
        }
    }
}
