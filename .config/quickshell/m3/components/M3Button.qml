import QtQuick
import qs.tokens

// variant: filled | tonal | elevated | outlined | text     size: xs | s | m | l | xl
// Icon-only when text is "". toggle: checked swaps shape (round <-> square). Pressing morphs the corners.
Item {
    id: root
    property string text: ""
    property string icon: ""
    property string variant: "filled"
    property string size: "s"
    property bool toggle: false
    property bool checked: false
    property bool round: true
    signal clicked()
    readonly property bool hovered: mouse.containsMouse

    readonly property var h:    ({ xs: 32, s: 40, m: 56, l: 96, xl: 136 })
    readonly property var fs:   ({ xs: 14, s: 14, m: 16, l: 24, xl: 32 })
    readonly property var isz:  ({ xs: 20, s: 20, m: 24, l: 32, xl: 40 })
    readonly property var padx: ({ xs: 12, s: 16, m: 24, l: 48, xl: 64 })
    readonly property var gap:  ({ xs: 4, s: 8, m: 8, l: 12, xl: 16 })
    readonly property var sqr:  ({ xs: 12, s: 12, m: 16, l: 28, xl: 28 })
    readonly property var prs:  ({ xs: 8, s: 8, m: 12, l: 16, xl: 16 })

    readonly property bool sel: toggle && checked
    readonly property bool iconOnly: text === ""
    readonly property bool useRound: sel ? !round : round
    property real cornerRadius: mouse.pressed ? prs[size] : (useRound ? h[size] / 2 : sqr[size])
    SpatialBehavior on cornerRadius {}

    readonly property color clear: Qt.alpha(M3Colors.surface, 0)
    readonly property color containerColor: {
        switch (variant) {
        case "filled": return toggle && !sel ? M3Colors.surfaceContainer : M3Colors.primary
        case "tonal": return sel ? M3Colors.secondary : M3Colors.secondaryContainer
        case "elevated": return sel ? M3Colors.primary : M3Colors.surfaceContainerLow
        case "outlined": return sel ? M3Colors.inverseSurface : clear
        default: return clear
        }
    }
    readonly property color contentColor: {
        switch (variant) {
        case "filled": return toggle && !sel ? M3Colors.fgSurfaceVariant : M3Colors.fgPrimary
        case "tonal": return sel ? M3Colors.fgSecondary : M3Colors.fgSecondaryContainer
        case "elevated": return sel ? M3Colors.fgPrimary : M3Colors.primary
        case "outlined": return sel ? M3Colors.inverseOnSurface : M3Colors.fgSurfaceVariant
        default: return M3Colors.primary
        }
    }

    implicitHeight: h[size]
    implicitWidth: (iconOnly ? h[size] : row.implicitWidth + 2 * padx[size]) + (mouse.pressed ? 4 : 0)
    SpatialBehavior on implicitWidth {}
    opacity: enabled ? 1 : M3Opacity.disabledContent

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Math.max(0, Math.min(root.cornerRadius, height / 2))
        color: root.containerColor
        border.width: root.variant === "outlined" && !root.sel ? 1 : 0
        border.color: M3Colors.outline
        ColorBehavior on color {}
        StateLayer {
            anchors.fill: parent
            radius: bg.radius
            tint: root.contentColor
            hovered: mouse.containsMouse
            pressed: mouse.pressed
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: root.gap[root.size]
        Icon {
            visible: root.icon !== ""
            name: root.icon
            size: root.isz[root.size]
            color: root.contentColor
            fill: root.sel ? 1 : 0
            anchors.verticalCenter: parent.verticalCenter
        }
        M3Text {
            visible: !root.iconOnly
            text: root.text
            color: root.contentColor
            role: ({ size: root.fs[root.size], line: Math.round(root.fs[root.size] * 1.43), weight: Font.Medium, tracking: 0.1 })
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { if (root.toggle) root.checked = !root.checked; root.clicked() }
    }
}
