import QtQuick
import "../core"
import "../components"

Item {
    id: root
    implicitHeight: col.implicitHeight

    property string notice: ""

    Column {
        id: col
        width: parent.width
        spacing: 8

        Txt {
            width: col.width
            wrapMode: Text.WordWrap
            text: "Click a widget to drop it into the first free spot, then drag it where you want it."
            color: Theme.onSurfaceDim
            font.pixelSize: 12
        }

        Repeater {
            model: WidgetRegistry.list

            delegate: Rectangle {
                id: item
                required property var modelData

                width: col.width
                height: 64
                radius: 16
                color: ma.containsMouse ? Qt.lighter(Theme.cardAlt, 1.12) : Theme.cardAlt
                Behavior on color { ColorAnimation { duration: 120 } }

                Rectangle {
                    id: badge
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 40
                    radius: 12
                    color: Qt.alpha(Theme.accent, 0.2)

                    Txt {
                        anchors.centerIn: parent
                        text: item.modelData.name.charAt(0)
                        color: Theme.accent
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                }

                Column {
                    anchors.left: badge.right
                    anchors.leftMargin: 12
                    anchors.right: sizeLabel.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Txt {
                        width: parent.width
                        text: item.modelData.name
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                    Txt {
                        width: parent.width
                        text: item.modelData.desc
                        color: Theme.onSurfaceDim
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }

                Txt {
                    id: sizeLabel
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: item.modelData.defaultW + " × " + item.modelData.defaultH
                    color: Theme.onSurfaceDim
                    font.pixelSize: 11
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const id = LayoutStore.addWidget(item.modelData.type);
                        root.notice = id !== ""
                            ? ""
                            : "No free space for " + item.modelData.name
                              + ". Move or remove something first.";
                    }
                }
            }
        }

        Txt {
            visible: root.notice !== ""
            width: col.width
            wrapMode: Text.WordWrap
            text: root.notice
            color: Theme.danger
            font.pixelSize: 12
        }
    }
}