import QtQuick

// Notification history; fills whatever size it is given.
Rectangle {
    id: root

    radius: Theme.r(24)
    color: Theme.tile
    border.width: 1
    border.color: Theme.tileHi

    Text {
        x: 16
        y: 14
        text: "Notifications"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(13)
    }

    PillButton {
        visible: Notifs.count > 0
        x: parent.width - width - 12
        y: 8
        label: "Clear all"
        onClicked: Notifs.clear()
    }

    Text {
        visible: Notifs.count === 0
        x: 16
        y: 46
        text: "No notifications"
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(15)
    }

    ListView {
        visible: Notifs.count > 0
        x: 12
        y: 46
        width: parent.width - 24
        height: parent.height - 58
        clip: true
        spacing: 8
        boundsBehavior: Flickable.StopAtBounds
        model: Notifs.list

        delegate: Rectangle {
            required property var modelData
            width: ListView.view.width
            height: nCol.implicitHeight + 20
            radius: Theme.r(16)
            color: Theme.tileHi

            Column {
                id: nCol
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: closeBtn.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    width: parent.width
                    text: modelData.appName
                    elide: Text.ElideRight
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(11)
                }
                Text {
                    width: parent.width
                    text: modelData.summary
                    elide: Text.ElideRight
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(14)
                    font.weight: Font.DemiBold
                }
                Text {
                    width: parent.width
                    visible: text !== ""
                    text: modelData.body
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.px(12)
                }
            }

            CircleButton {
                id: closeBtn
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                size: 26
                iconSize: 12
                icon: "x"
                onClicked: modelData.dismiss()
            }
        }
    }
}
