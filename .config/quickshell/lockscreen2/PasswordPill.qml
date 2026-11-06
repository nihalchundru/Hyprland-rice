import QtQuick

// Password input pill for lockscreen2
Item {
    id: root

    required property var context

    readonly property int count: context.currentText.length

    implicitWidth: 260
    implicitHeight: 46

    // Horizontal failure shake animation
    property real shakeOffset: 0
    transform: Translate { x: root.shakeOffset }

    SequentialAnimation {
        id: shakeAnim
        loops: 1
        NumberAnimation { target: root; property: "shakeOffset"; to: -14; duration: 45; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: 14; duration: 45; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: -10; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: 10; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: -4; duration: 35; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: 0; duration: 35; easing.type: Easing.OutQuad }
    }

    Connections {
        target: root.context
        function onFailed() { shakeAnim.restart(); }
    }

    Rectangle {
        id: pillBg
        anchors.fill: parent
        radius: height / 2
        color: Colors.cardBg
        border.width: 1.5
        border.color: root.context.showFailure ? Colors.red : Colors.cardBorder

        Behavior on border.color { ColorAnimation { duration: 180 } }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 6
            spacing: 10

            // Lock Icon
            Canvas {
                width: 14
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = Colors.sub;
                    ctx.fillStyle = Colors.sub;
                    ctx.lineWidth = 1.5;

                    // Shackle
                    ctx.beginPath();
                    ctx.arc(7, 6, 4.5, Math.PI, 0, false);
                    ctx.stroke();

                    // Body
                    ctx.fillRect(2, 6, 10, 8);
                }
            }

            // Text placeholder or masked password dots
            Item {
                width: parent.width - 32 - proceedBtn.width
                height: parent.height

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    text: "Enter your password"
                    color: Colors.sub
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    visible: root.count === 0
                }

                // Password dots row
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    spacing: 6
                    visible: root.count > 0

                    Repeater {
                        model: Math.min(18, root.count)
                        Rectangle {
                            width: 7
                            height: 7
                            radius: 3.5
                            color: Colors.accent
                        }
                    }
                }
            }

            // Circular proceed button (→)
            Rectangle {
                id: proceedBtn
                width: 34
                height: 34
                radius: 17
                anchors.verticalCenter: parent.verticalCenter
                color: btnArea.containsPress ? Qt.darker(Colors.accent, 1.2)
                     : btnArea.containsMouse ? Qt.lighter(Colors.accent, 1.1)
                     : Qt.rgba(0.32, 0.85, 0.72, 0.25)

                Behavior on color { ColorAnimation { duration: 150 } }
                scale: btnArea.containsPress ? 0.9 : (btnArea.containsMouse ? 1.05 : 1.0)

                Canvas {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = btnArea.containsMouse ? Colors.bg : Colors.accent;
                        ctx.lineWidth = 2;
                        ctx.lineCap = "round";
                        ctx.lineJoin = "round";

                        // Line
                        ctx.beginPath();
                        ctx.moveTo(2, 7);
                        ctx.lineTo(11, 7);
                        // Arrow
                        ctx.moveTo(7, 3);
                        ctx.lineTo(11, 7);
                        ctx.lineTo(7, 11);
                        ctx.stroke();
                    }
                }

                MouseArea {
                    id: btnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: root.count > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (root.count > 0) root.context.tryUnlock();
                    }
                }
            }
        }
    }
}
