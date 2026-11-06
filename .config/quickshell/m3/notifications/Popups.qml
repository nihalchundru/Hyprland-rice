import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.tokens
import qs.services
import qs.components

PanelWindow {
    id: win
    WlrLayershell.namespace: "m3-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: M3Config.barFloating ? 64 : 56; right: 12 }
    implicitWidth: 380
    implicitHeight: Math.max(1, col.implicitHeight)
    color: "transparent"
    mask: Region { item: col }
    visible: popups.length > 0

    property var popups: []
    function add(n) { popups = [n].concat(popups.filter(x => x !== n)).slice(0, 4) }
    function remove(n) { popups = popups.filter(x => x !== n) }

    Connections { target: Notifs; function onPopup(n) { win.add(n) } }
    Connections { target: UiState; function onNotifCenterOpenChanged() { if (UiState.notifCenterOpen) win.popups = [] } }

    Column {
        id: col
        width: parent.width
        spacing: 8
        Repeater {
            model: win.popups
            Item {
                id: slot
                required property var modelData
                property bool shown: false
                width: col.width
                height: card.implicitHeight
                Component.onCompleted: shown = true
                function leave() { shown = false; leaveTimer.start() }

                Timer { id: leaveTimer; interval: 260; onTriggered: win.remove(slot.modelData) }
                Timer {
                    interval: slot.modelData.expireTimeout > 0 ? slot.modelData.expireTimeout * 1000 : 6000
                    running: slot.shown && !hover.hovered && slot.modelData.urgency !== NotificationUrgency.Critical
                    onTriggered: slot.leave()
                }
                Connections { target: slot.modelData; function onClosed() { win.remove(slot.modelData) } }

                NotificationCard {
                    id: card
                    notif: slot.modelData
                    width: slot.width
                    x: slot.shown ? 0 : 80
                    opacity: slot.shown ? 1 : 0
                    SpatialBehavior on x {}
                    FadeBehavior on opacity { time: M3Motion.short4 }
                    HoverHandler { id: hover }
                    onCloseRequested: slot.modelData.dismiss()
                    onActivated: slot.modelData.dismiss()
                }
            }
        }
    }
}
