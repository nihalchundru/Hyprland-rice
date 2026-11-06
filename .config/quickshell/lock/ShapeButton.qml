import QtQuick

// Icon button whose background is a Material 3 pill.
//
// Note there is no `property bool enabled` here on purpose: Item already has
// `enabled`, and re-declaring it would shadow the built-in one -- the same
// mistake that broke the bar's modelData earlier.
Item {
    id: root

    property string icon: ""
    property color background: M3Theme.palette.surfaceContainerHighest
    property color foreground: M3Theme.palette.onSurface
    // Tonal buttons use the container/on-container pair instead.
    property bool tonal: false

    signal activated()

    implicitWidth: 58
    implicitHeight: 44

    // HoverHandler has no `pressed` (that lives on TapHandler / MouseArea),
    // so the press state comes from the MouseArea below.
    readonly property bool active: (hover.hovered || press.pressed) && root.enabled

    M3Shape {
        anchors.fill: parent
        kind: "pill"
        fillColor: {
            if (!root.enabled) return M3Theme.palette.surfaceContainerLow;
            if (root.active) return M3Theme.palette.primary;
            return root.tonal ? M3Theme.palette.primaryContainer : root.background;
        }
        Behavior on fillColor { ColorAnimation { duration: M3Theme.durationShort4 } }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: {
            if (!root.enabled) return M3Theme.palette.outline;
            if (root.active) return M3Theme.palette.onPrimary;
            return root.tonal ? M3Theme.palette.onPrimaryContainer : root.foreground;
        }
        font.family: M3Theme.font
        font.pixelSize: 16
        font.weight: Font.DemiBold
    }

    HoverHandler {
        id: hover
        enabled: root.enabled
    }

    MouseArea {
        id: press
        anchors.fill: parent
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
