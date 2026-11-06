pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// NOTE: only one notification daemon can own the D-Bus name. Stop swaync/mako before testing.
Singleton {
    id: root
    readonly property var all: server.trackedNotifications.values
    readonly property int count: all.length
    property bool dnd: false
    property var times: ({})
    function ago(id) {
        const t = times[id]
        if (!t) return ""
        const m = Math.floor((Clock.now - t) / 60000)
        return m < 1 ? "now" : m < 60 ? m + "m" : Math.floor(m / 60) + "h"
    }
    signal popup(var notif)

    function dismissAll() { all.slice().forEach(n => n.dismiss()) }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true
        onNotification: n => {
            n.tracked = true
            root.times[n.id] = Date.now()
            if (!root.dnd) root.popup(n)
        }
    }
}
