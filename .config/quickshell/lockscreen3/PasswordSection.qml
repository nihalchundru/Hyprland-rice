import QtQuick
import Quickshell
import "."

// Bottom-Right combined User and Password Pill for Deck lockscreen
Item {
    id: root

    required property var context

    readonly property int count: context.currentText.length

    implicitHeight: 46
    implicitWidth: mainRow.implicitWidth

    // Horizontal shake animation on failed unlock
    property real shakeOffset: 0
    transform: Translate { x: root.shakeOffset }

    SequentialAnimation {
        id: shakeAnim
        loops: 1
        NumberAnimation { target: root; property: "shakeOffset"; to: -12; duration: 45; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: 12; duration: 45; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: -8; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: 8; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: 0; duration: 35; easing.type: Easing.OutQuad }
    }

    Connections {
        target: root.context
        function onFailed() { shakeAnim.restart(); }
    }

    Row {
        id: mainRow
        spacing: 12

        // Main Glass Pill Container
        Rectangle {
            height: 46
            width: innerRow.implicitWidth + 28
            radius: 23
            color: Colors.cardBg
            border.width: 1.5
            border.color: root.context.showFailure ? Colors.red : Colors.cardBorder

            Behavior on border.color { ColorAnimation { duration: 180 } }

            Row {
                id: innerRow
                anchors.centerIn: parent
                spacing: 12

                // User Initial Avatar
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: Qt.rgba(0.95, 0.61, 0.72, 0.20)
                    border.width: 1
                    border.color: Colors.accent
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: (Quickshell.env("USER") || "U").charAt(0).toUpperCase()
                        color: Colors.accent
                        font.pixelSize: 13
                        font.weight: Font.Bold
                    }
                }

                // Username
                Text {
                    text: Quickshell.env("USER") || "user"
                    color: Colors.text
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "•"
                    color: Colors.sub
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Caps Lock warning icon
                Text {
                    text: "⇪"
                    color: Colors.red
                    font.pixelSize: 15
                    font.bold: true
                    visible: root.context.capsLock
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Password placeholder or dots
                Item {
                    width: Math.max(110, dotsRow.implicitWidth)
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Password..."
                        color: Colors.sub
                        font.pixelSize: 13
                        visible: root.count === 0
                    }

                    Row {
                        id: dotsRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5
                        visible: root.count > 0

                        Repeater {
                            model: Math.min(16, root.count)
                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: Colors.accent
                            }
                        }
                    }
                }
            }
        }

        // Circular Proceed Button (→)
        Rectangle {
            id: proceedBtn
            width: 46
            height: 46
            radius: 23
            anchors.verticalCenter: parent.verticalCenter
            color: btnArea.containsPress ? Qt.darker(Colors.accent, 1.15)
                 : btnArea.containsMouse ? Qt.lighter(Colors.accent, 1.08)
                 : Colors.accent
            scale: btnArea.containsPress ? 0.92 : (btnArea.containsMouse ? 1.05 : 1.0)
            Behavior on scale { NumberAnimation { duration: 120 } }
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "→"
                color: Colors.bg
                font.pixelSize: 18
                font.weight: Font.Bold
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
