import QtQuick
import "../core"

Rectangle {
    id: root

    default property alias content: inner.data

    // per-widget overrides from layout.json ("style" key); empty = use the global style
    property var ws: ({})

    readonly property string bgMode: ws.background ?? "card"
    readonly property real fillOpacity: ws.opacity ?? LayoutStore.cardOpacity
    readonly property bool outline: ws.outline ?? (bgMode !== "transparent")

    // accent roles, rotated so the chosen one comes first
    readonly property int roleIndex: ({ accent: 0, accent2: 1, accent3: 2 })[ws.accent ?? "accent"] ?? 0
    readonly property var accents: {
        const a = [Theme.accent, Theme.accent2, Theme.accent3];
        return [a[roleIndex], a[(roleIndex + 1) % 3], a[(roleIndex + 2) % 3]];
    }

    radius: ws.radius ?? LayoutStore.radius
    color: bgMode === "transparent" ? "transparent"
         : Qt.alpha(bgMode === "alt" ? Theme.cardAlt : Theme.card, fillOpacity)

    border.width: outline ? 1 : 0
    border.color: Qt.alpha(Theme.onSurface, bgMode === "transparent" ? 0.18 : 0.05)

    // hover brighten (separate layer so it doesn't fight the theme crossfade)
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Theme.onSurface
        opacity: hover.hovered ? 0.04 : 0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    }

    HoverHandler { id: hover }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: root.ws.padding ?? LayoutStore.padding
    }
}