import QtQuick
import "../core"
import "../components"

Item {
    id: f

    property string label: ""
    property string text: ""
    property string placeholder: ""
    signal committed(string v)

    implicitHeight: (label.length > 0 ? 24 : 0) + 34

    Txt {
        visible: f.label.length > 0
        anchors.left: parent.left
        anchors.top: parent.top
        text: f.label
        color: Theme.onSurface
        font.pixelSize: 13
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 34
        radius: 10
        color: Theme.cardAlt
        border.width: input.activeFocus ? 2 : 0
        border.color: Theme.accent

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Theme.onSurface
            font.family: LayoutStore.fontFamily
            font.pixelSize: 13
            selectByMouse: true
            selectionColor: Theme.accent
            selectedTextColor: Theme.onAccent

            // commits on Enter or when focus leaves, not on every keystroke
            onEditingFinished: f.committed(text)
            Keys.onReturnPressed: LayoutStore.focusEditor()
            Keys.onEnterPressed:  LayoutStore.focusEditor()
            Keys.onEscapePressed: { text = f.text; LayoutStore.focusEditor(); }
        }

        // keeps the field in sync with outside changes, except while typing
        Binding {
            target: input
            property: "text"
            value: f.text
            when: !input.activeFocus
        }

        Txt {
            visible: input.text.length === 0
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: f.placeholder
            color: Qt.alpha(Theme.onSurfaceDim, 0.6)
            font.pixelSize: 13
        }
    }
}