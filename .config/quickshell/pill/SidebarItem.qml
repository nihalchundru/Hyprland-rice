import QtQuick

Item {
    id: root

    property string icon: ""
    property string label: ""
    property bool selected: false
    signal clicked()

    height: 46

    Rectangle {
        anchors.fill: parent
        radius: Theme.r(18)
        color: root.selected ? Theme.tile : (ma.containsMouse ? Theme.inset : "transparent")
        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
    }

    Rectangle {
        id: circ
        x: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        radius: Theme.r(16)
        color: Theme.accent

        Icon {
            anchors.centerIn: parent
            name: root.icon
            size: 16
            color: Theme.onAccent
        }
    }

    Text {
        anchors.left: circ.right
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(15)
        font.weight: root.selected ? Font.Medium : Font.Normal
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
