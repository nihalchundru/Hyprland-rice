import QtQuick
import "../core"
import "../components"

Item {
    id: t

    property string label: ""
    property bool checked: false
    signal toggled(bool v)

    implicitHeight: 34

    Txt {
        anchors.verticalCenter: parent.verticalCenter
        text: t.label
        color: Theme.onSurface
        font.pixelSize: 13
    }

    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        height: 22
        radius: 11
        color: t.checked ? Theme.accent : Theme.track
        Behavior on color { ColorAnimation { duration: 150 } }

        Rectangle {
            y: 3
            x: t.checked ? 21 : 3
            width: 16
            height: 16
            radius: 8
            color: t.checked ? Theme.onAccent : Theme.onSurface
            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: t.toggled(!t.checked)
    }
}