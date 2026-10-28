import QtQuick

// Settings row that opens something: label on the left, value and an arrow on the right.
Item {
    id: root

    property var def: ({})
    property bool first: false

    readonly property string value: def.valueSource === "theme" ? Themes.current : (def.value || "")

    width: parent ? parent.width : 0
    height: 52

    Rectangle {
        anchors.fill: parent
        radius: Theme.r(22)
        color: ma.containsMouse ? Theme.tile : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
    }

    Rectangle {
        visible: !root.first
        x: 16
        width: parent.width - 32
        height: 1
        color: Theme.mix(Theme.body, Theme.text, 0.07)
    }

    Text {
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        text: root.def.label || ""
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(15)
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.value
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(14)
        }
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: "arrow-right"
            size: 14
            color: Theme.dim
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            // the pickers open in the pill at the top of the screen, which this
            // window would cover, so the window closes (on the next turn of the event loop)
            Pill.open(root.def.action, true);
            Settings.closeTick++;
        }
    }
}
