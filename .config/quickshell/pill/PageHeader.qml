import QtQuick

// Back button + title (+ optional trailing items, e.g. a switch).
Item {
    id: root

    property string title: ""
    property alias trailing: slot.data
    signal back()

    height: 56

    Rectangle {
        id: backBtn
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        height: 34
        radius: 17
        color: ma.containsMouse ? Theme.tileHi : Theme.tile

        Icon {
            anchors.centerIn: parent
            name: "chevron-left"
            size: 16
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.back()
        }
    }

    Text {
        anchors.left: backBtn.right
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 18
        font.weight: Font.Medium
    }

    Row {
        id: slot
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
    }
}
