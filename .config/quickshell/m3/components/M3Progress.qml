import QtQuick
import QtQuick.Shapes
import qs.tokens

// Linear progress. value 0..1, or indeterminate. wavy = animated wave on the active part.
Item {
    id: root
    property real value: 0
    property bool indeterminate: false
    property bool wavy: false
    property real thickness: 4
    property real amplitude: 3
    property real wavelength: 40
    property real phase: 0
    readonly property real gap: 4
    readonly property real activeW: Math.max(0, Math.min(1, value)) * width
    implicitWidth: 240
    implicitHeight: wavy ? amplitude * 2 + thickness : thickness
    property bool animate: true
    property color activeColor: M3Colors.primary
    property color trackColor: M3Colors.secondaryContainer
    FadeBehavior on value { enabled: root.animate; time: M3Motion.medium2 }
    NumberAnimation on phase { running: root.wavy && root.visible; from: 0; to: Math.PI * 2; duration: 1500; loops: Animation.Infinite }

    function points() {
        const t = thickness / 2
        const x0 = t, x1 = Math.max(t, activeW - t)
        const n = Math.max(2, Math.ceil((x1 - x0) / 3))
        const out = []
        for (let i = 0; i <= n; i++) {
            const x = x0 + (x1 - x0) * i / n
            out.push(Qt.point(x, height / 2 + amplitude * Math.sin(2 * Math.PI * x / wavelength - phase)))
        }
        return out
    }
    property var pts: wavy ? points() : []

    Item {   // track + indeterminate bar
        anchors.fill: parent
        clip: true
        Rectangle {
            x: root.indeterminate ? 0 : (root.activeW > 0 ? root.activeW + root.gap : 0)
            y: (parent.height - height) / 2
            width: Math.max(0, root.width - x)
            height: root.thickness; radius: height / 2
            color: root.trackColor
        }
        Rectangle {
            id: bar
            visible: root.indeterminate
            y: (parent.height - height) / 2
            width: root.width * 0.4; height: root.thickness; radius: height / 2
            color: root.activeColor
            NumberAnimation on x {
                running: root.indeterminate && root.visible
                from: -bar.width; to: root.width; duration: 1500; loops: Animation.Infinite
                easing.type: Easing.BezierSpline; easing.bezierCurve: M3Motion.standard
            }
        }
    }
    Rectangle {  // flat active
        visible: !root.wavy && !root.indeterminate
        y: (parent.height - height) / 2
        width: root.activeW; height: root.thickness; radius: height / 2
        color: root.activeColor
    }
    Shape {      // wavy active
        anchors.fill: parent
        visible: root.wavy && !root.indeterminate && root.activeW > 0
        layer.enabled: visible
        layer.samples: 4
        ShapePath {
            strokeColor: root.activeColor
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathPolyline { path: root.pts }
        }
    }

    property bool showStop: true
    Rectangle {  // stop indicator dot at the end of the track
        readonly property bool wanted: root.showStop && !root.indeterminate
                                       && root.activeW < root.width - root.gap - root.thickness - 4
        width: 4; height: 4; radius: 2
        x: root.width - root.thickness / 2 - width / 2
        y: (root.height - height) / 2
        color: root.activeColor
        opacity: wanted ? 1 : 0
        FadeBehavior on opacity { time: M3Motion.short3 }
    }
}
