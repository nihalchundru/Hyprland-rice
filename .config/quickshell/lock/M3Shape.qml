import QtQuick
import QtQuick.Shapes
import "M3Shapes.js" as Shapes

// Renders any Material 3 shape, and morphs between two of them.
//
//   M3Shape { kind: "sunny"; fillColor: M3Theme.palette.primaryContainer }
//   M3Shape { kind: "star12"; fromKind: "circle"; morph: 0.5 }   // halfway
//
// Set `width`/`height` (or anchor it) -- the path is generated to fill the
// item's box, and is rebuilt automatically when the size changes.
Shape {
    id: root

    property string kind: "circle"
    // When set (together with morph < 1) the outline is interpolated from this
    // shape to `kind`.
    property string fromKind: ""
    property real morph: 1
    property int samples: Shapes.SAMPLES

    property color fillColor: M3Theme.palette.primary
    property color strokeColor: "transparent"
    property int strokeWidth: 0

    implicitWidth: 48
    implicitHeight: 48
    antialiasing: true

    ShapePath {
        fillColor: root.fillColor
        strokeColor: root.strokeColor
        strokeWidth: root.strokeWidth
        capStyle: ShapePath.FlatCap
        joinStyle: ShapePath.RoundJoin

        PathSvg {
            path: Shapes.buildPath(
                root.kind,
                root.fromKind,
                root.morph,
                Math.min(root.width, root.height),
                root.width / 2,
                root.height / 2
            )
        }
    }
}
