import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Bottom-Right: Notifications Card with Chrome T-Rex illustration
Rectangle {
    id: root

    readonly property var notifs: NotificationServer.trackedNotifications ?
        NotificationServer.trackedNotifications.values : []
    readonly property int count: notifs ? notifs.length : 0

    implicitWidth: 210
    implicitHeight: 180
    radius: 18
    color: Colors.cardBg
    border.width: 1
    border.color: Colors.cardBorder

    Text {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 14
        text: "Notifications"
        color: Colors.sub
        font.pixelSize: 11
        font.weight: Font.Medium
        font.family: "monospace"
    }

    // Center Illustration & Message
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 12
        spacing: 8

            // T-Rex and Cactus Vector Illustration
            Canvas {
                width: 140
                height: 58
                anchors.horizontalCenter: parent.horizontalCenter
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Colors.sub;
                    ctx.strokeStyle = Colors.sub;
                    ctx.lineWidth = 1.2;

                    // Little Cloud
                    ctx.beginPath();
                    ctx.arc(100, 10, 4, Math.PI, 0, false);
                    ctx.arc(106, 9, 3, Math.PI, 0, false);
                    ctx.lineTo(112, 12);
                    ctx.lineTo(95, 12);
                    ctx.closePath();
                    ctx.stroke();

                    // Ground line
                    ctx.beginPath();
                    ctx.moveTo(15, 52);
                    ctx.lineTo(125, 52);
                    ctx.stroke();

                    // Cactus
                    ctx.fillRect(105, 30, 4, 22);
                    // Left arm
                    ctx.fillRect(99, 36, 6, 3);
                    ctx.fillRect(99, 33, 3, 5);
                    // Right arm
                    ctx.fillRect(109, 39, 6, 3);
                    ctx.fillRect(112, 36, 3, 5);

                    // T-Rex Silhouette
                    // Head & Snout
                    ctx.fillRect(45, 20, 14, 11);
                    ctx.fillRect(52, 23, 7, 6);
                    // Eye cutout
                    ctx.fillStyle = Colors.cardBg;
                    ctx.fillRect(48, 22, 2, 2);

                    ctx.fillStyle = Colors.sub;
                    // Body
                    ctx.fillRect(38, 28, 12, 14);
                    // Tail
                    ctx.fillRect(30, 32, 9, 4);
                    ctx.fillRect(25, 34, 6, 3);
                    // Tiny arm
                    ctx.fillRect(49, 33, 4, 2);
                    // Legs
                    ctx.fillRect(40, 42, 3, 8);
                    ctx.fillRect(40, 50, 4, 2);
                    ctx.fillRect(46, 42, 3, 8);
                    ctx.fillRect(46, 50, 4, 2);
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.count > 0 ?
                    root.count + (root.count === 1 ? " Notification" : " Notifications") :
                    "No Notifications"
                color: root.count > 0 ? Colors.accent : Colors.sub
                font.pixelSize: 12
                font.weight: Font.Medium
                font.family: "monospace"
            }
    }
}
