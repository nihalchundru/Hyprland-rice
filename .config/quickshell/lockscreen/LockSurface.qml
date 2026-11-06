import QtQuick

// Quickshell M3 Lockscreen Surface
// - UserBadge (Top-Left): ~/.face avatar masked to M3 cookie + greeting
// - StatusPill (Top-Right): Battery, Volume (scroll to adjust / click to mute), Network
// - NotificationPill (Bottom-Left): Privacy-conscious notification count
// - PowerActions (Bottom-Right): Suspend, Reboot, Power Off with confirmation
// - Center Stack: Cookie Clock, DateBadge (with set-6 weather), PasswordPill, CapsLock, MediaCard
// - Polish: Ambient idle breathe/dimming after 25s, smooth intro & unlock transitions
Item {
    id: root

    required property LockContext context

    Background {
        anchors.fill: parent
    }

    // --- Ambient Idle State ---
    property bool isAmbient: false

    Timer {
        id: idleTimer
        interval: 25000 // 25s of inactivity
        running: true
        repeat: false
        onTriggered: root.isAmbient = true
    }

    function wakeUp() {
        if (root.isAmbient) root.isAmbient = false;
        idleTimer.restart();
    }

    // Full-screen mouse activity detector
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

    // Outer wrapper for smooth intro and unlock exit animations
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
            function onUnlocking() {
                unlockAnim.start();
            }
        }

        // --- Top-Left: User Avatar & Greeting ---
        UserBadge {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 36
            opacity: root.isAmbient ? 0.25 : 1.0
            Behavior on opacity { NumberAnimation { duration: 600 } }
        }

        // --- Top-Right: Status Glanceables (Battery, Volume, Network) ---
        StatusPill {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 36
            opacity: root.isAmbient ? 0.25 : 1.0
            Behavior on opacity { NumberAnimation { duration: 600 } }
        }

        // --- Bottom-Left: Privacy-Conscious Notifications ---
        NotificationPill {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 36
            opacity: root.isAmbient ? 0.2 : 1.0
            Behavior on opacity { NumberAnimation { duration: 600 } }
        }

        // --- Bottom-Right: Session & Power Actions ---
        PowerActions {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 36
            opacity: root.isAmbient ? 0.25 : 1.0
            Behavior on opacity { NumberAnimation { duration: 600 } }
        }

        // --- Center Stack ---
        Column {
            anchors.centerIn: parent
            spacing: 32

            // Clock + Date Badge
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                Clock {
                    anchors.horizontalCenter: parent.horizontalCenter
                    size: Math.min(330, root.height * 0.36)
                }

                DateBadge {
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Input Area: Password Pill, Proceed Button, Caps Lock Banner, Status
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    PasswordPill {
                        id: pill
                        anchors.verticalCenter: parent.verticalCenter
                        context: root.context
                    }

                    // Circular proceed button
                    Rectangle {
                        id: proceedBtn
                        width: 64
                        height: 64
                        radius: 32
                        anchors.verticalCenter: parent.verticalCenter
                        color: mouseArea.containsPress ? Qt.darker(Colors.accent, 1.15)
                             : mouseArea.containsMouse ? Qt.lighter(Colors.accent, 1.1)
                             : Colors.accent

                        // Enable/scale effect when user types something
                        opacity: root.context.currentText.length > 0 ? 1.0 : 0.4
                        scale: mouseArea.containsPress ? 0.92 : (mouseArea.containsMouse ? 1.05 : 1.0)

                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        // Arrow icon (Canvas vector arrow pointing right)
                        Canvas {
                            anchors.centerIn: parent
                            width: 24
                            height: 24

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.strokeStyle = Colors.bg;
                                ctx.lineWidth = 3;
                                ctx.lineCap = "round";
                                ctx.lineJoin = "round";

                                // Line
                                ctx.beginPath();
                                ctx.moveTo(4, 12);
                                ctx.lineTo(19, 12);
                                // Arrow head
                                ctx.moveTo(13, 6);
                                ctx.lineTo(19, 12);
                                ctx.lineTo(13, 18);
                                ctx.stroke();
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: root.context.currentText.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (root.context.currentText.length > 0) {
                                    root.context.tryUnlock();
                                }
                            }
                        }
                    }
                }

                // Animated Caps Lock Warning Pill
                Item {
                    id: capsLockBanner
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: root.context.capsLock ? 34 : 0
                    visible: height > 0
                    clip: true

                    Behavior on height {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        height: 32
                        width: capsRow.implicitWidth + 24
                        radius: 16
                        color: Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.16)
                        border.width: 1
                        border.color: Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.4)
                        opacity: root.context.capsLock ? 1.0 : 0.0
                        scale: root.context.capsLock ? 1.0 : 0.85

                        Behavior on opacity { NumberAnimation { duration: 180 } }
                        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

                        Row {
                            id: capsRow
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "⇪"
                                color: Colors.red
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: "Caps Lock is on"
                                color: Colors.red
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Status message
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.context.unlockInProgress ? "Checking…"
                        : root.context.showFailure ? "Wrong password"
                        : " "
                    color: root.context.showFailure ? Colors.red : Colors.sub
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }
            }

            // Now Playing MPRIS Card
            MediaCard {
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: root.isAmbient ? 0.35 : (hasMedia ? 1.0 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 500 } }
            }

            // Invisible key grabber keeping focus so user can type directly
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
                            // Keep caps lock state synced with typed character casing
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
    }
}
