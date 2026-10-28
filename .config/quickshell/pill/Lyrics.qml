pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "lrc.js" as Lrc

// Synced lyrics for the playing song, shown on the media card when
// Settings -> Media -> Lyrics is on (off by default).
// MPRIS carries no lyrics, so they are fetched from lrclib.net, which means the
// song's title, artist, album and length are sent there. Nothing happens while
// the setting is off.
Singleton {
    id: root

    readonly property bool wanted: Media.showLyrics && Media.hasPlayer

    property var lines: []
    property string status: "idle"        // idle | loading | none | ready
    property string loadedKey: ""
    property int seq: 0                   // identifies the request whose answer we still want
    property int stage: 1                 // 1: exact lookup, 2: search fallback
    property var req: ({ title: "", artist: "", album: "", dur: 0 })

    readonly property string key: Media.title + "|" + Media.artist + "|" + Media.album + "|" + Math.round(Media.length)
    readonly property string current: status === "ready" ? Lrc.lineAt(lines, Media.position + 0.25) : ""

    onKeyChanged: refetch()
    onWantedChanged: refetch()

    function refetch() {
        if (!wanted || Media.title === "") {
            seq++;
            lines = [];
            status = "idle";
            loadedKey = "";
            return;
        }
        if (key === loadedKey) return;
        loadedKey = key;
        seq++;
        stage = 1;
        lines = [];
        status = "loading";
        req = { title: Media.title, artist: Media.artist, album: Media.album, dur: Math.round(Media.length) };
        launch();
    }

    function launch() {
        const base = ["curl", "-s", "-m", "8", "-A", "pill-quickshell", "-G"];
        let cmd;
        if (stage === 1) {
            cmd = base.concat(["https://lrclib.net/api/get",
                "--data-urlencode", "track_name=" + req.title,
                "--data-urlencode", "artist_name=" + req.artist,
                "--data-urlencode", "album_name=" + req.album,
                "--data-urlencode", "duration=" + req.dur]);
        } else {
            cmd = base.concat(["https://lrclib.net/api/search",
                "--data-urlencode", "track_name=" + req.title,
                "--data-urlencode", "artist_name=" + req.artist]);
        }
        procC.createObject(root, { seq: root.seq, command: cmd, running: true });
    }

    function handle(id, text) {
        if (id !== seq) return;                       // an answer for a song that is no longer playing
        let data = null;
        try { data = JSON.parse(text); } catch (e) {}

        let lrc = "";
        if (stage === 1) {
            lrc = (data && typeof data.syncedLyrics === "string") ? data.syncedLyrics : "";
        } else {
            const best = Lrc.pickSearch(Array.isArray(data) ? data : [], req.dur);
            lrc = best ? best.syncedLyrics : "";
        }

        if (lrc !== "") {
            lines = Lrc.parseLrc(lrc);
            status = lines.length > 0 ? "ready" : "none";
        } else if (stage === 1) {
            stage = 2;
            launch();
        } else {
            status = "none";
        }
    }

    // one short-lived process per request, so a late answer can never be mistaken for the current one
    Component {
        id: procC

        Process {
            id: p
            property int seq: 0
            stdout: StdioCollector {
                onStreamFinished: root.handle(p.seq, text)
            }
            onExited: p.destroy()
        }
    }

    // MPRIS only reports the position when asked, so nudge it while lyrics are on screen
    Timer {
        interval: 400
        repeat: true
        running: root.status === "ready" && Media.playing
        onTriggered: { if (Media.player) Media.player.positionChanged(); }
    }
}
