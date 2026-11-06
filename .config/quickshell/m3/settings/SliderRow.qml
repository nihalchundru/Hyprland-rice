import QtQuick
import qs.tokens
import qs.components

SRow {
    id: root
    property real from: 0
    property real to: 1
    property real step: 0
    property real value: 0
    property real displayScale: 1
    property int decimals: 0
    property string suffix: ""
    signal picked(real v)
    M3Slider { id: s; from: root.from; to: root.to; stepSize: root.step; implicitWidth: 240; onMoved: v => root.picked(v) }
    Binding { target: s; property: "value"; value: root.value }
    M3Text { width: 60; height: 44; horizontalAlignment: Text.AlignRight; text: (root.value * root.displayScale).toFixed(root.decimals) + root.suffix; role: M3Type.labelMedium; color: M3Colors.fgSurfaceVariant }
}
