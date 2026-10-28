import QtQuick

// Album art, title / artist and transport buttons. Adapts to its size.
Item {
    id: root

    readonly property real artSize: Math.max(44, Math.min(84, height - 24 - 44))

    Rectangle {
        anchors.fill: parent
        radius: Theme.r(24)
        color: Theme.tile
        border.width: 1
        border.color: Theme.tileHi
    }

    // nothing playing
    Column {
        visible: !Media.hasPlayer
        anchors.centerIn: parent
        spacing: 6

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "music"
            size: 22
            color: Theme.dim
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Nothing playing"
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(13)
        }
    }

    Item {
        visible: Media.hasPlayer
        anchors.fill: parent

        RoundImage {
            id: art
            x: 12
            y: 12
            width: root.artSize
            height: root.artSize
            radius: Theme.r(14)
            source: Media.art
        }

        Column {
            anchors.left: art.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            y: 14
            spacing: 2

            Text {
                width: parent.width
                text: Media.title
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(15)
                font.weight: Font.DemiBold
            }
            Text {
                width: parent.width
                text: Media.artist
                elide: Text.ElideRight
                color: Theme.dim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.px(12)
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            spacing: 10

            CircleButton {
                size: 34
                iconSize: 15
                icon: "skip-back"
                onClicked: Media.previous()
            }
            CircleButton {
                size: 34
                iconSize: 15
                icon: Media.playing ? "pause" : "play"
                active: Media.playing
                onClicked: Media.toggle()
            }
            CircleButton {
                size: 34
                iconSize: 15
                icon: "skip-forward"
                onClicked: Media.next()
            }
        }
    }
}
