import QtQuick
import Quickshell
import Quickshell.Io

// Material 3 Session & Power Actions (Bottom-Right)
// - Suspend, Reboot, Power Off
// - 2-step confirmation to prevent accidental clicks
// - Crisp vector Canvas icons tied to theme palette
Item {
    id: root

    property string confirmAction: "" // "suspend", "reboot", "poweroff", or ""

    Timer {
        id: resetTimer
        interval: 3000
        repeat: false
        onTriggered: root.confirmAction = ""
    }

    function triggerAction(actionName, cmd) {
        if (root.confirmAction === actionName) {
            // Confirmed! Run command
            root.confirmAction = "";
            actionProcess.command = cmd;
            actionProcess.running = true;
        } else {
            // First click: ask for confirmation
            root.confirmAction = actionName;
            resetTimer.restart();
        }
    }

    Process {
        id: actionProcess
        running: false
    }

    implicitWidth: row.implicitWidth + 20
    implicitHeight: 52

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.75)
        border.width: 1
        border.color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.12)

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 8

            // --- 1. Suspend Button (☾) ---
            Rectangle {
                id: sleepBtn
                width: 38
                height: 38
                radius: 19
                anchors.verticalCenter: parent.verticalCenter
                color: root.confirmAction === "suspend" ? Colors.teal
                     : sleepArea.containsMouse ? Qt.rgba(Colors.teal.r, Colors.teal.g, Colors.teal.b, 0.25)
                     : "transparent"

                Behavior on color { ColorAnimation { duration: 150 } }
                scale: sleepArea.containsPress ? 0.9 : 1.0

                Canvas {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = root.confirmAction === "suspend" ? Colors.bg : Colors.text;

                        // Crescent moon
                        ctx.beginPath();
                        ctx.arc(9, 9, 7.5, -0.4 * Math.PI, 0.8 * Math.PI, false);
                        ctx.bezierCurveTo(4, 13, 4, 5, 9 + 7.5 * Math.cos(-0.4 * Math.PI), 9 + 7.5 * Math.sin(-0.4 * Math.PI));
                        ctx.fill();
                    }

                    Connections {
                        target: root
                        function onConfirmActionChanged() { sleepBtn.children[0].requestPaint(); }
                    }
                }

                MouseArea {
                    id: sleepArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.triggerAction("suspend", ["systemctl", "suspend"])
                }
            }

            // --- 2. Reboot Button (↻) ---
            Rectangle {
                id: rebootBtn
                width: 38
                height: 38
                radius: 19
                anchors.verticalCenter: parent.verticalCenter
                color: root.confirmAction === "reboot" ? Colors.accent
                     : rebootArea.containsMouse ? Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.25)
                     : "transparent"

                Behavior on color { ColorAnimation { duration: 150 } }
                scale: rebootArea.containsPress ? 0.9 : 1.0

                Canvas {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = root.confirmAction === "reboot" ? Colors.bg : Colors.text;
                        ctx.lineWidth = 2.2;
                        ctx.lineCap = "round";

                        // Circular arc
                        ctx.beginPath();
                        ctx.arc(9, 9, 6.5, -0.2 * Math.PI, 1.4 * Math.PI, false);
                        ctx.stroke();

                        // Arrow tip
                        ctx.fillStyle = ctx.strokeStyle;
                        ctx.beginPath();
                        ctx.moveTo(13.5, 3.5);
                        ctx.lineTo(15.5, 7.5);
                        ctx.lineTo(11, 6.5);
                        ctx.closePath();
                        ctx.fill();
                    }

                    Connections {
                        target: root
                        function onConfirmActionChanged() { rebootBtn.children[0].requestPaint(); }
                    }
                }

                MouseArea {
                    id: rebootArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.triggerAction("reboot", ["systemctl", "reboot"])
                }
            }

            // --- 3. Power Off Button (⏻) ---
            Rectangle {
                id: powerBtn
                width: 38
                height: 38
                radius: 19
                anchors.verticalCenter: parent.verticalCenter
                color: root.confirmAction === "poweroff" ? Colors.red
                     : powerArea.containsMouse ? Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.25)
                     : "transparent"

                Behavior on color { ColorAnimation { duration: 150 } }
                scale: powerArea.containsPress ? 0.9 : 1.0

                Canvas {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = root.confirmAction === "poweroff" ? Colors.bg : Colors.text;
                        ctx.lineWidth = 2.2;
                        ctx.lineCap = "round";

                        // Open ring
                        ctx.beginPath();
                        ctx.arc(9, 9, 6.5, -0.35 * Math.PI, 1.35 * Math.PI, false);
                        ctx.stroke();

                        // Vertical power line
                        ctx.beginPath();
                        ctx.moveTo(9, 2);
                        ctx.lineTo(9, 8);
                        ctx.stroke();
                    }

                    Connections {
                        target: root
                        function onConfirmActionChanged() { powerBtn.children[0].requestPaint(); }
                    }
                }

                MouseArea {
                    id: powerArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.triggerAction("poweroff", ["systemctl", "poweroff"])
                }
            }
        }
    }
}
