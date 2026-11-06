import QtQuick
import "../core"

MouseArea {
    id: root

    property color stateColor: Theme.onSurface
    property real cornerRadius: Motion.radiusFull
    property bool disabled: false
    readonly property bool hovered: root.containsMouse

    hoverEnabled: !disabled
    cursorShape: disabled ? Qt.ArrowCursor : Qt.PointingHandCursor

    // Hover / Press tint overlay per M3 State Layer spec
    Rectangle {
        id: stateOverlay
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.stateColor
        opacity: {
            if (root.disabled) return 0;
            if (root.pressed) return Motion.statePressOpacity;
            if (root.containsMouse) return Motion.stateHoverOpacity;
            return 0;
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Motion.durationShort3
                easing.type: Easing.OutCubic
            }
        }
    }

    // Expressive expanding ripple circle on press
    Rectangle {
        id: rippleCircle
        property real maxDim: Math.max(root.width, root.height) * 2.2
        width: rippleAnim.running ? maxDim : 0
        height: width
        radius: width / 2
        x: root.mouseX - width / 2
        y: root.mouseY - height / 2
        color: root.stateColor
        opacity: 0
        visible: opacity > 0.005

        ParallelAnimation {
            id: rippleAnim
            NumberAnimation {
                target: rippleCircle
                property: "width"
                from: 0
                to: rippleCircle.maxDim
                duration: Motion.durationMedium3
                easing.type: Easing.OutCubic
            }
            SequentialAnimation {
                NumberAnimation {
                    target: rippleCircle
                    property: "opacity"
                    from: 0.16
                    to: 0.12
                    duration: 120
                }
                NumberAnimation {
                    target: rippleCircle
                    property: "opacity"
                    from: 0.12
                    to: 0.0
                    duration: 260
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    onPressed: (mouse) => {
        if (!root.disabled) {
            rippleAnim.restart();
        }
    }
}
