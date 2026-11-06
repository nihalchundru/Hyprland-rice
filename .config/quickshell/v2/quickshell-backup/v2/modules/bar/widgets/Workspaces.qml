import QtQuick
import Quickshell.Hyprland
import qs.config
import qs.theme
import qs.components

Group {
    id: root
    required property var screen

    readonly property var monitor: Hyprland.monitorFor(screen)
    readonly property int activeId: monitor?.activeWorkspace?.id ?? 1
    readonly property int count: Math.min(10, Math.max(Config.bar.workspaces, maxId()))

    function exists(id) {
        const v = Hyprland.workspaces.values
        for (let i = 0; i < v.length; i++) if (v[i].id === id) return true
        return false
    }
    function maxId() {
        const v = Hyprland.workspaces.values
        let m = 0
        for (let i = 0; i < v.length; i++) m = Math.max(m, v[i].id)
        return m
    }

    WheelHandler {
        onWheel: e => Hyprland.dispatch(e.angleDelta.y > 0 ? "workspace e-1" : "workspace e+1")
    }

    Repeater {
        model: root.count

        delegate: Item {
            id: ws
            required property int index
            readonly property int wsId: index + 1
            readonly property bool active: root.activeId === wsId
            readonly property bool occupied: root.exists(wsId)

            implicitWidth: active ? 36 : 24
            implicitHeight: 24
            Behavior on implicitWidth {
                NumberAnimation {
                    duration: M3.motion.medium2
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: M3.motion.emphasizedDecelerate
                }
            }

            Surface {
                anchors.fill: parent
                radius: M3.shape.full
                color: ws.active ? Colors.primary : Qt.alpha(Colors.primary, 0)
            }
            Rectangle {
                anchors.centerIn: parent
                width: 8; height: 8; radius: 4
                opacity: ws.active ? 0 : 1
                color: ws.occupied ? Colors.onSurfaceVariant : Colors.outlineVariant
                Behavior on opacity { NumberAnimation { duration: M3.motion.short4 } }
            }
            M3Text {
                anchors.centerIn: parent
                text: ws.wsId
                role: "labelMedium"
                color: Colors.onPrimary
                opacity: ws.active ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: M3.motion.short4 } }
            }
            StateLayer {
                anchors.fill: parent
                radius: M3.shape.full
                color: ws.active ? Colors.onPrimary : Colors.onSurface
                onClicked: Hyprland.dispatch("workspace " + ws.wsId)
            }
        }
    }
}