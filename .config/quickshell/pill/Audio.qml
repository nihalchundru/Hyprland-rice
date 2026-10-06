pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Thin helper layer over PipeWire: device lists, default devices, per-app streams.
Singleton {
    id: root

    PwObjectTracker { objects: Pipewire.nodes.values }

    function mediaClass(n) {
        return (n && n.properties && n.properties["media.class"]) || "";
    }

    readonly property var nodes: Pipewire.nodes.values
    readonly property var sinks:   nodes.filter(n => n.ready && n.audio && mediaClass(n) === "Audio/Sink")
    readonly property var sources: nodes.filter(n => n.ready && n.audio && mediaClass(n) === "Audio/Source")
    readonly property var apps:    nodes.filter(n => n.ready && n.audio && mediaClass(n) === "Stream/Output/Audio")

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    function volumeOf(n) { return (n && n.audio) ? n.audio.volume : 0; }
    function mutedOf(n) { return (n && n.audio) ? n.audio.muted : false; }

    function setVolume(n, v) {
        if (!n || !n.audio) return;
        if (n.audio.muted && v > 0) n.audio.muted = false;
        n.audio.volume = Math.max(0, Math.min(1, v));
    }

    function nameOf(n) { return n.description || n.nickname || n.name; }

    function appName(n) {
        const p = n.properties || {};
        return p["application.name"] || n.nickname || n.name;
    }

    function iconFor(n) {
        const s = (n.description || n.name || "").toLowerCase();
        if (s.indexOf("headphone") >= 0 || s.indexOf("headset") >= 0) return "headphones";
        if (s.indexOf("hdmi") >= 0 || s.indexOf("displayport") >= 0) return "monitor";
        return "volume";
    }

    function selectSink(n) { Pipewire.preferredDefaultAudioSink = n; }
    function selectSource(n) { Pipewire.preferredDefaultAudioSource = n; }
}
