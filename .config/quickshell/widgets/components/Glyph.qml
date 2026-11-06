import QtQuick
import QtQuick.Shapes

Item {
    id: g

    property string kind: "play"            // play | pause | prev | next
    property color color: "white"

    implicitWidth: 16
    implicitHeight: 16

    readonly property real u: Math.min(width, height) / 16
    readonly property bool triRight: kind === "play" || kind === "next"
    readonly property real triX: kind === "next" ? 2 : 4
    readonly property real triW: kind === "next" ? 9 : 10

    function pt(x, y) { return Qt.point(x * u, y * u); }

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        // right-pointing triangle (play, next)
        ShapePath {
            fillColor: g.triRight ? g.color : "transparent"
            strokeColor: "transparent"
            PathPolyline {
                path: [g.pt(g.triX, 2), g.pt(g.triX + g.triW, 8),
                       g.pt(g.triX, 14), g.pt(g.triX, 2)]
            }
        }
        // left-pointing triangle (prev)
        ShapePath {
            fillColor: g.kind === "prev" ? g.color : "transparent"
            strokeColor: "transparent"
            PathPolyline { path: [g.pt(14, 2), g.pt(5, 8), g.pt(14, 14), g.pt(14, 2)] }
        }
        // bar after the triangle (next)
        ShapePath {
            fillColor: g.kind === "next" ? g.color : "transparent"
            strokeColor: "transparent"
            PathPolyline { path: [g.pt(12, 2), g.pt(14.5, 2), g.pt(14.5, 14), g.pt(12, 14), g.pt(12, 2)] }
        }
        // bar before the triangle (prev)
        ShapePath {
            fillColor: g.kind === "prev" ? g.color : "transparent"
            strokeColor: "transparent"
            PathPolyline { path: [g.pt(1.5, 2), g.pt(4, 2), g.pt(4, 14), g.pt(1.5, 14), g.pt(1.5, 2)] }
        }
        // two bars (pause)
        ShapePath {
            fillColor: g.kind === "pause" ? g.color : "transparent"
            strokeColor: "transparent"
            PathPolyline { path: [g.pt(3.5, 2), g.pt(6.5, 2), g.pt(6.5, 14), g.pt(3.5, 14), g.pt(3.5, 2)] }
        }
        ShapePath {
            fillColor: g.kind === "pause" ? g.color : "transparent"
            strokeColor: "transparent"
            PathPolyline { path: [g.pt(9.5, 2), g.pt(12.5, 2), g.pt(12.5, 14), g.pt(9.5, 14), g.pt(9.5, 2)] }
        }
    }
}