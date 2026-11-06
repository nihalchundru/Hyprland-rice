import QtQuick
import "."

// Main fullscreen surface for lockscreen3 ("Deck")
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
        opacity: root.isAmbient ? 0.35 : 0.0
        Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }
    }

    // Outer Wrapper with Intro & Unlock Animations
    Item {
        id: contentWrapper
        anchors.fill: parent
        opacity: 0.0
        scale: 0.96

        Component.onCompleted: introAnim.start()

        ParallelAnimation {
            id: introAnim
            NumberAnimation { target: contentWrapper; property: "opacity"; to: 1.0; duration: 320; easing.type: Easing.OutCubic }
            NumberAnimation { target: contentWrapper; property: "scale"; to: 1.0; duration: 350; easing.type: Easing.OutBack }
        }

        ParallelAnimation {
            id: unlockAnim
            NumberAnimation { target: contentWrapper; property: "opacity"; to: 0.0; duration: 200; easing.type: Easing.InQuad }
            NumberAnimation { target: contentWrapper; property: "scale"; to: 1.04; duration: 220; easing.type: Easing.OutQuad }
        }

        Connections {
            target: root.context
            function onUnlocking() { unlockAnim.start(); }
        }

        // ================= CENTER: Media Deck Island =================
        MediaDeck {
            id: mediaDeck
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -24
        }

        // ================= BOTTOM-LEFT: Status Pill =================
        StatusPill {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 44
            opacity: root.isAmbient ? 0.3 : 1.0
            Behavior on opacity { NumberAnimation { duration: 600 } }
        }

        // ================= BOTTOM-RIGHT: User & Password =================
        PasswordSection {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 44
            context: root.context
            opacity: root.isAmbient ? 0.3 : 1.0
            Behavior on opacity { NumberAnimation { duration: 600 } }
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

            if (event.key === Qt.Key_CapsLock) {
                root.context.capsLock = !root.context.capsLock;
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
                const ch = event.text;
                const code = ch.charCodeAt(0);
                if (code >= 32 && code !== 127) {
                    const isUpper = ch >= 'A' && ch <= 'Z';
                    const isLower = ch >= 'a' && ch <= 'z';
                    const shift = (event.modifiers & Qt.ShiftModifier) !== 0;

                    if (isUpper) {
                        root.context.capsLock = !shift;
                    } else if (isLower) {
                        root.context.capsLock = shift;
                    }

                    root.context.currentText += ch;
                    event.accepted = true;
                }
            }
        }
    }
}
