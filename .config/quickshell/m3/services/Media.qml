pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root
    readonly property var players: Mpris.players.values
    property var preferred: null
    readonly property var active: {
        if (preferred && players.indexOf(preferred) >= 0) return preferred
        for (const p of players) if (p.isPlaying) return p
        return players.length > 0 ? players[0] : null
    }
    readonly property bool has: active !== null
    readonly property bool playing: has && active.isPlaying
    readonly property string title: has ? (active.trackTitle || "") : ""
    readonly property string artist: has ? (active.trackArtist || "") : ""
    readonly property string art: has ? (active.trackArtUrl || "") : ""
    readonly property real position: has ? active.position : 0
    readonly property real length: has ? active.length : 0
    readonly property real progress: length > 0 ? Math.min(1, position / length) : 0

    function toggle() { if (has && active.canTogglePlaying) active.togglePlaying() }
    function next() { if (has && active.canGoNext) active.next() }
    function previous() { if (has && active.canGoPrevious) active.previous() }

    Timer {
        interval: 1000; repeat: true
        running: root.playing
        onTriggered: root.active.positionChanged()
    }
    readonly property string album: has ? (active.trackAlbum || "") : ""
    readonly property bool canSeek: has && active.canSeek && active.positionSupported
    readonly property bool shuffleSupported: has && active.shuffleSupported
    readonly property bool shuffle: shuffleSupported && active.shuffle
    readonly property bool loopSupported: has && active.loopSupported
    readonly property string loopIcon: !loopSupported || active.loopState === MprisLoopState.None ? "repeat" : active.loopState === MprisLoopState.Track ? "repeat_one" : "repeat_on"

    function seek(frac) { if (canSeek && length > 0) active.position = frac * length }
    function select(p) { preferred = p }
    function toggleShuffle() { if (shuffleSupported) active.shuffle = !active.shuffle }
    function cycleLoop() {
        if (!loopSupported) return
        const s = active.loopState
        active.loopState = s === MprisLoopState.None ? MprisLoopState.Playlist : s === MprisLoopState.Playlist ? MprisLoopState.Track : MprisLoopState.None
    }
}
