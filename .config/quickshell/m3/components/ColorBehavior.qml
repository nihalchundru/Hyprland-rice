import QtQuick
import qs.tokens
Behavior {
    property int time: M3Motion.short4
    ColorAnimation { duration: time; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Motion.standard }
}
