import QtQuick

// Wide control-center tile. Clicking the circle emits toggled(); clicking the
// rest of the tile emits clicked().
Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal clicked()
    signal toggled()

    height: 64

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: bodyMa.containsMouse ? Theme.tileHi : Theme.tile
        border.width: 1
        border.color: Theme.tileHi
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    MouseArea {
        id: bodyMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Rectangle {
        id: circ
        x: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        height: 48
        radius: 24
        color: root.active ? Theme.accent : Theme.tileHi
        Behavior on color { ColorAnimation { duration: 150 } }

        Icon {
            anchors.centerIn: parent
            name: root.icon
            size: 20
            color: root.active ? Theme.onAccent : Theme.text
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()
        }
    }

    Column {
        anchors.left: circ.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            text: root.title
            elide: Text.ElideRight
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
        Text {
            width: parent.width
            text: root.subtitle
            elide: Text.ElideRight
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }
    }
}
