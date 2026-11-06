pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property string sinkName: sink ? (sink.description || sink.nickname || sink.name) : ""
    readonly property bool micMuted: source && source.audio ? source.audio.muted : false
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)

    function setVolume(v) { if (ready) sink.audio.volume = Math.max(0, Math.min(1.0, v)) }
    function toggleMute() { if (ready) sink.audio.muted = !sink.audio.muted }
    function toggleMic() { if (source && source.audio) source.audio.muted = !source.audio.muted }
    function setDefaultSink(node) { Pipewire.preferredDefaultAudioSink = node }

    PwObjectTracker { objects: [root.sink, root.source].filter(n => n) }
    readonly property string icon: muted || volume <= 0 ? "volume_off" : volume < 0.33 ? "volume_mute" : volume < 0.66 ? "volume_down" : "volume_up"
}
