import QtQuick

// Main lock surface for lockscreen2
Item {
    id: root

    required property var context

    Background {
        anchors.fill: parent
    }

    // Ambient Idle state
    property bool isAmbient: false
    Timer {
        id: idleTimer
        interval: 30000 // 30s
        running: true
        repeat: false
        onTriggered: root.isAmbient = true
    }

    function wakeUp() {
        if (root.isAmbient) root.isAmbient = false;
        idleTimer.restart();
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        onPositionChanged: root.wakeUp()
    }

    // Ambient dimming overlay
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.isAmbient ? 0.4 : 0.0
        Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }
    }

    // Dashboard Wrapper with Intro and Exit animations
    Item {
        id: dashboardWrapper
        anchors.centerIn: parent
        width: bento.width
        height: bento.height
        opacity: 0.0
        scale: 0.95

        Component.onCompleted: introAnim.start()

        ParallelAnimation {
            id: introAnim
            NumberAnimation { target: dashboardWrapper; property: "opacity"; to: 1.0; duration: 320; easing.type: Easing.OutCubic }
            NumberAnimation { target: dashboardWrapper; property: "scale"; to: 1.0; duration: 350; easing.type: Easing.OutBack }
        }

        ParallelAnimation {
            id: unlockAnim
            NumberAnimation { target: dashboardWrapper; property: "opacity"; to: 0.0; duration: 200; easing.type: Easing.InQuad }
            NumberAnimation { target: dashboardWrapper; property: "scale"; to: 1.05; duration: 220; easing.type: Easing.OutQuad }
        }

        Connections {
            target: root.context
            function onUnlocking() {
                unlockAnim.start();
            }
        }

        BentoContainer {
            id: bento
            anchors.centerIn: parent
            context: root.context
        }
    }

    // Keyboard Grabber
    Item {
        id: keyGrabber
        focus: true

        Keys.onPressed: event => {
            root.wakeUp();

            if (event.key === Qt.Key_Escape) {
                root.context.currentText = "";
                event.accepted = true;
                return;
            }

            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.context.tryUnlock();
                event.accepted = true;
                return;
            }

            if (event.key === Qt.Key_Backspace) {
                if (root.context.currentText.length > 0) {
                    root.context.currentText = root.context.currentText.slice(0, -1);
                }
                event.accepted = true;
                return;
            }

            if (event.text && event.text.length > 0 && !root.context.unlockInProgress) {
                const code = event.text.charCodeAt(0);
                if (code >= 32 && code !== 127) {
                    root.context.currentText += event.text;
                    event.accepted = true;
                }
            }
        }
    }
}
