pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property string icon: muted ? "volume_off"
                                 : volume < 0.01 ? "volume_mute"
                                 : volume < 0.5 ? "volume_down" : "volume_up"

    PwObjectTracker { objects: [root.sink] }

    function setVolume(v) {
        if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1, v))
    }
    function toggleMute() {
        if (sink?.audio) sink.audio.muted = !sink.audio.muted
    }
}