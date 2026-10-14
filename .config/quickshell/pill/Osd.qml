pragma Singleton
import QtQuick
import Quickshell

// Volume / brightness on-screen display, shown inside the pill for a moment.
//  - Volume and mute are picked up automatically from PipeWire.
//  - Brightness has no change signal, so your brightness keybinds call
//    `qs -c pill ipc call osd brightness` after changing it.
// It never interrupts a page you have open or a notification toast.
Singleton {
    id: root

    property string kind: "volume"        // "volume" | "brightness"
    property bool armed: false            // ignore the volume "changes" while starting up
    property double suppressUntil: 0      // ignore the jump when the default output switches

    readonly property real vol: Audio.volumeOf(Audio.sink)
    readonly property bool mute: Audio.mutedOf(Audio.sink)

    readonly property real level: kind === "brightness" ? Brightness.value : vol
    readonly property bool muted: kind === "volume" && mute
    readonly property string icon: kind === "brightness" ? "sun"
                                 : (muted || vol <= 0 ? "volume-mute" : "volume")

    function show(k) {
        if (!armed) return;
        if (k === "brightness" && !Brightness.available) return;
        // only borrow the pill when nothing else is using it
        if (["idle", "hover", "osd"].indexOf(Pill.mode) < 0) return;

        kind = k;
        Pill.open("osd", true);
        hideTimer.interval = Settings.get("osdTime");
        hideTimer.restart();
    }

    function hide() {
        hideTimer.stop();
        if (Pill.mode === "osd") {
            Pill.close();
            if (Pill.hovering) Pill.open("hover", false);
        }
    }

    function autoShow(k) {
        if (Date.now() < suppressUntil) return;
        show(k);
    }

    onVolChanged: autoShow("volume")
    onMuteChanged: autoShow("volume")

    Timer {
        id: hideTimer
        onTriggered: root.hide()
    }

    Timer {
        interval: 2500
        running: true
        onTriggered: root.armed = true
    }

    Connections {
        target: Audio
        function onSinkChanged() { root.suppressUntil = Date.now() + 700; }
    }

    // something else took over the pill (a toast, a page): stop counting down
    Connections {
        target: Pill
        function onModeChanged() {
            if (Pill.mode !== "osd") hideTimer.stop();
        }
    }
}
