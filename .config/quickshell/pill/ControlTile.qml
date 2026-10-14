import QtQuick

// A control that is a wide tile when it has room, and a single circle when it
// is one cell wide.
Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal clicked()
    signal toggled()

    readonly property bool compact: width < 110

    Tile {
        visible: !root.compact
        width: root.width
        height: root.height
        icon: root.icon
        title: root.title
        subtitle: root.subtitle
        active: root.active
        onClicked: root.clicked()
        onToggled: root.toggled()
    }

    CircleButton {
        visible: root.compact
        anchors.centerIn: parent
        size: Math.min(root.width, root.height)
        icon: root.icon
        active: root.active
        onClicked: root.toggled()
    }
}
