import QtQuick
import Quickshell
import Quickshell.Widgets

// One icon in the dock: the app icon, a dot per open window, and a name label on hover.
Item {
    id: root

    required property var modelData          // {key, name, entry, appId, windows, pinned}
    property int size: 36
    property string edge: "bottom"           // which screen edge the dock is on (dots sit toward it)
    signal menuRequested(var item, real cx, real cy)

    readonly property bool vertical: edge !== "bottom"
    readonly property int dotRoom: 8
    readonly property var windows: modelData.windows
    readonly property bool running: windows.length > 0
    readonly property bool active: windows.some(w => w.activated)
    readonly property bool hovered: ma.containsMouse

    width: vertical ? size + dotRoom : size
    height: vertical ? size : size + dotRoom
    z: hovered ? 10 : 1

    function iconSource() {
        const e = modelData.entry;
        const names = [e ? e.icon : "", modelData.appId, String(modelData.appId).toLowerCase()];
        for (let i = 0; i < names.length; i++) {
            if (!names[i]) continue;
            const p = Quickshell.iconPath(names[i], true);
            if (p) return p;
        }
        return Quickshell.iconPath("application-x-executable");
    }

    Item {
        id: iconBox
        x: root.edge === "left" ? root.dotRoom : 0
        y: 0
        width: root.size
        height: root.size

        // soft highlight behind the app that has focus
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: Theme.r(12)
            color: Theme.tile
            opacity: root.active ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.fadeMs } }
        }

        IconImage {
            anchors.fill: parent
            source: root.iconSource()
        }
    }

    // one dot per window (up to four); the focused window's dot is accent coloured
    Grid {
        visible: root.running
        columns: root.vertical ? 1 : 4
        spacing: 3
        x: root.vertical ? (root.edge === "left" ? 1 : root.size + 3) : (root.width - width) / 2
        y: root.vertical ? (root.height - height) / 2 : root.size + 3

        Repeater {
            model: Math.min(root.windows.length, 4)

            Rectangle {
                required property int index
                width: 4
                height: 4
                radius: 2
                color: root.windows[index] && root.windows[index].activated ? Theme.accent : Theme.dim
                Behavior on color { ColorAnimation { duration: Theme.fadeMs } }
            }
        }
    }

    // name label
    Rectangle {
        visible: root.hovered
        x: root.edge === "bottom" ? (root.width - width) / 2
         : root.edge === "left" ? root.width + 10 : -(width + 10)
        y: root.edge === "bottom" ? -(height + 10) : (root.height - height) / 2
        width: nameText.implicitWidth + 24
        height: nameText.implicitHeight + 14
        radius: Theme.r(12)
        color: Theme.body
        border.width: 1
        border.color: Theme.tileHi

        Text {
            id: nameText
            anchors.centerIn: parent
            text: root.modelData.name
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.px(12)
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) Dock.activate(root.modelData);
            else if (mouse.button === Qt.MiddleButton) Dock.launch(root.modelData);
            else {
                const pt = root.mapToItem(null, root.width / 2, root.height / 2);
                root.menuRequested(root.modelData, pt.x, pt.y);
            }
        }
    }
}
