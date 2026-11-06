import QtQuick
import "rounded-polygon-qmljs"
import "rounded-polygon-qmljs/material-shapes.js" as MaterialShapes

// Draws one Material 3 shape at a given pixel size and color.
// `shape` is the name without "get", e.g. "Cookie9Sided", "Gem", "Heart".
// Full list in ShapeList.js.
//
// Shapes in the library are normalized to 0..1, and ShapeCanvas scales them
// to min(width, height), so this is always a square box.
// Changing `shape` at runtime morphs smoothly. Changing `color` repaints.
// For cheap animation, animate this item's scale/rotation/opacity
// (no canvas repaint) rather than `size`.
Item {
    id: root

    property string shape: "Circle"
    property color color: "white"
    property real size: 48

    implicitWidth: size
    implicitHeight: size

    ShapeCanvas {
        anchors.fill: parent
        color: root.color
        antialiasing: true
        roundedPolygon: {
            const getter = MaterialShapes["get" + root.shape];
            if (!getter) {
                console.warn("[lockscreen] unknown shape:", root.shape);
                return MaterialShapes.getCircle();
            }
            return getter();
        }
    }
}
