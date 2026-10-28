import QtQuick

// Row with a button. A row marked `confirm` needs a second click within 4 seconds.
Item {
    id: root

    property var def: ({})
    property bool first: false
    property bool armed: false

    readonly property bool hasNote: !!def.note

    width: parent ? parent.width : 0
    height: hasNote ? 74 : 54

    function press() {
        if (def.confirm && !armed) {
            armed = true;
            disarm.restart();
            return;
        }
        armed = false;
        disarm.stop();
        SysInfo.run(def.action);
    }

    Timer {
        id: disarm
        interval: 4000
        onTriggered: root.armed = false
    }

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
        width: parent.width - 32 - btn.width - 24
        spacing: 3

        Text {
            width: parent.width
            text: root.def.label || ""
            elide: Text.ElideRight
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 15
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
            font.pixelSize: 12
        }
    }

    Rectangle {
        id: btn
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: txt.implicitWidth + 32
        height: 34
        radius: 17
        color: root.armed ? Theme.red : (ma.containsMouse ? Theme.tileHi : Theme.tile)
        border.width: root.armed ? 0 : 1
        border.color: Theme.tileHi
        Behavior on color { ColorAnimation { duration: Theme.fadeMs } }

        Text {
            id: txt
            anchors.centerIn: parent
            text: root.armed ? "Click again to confirm" : (root.def.button || "Run")
            color: root.armed ? Theme.onAccent : (root.def.danger ? Theme.red : Theme.text)
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.press()
        }
    }
}
