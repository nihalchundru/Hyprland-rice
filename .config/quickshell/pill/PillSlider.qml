import QtQuick

// Rounded track, accent fill, icon inside the fill. value is 0..1.
Item {
    id: root

    property real value: 0
    property string icon: ""
    property bool active: true
    signal moved(real v)

    property real local: 0
    readonly property real shown: ma.pressed ? local : value

    height: 28
    opacity: active ? 1 : 0.45

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.inset
    }

    Rectangle {
        id: fill
        height: parent.height
        width: height + (root.width - height) * Math.max(0, Math.min(1, root.shown))
        radius: height / 2
        color: Theme.accent

        Behavior on width {
            enabled: !ma.pressed
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        Icon {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: 14
            color: Theme.onAccent
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        enabled: root.active
        cursorShape: Qt.PointingHandCursor

        function setFrom(x) {
            const span = root.width - root.height;
            const v = Math.max(0, Math.min(1, (x - root.height / 2) / span));
            root.local = v;
            root.moved(v);
        }
        onPressed: mouse => setFrom(mouse.x)
        onPositionChanged: mouse => { if (pressed) setFrom(mouse.x); }
    }
}
