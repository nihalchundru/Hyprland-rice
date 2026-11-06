import QtQuick
import QtQuick.Effects
import Quickshell

// Material 3 User Badge (Top-Left)
// - Avatar from ~/.face or ~/.face.icon masked into an M3 9-sided cookie
// - Fallback with user initial in theme accent if no avatar file exists
// - Displays greeting and user name in a frosted M3 pill
Item {
    id: root

    property string artShape: "Cookie9Sided"
    readonly property string username: Quickshell.env("USER") || "User"
    readonly property string displayName: username.charAt(0).toUpperCase() + username.slice(1)
    readonly property string facePath: "file://" + Quickshell.env("HOME") + "/.face"
    readonly property string faceIconPath: "file://" + Quickshell.env("HOME") + "/.face.icon"

    implicitWidth: pill.width
    implicitHeight: pill.height

    Rectangle {
        id: pill
        width: row.implicitWidth + 24
        height: 52
        radius: height / 2
        color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.75)
        border.width: 1
        border.color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.12)

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 12

            // Avatar Container
            Item {
                width: 38
                height: 38
                anchors.verticalCenter: parent.verticalCenter

                // 1. Fallback 9-sided cookie shape with Initial letter
                MShape {
                    id: fallbackShape
                    anchors.fill: parent
                    size: parent.width
                    shape: root.artShape
                    color: Qt.darker(Colors.surface, 1.25)
                    visible: !avatarEffect.visible

                    Text {
                        anchors.centerIn: parent
                        text: root.displayName.charAt(0)
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: Colors.accent
                    }
                }

                // 2. Avatar Image source
                Image {
                    id: avatarImage
                    anchors.fill: parent
                    source: root.facePath
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    visible: false
                    asynchronous: true
                    onStatusChanged: {
                        if (status === Image.Error && source === root.facePath) {
                            source = root.faceIconPath;
                        }
                    }
                }

                // 3. Avatar Mask
                Item {
                    id: avatarMask
                    anchors.fill: parent
                    layer.enabled: true
                    visible: false

                    MShape {
                        anchors.fill: parent
                        size: parent.width
                        shape: root.artShape
                        color: "white"
                    }
                }

                // 4. Cut Avatar into M3 Cookie shape
                MultiEffect {
                    id: avatarEffect
                    anchors.fill: parent
                    source: avatarImage
                    maskSource: avatarMask
                    maskEnabled: true
                    visible: avatarImage.status === Image.Ready
                }
            }

            // User Info
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: "Welcome back,"
                    color: Colors.sub
                    font.pixelSize: 10
                    font.weight: Font.Medium
                }

                Text {
                    text: root.displayName
                    color: Colors.text
                    font.pixelSize: 13
                    font.weight: Font.Bold
                }
            }
        }
    }
}
