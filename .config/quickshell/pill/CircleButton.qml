import QtQuick

Item {
    id: root

    property string icon: ""
    property bool active: false
    property real size: 64
    property real iconSize: 20
    signal clicked()

    width: size
    height: size

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.active ? Theme.accent
             : ma.pressed ? Theme.tileHi
             : ma.containsMouse ? Theme.tileHi : Theme.tile
        border.width: root.active ? 0 : 1
        border.color: Theme.tileHi
        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
    }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        size: root.iconSize
        color: root.active ? Theme.onAccent : Theme.text
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
