import QtQuick

// Settings row: label on the left (with an optional note under it), switch on the right.
Item {
    id: root

    property var def: ({})
    property bool first: false

    readonly property bool hasNote: !!def.note

    width: parent ? parent.width : 0
    height: hasNote ? 74 : 54

    Rectangle {
        visible: !root.first
        x: 16
        width: parent.width - 32
        height: 1
        color: Theme.mix(Theme.body, Theme.text, 0.07)
    }

    Column {
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 32 - sw.width - 24
        spacing: 3

        Text {
            width: parent.width
            text: root.def.label || ""
            elide: Text.ElideRight
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(15)
        }
        Text {
            visible: root.hasNote
            width: parent.width
            text: root.def.note || ""
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(12)
        }
    }

    PillSwitch {
        id: sw
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        checked: root.def.source === "clock24" ? ClockFmt.use24 : !!Settings.get(root.def.key)
        onToggled: v => {
            if (root.def.source === "clock24") ClockFmt.setUse24(v);
            else Settings.set(root.def.key, v);
        }
    }
}
