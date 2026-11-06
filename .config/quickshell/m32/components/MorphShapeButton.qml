import QtQuick
import "../core"
import "../shapes"
import "../shapes/material-shapes.js" as MaterialShapes

Item {
    id: root

    property string icon: "✨"
    property string label: ""
    property bool active: false
    property bool tonal: true

    // Shape names from material-shapes.js
    property string idleShape: "circle"
    property string hoverShape: "cookie6"
    property string pressedShape: "softBurst"
    property string activeShape: "sunny"

    property color idleBg: tonal ? Theme.surfaceContainerHigh : "transparent"
    property color hoverBg: Theme.secondaryContainer
    property color activeBg: Theme.primary
    property color idleFg: tonal ? Theme.onSurface : Theme.onSurfaceVariant
    property color hoverFg: Theme.onSecondaryContainer
    property color activeFg: Theme.onPrimary

    property int size: 34
    property int iconSize: 16
    property real spinOnHover: 0

    signal clicked()
    signal rightClicked()

    implicitWidth: size
    implicitHeight: size

    readonly property string currentShapeName: {
        if (mouseArea.pressed) return pressedShape;
        if (active) return activeShape;
        if (mouseArea.containsMouse) return hoverShape;
        return idleShape;
    }

    readonly property color currentBgColor: {
        if (active) return activeBg;
        if (mouseArea.containsMouse) return hoverBg;
        return idleBg;
    }

    readonly property color currentFgColor: {
        if (active) return activeFg;
        if (mouseArea.containsMouse) return hoverFg;
        return idleFg;
    }

    ShapeCanvas {
        id: morphBg
        anchors.fill: parent
        shapeName: root.currentShapeName
        color: root.currentBgColor
        rotationAngle: mouseArea.containsMouse ? root.spinOnHover : 0

        Behavior on rotationAngle {
            NumberAnimation {
                duration: Motion.durationMedium4
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.expressiveSpatialDefault
            }
        }

        scale: mouseArea.pressed ? 0.90 : (mouseArea.containsMouse ? 1.06 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: Motion.durationMedium1
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.expressiveSpatialFast
            }
        }
    }

    Text {
        id: iconLabel
        anchors.centerIn: parent
        text: root.icon
        font.family: Theme.fontFamilyMono
        font.pixelSize: root.iconSize
        font.weight: Font.Bold
        color: root.currentFgColor

        Behavior on color {
            ColorAnimation { duration: Motion.durationShort4 }
        }

        scale: mouseArea.pressed ? 0.88 : 1.0
        Behavior on scale {
            NumberAnimation { duration: Motion.durationShort3; easing.type: Easing.OutBack }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
    }
}
