import QtQuick

Item {
    id: root

    property bool checked: false
    signal toggled(bool v)

    width: 54
    height: 30

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.accent : Theme.tileHi
        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
    }

    Rectangle {
        y: 4
        width: 22
        height: 22
        radius: 11
        x: root.checked ? parent.width - width - 4 : 4
        color: root.checked ? Theme.onAccent : Theme.dim
        Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
