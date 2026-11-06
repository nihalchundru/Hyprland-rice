import QtQuick
import QtQuick.Effects
import Quickshell

// Circular User Avatar for lockscreen2 center column
Item {
    id: root

    property real size: 130
    readonly property string facePath: "file://" + Quickshell.env("HOME") + "/.face"
    readonly property string faceIconPath: "file://" + Quickshell.env("HOME") + "/.face.icon"
    readonly property string username: Quickshell.env("USER") || "User"

    implicitWidth: size
    implicitHeight: size

    // Subtle outer glow/border ring
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: Colors.cardBorder
    }

    Item {
        anchors.centerIn: parent
        width: root.size - 6
        height: width

        // Fallback placeholder
        Rectangle {
            id: fallbackBg
            anchors.fill: parent
            radius: width / 2
            color: Colors.cardBg
            visible: !avatarEffect.visible

            Text {
                anchors.centerIn: parent
                text: root.username.charAt(0).toUpperCase()
                font.pixelSize: 42
                font.weight: Font.Bold
                color: Colors.accent
            }
        }

        // Image source
        Image {
            id: avatarImg
            anchors.fill: parent
            source: root.facePath
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            layer.enabled: true
            visible: false

            onStatusChanged: {
                if (status === Image.Error && source === root.facePath) {
                    source = root.faceIconPath;
                }
            }
        }

        // Circle Mask
        Rectangle {
            id: circleMask
            anchors.fill: parent
            radius: width / 2
            color: "white"
            layer.enabled: true
            visible: false
        }

        // MultiEffect mask
        MultiEffect {
            id: avatarEffect
            anchors.fill: parent
            source: avatarImg
            maskSource: circleMask
            maskEnabled: true
            visible: avatarImg.status === Image.Ready
        }
    }
}
