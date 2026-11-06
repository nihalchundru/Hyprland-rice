import QtQuick
import qs.tokens
// role = any M3Type.* entry: {size, line, weight, tracking}
Text {
    property var role: M3Type.bodyMedium
    color: M3Colors.fgSurface
    font.family: M3Type.family
    font.pixelSize: role.size
    font.weight: role.weight
    font.letterSpacing: role.tracking
    lineHeightMode: Text.FixedHeight
    lineHeight: role.line
    verticalAlignment: Text.AlignVCenter
}
