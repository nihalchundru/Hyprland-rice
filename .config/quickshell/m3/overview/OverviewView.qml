import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.tokens
import qs.services
import qs.components

// Workspace cards with live window thumbnails. Used by the full-screen overview and the main panel.
RowLayout {
    id: root
    property bool live: false
    signal picked()
    spacing: 12
    uniformCellSizes: true

    Repeater {
        model: 5
        Rectangle {
            id: ws
            required property int index
            readonly property int wsId: index + 1
            readonly property bool focused: Hypr.focusedId === wsId
            readonly property var wins: Hyprland.toplevels.values.filter(t => t.workspace && t.workspace.id === wsId)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            implicitHeight: Math.max(200, col.implicitHeight + 64)
            radius: 28
            color: focused ? M3Colors.primaryContainer : M3Colors.surfaceContainerHigh
            ColorBehavior on color {}
            SpatialBehavior on implicitHeight {}

            MouseArea { anchors.fill: parent; onClicked: { Hypr.goto(ws.wsId); root.picked() } }
            M3Text { x: 20; y: 14; text: String(ws.wsId); role: M3Type.titleMedium; color: ws.focused ? M3Colors.fgPrimaryContainer : M3Colors.fgSurface }
            M3Text { visible: ws.wins.length === 0; anchors.centerIn: parent; text: "Empty"; role: M3Type.bodyMedium; color: M3Colors.fgSurfaceVariant }

            Column {
                id: col
                x: 12; y: 48
                width: parent.width - 24
                spacing: 10
                Repeater {
                    model: ws.wins
                    Rectangle {
                        id: card
                        required property var modelData
                        width: col.width
                        height: Math.round(col.width * 0.56)
                        radius: 16
                        color: M3Colors.surfaceContainerHighest
                        clip: true
                        Icon { anchors.centerIn: parent; name: "web_asset"; size: 36; color: M3Colors.fgSurfaceVariant }
                        ScreencopyView {
                            anchors.fill: parent
                            captureSource: card.modelData.wayland
                            live: root.live
                            visible: hasContent
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width; height: 26
                            color: Qt.alpha(M3Colors.scrim, 0.6)
                            M3Text { anchors.fill: parent; anchors.leftMargin: 10; elide: Text.ElideRight; text: card.modelData.title; role: M3Type.labelMedium; color: "white" }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { if (card.modelData.wayland) card.modelData.wayland.activate(); root.picked() }
                        }
                    }
                }
            }
        }
    }
}
