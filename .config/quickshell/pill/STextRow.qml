import QtQuick

// Settings row with a text field. kind "hex" applies as you type (and shows red
// while the colour is invalid); anything else (fonts) applies on Enter / focus loss.
Item {
    id: root

    property var def: ({})
    property bool first: false
    property bool valid: true

    readonly property string stored: String(Settings.get(def.key) || "")
    readonly property bool hex: def.kind === "hex"

    width: parent ? parent.width : 0
    height: 56

    function accept(t) {
        t = t.trim();
        if (hex) {
            if (t === "") { valid = true; Settings.set(def.key, ""); return; }
            const v = t[0] === "#" ? t : "#" + t;
            valid = /^#[0-9a-fA-F]{6}$/.test(v);
            if (valid) Settings.set(def.key, v.toLowerCase());
        } else {
            Settings.set(def.key, t);
        }
    }

    onStoredChanged: { if (!input.activeFocus) input.text = stored; }
    Component.onCompleted: input.text = stored

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

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 260
        height: 34
        radius: Theme.r(12)
        color: Theme.tile
        border.width: 1
        border.color: !root.valid ? Theme.red : (input.activeFocus ? Theme.accent : "transparent")
        Behavior on border.color { ColorAnimation { duration: Theme.fadeMs } }

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            color: Theme.text
            selectionColor: Theme.accent
            selectedTextColor: Theme.onAccent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(14)

            onTextEdited: { if (root.hex) root.accept(text); }
            onEditingFinished: root.accept(text)
            Keys.onEscapePressed: { text = root.stored; root.valid = true; focus = false; }

            Text {
                visible: input.text === ""
                anchors.verticalCenter: parent.verticalCenter
                text: root.def.placeholder || ""
                color: Theme.dim
                font: input.font
            }
        }
    }
}
