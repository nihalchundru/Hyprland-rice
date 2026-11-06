import QtQuick

// Represents an individual animated character shape inside the password pill.
// Animates in on insertion (scale with overshoot + rotation settle + fade)
// Animates out on deletion (scale down + spin + fade + width collapse)
Item {
    id: root

    property string shapeName: "Circle"
    property int colorIdx: 0
    property real targetSize: 26
    property real spacing: 8

    // Removal trigger
    property bool removing: false
    signal removeFinished()

    width: targetSize + spacing
    height: targetSize

    opacity: 0
    scale: 0
    rotation: -25

    // Smooth width collapse for neighbors when this item is deleted
    Behavior on width {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutQuad
        }
    }

    // Appearance animation when spawned
    ParallelAnimation {
        id: enterAnim
        running: true

        NumberAnimation {
            target: root
            property: "scale"
            from: 0
            to: 1
            duration: 250
            easing.type: Easing.OutBack
            easing.overshoot: 1.6
        }

        NumberAnimation {
            target: root
            property: "opacity"
            from: 0
            to: 1
            duration: 150
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: root
            property: "rotation"
            from: -25
            to: 0
            duration: 250
            easing.type: Easing.OutBack
        }
    }

    // Exit animation triggered when character is removed
    SequentialAnimation {
        id: exitAnim

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "scale"
                to: 0
                duration: 160
                easing.type: Easing.InBack
                easing.overshoot: 1.2
            }
            NumberAnimation {
                target: root
                property: "opacity"
                to: 0
                duration: 120
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: root
                property: "rotation"
                to: 35
                duration: 160
                easing.type: Easing.InQuad
            }
        }

        // Collapse slot width to slide adjacent characters smoothly
        PropertyAction {
            target: root
            property: "width"
            value: 0
        }

        PauseAnimation {
            duration: 180
        }

        ScriptAction {
            script: root.removeFinished()
        }
    }

    onRemovingChanged: {
        if (removing) {
            enterAnim.stop();
            exitAnim.restart();
        }
    }

    MShape {
        id: shapeWidget
        anchors.centerIn: parent
        size: root.targetSize
        shape: root.shapeName
        color: Colors.charColors[root.colorIdx % Colors.charColors.length]
    }
}
