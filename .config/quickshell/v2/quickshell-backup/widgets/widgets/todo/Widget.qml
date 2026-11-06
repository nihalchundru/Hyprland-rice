import QtQuick
import "../../core"
import "../../components"
import "../../services"

Item {
    id: root

    property int cols: 3
    property int rows: 3
    property var settings: ({})
    property color accent:  Theme.accent
    property color accent2: Theme.accent2
    property color accent3: Theme.accent3

    readonly property string title: settings.title || "To-do"
    readonly property bool hideDone: settings.hideDone ?? false

    // keeps each item's real index so toggling still hits the right entry
    readonly property var entries: Todos.items
        .map((it, i) => ({ text: it.text, done: it.done, idx: i }))
        .filter(r => !(hideDone && r.done))

    // header
    Item {
        id: head
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 26

        Txt {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: headRight.left
            anchors.rightMargin: 8
            text: root.title
            font.pixelSize: 15
            font.weight: Font.Bold
            elide: Text.ElideRight
        }

        Row {
            id: headRight
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Txt {
                visible: Todos.doneCount > 0
                text: "Clear"
                color: root.accent
                font.pixelSize: 11
                font.weight: Font.Bold

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Todos.clearDone()
                }
            }
            Txt {
                text: Todos.doneCount + "/" + Todos.items.length
                color: Theme.onSurfaceDim
                font.pixelSize: 11
            }
        }
    }

    // add field
    Rectangle {
        id: addBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 32
        radius: 12
        color: Theme.cardAlt
        border.width: input.activeFocus ? 2 : 0
        border.color: root.accent

        Txt {
            id: plus
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: "+"
            color: root.accent
            font.pixelSize: 16
            font.weight: Font.Bold
        }

        TextInput {
            id: input
            anchors.left: plus.right
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            color: Theme.onSurface
            font.family: LayoutStore.fontFamily
            font.pixelSize: 13
            selectByMouse: true
            selectionColor: root.accent
            selectedTextColor: Theme.onAccent

            onAccepted: {
                Todos.add(text);
                text = "";
            }
            Keys.onEscapePressed: {
                text = "";
                focus = false;
            }
        }

        Txt {
            visible: input.text.length === 0
            anchors.left: input.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Add item…"
            color: Qt.alpha(Theme.onSurfaceDim, 0.6)
            font.pixelSize: 13
        }
    }

    // list
    ListView {
        id: list
        anchors.top: head.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: addBar.top
        anchors.bottomMargin: 8
        clip: true
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        model: root.entries

        delegate: Item {
            id: row
            required property var modelData
            readonly property bool done: modelData.done

            width: list.width
            height: 30

            HoverHandler { id: hh }

            Rectangle {
                id: box
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 18
                height: 18
                radius: 9
                color: row.done ? root.accent : "transparent"
                border.width: 2
                border.color: row.done ? root.accent : Theme.track
                Behavior on color { ColorAnimation { duration: 150 } }

                Rectangle {
                    anchors.centerIn: parent
                    width: 6
                    height: 6
                    radius: 3
                    color: Theme.onAccent
                    opacity: row.done ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }

            Txt {
                id: label
                anchors.left: box.right
                anchors.leftMargin: 10
                anchors.right: del.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.text
                color: row.done ? Theme.onSurfaceDim : Theme.onSurface
                font.strikeout: row.done
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            // toggle (covers checkbox + text)
            MouseArea {
                anchors.left: parent.left
                anchors.right: del.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                cursorShape: Qt.PointingHandCursor
                onClicked: Todos.toggle(row.modelData.idx)
            }

            // delete (shown on hover)
            Txt {
                id: del
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                horizontalAlignment: Text.AlignHCenter
                text: "×"
                color: Theme.danger
                font.pixelSize: 16
                opacity: hh.hovered ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 120 } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Todos.remove(row.modelData.idx)
                }
            }
        }

        Txt {
            visible: root.entries.length === 0
            anchors.centerIn: parent
            text: Todos.items.length > 0 ? "All done" : "Nothing to do"
            color: Theme.onSurfaceDim
            font.pixelSize: 12
        }
    }
}