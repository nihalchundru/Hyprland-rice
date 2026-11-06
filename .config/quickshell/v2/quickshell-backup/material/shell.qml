import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    id: root

    property var colors: {
        "bg": "#141210",       
        "bg2": "#2A2421",      
        "surface": "#3C3430",  
        "surface2": "#4F443F", 
        "text": "#FBECE6",     
        "sub": "#D7C2B9",      
        "accent": "#FFB59E",   
        "accent2": "#E6C4A6"   
    }
    property var palettes: {}

    // Dynamic Color Config Stream Readers
    Process {
        id: colorReader
        command: ["cat", `${Quickshell.env("HOME")}/.config/quickshell/topbar/colors.json`]
        stdout: StdioCollector { onStreamFinished: { try { root.colors = JSON.parse(this.text) } catch(e) {} } }
    }
    Process {
        id: paletteReader
        command: ["cat", `${Quickshell.env("HOME")}/.config/quickshell/material/palettes.json`]
        stdout: StdioCollector { onStreamFinished: { try { root.palettes = JSON.parse(this.text) } catch(e) {} } }
        running: true
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: colorReader.running = true }

    property string clockTime: "00:00:00 AM"
    property string clockDate: ""
    Process { id: procClock; command: ["date", "+%I:%M:%S %p"]; stdout: StdioCollector { onStreamFinished: root.clockTime = this.text.trim() } }
    Process { id: procDate; command: ["date", "+%A %b %d"]; stdout: StdioCollector { onStreamFinished: root.clockDate = this.text.trim() } }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: procClock.running = true }
    Timer { interval: 30000; running: true; repeat: true; onTriggered: procDate.running = true }

    property string currentVolume: "50%"
    Process { id: volumeReader; command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int(\$2*100)\"%\"}'"]; stdout: StdioCollector { onStreamFinished: root.currentVolume = this.text.trim() } }
    Timer { interval: 1500; running: true; repeat: true; onTriggered: volumeReader.running = true }

    property string cpuUsage: "10%"
    property string ramUsage: "45%"
    Process { id: cpuReader; command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print int(\$2 - \$1)\"%\"}'"]; stdout: StdioCollector { onStreamFinished: root.cpuUsage = this.text.trim() } }
    Process { id: ramReader; command: ["sh", "-c", "free -m | awk '/Mem:/ {print int(\$3/\$2*100)\"%\"}'"]; stdout: StdioCollector { onStreamFinished: root.ramUsage = this.text.trim() } }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: { cpuReader.running = true; ramReader.running = true } }

    property string activeWindowTitle: Hyprland.activeWindow ? Hyprland.activeWindow.title : ""
    property bool isMusicPlaying: false
    property string trackArtistTitle: ""
    Process { id: musicStatusReader; command: ["playerctl", "status", "-F"]; running: true; stdout: SplitParser { onRead: data => { root.isMusicPlaying = (data.trim() === "Playing") } } }
    Process { id: musicTrackReader; command: ["playerctl", "metadata", "--format", "{{ artist }} - {{ title }}", "-F"]; running: true; stdout: SplitParser { onRead: data => { root.trackArtistTitle = data.trim() } } }

    property string weatherTempDisplay: "19°C"
    property string weatherCondDisplay: "Cloudy"
    property string weatherWindDisplay: "12m/s"
    property string weatherHumidDisplay: "80%"
    Process { id: weatherFetcher; command: ["sh", "-c", "curl -s 'wttr.in?format=%t|%C|%w|%h' | sed 's/+//g'"]; stdout: StdioCollector { onStreamFinished: { if (this.text.trim() !== "" && !this.text.includes("Error")) { var parts = this.text.trim().split("|"); if (parts.length >= 4) { root.weatherTempDisplay = parts; root.weatherCondDisplay = parts; root.weatherWindDisplay = parts; root.weatherHumidDisplay = parts } } } } }
    Timer { interval: 900000; running: true; repeat: true; triggeredOnStart: true; onTriggered: weatherFetcher.running = true }

    property string latestSummary: ""
    property string latestBody: ""

    // ==========================================
    // IPC ACTION HANDLER INTERFACE
    // ==========================================
    IpcHandler {
        target: "material"
        function toggleLauncher()  { }
        function toggleTheme()     { customizerPanel.toggle() }
        function toggleWallpaper() { customizerPanel.toggle() }
        function toggleControl()   { }
        
        // FIX: Anonymous parameters prevent QVariant parsing constraints across the engine boundary
        function pushNotification() {
            try {
                var jsonStringPayload = arguments[0];
                var payload = JSON.parse(jsonStringPayload);
                root.latestSummary = payload.summary || "Notification";
                root.latestBody = payload.body || "";
                barRoot.triggerNotificationDrop();
            } catch (e) {
                root.latestSummary = "Alert Notification";
                root.latestBody = arguments[0] || "";
                barRoot.triggerNotificationDrop();
            }
        }
    }

    ThemePanel { id: customizerPanel; colors: root.colors; palettes: root.palettes }

    Bar {
        id: barRoot
        colors: root.colors
        clockTime: root.clockTime
        clockDate: root.clockDate
        volDisplay: root.currentVolume
        cpuDisplay: root.cpuUsage
        ramDisplay: root.ramUsage
        windowTitleDisplay: root.activeWindowTitle
        musicPlaying: root.isMusicPlaying
        trackDisplay: root.trackArtistTitle
        wTemp: root.weatherTempDisplay
        wCond: root.weatherCondDisplay
        wWind: root.weatherWindDisplay
        wHumid: root.weatherHumidDisplay
        
        property string alertSummary: root.latestSummary
        property string alertBody: root.latestBody
    }
}
