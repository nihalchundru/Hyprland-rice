
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: service

    property var currentNotification: null
    property var notifications: []

    NotificationServer {
        id: server

        // Keep notifications alive so the shell can display them.
        persistenceSupported: true
        actionsSupported: true
        imageSupported: true
        bodySupported: true

        onNotification: function(notification) {
            if (!notification)
                return

            // IMPORTANT:
            // Quickshell discards notifications that aren't tracked.
            notification.tracked = true

            service.currentNotification = notification

            service.notifications =
                [notification].concat(service.notifications)

            notificationTimer.restart()
        }
    }

    Timer {
        id: notificationTimer

        interval: 5000
        repeat: false

        onTriggered: {
            service.currentNotification = null
        }
    }

    function dismissCurrent() {
        if (service.currentNotification) {
            service.currentNotification.dismiss()
        }

        service.currentNotification = null
    }

    function clearAll() {
        for (var i = 0; i < service.notifications.length; i++) {
            var notification = service.notifications[i]

            if (notification)
                notification.dismiss()
        }

        service.notifications = []
        service.currentNotification = null
    }
}

