pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Mpris

Singleton {
    id: root

    // ------------------------------------------------------------------------
    // Clock & Date
    // ------------------------------------------------------------------------
    property date now: new Date()
    readonly property string time12: Qt.formatDateTime(now, "hh:mm AP")
    readonly property string time12Short: Qt.formatDateTime(now, "h:mm")
    readonly property string amPm: Qt.formatDateTime(now, "AP")
    readonly property string time24: Qt.formatDateTime(now, "HH:mm")
    readonly property string seconds: Qt.formatDateTime(now, "ss")
    readonly property string dateShort: Qt.formatDateTime(now, "ddd, MMM d")
    readonly property string dateLong: Qt.formatDateTime(now, "dddd, MMMM d")

    function formattedTime(is24Hour) {
        return is24Hour ? time24 : time12Short;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    // ------------------------------------------------------------------------
    // Audio (Pipewire + wpctl fallback) & OSD Triggers
    // ------------------------------------------------------------------------
    property PwNode defaultSink: Pipewire.defaultAudioSink
    property PwNode defaultSource: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.defaultSink, root.defaultSource]
    }

    property int volumePercent: {
        if (defaultSink && defaultSink.audio && !isNaN(defaultSink.audio.volume))
            return Math.round(defaultSink.audio.volume * 100);
        return fallbackVolume;
    }
    property bool muted: {
        if (defaultSink && defaultSink.audio)
            return Boolean(defaultSink.audio.muted);
        return fallbackMuted;
    }

    property int fallbackVolume: 60
    property bool fallbackMuted: false
    property int brightnessPercent: 80

    // OSD State & Signals (Stage 4)
    property bool osdVisible: false
    property string osdKind: "volume"   // "volume" | "brightness"
    property int osdValue: 60
    property bool osdMuted: false

    signal osdTriggered(string kind, int value, bool mutedState)

    function triggerOsd(kind, value, mutedState) {
        osdKind = kind;
        osdValue = value;
        osdMuted = mutedState;
        osdVisible = true;
        osdHideTimer.restart();
        osdTriggered(kind, value, mutedState);
    }

    Timer {
        id: osdHideTimer
        interval: 2200
        repeat: false
        onTriggered: root.osdVisible = false
    }

    function setVolume(percent) {
        var clamped = Math.max(0, Math.min(150, Math.round(percent)));
        if (defaultSink && defaultSink.audio) {
            defaultSink.audio.volume = clamped / 100.0;
        }
        fallbackVolume = clamped;
        cmdRunner.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (clamped / 100.0).toFixed(2)]);
        triggerOsd("volume", clamped, muted);
    }

    function adjustVolume(delta) {
        setVolume(volumePercent + delta);
    }

    function toggleMute() {
        var nextMute = !muted;
        if (defaultSink && defaultSink.audio) {
            defaultSink.audio.muted = nextMute;
        }
        fallbackMuted = nextMute;
        cmdRunner.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
        triggerOsd("volume", volumePercent, nextMute);
    }

    function setBrightness(percent) {
        var clamped = Math.max(5, Math.min(100, Math.round(percent)));
        brightnessPercent = clamped;
        cmdRunner.run(["brightnessctl", "set", clamped + "%"]);
        triggerOsd("brightness", clamped, false);
    }

    function adjustBrightness(delta) {
        setBrightness(brightnessPercent + delta);
    }

    // ------------------------------------------------------------------------
    // Battery (UPower + sysfs check so VMs without batteries don't show 0%)
    // ------------------------------------------------------------------------
    property var displayDevice: UPower.displayDevice
    property bool hasSysfsBattery: false
    property int sysfsBatteryPercent: 100
    property bool sysfsBatteryCharging: false

    readonly property bool hasBattery: {
        if (hasSysfsBattery) return true;
        if (displayDevice && displayDevice.ready && displayDevice.isLaptopBattery && displayDevice.percentage > 0)
            return true;
        return false;
    }

    readonly property int batteryPercent: {
        if (hasSysfsBattery) return sysfsBatteryPercent;
        if (displayDevice && displayDevice.ready && !isNaN(displayDevice.percentage)) {
            var p = Math.round(displayDevice.percentage * (displayDevice.percentage <= 1.0 ? 100 : 1));
            if (p > 0) return p;
        }
        return 100;
    }

    readonly property bool batteryCharging: {
        if (hasSysfsBattery) return sysfsBatteryCharging;
        if (displayDevice && displayDevice.ready)
            return displayDevice.state === UPowerDeviceState.Charging || displayDevice.state === UPowerDeviceState.FullyCharged;
        return false;
    }

    // ------------------------------------------------------------------------
    // MPRIS Media Player
    // ------------------------------------------------------------------------
    readonly property var players: Mpris.players.values
    property var activePlayer: {
        var list = Mpris.players.values;
        if (!list || list.length === 0) return null;
        for (var i = 0; i < list.length; i++) {
            if (list[i].isPlaying) return list[i];
        }
        return list[0];
    }
    readonly property bool mediaPlaying: activePlayer ? activePlayer.isPlaying : false
    readonly property string mediaTitle: (activePlayer && activePlayer.trackTitle) ? activePlayer.trackTitle : "Nothing Playing"
    readonly property string mediaArtist: (activePlayer && activePlayer.trackArtist) ? activePlayer.trackArtist : ""
    readonly property string mediaArtUrl: (activePlayer && activePlayer.trackArtUrl) ? activePlayer.trackArtUrl : ""

    function mediaPlayPause() {
        if (activePlayer && activePlayer.canTogglePlaying) activePlayer.togglePlaying();
        else cmdRunner.run(["playerctl", "play-pause"]);
    }
    function mediaNext() {
        if (activePlayer && activePlayer.canGoNext) activePlayer.next();
        else cmdRunner.run(["playerctl", "next"]);
    }
    function mediaPrevious() {
        if (activePlayer && activePlayer.canGoPrevious) activePlayer.previous();
        else cmdRunner.run(["playerctl", "previous"]);
    }

    // ------------------------------------------------------------------------
    // Hyprland Workspaces & Active Window
    // ------------------------------------------------------------------------
    readonly property var workspaces: Hyprland.workspaces
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property int activeWorkspaceId: focusedWorkspace ? focusedWorkspace.id : 1

    function switchWorkspace(wsId) {
        Hyprland.dispatch("workspace " + wsId);
    }

    // ------------------------------------------------------------------------
    // Fast, Non-Blocking CPU & RAM Telemetry (direct /proc/stat + /proc/meminfo)
    // ------------------------------------------------------------------------
    property int cpuPercent: 0
    property int memPercent: 0
    property string memUsedGb: "0.0"
    property string memTotalGb: "0.0"

    property double _prevCpuTotal: 0
    property double _prevCpuIdle: 0

    Process {
        id: cpuMemProc
        command: ["cat", "/proc/stat", "/proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = this.text || "";
                if (!txt) return;
                var lines = txt.split("\n");
                var memTotalKb = 0;
                var memAvailKb = 0;

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i];
                    if (line.indexOf("cpu ") === 0) {
                        var parts = line.trim().split(/\s+/);
                        if (parts.length >= 5) {
                            var user = parseFloat(parts[1]) || 0;
                            var nice = parseFloat(parts[2]) || 0;
                            var system = parseFloat(parts[3]) || 0;
                            var idle = parseFloat(parts[4]) || 0;
                            var iowait = parseFloat(parts[5]) || 0;
                            var irq = parseFloat(parts[6]) || 0;
                            var softirq = parseFloat(parts[7]) || 0;
                            var steal = parseFloat(parts[8]) || 0;

                            var idleAll = idle + iowait;
                            var total = user + nice + system + idleAll + irq + softirq + steal;

                            if (root._prevCpuTotal > 0 && total > root._prevCpuTotal) {
                                var diffTotal = total - root._prevCpuTotal;
                                var diffIdle = idleAll - root._prevCpuIdle;
                                root.cpuPercent = Math.max(1, Math.min(100, Math.round(((diffTotal - diffIdle) * 100) / diffTotal)));
                            } else if (total > 0) {
                                root.cpuPercent = Math.max(1, Math.min(100, Math.round(((total - idleAll) * 100) / total)));
                            }
                            root._prevCpuTotal = total;
                            root._prevCpuIdle = idleAll;
                        }
                    } else if (line.indexOf("MemTotal:") === 0) {
                        var mt = line.split(/\s+/);
                        memTotalKb = parseFloat(mt[1]) || 0;
                    } else if (line.indexOf("MemAvailable:") === 0) {
                        var ma = line.split(/\s+/);
                        memAvailKb = parseFloat(ma[1]) || 0;
                    }
                }

                if (memTotalKb > 0) {
                    var usedKb = Math.max(0, memTotalKb - memAvailKb);
                    root.memPercent = Math.max(1, Math.min(100, Math.round((usedKb * 100) / memTotalKb)));
                    root.memUsedGb = (usedKb / 1048576).toFixed(1);
                    root.memTotalGb = (memTotalKb / 1048576).toFixed(1);
                }
            }
        }
        running: true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: cpuMemProc.running = true
    }

    // ------------------------------------------------------------------------
    // Connectivity & Hardware Polling (with strict timeouts so it never hangs)
    // ------------------------------------------------------------------------
    property bool wifiEnabled: true
    property string wifiSsid: "Connected"
    property bool bluetoothEnabled: true

    function toggleWifi() {
        var next = !wifiEnabled;
        wifiEnabled = next;
        cmdRunner.run(["nmcli", "radio", "wifi", next ? "on" : "off"]);
    }

    function toggleBluetooth() {
        var next = !bluetoothEnabled;
        bluetoothEnabled = next;
        cmdRunner.run(["bluetoothctl", "power", next ? "on" : "off"]);
    }

    Process {
        id: cmdRunner
        function run(args) {
            cmdRunner.command = args;
            cmdRunner.running = true;
        }
    }

    Process {
        id: connectivityProc
        command: [
            "sh", "-c",
            "WIFI_STATE=$(timeout 1 nmcli -t -f WIFI g 2>/dev/null | head -n1 || echo enabled); " +
            "SSID=$(timeout 1 nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1==\"yes\"{print $2; exit}'); " +
            "BT_STATE=$(timeout 1 bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2; exit}' || echo yes); " +
            "BRI=$(brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/,\"\",$4); print $4}' || echo 80); " +
            "BAT_CAP=\"\"; BAT_STAT=\"\"; " +
            "for b in /sys/class/power_supply/BAT*; do " +
            "  if [ -f \"$b/capacity\" ]; then BAT_CAP=$(cat \"$b/capacity\" 2>/dev/null); BAT_STAT=$(cat \"$b/status\" 2>/dev/null); break; fi; " +
            "done; " +
            "printf '{\"wifi\":\"%s\",\"ssid\":\"%s\",\"bt\":\"%s\",\"bri\":%s,\"batCap\":\"%s\",\"batStat\":\"%s\"}\\n' " +
            "\"${WIFI_STATE:-enabled}\" \"${SSID:-Connected}\" \"${BT_STATE:-yes}\" \"${BRI:-80}\" \"${BAT_CAP}\" \"${BAT_STAT}\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = this.text ? this.text.trim() : "";
                if (!txt) return;
                try {
                    var d = JSON.parse(txt);
                    root.wifiEnabled = (d.wifi !== "disabled");
                    root.wifiSsid = d.ssid || (root.wifiEnabled ? "Connected" : "Off");
                    root.bluetoothEnabled = (d.bt !== "no");
                    if (!isNaN(d.bri) && d.bri > 0) root.brightnessPercent = d.bri;
                    if (d.batCap !== undefined && d.batCap !== "") {
                        root.hasSysfsBattery = true;
                        root.sysfsBatteryPercent = parseInt(d.batCap, 10) || 100;
                        root.sysfsBatteryCharging = (d.batStat === "Charging" || d.batStat === "Full");
                    } else {
                        root.hasSysfsBattery = false;
                    }
                } catch (e) {}
            }
        }
        running: true
    }

    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: connectivityProc.running = true
    }

    // ------------------------------------------------------------------------
    // Notification History & Toast Queue (Stage 4)
    // ------------------------------------------------------------------------
    property ListModel notificationModel: ListModel {}
    property ListModel popupNotificationModel: ListModel {}
    readonly property int notificationCount: notificationModel.count

    function pushNotification(appName, summary, body, urgency) {
        var entry = {
            "uid": Date.now() + "-" + Math.round(Math.random() * 10000),
            "appName": appName || "System",
            "summary": summary || "Notification",
            "body": body || "",
            "urgency": urgency || "normal",
            "timeStr": Qt.formatDateTime(new Date(), "hh:mm")
        };
        notificationModel.insert(0, entry);
        while (notificationModel.count > 30) {
            notificationModel.remove(notificationModel.count - 1);
        }
        popupNotificationModel.insert(0, entry);
        while (popupNotificationModel.count > 4) {
            popupNotificationModel.remove(popupNotificationModel.count - 1);
        }
    }

    function dismissPopup(uid) {
        for (var i = 0; i < popupNotificationModel.count; i++) {
            if (popupNotificationModel.get(i).uid === uid) {
                popupNotificationModel.remove(i);
                break;
            }
        }
    }

    function dismissNotification(uid) {
        dismissPopup(uid);
        for (var i = 0; i < notificationModel.count; i++) {
            if (notificationModel.get(i).uid === uid) {
                notificationModel.remove(i);
                break;
            }
        }
    }

    function clearNotifications() {
        popupNotificationModel.clear();
        notificationModel.clear();
    }
}
