import QtQuick

// Bottom carousel item card representing a lockscreen style
Item {
    id: root

    property string styleId: "veil"
    property string styleName: "Veil"
    property bool isSelected: false
    property bool isInUse: false
    property bool isAvailable: true

    signal clicked()

    implicitWidth: 164
    implicitHeight: 122

    // Palette
    readonly property color colAccent: "#f3b3c8"
    readonly property color colSurface: Qt.rgba(0.12, 0.10, 0.13, 0.88)
    readonly property color colBorder: root.isSelected ? root.colAccent : Qt.rgba(0.95, 0.70, 0.78, 0.18)
    readonly property color colText: "#fcebf0"
    readonly property color colSub: "#b39aa3"

    Column {
        anchors.fill: parent
        spacing: 8

        // Thumbnail Card Container
        Rectangle {
            width: parent.width
            height: 94
            radius: 16
            color: root.colSurface
            border.width: root.isSelected ? 2.5 : 1
            border.color: root.colBorder
            clip: true

            Behavior on border.color { ColorAnimation { duration: 180 } }
            scale: cardMouse.containsPress ? 0.96 : (cardMouse.containsMouse ? 1.02 : 1.0)
            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }

            // Thumbnail Artwork
            Item {
                anchors.fill: parent
                opacity: root.isAvailable ? 1.0 : 0.45

                // --- Veil Artwork (Material 3 Cookie) ---
                Item {
                    anchors.fill: parent
                    visible: root.styleId === "veil"

                    Rectangle {
                        anchors.fill: parent
                        color: "#2a1822"
                    }

                    // Top-Left User Pill
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 6
                        width: 28; height: 8; radius: 4
                        color: Qt.rgba(0.9, 0.68, 0.59, 0.22)
                    }

                    // Top-Right Status Pill
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 6
                        width: 24; height: 7; radius: 3.5
                        color: Qt.rgba(0.9, 0.68, 0.59, 0.22)
                    }

                    // Center: Scallop Cookie Clock
                    Rectangle {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -4
                        width: 44
                        height: 44
                        radius: 22
                        color: "#1e1017"
                        border.width: 1
                        border.color: Qt.rgba(0.9, 0.68, 0.59, 0.3)

                        Column {
                            anchors.centerIn: parent
                            spacing: -2
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "6"
                                color: "#e7ad97"
                                font.pixelSize: 13
                                font.bold: true
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "49"
                                color: "#e7ad97"
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }
                    }

                    // Date & Password mini pills
                    Column {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 6
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 3

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 46; height: 6; radius: 3
                            color: Qt.rgba(0.9, 0.68, 0.59, 0.25)
                        }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 38; height: 6; radius: 3
                            color: Qt.rgba(0.9, 0.68, 0.59, 0.20)
                        }
                    }

                    // Bottom-Right mini power actions
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: 6
                        width: 18; height: 6; radius: 3
                        color: Qt.rgba(0.9, 0.68, 0.59, 0.2)
                    }
                }

                // --- Tessera Artwork (Bento Grid) ---
                Item {
                    anchors.fill: parent
                    visible: root.styleId === "tessera"

                    Rectangle {
                        anchors.fill: parent
                        color: "#0a1110"
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 4

                        // Col 1
                        Column {
                            spacing: 3
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle { width: 34; height: 18; radius: 3; color: Qt.rgba(0.32, 0.85, 0.72, 0.25) }
                            Rectangle { width: 34; height: 26; radius: 3; color: Qt.rgba(0.32, 0.85, 0.72, 0.20) }
                            Rectangle { width: 34; height: 18; radius: 3; color: Qt.rgba(0.32, 0.85, 0.72, 0.25) }
                        }

                        // Col 2
                        Column {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            Text { text: "10:44"; color: "#e5f2ee"; font.pixelSize: 11; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                            Rectangle { width: 22; height: 22; radius: 11; color: Qt.rgba(0.32, 0.85, 0.72, 0.4); anchors.horizontalCenter: parent.horizontalCenter }
                            Rectangle { width: 44; height: 10; radius: 5; color: Qt.rgba(0.32, 0.85, 0.72, 0.2); anchors.horizontalCenter: parent.horizontalCenter }
                        }

                        // Col 3
                        Column {
                            spacing: 3
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle { width: 32; height: 32; radius: 3; color: Qt.rgba(0.32, 0.85, 0.72, 0.25) }
                            Rectangle { width: 32; height: 28; radius: 3; color: Qt.rgba(0.32, 0.85, 0.72, 0.20) }
                        }
                    }
                }

                // --- Bloom Artwork (Coming Soon) ---
                Item {
                    anchors.fill: parent
                    visible: root.styleId === "bloom"
                    Rectangle { anchors.fill: parent; color: "#22131b" }
                    Row {
                        anchors.centerIn: parent
                        spacing: 3
                        Repeater {
                            model: ["1", "0", "4", "4"]
                            Rectangle {
                                width: 18; height: 24; radius: 6; color: "#f3b3c8"
                                Text { anchors.centerIn: parent; text: modelData; color: "#22131b"; font.pixelSize: 12; font.bold: true }
                            }
                        }
                    }
                }

                // --- Orbit Artwork (Coming Soon) ---
                Item {
                    anchors.fill: parent
                    visible: root.styleId === "orbit"
                    Rectangle { anchors.fill: parent; color: "#181a20" }
                    Rectangle {
                        anchors.centerIn: parent
                        width: 48; height: 48; radius: 24; color: "transparent"
                        border.width: 2; border.color: "#82e0cf"
                        Text { anchors.centerIn: parent; text: "10:44"; color: "#82e0cf"; font.pixelSize: 10; font.bold: true }
                    }
                }

                // --- Darkroom Artwork (Coming Soon) ---
                Item {
                    anchors.fill: parent
                    visible: root.styleId === "darkroom"
                    Rectangle { anchors.fill: parent; color: "#1f1816" }
                    Rectangle {
                        anchors.centerIn: parent
                        width: 46; height: 56; radius: 3; color: "#eee"
                        Rectangle { anchors.top: parent.top; anchors.topMargin: 4; anchors.horizontalCenter: parent.horizontalCenter; width: 38; height: 36; color: "#666" }
                    }
                }

                // --- Deck Artwork (Media Island Dashboard) ---
                Item {
                    anchors.fill: parent
                    visible: root.styleId === "deck"

                    Rectangle {
                        anchors.fill: parent
                        color: "#13151f"
                    }

                    // Center Media Deck Island
                    Rectangle {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -3
                        width: 108
                        height: 38
                        radius: 8
                        color: Qt.rgba(0.12, 0.14, 0.22, 0.90)
                        border.width: 1
                        border.color: Qt.rgba(0.95, 0.61, 0.72, 0.35)

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            // Mini Scallop Album Art
                            Rectangle {
                                width: 26
                                height: 26
                                radius: 7
                                color: "#321d28"
                                border.width: 1
                                border.color: "#f29cb8"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "♫"
                                    color: "#f29cb8"
                                    font.pixelSize: 11
                                }
                            }

                            // Track Info lines
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3
                                width: 34

                                Rectangle { width: 30; height: 4; radius: 2; color: "#f29cb8" }
                                Rectangle { width: 22; height: 3; radius: 1.5; color: Qt.rgba(0.91, 0.92, 0.95, 0.45) }
                                Row {
                                    spacing: 3
                                    Rectangle { width: 4; height: 4; radius: 2; color: Qt.rgba(1,1,1,0.5) }
                                    Rectangle { width: 4; height: 4; radius: 2; color: "#f29cb8" }
                                    Rectangle { width: 4; height: 4; radius: 2; color: Qt.rgba(1,1,1,0.5) }
                                }
                            }

                            // Divider
                            Rectangle {
                                width: 1
                                height: 24
                                color: Qt.rgba(1, 1, 1, 0.15)
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Stacked Mini Clock
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: -2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "10"
                                    color: "#f29cb8"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "44"
                                    color: "#f29cb8"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                        }
                    }

                    // Bottom-Left mini status pill
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.margins: 6
                        width: 26; height: 6; radius: 3
                        color: Qt.rgba(0.91, 0.92, 0.95, 0.2)
                    }

                    // Bottom-Right mini password/user pill
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: 6
                        width: 32; height: 6; radius: 3
                        color: Qt.rgba(0.95, 0.61, 0.72, 0.25)
                    }
                }
            }

            // "In use" pill badge
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 7
                height: 18
                width: inUseRow.implicitWidth + 12
                radius: 9
                color: Qt.rgba(0.24, 0.12, 0.20, 0.92)
                border.width: 1
                border.color: root.colAccent
                visible: root.isInUse

                Row {
                    id: inUseRow
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "In use"
                        color: root.colAccent
                        font.pixelSize: 9
                        font.weight: Font.Bold
                    }
                }
            }

            // "Coming soon" badge for placeholders
            Rectangle {
                anchors.centerIn: parent
                height: 20
                width: soonText.implicitWidth + 12
                radius: 10
                color: Qt.rgba(0, 0, 0, 0.75)
                visible: !root.isAvailable

                Text {
                    id: soonText
                    anchors.centerIn: parent
                    text: "Coming Soon"
                    color: root.colSub
                    font.pixelSize: 9
                    font.weight: Font.Medium
                }
            }

            MouseArea {
                id: cardMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: root.isAvailable ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                onClicked: {
                    if (root.isAvailable) root.clicked();
                }
            }
        }

        // Style Name Label Below Card
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.styleName
            color: root.isSelected ? root.colAccent : root.colSub
            font.pixelSize: 12
            font.weight: root.isSelected ? Font.Bold : Font.Medium
        }
    }
}
