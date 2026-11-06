import QtQuick
import qs.tokens
import qs.services
import qs.components

TileBase {
    id: t
    M3Text { x: 18; y: 12; text: Weather.ready ? Weather.temp + "\u00b0" : "--"; role: ({ size: 46, line: 52, weight: Font.Bold, tracking: -1 }); color: t.fg }
    M3Text { x: 18; anchors.bottom: parent.bottom; anchors.bottomMargin: 16; width: parent.width - 84; elide: Text.ElideRight; text: Weather.ready ? Weather.desc : "No data"; role: M3Type.labelLarge; color: t.fg; opacity: 0.85 }
    MorphShape { x: t.width - 60; y: t.height - 52; size: 78; shape: t.cfg.shape || "clover4Leaf"; color: t.accent }
    Icon { x: t.width - 36; y: t.height - 28; name: Weather.icon; size: 26; fill: 1; color: t.onAccent }
}
