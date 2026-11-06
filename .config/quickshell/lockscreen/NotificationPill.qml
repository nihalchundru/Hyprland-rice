import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Material 3 Privacy-Conscious Notification Pill (Bottom-Left)
// - Shows count of unread/active notifications (e.g. "3 notifications")
// - Preserves user privacy: hides sensitive message preview bodies while locked
// - Balances PowerActions in the bottom-right corner
Item {
    id: root

    readonly property var notifs: NotificationServer.trackedNotifications ?
        NotificationServer.trackedNotifications.values : []
    readonly property int count: notifs ? notifs.length : 0

    implicitWidth: pill.width
    implicitHeight: pill.height

    Rectangle {
        id: pill
        width: row.implicitWidth + 28
        height: 52
        radius: height / 2
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.75)
        border.width: 1
        border.color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.12)

        opacity: root.count > 0 ? 1.0 : 0.65
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 10

            // Notification Bell Vector Icon
            Canvas {
                id: bellCanvas
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = root.count > 0 ? Colors.accent : Colors.sub;
                    ctx.fillStyle = ctx.strokeStyle;
                    ctx.lineWidth = 1.8;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";

                    // Bell body
                    ctx.beginPath();
                    ctx.moveTo(10, 3);
                    ctx.bezierCurveTo(7, 3, 5, 6, 5, 11);
                    ctx.lineTo(3.5, 14.5);
                    ctx.lineTo(16.5, 14.5);
                    ctx.lineTo(15, 11);
                    ctx.bezierCurveTo(15, 6, 13, 3, 10, 3);
                    ctx.stroke();

                    // Clapper
                    ctx.beginPath();
                    ctx.arc(10, 15.5, 2, 0, Math.PI);
                    ctx.stroke();

                    // Top loop
                    ctx.beginPath();
                    ctx.arc(10, 2.5, 1.2, 0, 2 * Math.PI);
                    ctx.fill();
                }

                Connections {
                    target: root
                    function onCountChanged() { bellCanvas.requestPaint(); }
                }
            }

            // Notification Text
            Text {
                text: root.count > 0 ?
                    root.count + (root.count === 1 ? " notification" : " notifications") :
                    "No notifications"
                color: root.count > 0 ? Colors.text : Colors.sub
                font.pixelSize: 13
                font.weight: root.count > 0 ? Font.DemiBold : Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
