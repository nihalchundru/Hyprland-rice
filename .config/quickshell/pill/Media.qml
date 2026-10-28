pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // prefer a playing player, else the first one
    readonly property var player: {
        const list = Mpris.players.values;
        return list.find(p => p.isPlaying) ?? list[0] ?? null;
    }

    readonly property bool hasPlayer: player !== null
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player ? (player.trackTitle ?? "") : ""
    readonly property string artist: player ? (player.trackArtist ?? "") : ""
    readonly property string art: player ? (player.trackArtUrl ?? "") : ""
    readonly property string album: player ? (player.trackAlbum ?? "") : ""
    readonly property real length: player ? (player.length ?? 0) : 0          // seconds
    readonly property real position: player ? player.position : 0              // seconds

    // ── the media card in the expanded island (Settings -> Media) ──────────
    readonly property int artSize: Settings.get("mediaArt")
    readonly property int songW: Settings.get("mediaSongW")
    readonly property bool showArtist: !!Settings.get("mediaArtist")
    readonly property bool showAlbum: !!Settings.get("mediaAlbum")
    readonly property bool showTransport: !!Settings.get("mediaTransport")
    readonly property bool showLyrics: !!Settings.get("mediaLyrics")
    readonly property bool scrollSkip: !!Settings.get("mediaScroll")

    readonly property int textH: (Theme.px(14) + 5)
                               + (showArtist ? Theme.px(12) + 5 : 0)
                               + (showAlbum ? Theme.px(12) + 5 : 0)
                               + (showLyrics ? Theme.px(12) + 5 : 0)
    readonly property int cardH: Math.max(54, artSize + 16, textH + 18)
    readonly property int rightW: showTransport ? 102 : 66
    readonly property int cardW: 9 + artSize + 11 + songW + 10 + rightW + 14
    readonly property int hoverH: 70 + cardH       // clock row + card + padding

    function toggle() { if (player) player.togglePlaying(); }
    function next() { if (player) player.next(); }
    function previous() { if (player) player.previous(); }
}
