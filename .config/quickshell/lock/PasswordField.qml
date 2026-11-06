import QtQuick
import "M3Shapes.js" as Shapes

// The password field, where every typed character becomes its own Material 3
// shape instead of a dot.
//
// The shapes live in a ListModel driving a ListView rather than a Repeater over
// a JS array: a Repeater destroys and rebuilds every delegate whenever the
// model changes, which would replay the entry animation on all of them on each
// keystroke. ListModel supports incremental append/remove, so only the
// character that actually changed animates.
Item {
    id: root

    property string password: ""
    property int maxLength: Config.maxPasswordLength
    property int shapeSize: 34

    signal submitted(string password)

    implicitWidth: Math.min(contentWidth, 720)
    implicitHeight: 56

    readonly property int contentWidth: Math.max(280, shapes.count * (shapeSize + 10))
    readonly property bool empty: shapes.count === 0

    // shake on a rejected password
    property real shakeOffset: 0

    ListModel { id: shapes }

    function forceFocus() {
        input.forceActiveFocus();
    }

    function clear() {
        if (input.text !== "")
            input.text = "";   // triggers sync(), which pops every shape in turn
    }

    function submit() {
        if (root.password.length === 0 || Auth.busy) return;
        root.submitted(root.password);
    }

    function pushChar(ch) {
        const names = Shapes.shapeNames();
        const kind = Shapes.kindForChar(ch);
        // morph in from a shape a few places along the sheet, so the character
        // materialises rather than simply appearing
        const from = names[(names.indexOf(kind) + 7) % names.length];
        shapes.append({ kind: kind, fromKind: from });
    }

    function popChar() {
        if (shapes.count > 0)
            shapes.remove(shapes.count - 1);
    }

    // Reconcile the hidden input with what is on screen. Handles paste and
    // multi-character deletes, not just single keystrokes.
    function sync() {
        const text = input.text;
        const shown = root.password;

        if (text.length > shown.length) {
            for (let i = shown.length; i < text.length; i++)
                root.pushChar(text.charAt(i));
        } else if (text.length < shown.length) {
            const removed = shown.length - text.length;
            for (let i = 0; i < removed; i++)
                root.popChar();
        }

        root.password = text;
    }

    // ---------------------------------------------------------------- shapes
    ListView {
        id: row

        anchors.centerIn: parent
        width: Math.min(contentWidth, root.width)
        height: root.shapeSize + 8
        orientation: ListView.Horizontal
        model: shapes
        spacing: 10
        interactive: false
        clip: true
        onCountChanged: positionViewAtEnd()

        transform: Translate { x: root.shakeOffset }

        delegate: Item {
            id: cell

            required property string kind
            required property string fromKind

            width: root.shapeSize
            height: root.shapeSize
            // start hidden so the very first frame doesn't flash the finished
            // shape before the entry animation runs
            scale: 0.2
            opacity: 0

            M3Shape {
                anchors.fill: parent
                kind: cell.kind
                fromKind: cell.fromKind
                fillColor: M3Theme.palette.primary

                // morphs from fromKind into kind as the character lands
                NumberAnimation on morph {
                    from: 0
                    to: 1
                    duration: 340
                    easing.type: Easing.OutBack
                    running: true
                }
            }

            ParallelAnimation {
                id: enter

                NumberAnimation {
                    target: cell
                    property: "scale"
                    to: 1
                    duration: 280
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: cell
                    property: "opacity"
                    to: 1
                    duration: 160
                }
            }

            Component.onCompleted: enter.start()
        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 120 }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "scale"
                    to: 0
                    duration: M3Theme.durationMedium1
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: M3Theme.durationShort4
                }
                NumberAnimation {
                    property: "rotation"
                    to: 40
                    duration: M3Theme.durationMedium1
                    easing.type: Easing.InCubic
                }
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: M3Theme.durationShort4
                easing.type: Easing.OutCubic
            }
        }
    }

    // placeholder shown while nothing has been typed
    Text {
        anchors.centerIn: parent
        visible: root.empty
        text: Auth.busy ? "checking…" : "enter password"
        color: M3Theme.palette.onSurfaceVariant
        opacity: 0.7
        font.family: M3Theme.font
        font.pixelSize: M3Theme.bodyMedium
    }

    // ------------------------------------------------------------- input sink
    // Invisible: it exists only to receive keystrokes. echoMode keeps the real
    // characters out of every rendering path.
    TextInput {
        id: input

        anchors.fill: parent
        opacity: 0
        echoMode: TextInput.Password
        enabled: !Auth.busy
        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText

        onTextChanged: {
            if (input.length > root.maxLength) {
                // Trimming re-enters onTextChanged; that pass then sees equal
                // lengths and does nothing, so this cannot loop.
                input.text = input.text.slice(0, root.maxLength);
                return;
            }
            root.sync();
        }

        onAccepted: root.submit()

        Keys.onEscapePressed: root.clear()
    }

    SequentialAnimation {
        id: shake

        NumberAnimation { target: root; property: "shakeOffset"; to: -11; duration: 50 }
        NumberAnimation { target: root; property: "shakeOffset"; to: 11; duration: 50 }
        NumberAnimation { target: root; property: "shakeOffset"; to: -7; duration: 50 }
        NumberAnimation { target: root; property: "shakeOffset"; to: 7; duration: 50 }
        NumberAnimation { target: root; property: "shakeOffset"; to: 0; duration: 60 }
    }

    Connections {
        target: Auth

        function onFailed() {
            shake.start();
            root.clear();
            root.forceFocus();
        }

        function onUnlocked() {
            root.clear();
        }
    }
}
