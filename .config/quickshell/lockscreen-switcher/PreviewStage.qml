import QtQuick
import QtQuick.Effects
import Quickshell

// Center stage showing the large live preview card and cycle chevrons
Item {
    id: root

    property string selectedStyleId: "veil"

    signal previousRequested()
    signal nextRequested()

    implicitWidth: 880
    implicitHeight: 460

    readonly property color colAccent: "#f3b3c8"
    readonly property color colSurface: Qt.rgba(0.12, 0.10, 0.13, 0.88)
    readonly property color colBorder: Qt.rgba(0.95, 0.70, 0.78, 0.20)

    // Left Chevron Button (<)
    Rectangle {
        id: leftBtn
        anchors.left: parent.left
        anchors.verticalCenter: previewFrame.verticalCenter
        width: 44
        height: 44
        radius: 22
        color: leftMouse.containsMouse ? Qt.rgba(0.24, 0.18, 0.22, 0.95) : root.colSurface
        border.width: 1
        border.color: root.colBorder
        scale: leftMouse.containsPress ? 0.92 : (leftMouse.containsMouse ? 1.06 : 1.0)
        Behavior on scale { NumberAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: "‹"
            color: root.colAccent
            font.pixelSize: 24
            font.bold: true
        }

        MouseArea {
            id: leftMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.previousRequested()
        }
    }

    // Right Chevron Button (>)
    Rectangle {
        id: rightBtn
        anchors.right: parent.right
        anchors.verticalCenter: previewFrame.verticalCenter
        width: 44
        height: 44
        radius: 22
        color: rightMouse.containsMouse ? Qt.rgba(0.24, 0.18, 0.22, 0.95) : root.colSurface
        border.width: 1
        border.color: root.colBorder
        scale: rightMouse.containsPress ? 0.92 : (rightMouse.containsMouse ? 1.06 : 1.0)
        Behavior on scale { NumberAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: "›"
            color: root.colAccent
            font.pixelSize: 24
            font.bold: true
        }

        MouseArea {
            id: rightMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.nextRequested()
        }
    }

    // Rounded Mask for the preview stage
    Rectangle {
        id: previewMask
        width: previewFrame.width
        height: previewFrame.height
        radius: 26
        color: "white"
        visible: false
        layer.enabled: true
    }

    // Main Rounded Preview Frame (16:9 ratio, 740x416)
    Item {
        id: previewFrame
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -12
        width: 740
        height: 416

        // Masked Container for the 1:1 Live Lockscreen
        Item {
            anchors.fill: parent
            visible: root.selectedStyleId === "veil" || root.selectedStyleId === "tessera" || root.selectedStyleId === "deck"
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: previewMask
            }

            // Virtual 1920x1080 stage scaled down
            Item {
                id: stageWrapper
                width: 1920
                height: 1080
                scale: previewFrame.width / 1920
                transformOrigin: Item.TopLeft

                Loader {
                    id: liveLoader
                    anchors.fill: parent
                    asynchronous: false
                    source: {
                        const base = "file://" + Quickshell.env("HOME") + "/.config/quickshell";
                        if (root.selectedStyleId === "veil") {
                            return base + "/lockscreen/Preview.qml";
                        } else if (root.selectedStyleId === "tessera") {
                            return base + "/lockscreen2/Preview.qml";
                        } else if (root.selectedStyleId === "deck") {
                            return base + "/lockscreen3/Preview.qml";
                        }
                        return "";
                    }
                    onStatusChanged: {
                        if (status === Loader.Error) {
                            console.warn("[switcher] Preview loader error for source:", source);
                        }
                    }
                }
            }
        }

        // Placeholder for coming-soon styles
        Item {
            anchors.fill: parent
            visible: root.selectedStyleId !== "veil" && root.selectedStyleId !== "tessera" && root.selectedStyleId !== "deck"

            Rectangle {
                anchors.fill: parent
                radius: 26
                color: "#080608"

                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "✨"
                        font.pixelSize: 42
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.selectedStyleId.toUpperCase()
                        color: root.colAccent
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        font.letterSpacing: 1.5
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Style under development • Coming soon"
                        color: Qt.rgba(0.95, 0.70, 0.78, 0.6)
                        font.pixelSize: 13
                    }
                }
            }
        }

        // Overlay Border with exact rounded corners
        Rectangle {
            anchors.fill: parent
            radius: 26
            color: "transparent"
            border.width: 1.5
            border.color: root.colBorder
            z: 2
        }

        // Click catcher overlay
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: true
            cursorShape: Qt.ArrowCursor
            z: 3
        }
    }

    // Pill label below the preview: ⌄ 6 styles
    Rectangle {
        anchors.top: previewFrame.bottom
        anchors.topMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        height: 26
        width: stylesPillRow.implicitWidth + 20
        radius: 13
        color: root.colSurface
        border.width: 1
        border.color: root.colBorder

        Row {
            id: stylesPillRow
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: "⌄"
                color: root.colAccent
                font.pixelSize: 11
                font.bold: true
            }

            Text {
                text: "6 styles"
                color: root.colAccent
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }
    }
}
