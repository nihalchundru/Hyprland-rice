import QtQuick
import qs.config
import qs.theme

Text {
    property string name: ""
    property real size: 20
    property bool filled: false

    text: name
    width: size
    height: size
    clip: true                      // hides the ligature word before the font loads
    color: Colors.onSurface
    font.family: Config.fontIcons
    font.pixelSize: size
    font.variableAxes: ({ "FILL": filled ? 1 : 0, "wght": 400, "GRAD": 0, "opsz": 24 })
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation { duration: M3.motion.medium2 }
    }
}