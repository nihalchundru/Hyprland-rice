import QtQuick
import qs.tokens
import qs.components

// Staggered entrance: slides up and fades in after `delay` ms.
Item {
    id: rv
    property int delay: 0
    property bool on: false
    default property alias content: holder.data
    opacity: on ? 1 : 0
    FadeBehavior on opacity { time: M3Motion.medium3 }
    Timer { interval: rv.delay; running: true; onTriggered: rv.on = true }
    Item {
        id: holder
        width: parent.width; height: parent.height
        y: rv.on ? 0 : 28
        SpatialBehavior on y {}
    }
}
