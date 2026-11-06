import QtQuick
import qs.tokens
// Material Symbols Rounded (needs the variable font installed). name = ligature, e.g. "wifi".
Text {
    property string name: ""
    property real fill: 0
    property int size: 24
    text: name
    color: M3Colors.fgSurface
    width: size; height: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    font.family: M3Type.icons
    font.pixelSize: size
    font.variableAxes: ({ "FILL": fill, "wght": 400, "GRAD": 0, "opsz": Math.max(20, Math.min(48, size)) })
    FadeBehavior on fill {}
}
