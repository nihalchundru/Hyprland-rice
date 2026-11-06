import QtQuick
import qs.tokens

// Child of the item it describes. Bind shown to that item's hover state, e.g. shown: btn.hovered
Rectangle {
    id: root
    property string text: ""
    property bool shown: false
    property int delay: 500
    property bool vis: false
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.top
    anchors.bottomMargin: 6
    z: 1000
    width: label.implicitWidth + 16
    height: 24
    radius: 4
    color: M3Colors.inverseSurface
    opacity: vis ? 1 : 0
    scale: vis ? 1 : 0.85
    visible: opacity > 0.01
    FadeBehavior on opacity { time: M3Motion.short3 }
    SpatialBehavior on scale { eps: 0.002 }
    onShownChanged: if (!shown) vis = false
    Timer { interval: root.delay; running: root.shown; onTriggered: root.vis = true }
    M3Text { id: label; anchors.centerIn: parent; text: root.text; color: M3Colors.inverseOnSurface; role: M3Type.bodySmall }
}
