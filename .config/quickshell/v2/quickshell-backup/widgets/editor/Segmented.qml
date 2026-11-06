import QtQuick
import "../core"
import "../components"

Item {
    id: sg

    property string label: ""
    property var options: []
    property string current: ""
    signal picked(string v)

    implicitHeight: 34

    Txt {
        anchors.verticalCenter: parent.verticalCenter
        text: sg.label
        color: Theme.onSurface
        font.pixelSize: 13
    }

    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: segRow.width + 6
        height: 28
        radius: 10
        color: Theme.cardAlt

        Row {
            id: segRow
            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: sg.options

                Rectangle {
                    required property string modelData
                    readonly property bool active: modelData === sg.current

                    width: optLabel.implicitWidth + 20
                    height: 22
                    radius: 8
                    color: active ? Theme.accent : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Txt {
                        id: optLabel
                        anchors.centerIn: parent
                        text: parent.modelData
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: parent.active ? Theme.onAccent : Theme.onSurfaceDim
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sg.picked(parent.modelData)
                    }
                }
            }
        }
    }
}