import QtQuick
import qs.theme

Rectangle {
    color: Colors.surfaceContainer
    Behavior on color {
        ColorAnimation {
            duration: M3.motion.medium2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: M3.motion.standard
        }
    }
}