import QtQuick
import QtQuick.Effects
import Quickshell

// Live visual preview of the actual Material 3 Iris lockscreen ("Veil")
Item {
    id: root

    // Reference virtual screen: 1920x1080, scaled to fit the preview container
    readonly property real scaleFactor: width / 1920

    property date now: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    readonly property real secs: now.getSeconds()
    readonly property real mins: now.getMinutes() + secs / 60
    readonly property real hours: (now.getHours() % 12) + mins / 60
    readonly property int hour12: now.getHours() % 12 === 0 ? 12 : now.getHours() % 12
    readonly property string minuteText: now.getMinutes().toString().padStart(2, "0")

    readonly property string formattedDate: {
        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        return days[now.getDay()] + ", " + months[now.getMonth()] + " " + now.getDate();
    }

    // Iris Theme Palette
    readonly property color colBg:      "#361e27"
    readonly property color colSurface: Qt.rgba(0.22, 0.13, 0.18, 0.85)
    readonly property color colCookie:  "#24131a"
    readonly property color colBorder:  Qt.rgba(0.91, 0.68, 0.59, 0.14)
    readonly property color colText:    "#e7ad97"
    readonly property color colSub:     "#8c6474"
    readonly property color colAccent:  "#dc8767"

    // 1. Wallpaper with Iris Scrim
    Rectangle {
        anchors.fill: parent
        color: root.colBg

        Image {
            id: bgWall
            anchors.fill: parent
            source: "file://" + Quickshell.env("HOME") + "/.config/rofi/images/a.png"
            fillMode: Image.PreserveAspectCrop
            visible: false
            asynchronous: true
        }

        MultiEffect {
            source: bgWall
            anchors.fill: parent
            visible: bgWall.status === Image.Ready
            blurEnabled: true
            blur: 1.0
            blurMax: 48
            scale: 1.06
        }

        Rectangle {
            anchors.fill: parent
            color: root.colBg
            opacity: 0.50
        }
    }

    // 2. Virtual Fullscreen Stage (1920x1080 scaled down to 740x416)
    Item {
        id: stage
        width: 1920
        height: 1080
        scale: root.scaleFactor
        transformOrigin: Item.TopLeft

        // ================= TOP-LEFT: User Badge =================
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 44
            height: 60
            width: userRow.implicitWidth + 24
            radius: 30
            color: root.colSurface
            border.width: 1
            border.color: root.colBorder

            Row {
                id: userRow
                anchors.centerIn: parent
                spacing: 14

                // Avatar Circle
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: Qt.rgba(0, 0, 0, 0.25)
                    border.width: 1.5
                    border.color: root.colAccent
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: (Quickshell.env("USER") || "N").charAt(0).toUpperCase()
                        color: root.colText
                        font.pixelSize: 20
                        font.weight: Font.Bold
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: "Welcome back,"
                        color: root.colSub
                        font.pixelSize: 13
                    }
                    Text {
                        text: (Quickshell.env("USER") || "Nihal").replace(/^./, c => c.toUpperCase())
                        color: root.colText
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }
                }
            }
        }

        // ================= TOP-RIGHT: Status Pill =================
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 44
            height: 48
            width: statusRow.implicitWidth + 28
            radius: 24
            color: root.colSurface
            border.width: 1
            border.color: root.colBorder

            Row {
                id: statusRow
                anchors.centerIn: parent
                spacing: 12

                Text {
                    text: "󰤨 Online"
                    color: root.colText
                    font.pixelSize: 15
                    font.weight: Font.Medium
                }
                Text {
                    text: "|"
                    color: root.colSub
                    font.pixelSize: 13
                }
                Text {
                    text: "󰕾 0%"
                    color: root.colText
                    font.pixelSize: 15
                    font.weight: Font.Medium
                }
            }
        }

        // ================= BOTTOM-LEFT: Notifications =================
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 44
            height: 48
            width: notifRow.implicitWidth + 28
            radius: 24
            color: root.colSurface
            border.width: 1
            border.color: root.colBorder

            Row {
                id: notifRow
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "🔔"
                    font.pixelSize: 15
                }
                Text {
                    text: "No notifications"
                    color: root.colText
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }
            }
        }

        // ================= BOTTOM-RIGHT: Power Actions =================
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 44
            height: 48
            width: powerRow.implicitWidth + 32
            radius: 24
            color: root.colSurface
            border.width: 1
            border.color: root.colBorder

            Row {
                id: powerRow
                anchors.centerIn: parent
                spacing: 24

                Text { text: "💧"; font.pixelSize: 16 }
                Text { text: "↺"; color: root.colText; font.pixelSize: 18; font.weight: Font.Bold }
                Text { text: "⏻"; color: root.colText; font.pixelSize: 18; font.weight: Font.Bold }
            }
        }

        // ================= CENTER STACK =================
        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -20
            spacing: 26

            // Material 3 Cookie Clock
            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 320
                height: 320

                // 12-Lobed M3 Scallop Canvas
                Canvas {
                    id: cookieCanvas
                    anchors.fill: parent
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        const cx = width / 2;
                        const cy = height / 2;
                        const R0 = width * 0.42;
                        const A = width * 0.055;
                        const lobes = 12;

                        ctx.beginPath();
                        for (let a = 0; a <= 2 * Math.PI; a += 0.02) {
                            const r = R0 + A * Math.cos(lobes * a);
                            const x = cx + r * Math.cos(a);
                            const y = cy + r * Math.sin(a);
                            if (a === 0) ctx.moveTo(x, y);
                            else ctx.lineTo(x, y);
                        }
                        ctx.closePath();
                        ctx.fillStyle = root.colCookie;
                        ctx.fill();
                    }
                }

                // 12 Hour Ticks
                Repeater {
                    model: 12
                    Item {
                        required property int index
                        readonly property bool major: index % 3 === 0
                        anchors.centerIn: parent
                        width: 0; height: 0
                        rotation: index * 30

                        Rectangle {
                            x: -width / 2
                            y: -320 * 0.36
                            width: major ? 3.5 : 2.5
                            height: major ? 18 : 10
                            radius: width / 2
                            color: root.colText
                            opacity: major ? 0.9 : 0.45
                        }
                    }
                }

                // Stacked Digits (Hour on top, Minute below)
                Column {
                    anchors.centerIn: parent
                    spacing: -16

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.hour12
                        color: root.colText
                        font.pixelSize: 84
                        font.weight: Font.Black
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.minuteText
                        color: root.colText
                        font.pixelSize: 84
                        font.weight: Font.Black
                    }
                }

                // Analog Hands
                // Hour Hand
                Item {
                    anchors.centerIn: parent
                    width: 0; height: 0
                    rotation: root.hours * 30

                    Rectangle {
                        x: -3.5
                        y: -75
                        width: 7
                        height: 75
                        radius: 3.5
                        color: root.colText
                    }
                }

                // Minute Hand
                Item {
                    anchors.centerIn: parent
                    width: 0; height: 0
                    rotation: root.mins * 6

                    Rectangle {
                        x: -2.5
                        y: -110
                        width: 5
                        height: 110
                        radius: 2.5
                        color: root.colText
                    }
                }

                // Smooth Seconds Hand extending past edge
                Item {
                    anchors.centerIn: parent
                    width: 0; height: 0
                    rotation: root.secs * 6

                    Rectangle {
                        x: -1.25
                        y: -145
                        width: 2.5
                        height: 175
                        radius: 1.25
                        color: root.colAccent
                    }

                    // Center Cap Circle
                    Rectangle {
                        x: -6
                        y: -6
                        width: 12
                        height: 12
                        radius: 6
                        color: root.colAccent
                    }
                }
            }

            // Date & Weather Pill
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                height: 44
                width: dateRow.implicitWidth + 36
                radius: 22
                color: root.colSurface
                border.width: 1
                border.color: root.colBorder

                Row {
                    id: dateRow
                    anchors.centerIn: parent
                    spacing: 12

                    // Bullet
                    Text {
                        text: "•"
                        color: root.colAccent
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.formattedDate
                        color: root.colText
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "|"
                        color: root.colSub
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Weather Icon & Temp
                    Row {
                        spacing: 6
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: "☀️"; font.pixelSize: 18 }
                        Text {
                            text: "85°F"
                            color: root.colText
                            font.pixelSize: 15
                            font.weight: Font.Medium
                        }
                    }
                }
            }

            // Password Pill + Proceed Button
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                Rectangle {
                    width: 230
                    height: 52
                    radius: 26
                    color: root.colSurface
                    border.width: 1
                    border.color: root.colBorder
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "Password"
                        color: root.colSub
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }
                }

                Rectangle {
                    width: 52
                    height: 52
                    radius: 26
                    color: root.colAccent
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "→"
                        color: "#28121a"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                    }
                }
            }
        }
    }
}
