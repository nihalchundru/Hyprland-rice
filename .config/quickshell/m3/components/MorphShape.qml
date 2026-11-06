import QtQuick
import qs.tokens
import qs.shapes
import "../shapes/material-shapes.js" as MS

// shape: circle square slanted arch fan arrow semiCircle oval pill triangle diamond clamShell pentagon gem
// sunny verySunny cookie4Sided cookie6Sided cookie7Sided cookie9Sided cookie12Sided ghostish clover4Leaf
// clover8Leaf burst softBurst boom softBoom flower puffy puffyDiamond pixelCircle pixelTriangle bun heart
Item {
    id: root
    property string shape: "circle"
    property real size: 48
    property color color: M3Colors.primary
    width: size; height: size

    ShapeCanvas {
        anchors.fill: parent
        color: root.color
        roundedPolygon: MS["get" + root.shape.charAt(0).toUpperCase() + root.shape.slice(1)]()
        animation: SpringAnimation {
            spring: M3Motion.spatialFast.spring
            damping: M3Motion.spatialFast.damping
            epsilon: 0.002
        }
    }
}
