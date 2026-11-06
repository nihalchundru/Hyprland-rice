import QtQuick
import "../core"
import "../shapes"

Item {
    id: root

    property real value: 50
    property real from: 0
    property real to: 100
    property string icon: ""
    property color activeColor: Theme.primary
    property color trackColor: Theme.surfaceContainerHighest
    property color iconColor: Theme.onPrimary
    property color thumbColor: Theme.onPrimary
    property color onThumbColor: Theme.primary

    signal moved(real newValue)

    implicitWidth: 220
    implicitHeight: 36

    readonly property real normalizedValue: Math.max(0, Math.min(1, (value - from) / Math.max(1, (to - from))))

    // Inactive background track
    Rectangle {
        id: bgTrack
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        radius: height / 2
        color: root.trackColor

        Behavior on color { ColorAnimation { duration: Motion.durationColor } }

        // Active filled pill track
        Rectangle {
            id: activeTrack
            height: parent.height
            width: Math.max(height, parent.width * root.normalizedValue)
            radius: height / 2
            color: root.activeColor

            Behavior on width {
                enabled: !dragArea.pressed
                NumberAnimation {
                    duration: Motion.durationMedium1
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Motion.emphasizedDecelerate
                }
            }
            Behavior on color { ColorAnimation { duration: Motion.durationColor } }
        }
    }

    // Morphing M3 Thumb
    Item {
        id: thumb
        width: dragArea.pressed ? 34 : (dragArea.containsMouse ? 30 : 26)
        height: width
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(2, Math.min(root.width - width - 2, root.normalizedValue * (root.width - width)))

        Behavior on x {
            enabled: !dragArea.pressed
            NumberAnimation {
                duration: Motion.durationMedium1
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: Motion.durationShort4
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.expressiveSpatialFast
            }
        }

        ShapeCanvas {
            anchors.fill: parent
            shapeName: {
                if (dragArea.pressed) return "sunny";
                if (dragArea.containsMouse) return "cookie7";
                if (root.normalizedValue > 0.85) return "clover8";
                return "circle";
            }
            color: root.thumbColor
            borderWidth: 2
            borderColor: root.activeColor
        }
    }

    // Optional leading icon inside track
    Text {
        visible: root.icon !== ""
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        font.family: Theme.fontFamilyMono
        font.pixelSize: 14
        color: root.normalizedValue > 0.14 ? root.iconColor : Theme.onSurfaceVariant
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateFromMouse(mx) {
            var ratio = Math.max(0, Math.min(1, mx / Math.max(1, root.width)));
            var nextVal = root.from + ratio * (root.to - root.from);
            root.value = nextVal;
            root.moved(nextVal);
        }

        onPressed: (mouse) => updateFromMouse(mouse.x)
        onPositionChanged: (mouse) => {
            if (pressed) updateFromMouse(mouse.x);
        }
        onWheel: (wheel) => {
            var step = (root.to - root.from) * 0.05;
            var nextVal = Math.max(root.from, Math.min(root.to, root.value + (wheel.angleDelta.y > 0 ? step : -step)));
            root.value = nextVal;
            root.moved(nextVal);
        }
    }
}
