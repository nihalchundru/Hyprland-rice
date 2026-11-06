import QtQuick
import "../core"
import "../components"

Item {
    id: s

    property string label: ""
    property var roles: ["accent", "accent2", "accent3"]
    property string current: "accent"
    signal picked(string role)

    implicitHeight: 38

    function colorOf(r) {
        return r === "accent2" ? Theme.accent2 : r === "accent3" ? Theme.accent3 : Theme.accent;
    }

    Txt {
        anchors.verticalCenter: parent.verticalCenter
        text: s.label
        color: Theme.onSurface
        font.pixelSize: 13
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: s.roles

            Item {
                id: sw
                required property string modelData
                readonly property bool active: modelData === s.current

                width: 30
                height: 30

                Rectangle {
                    anchors.fill: parent
                    radius: 15
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.onSurface
                    opacity: sw.active ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    radius: 10
                    color: s.colorOf(sw.modelData)
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: s.picked(sw.modelData)
                }
            }
        }
    }
}