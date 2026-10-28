import QtQuick

// Search box with icon, placeholder and an optional trailing label.
// Esc always goes back; Up/Down are emitted; Left/Right only when horizontalKeys.
Item {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property string trailing: ""
    property bool horizontalKeys: false

    signal navUp()
    signal navDown()
    signal navLeft()
    signal navRight()
    signal accepted()

    function focusInput() { input.forceActiveFocus(); }
    function clear() { input.text = ""; }

    height: 40

    Icon {
        id: ic
        x: 4
        anchors.verticalCenter: parent.verticalCenter
        name: "search"
        size: 18
        color: Theme.dim
    }

    TextInput {
        id: input
        anchors.left: ic.right
        anchors.leftMargin: 12
        anchors.right: trail.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        color: Theme.text
        selectionColor: Theme.accent
        selectedTextColor: Theme.onAccent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(17)

        onAccepted: root.accepted()

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) { Pill.back(); event.accepted = true; }
            else if (event.key === Qt.Key_Up) { root.navUp(); event.accepted = true; }
            else if (event.key === Qt.Key_Down) { root.navDown(); event.accepted = true; }
            else if (root.horizontalKeys && event.key === Qt.Key_Left) { root.navLeft(); event.accepted = true; }
            else if (root.horizontalKeys && event.key === Qt.Key_Right) { root.navRight(); event.accepted = true; }
        }

        Text {
            visible: input.text === ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.placeholder
            color: Theme.dim
            font: input.font
        }
    }

    Text {
        id: trail
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: root.trailing
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.px(12)
    }
}
