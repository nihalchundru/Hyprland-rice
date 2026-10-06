pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Owns org.freedesktop.Notifications, so stop mako/dunst/swaync first.
// Stage 2 only lists them in the control center; toasts come in stage 4.
Singleton {
    id: root

    readonly property var list: server.trackedNotifications.values.slice().reverse()
    readonly property int count: list.length

    function clear() {
        const l = list.slice();
        l.forEach(n => n.dismiss());
    }

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: false
        imageSupported: false
        onNotification: n => { n.tracked = true; }
    }
}
