import QtQuick
import qs.tokens
import qs.components

// Base for main-panel pages: slides + fades in/out as `current` changes.
Item {
    id: root
    property int index: 0
    property int current: 0
    readonly property bool active: current === index
    default property alias content: inner.data
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    opacity: active ? 1 : 0
    visible: opacity > 0.01
    x: active ? 0 : (index < current ? -48 : 48)
    FadeBehavior on opacity { time: M3Motion.short4 }
    SpatialBehavior on x {}
    Item { id: inner; anchors.fill: parent }
}
