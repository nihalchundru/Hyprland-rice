import QtQuick

// Settings row: label on the left, switch on the right.
Item {
    id: root

    property var def: ({})
    property bool first: false

    width: parent ? parent.width : 0
    height: 54

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
        font.pixelSize: 15
    }

    PillSwitch {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        checked: !!Settings.get(root.def.key)
        onToggled: v => Settings.set(root.def.key, v)
    }
}
