import QtQuick
import qs.tokens
// Non-overshooting number animation (opacity etc).
Behavior {
    property int time: M3Motion.short4
    NumberAnimation { duration: time; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Motion.standard }
}
