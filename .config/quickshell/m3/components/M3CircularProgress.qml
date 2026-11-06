import QtQuick
import QtQuick.Shapes
import qs.tokens

Item {
    id: root
    property real value: 0
    property bool indeterminate: false
    property real size: 48
    property real thickness: 4
    property real sweep: 60
    implicitWidth: size; implicitHeight: size
    FadeBehavior on value { time: M3Motion.medium2 }

    NumberAnimation on rotation { running: root.indeterminate && root.visible; from: 0; to: 360; duration: 1600; loops: Animation.Infinite }
    SequentialAnimation on sweep {
        running: root.indeterminate && root.visible
        loops: Animation.Infinite
        NumberAnimation { to: 260; duration: 800; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Motion.standard }
        NumberAnimation { to: 40; duration: 800; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Motion.standard }
    }
    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        ShapePath {
            strokeColor: M3Colors.secondaryContainer
            strokeWidth: root.thickness
            fillColor: "transparent"
            PathAngleArc { centerX: root.size / 2; centerY: root.size / 2; radiusX: root.size / 2 - root.thickness / 2; radiusY: radiusX; startAngle: 0; sweepAngle: 360 }
        }
        ShapePath {
            strokeColor: M3Colors.primary
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.size / 2; centerY: root.size / 2
                radiusX: root.size / 2 - root.thickness / 2; radiusY: radiusX
                startAngle: -90
                sweepAngle: root.indeterminate ? root.sweep : Math.max(0.1, root.value * 360)
            }
        }
    }
}
