import QtQuick
import QtQuick.Shapes

Item {
    id: ring

    property real value: 0                  // 0..1
    property color color: "white"
    property color trackColor: "gray"
    property real lineWidth: Math.max(4, Math.min(width, height) * 0.09)

    default property alias content: center.data

    readonly property real r: Math.max(0, (Math.min(width, height) - lineWidth) / 2)

    property real shown: Math.max(0, Math.min(1, value))
    Behavior on shown { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: ring.trackColor
            strokeWidth: ring.lineWidth
            fillColor: "transparent"
            PathAngleArc {
                centerX: ring.width / 2; centerY: ring.height / 2
                radiusX: ring.r; radiusY: ring.r
                startAngle: 0; sweepAngle: 360
            }
        }

        ShapePath {
            strokeColor: ring.shown > 0.004 ? ring.color : "transparent"
            strokeWidth: ring.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: ring.width / 2; centerY: ring.height / 2
                radiusX: ring.r; radiusY: ring.r
                startAngle: -90; sweepAngle: 360 * ring.shown
            }
        }
    }

    Item { id: center; anchors.fill: parent }
}