import QtQuick
import qs.tokens
import qs.services
import qs.components

Item {
    id: root
    property int count: 5
    implicitWidth: row.implicitWidth + 20
    implicitHeight: 28
    SpatialBehavior on implicitWidth {}

    Rectangle { anchors.fill: parent; radius: height / 2; color: M3Colors.surfaceContainerHigh }
    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6
        Repeater {
            model: root.count
            Item {
                id: ws
                required property int index
                readonly property int wsId: index + 1
                readonly property bool active: Hypr.focusedId === wsId
                readonly property bool occupied: Hypr.exists(wsId)
                width: active ? 28 : 10
                height: 10
                anchors.verticalCenter: parent.verticalCenter
                SpatialBehavior on width {}
                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: ws.active ? M3Colors.primary : ws.occupied ? M3Colors.secondary : M3Colors.outlineVariant
                    ColorBehavior on color {}
                }
                MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: Hypr.goto(ws.wsId) }
            }
        }
    }
}
