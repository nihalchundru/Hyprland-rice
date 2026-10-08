pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Owns org.freedesktop.Notifications, so stop mako/dunst/swaync first.
// Every notification is kept in `list` (control center). A toast is shown only
// when the pill is idle/hovered; Focus mode only lets critical ones through.
Singleton {
    id: root

    readonly property var list: server.trackedNotifications.values.slice().reverse()
    readonly property int count: list.length

    property var toast: null      // notification currently shown in the pill
    property var queue: []

    // countdown shown as a line at the bottom of the toast
    readonly property int duration: tmr.interval
    property int countdownTick: 0          // bumps every time the countdown (re)starts

    function startCountdown() {
        tmr.restart();
        countdownTick++;
    }

    function clear() {
        const l = list.slice();
        l.forEach(n => n.dismiss());
    }

    function enqueue(n) {
        queue.push(n);
        next();
    }

    function next() {
        if (toast !== null || queue.length === 0) return;

        // another page is open: don't interrupt it, the notification stays in the list
        const free = Pill.mode === "idle" || Pill.mode === "hover" || Pill.mode === "notify";
        if (!free) { queue = []; return; }

        toast = queue.shift();
        const urgent = toast.urgency === NotificationUrgency.Critical;
        tmr.interval = urgent ? Settings.get("notifUrgentTimeout") : Settings.get("notifTimeout");
        Pill.open("notify", true);
        if (!Pill.hovering) startCountdown();
    }

    // hides the toast only; the notification itself stays in the list
    function dismissToast() {
        tmr.stop();
        toast = null;
        if (queue.length > 0) { next(); return; }
        if (Pill.mode === "notify") {
            Pill.close();
            if (Pill.hovering) Pill.open("hover", false);
        }
    }

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: false
        imageSupported: false

        onNotification: n => {
            n.tracked = true;
            if (Toggles.focus && n.urgency !== NotificationUrgency.Critical) return;
            root.enqueue(n);
        }
    }

    Timer {
        id: tmr
        onTriggered: root.dismissToast()
    }

    // the sender closed it, or it was dismissed from the list
    Connections {
        target: root.toast
        ignoreUnknownSignals: true
        function onClosed() { root.dismissToast(); }
    }

    Connections {
        target: Pill

        // something else took over the pill: drop the toast
        function onModeChanged() {
            if (Pill.mode !== "notify" && root.toast !== null) {
                tmr.stop();
                root.toast = null;
                root.queue = [];
            }
        }

        // hovering the toast pauses it; leaving restarts the countdown
        function onHoveringChanged() {
            if (root.toast === null) return;
            if (Pill.hovering) tmr.stop();
            else {
                tmr.interval = 1500;   // ms left after the mouse leaves; change to taste
                startCountdown();
            }
        }
    }
}
