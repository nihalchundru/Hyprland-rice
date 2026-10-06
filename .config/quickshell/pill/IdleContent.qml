import QtQuick

Item {
    id: root
    width: Theme.idleW
    height: Theme.idleH

    WorkspaceDots {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        size: 10
    }

    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(Pill.now, "HH:mm")
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 15
        font.weight: Font.Medium
    }

    Row {
        id: cluster
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        SignalBars {}
        BatteryIcon {}
    }

    MouseArea {
        anchors.fill: cluster
        anchors.margins: -8
        cursorShape: Qt.PointingHandCursor
        onClicked: Pill.open("control", true)
    }
}
