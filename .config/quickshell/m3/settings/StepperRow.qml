import QtQuick
import qs.tokens
import qs.components

SRow {
    id: root
    property real value: 0
    property real step: 1
    property real min: 0
    property real max: 100
    property string suffix: ""
    signal picked(real v)
    M3Button { icon: "remove"; variant: "text"; size: "xs"; onClicked: root.picked(Math.max(root.min, root.value - root.step)) }
    M3Text { width: 72; height: 32; horizontalAlignment: Text.AlignHCenter; text: root.value + root.suffix; role: M3Type.titleSmall }
    M3Button { icon: "add"; variant: "text"; size: "xs"; onClicked: root.picked(Math.min(root.max, root.value + root.step)) }
}
