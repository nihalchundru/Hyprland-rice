import QtQuick
import qs.tokens

// kind: assist | filter | input | suggestion
Item {
    id: root
    property string text: ""
    property string icon: ""
    property string kind: "assist"
    property bool selected: false
    signal clicked()
    readonly property bool hovered: ma.containsMouse
    readonly property bool lead: icon !== "" || (kind === "filter" && selected)
    readonly property color contentColor: selected ? M3Colors.fgSecondaryContainer : M3Colors.fgSurfaceVariant
    property real cornerRadius: ma.pressed ? 16 : 8
    SpatialBehavior on cornerRadius {}
    implicitHeight: 32
    implicitWidth: row.implicitWidth + (lead ? 24 : 32)
    SpatialBehavior on implicitWidth {}

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Math.max(0, Math.min(root.cornerRadius, height / 2))
        color: root.selected ? M3Colors.secondaryContainer : Qt.alpha(M3Colors.surface, 0)
        border.width: root.selected ? 0 : 1
        border.color: M3Colors.outlineVariant
        ColorBehavior on color {}
        StateLayer { anchors.fill: parent; radius: bg.radius; tint: root.contentColor; hovered: ma.containsMouse; pressed: ma.pressed }
    }
    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
        Icon {
            visible: root.lead
            name: root.kind === "filter" && root.selected ? "check" : root.icon
            size: 18
            color: root.contentColor
            anchors.verticalCenter: parent.verticalCenter
        }
        M3Text { text: root.text; role: M3Type.labelLarge; color: root.contentColor; anchors.verticalCenter: parent.verticalCenter }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { if (root.kind === "filter") root.selected = !root.selected; root.clicked() }
    }
}
