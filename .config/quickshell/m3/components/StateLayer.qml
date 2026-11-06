import QtQuick
import qs.tokens
// Hover/focus/press overlay. Set anchors.fill + radius from the parent.
Rectangle {
    property bool hovered: false
    property bool pressed: false
    property bool focused: false
    property bool dragged: false
    property color tint: M3Colors.fgSurface
    color: tint
    opacity: pressed ? M3Opacity.pressed : dragged ? M3Opacity.dragged
           : focused ? M3Opacity.focus : hovered ? M3Opacity.hover : 0
    FadeBehavior on opacity { time: M3Motion.short2 }
}
