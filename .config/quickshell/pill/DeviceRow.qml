import QtQuick

// List row: icon circle, label (+ sub), optional check and trailing items.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property string sub: ""
    property bool selected: false
    property bool showCheck: false
    property bool clickable: true
    property alias trailing: slot.data
    signal clicked()

    height: sub ? 54 : 46

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: (ma.containsMouse && root.clickable) ? Theme.tileHi : Theme.tile
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.clickable
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Rectangle {
        id: circ
        x: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        radius: 16
        color: root.selected ? Theme.accent : Theme.tileHi

        Icon {
            anchors.centerIn: parent
            name: root.icon
            size: 15
            color: root.selected ? Theme.onAccent : Theme.text
        }
    }

    Column {
        anchors.left: circ.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: slot.width + (root.showCheck ? 44 : 22)
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            text: root.label
            elide: Text.ElideRight
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 14
            font.weight: root.selected ? Font.DemiBold : Font.Normal
        }
        Text {
            width: parent.width
            visible: root.sub !== ""
            text: root.sub
            elide: Text.ElideRight
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }
    }

    Row {
        id: slot
        anchors.right: parent.right
        anchors.rightMargin: root.showCheck ? 38 : 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
    }

    Icon {
        visible: root.showCheck
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        name: "check"
        size: 16
        color: Theme.accent
    }
}
