import QtQuick
import QtQuick.Effects
import Quickshell

// Live visual preview of the Cyberpunk Bento lockscreen ("Tessera")
Item {
    id: root

    // Reference virtual screen: 1920x1080 scaled down to 740x416
    readonly property real scaleFactor: width / 1920

    property date now: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    readonly property int rawHour: now.getHours()
    readonly property int hour12: rawHour % 12 === 0 ? 12 : rawHour % 12
    readonly property string minuteText: now.getMinutes().toString().padStart(2, "0")
    readonly property string ampm: rawHour >= 12 ? "PM" : "AM"
    readonly property string dateStr: {
        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        return days[now.getDay()] + ", " + now.getDate() + " " + months[now.getMonth()];
    }

    // Palette: Cyberpunk Bento Teal
    readonly property color colBg: "#0e1413"
    readonly property color colCardBg: Qt.rgba(0.08, 0.12, 0.11, 0.85)
    readonly property color colBorder: Qt.rgba(0.32, 0.85, 0.72, 0.22)
    readonly property color colAccent: "#52d9b8"
    readonly property color colText: "#e5f2ee"
    readonly property color colSub: "#708a83"

    // Background
    Rectangle {
        anchors.fill: parent
        color: root.colBg

        Image {
            id: bgImg
            anchors.fill: parent
            source: "file://" + Quickshell.env("HOME") + "/.config/rofi/images/a.png"
            fillMode: Image.PreserveAspectCrop
            visible: false
            asynchronous: true
        }

        MultiEffect {
            source: bgImg
            anchors.fill: parent
            visible: bgImg.status === Image.Ready
            blurEnabled: true
            blur: 0.9
            blurMax: 32
        }

        Rectangle {
            anchors.fill: parent
            color: root.colBg
            opacity: 0.55
        }
    }

    // Virtual Fullscreen Stage (1920x1080)
    Item {
        width: 1920
        height: 1080
        scale: root.scaleFactor
        transformOrigin: Item.TopLeft

        // Central 3-Column Bento Grid Container
        Rectangle {
            anchors.centerIn: parent
            width: 1100
            height: 640
            radius: 28
            color: Qt.rgba(0.06, 0.09, 0.08, 0.76)
            border.width: 1.5
            border.color: root.colBorder

            Row {
                anchors.centerIn: parent
                spacing: 24

                // ================= LEFT COLUMN =================
                Column {
                    spacing: 16
                    anchors.verticalCenter: parent.verticalCenter

                    // 1. Weather Card
                    Rectangle {
                        width: 320
                        height: 130
                        radius: 18
                        color: root.colCardBg
                        border.width: 1
                        border.color: root.colBorder

                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 8

                            Text {
                                text: "Weather"
                                color: root.colAccent
                                font.pixelSize: 15
                                font.weight: Font.Bold
                            }

                            Row {
                                spacing: 14
                                Text {
                                    text: "☁"
                                    color: root.colText
                                    font.pixelSize: 38
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 3
                                    Text {
                                        text: "Overcast"
                                        color: root.colText
                                        font.pixelSize: 16
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: "76% • 21°C"
                                        color: root.colSub
                                        font.pixelSize: 13
                                    }
                                }
                            }
                        }
                    }

                    // 2. Fastfetch Card
                    Rectangle {
                        width: 320
                        height: 210
                        radius: 18
                        color: root.colCardBg
                        border.width: 1
                        border.color: root.colBorder

                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 12

                            // Header chip
                            Rectangle {
                                height: 26
                                width: 110
                                radius: 6
                                color: Qt.rgba(0.32, 0.85, 0.72, 0.14)
                                Text {
                                    anchors.centerIn: parent
                                    text: "> fastfetch"
                                    color: root.colAccent
                                    font.pixelSize: 13
                                    font.family: "monospace"
                                }
                            }

                            // Logo + specs
                            Row {
                                spacing: 18
                                Text {
                                    text: "󰣇"
                                    color: root.colAccent
                                    font.pixelSize: 54
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4
                                    Text { text: "OS: Arch Linux"; color: root.colText; font.pixelSize: 13; font.family: "monospace" }
                                    Text { text: "WM: Hyprland"; color: root.colText; font.pixelSize: 13; font.family: "monospace" }
                                    Text { text: "USER: " + (Quickshell.env("USER") || "user"); color: root.colText; font.pixelSize: 13; font.family: "monospace" }
                                    Text { text: "UP: active"; color: root.colSub; font.pixelSize: 13; font.family: "monospace" }
                                }
                            }

                            // Palette Dots
                            Row {
                                spacing: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                Repeater {
                                    model: ["#2a3835", "#52d9b8", "#82e0cf", "#a7f3d0", "#6ee7b7", "#93c5fd", "#c4b5fd"]
                                    Rectangle {
                                        required property string modelData
                                        width: 13; height: 13; radius: 3; color: modelData
                                    }
                                }
                            }
                        }
                    }

                    // 3. Media Card
                    Rectangle {
                        width: 320
                        height: 170
                        radius: 18
                        color: root.colCardBg
                        border.width: 1
                        border.color: root.colBorder

                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 14

                            Row {
                                spacing: 14
                                Rectangle {
                                    width: 44; height: 44; radius: 10
                                    color: root.colAccent
                                    Text { anchors.centerIn: parent; text: "♪"; color: root.colBg; font.pixelSize: 22; font.bold: true }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    Text { width: 200; text: "Cyberpunk 2077"; color: root.colText; font.pixelSize: 15; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                    Text { width: 200; text: "Marcin Przybyłowicz"; color: root.colSub; font.pixelSize: 13; elide: Text.ElideRight }
                                }
                            }

                            // Controls
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 26
                                Text { text: "⏮"; color: root.colSub; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                                Rectangle {
                                    width: 36; height: 36; radius: 18
                                    color: root.colAccent
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { anchors.centerIn: parent; text: "▶"; color: root.colBg; font.pixelSize: 14 }
                                }
                                Text { text: "⏭"; color: root.colSub; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }
                }

                // ================= CENTER COLUMN =================
                Column {
                    width: 340
                    spacing: 28
                    anchors.verticalCenter: parent.verticalCenter

                    // Clock
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 6
                            Text {
                                text: root.hour12 + ":" + root.minuteText
                                color: root.colText
                                font.pixelSize: 52
                                font.weight: Font.Bold
                            }
                            Text {
                                text: root.ampm
                                color: root.colAccent
                                font.pixelSize: 24
                                font.weight: Font.Bold
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 6
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.dateStr
                            color: root.colSub
                            font.pixelSize: 16
                        }
                    }

                    // Avatar
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 140
                        height: 140
                        radius: 70
                        color: root.colCardBg
                        border.width: 2.5
                        border.color: root.colAccent

                        Text {
                            anchors.centerIn: parent
                            text: (Quickshell.env("USER") || "U").charAt(0).toUpperCase()
                            color: root.colAccent
                            font.pixelSize: 48
                            font.bold: true
                        }
                    }

                    // Password Pill
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 280
                        height: 50
                        radius: 25
                        color: root.colCardBg
                        border.width: 1.5
                        border.color: root.colBorder

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Enter your password"
                            color: root.colSub
                            font.pixelSize: 14
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            width: 38; height: 38; radius: 19
                            color: Qt.rgba(0.32, 0.85, 0.72, 0.25)
                            Text {
                                anchors.centerIn: parent
                                text: "→"
                                color: root.colAccent
                                font.pixelSize: 18
                                font.bold: true
                            }
                        }
                    }
                }

                // ================= RIGHT COLUMN =================
                Column {
                    spacing: 20
                    anchors.verticalCenter: parent.verticalCenter

                    // 1. Gauges Card
                    Rectangle {
                        width: 260
                        height: 250
                        radius: 18
                        color: root.colCardBg
                        border.width: 1
                        border.color: root.colBorder

                        Grid {
                            anchors.centerIn: parent
                            columns: 2
                            spacing: 16

                            // CPU
                            Rectangle {
                                width: 95; height: 95; radius: 47.5; color: Qt.rgba(0,0,0,0.2)
                                border.width: 2.5; border.color: root.colAccent
                                Text { anchors.centerIn: parent; text: "CPU\n32%"; color: root.colText; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter }
                            }
                            // Temp
                            Rectangle {
                                width: 95; height: 95; radius: 47.5; color: Qt.rgba(0,0,0,0.2)
                                border.width: 2.5; border.color: root.colAccent
                                Text { anchors.centerIn: parent; text: "TMP\n45°C"; color: root.colText; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter }
                            }
                            // RAM
                            Rectangle {
                                width: 95; height: 95; radius: 47.5; color: Qt.rgba(0,0,0,0.2)
                                border.width: 2.5; border.color: root.colAccent
                                Text { anchors.centerIn: parent; text: "RAM\n54%"; color: root.colText; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter }
                            }
                            // Disk
                            Rectangle {
                                width: 95; height: 95; radius: 47.5; color: Qt.rgba(0,0,0,0.2)
                                border.width: 2.5; border.color: root.colAccent
                                Text { anchors.centerIn: parent; text: "DISK\n62%"; color: root.colText; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter }
                            }
                        }
                    }

                    // 2. Notifications Card
                    Rectangle {
                        width: 260
                        height: 230
                        radius: 18
                        color: root.colCardBg
                        border.width: 1
                        border.color: root.colBorder

                        Text {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 16
                            text: "Notifications"
                            color: root.colSub
                            font.pixelSize: 13
                            font.family: "monospace"
                        }

                        Column {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 12
                            spacing: 10

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "🦖"
                                font.pixelSize: 48
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "No Notifications"
                                color: root.colSub
                                font.pixelSize: 14
                            }
                        }
                    }
                }
            }
        }
    }
}
