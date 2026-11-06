import QtQuick
import qs.config
import qs.theme

Text {
    property string role: "bodyMedium"
    readonly property var _t: M3.type[role] ?? M3.type.bodyMedium

    color: Colors.onSurface
    font.family: Config.fontSans
    font.pixelSize: _t.size
    font.weight: _t.weight
    font.letterSpacing: _t.tracking
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation { duration: M3.motion.medium2 }
    }
}