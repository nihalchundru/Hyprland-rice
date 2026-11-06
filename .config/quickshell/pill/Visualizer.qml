pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "viz.js" as Viz

// Feeds the "music synced" visualizer. It runs `cava` (through scripts/visualizer.sh)
// only while the bars can actually be seen: music playing, the pill expanded, and
// Settings -> Media -> Music visualizer set to "Music synced". If cava is missing
// or will not start, the bars quietly fall back to the static loop.
Singleton {
    id: root

    readonly property int bars: 10
    readonly property bool synced: !!Settings.get("mediaVisualizer") && Settings.get("mediaVisMode") === "sync"

    property bool installed: true          // set by the check below
    property bool failed: false            // cava is there but would not start
    property bool live: false              // frames are arriving right now
    property var levels: []                // 0..1 per bar

    readonly property bool wanted: synced && installed && !failed && Media.playing && Pill.mode === "hover"
    readonly property string statusText: !installed ? "cava not installed, using the loop"
                                       : failed ? "cava could not start, using the loop"
                                       : "cava found"

    function feed(line) {
        const v = Viz.parseFrame(line, bars);
        if (!v) return;
        levels = v;
        live = true;
        dog.restart();
    }

    onWantedChanged: {
        if (wanted) {
            stopDelay.stop();
            if (!proc.running) proc.running = true;
        } else {
            stopDelay.restart();
        }
    }

    // choosing "Music synced" again gives a failed cava another chance
    onSyncedChanged: { if (synced) failed = false; }

    // keep cava alive through short gaps (moving the mouse off and back on)
    Timer {
        id: stopDelay
        interval: 800
        onTriggered: {
            if (proc.running) proc.running = false;
            root.live = false;
            root.levels = [];
        }
    }

    // no frames for a moment: treat it as not live
    Timer {
        id: dog
        interval: 1200
        onTriggered: root.live = false
    }

    Timer {
        id: retry
        interval: 1000
        onTriggered: { if (root.wanted && !proc.running) proc.running = true; }
    }

    Process {
        id: proc
        command: ["bash", Theme.scriptsDir + "visualizer.sh", String(root.bars)]
        stdout: SplitParser { onRead: line => root.feed(line) }
        onExited: (code, status) => {
            root.live = false;
            if (code === 3) root.installed = false;
            else if (code === 4) root.failed = true;
            else if (root.wanted) retry.restart();        // it died unexpectedly: try again shortly
        }
    }

    // is cava installed at all? (so Settings can say so without running it)
    Process {
        command: ["sh", "-c", "command -v cava"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.installed = text.trim() !== "" }
    }
}
