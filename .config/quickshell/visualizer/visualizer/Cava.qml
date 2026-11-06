pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Spawns `cava` in raw ASCII mode and exposes the current frame as `values` (0..1 each).
// The config is generated from the settings panel and written next to shell.qml.
Singleton {
    id: root
    property var values: []
    property int maxValue: 1000
    property string status: "starting"
    readonly property bool active: process.running

    readonly property string configPath: Quickshell.shellPath("cava.conf")

    function confText() {
        const s = Config.s;
        return "[general]\n" +
            "bars = " + s.bars + "\n" +
            "framerate = " + s.framerate + "\n" +
            "autosens = 1\n" +
            "lower_cutoff_freq = " + s.lowCutoff + "\n" +
            "higher_cutoff_freq = " + s.highCutoff + "\n" +
            "[input]\n" +
            "method = " + s.inputMethod + "\n" +
            "source = " + s.inputSource + "\n" +
            "[output]\n" +
            "method = raw\nraw_target = /dev/stdout\n" +
            "data_format = ascii\nascii_max_range = " + maxValue + "\n" +
            "bar_delimiter = 59\nframe_delimiter = 10\n" +
            "channels = " + (s.stereo ? "stereo" : "mono") + "\n" +
            "mono_option = average\n" +
            "[smoothing]\n" +
            "noise_reduction = " + Math.round(s.noiseReduction * 100) + "\n" +
            "monstercat = " + (s.monstercat ? 1 : 0) + "\n" +
            "waves = " + (s.waves ? 1 : 0) + "\n";
    }

    // Rebuild + restart cava when any cava-relevant setting changes.
    readonly property string sig: [
        Config.s.enabled, Config.s.bars, Config.s.framerate, Config.s.inputMethod,
        Config.s.inputSource, Config.s.stereo, Config.s.lowCutoff, Config.s.highCutoff,
        Config.s.noiseReduction, Config.s.monstercat, Config.s.waves
    ].join("|")
    onSigChanged: writeTimer.restart()
    Timer { id: writeTimer; interval: 300; repeat: false; onTriggered: root.writeAndStart() }
    Component.onCompleted: writeTimer.start()

    function writeAndStart() {
        writer.setText(confText());
    }

    FileView {
        id: writer
        path: root.configPath
        preload: false // we only write this file
        atomicWrites: true
        printErrors: true
        onSaved: {
            console.log("CAVA: cava.conf saved");
            if (Config.s.enabled) root.process.running = true;
        }
        onSaveFailed: console.warn("CAVA: cava.conf write FAILED")
    }

    property Process process: Process {
        id: proc
        command: ["cava", "-p", root.configPath]
        onRunningChanged: {
            console.log("CAVA: cava running =", running);
            if (running) { retryTimer.interval = 1000; root.status = "running"; }
        }
        onExited: (code) => {
            root.status = code === 0 ? "stopped" : "cava exited (" + code + ")";
            console.warn("CAVA: cava exited code", code);
            retryTimer.interval = Math.min(retryTimer.interval * 2, 10000);
            retryTimer.restart();
        }
        stdout: SplitParser {
            onRead: line => root.applyFrame(line)
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.length) console.warn("CAVA stderr:", text)
        }
    }

    property Timer retryTimer: Timer {
        interval: 1000
        repeat: false
        onTriggered: root.process.running = true
    }

    property bool loggedFrame: false
    property int frameCount: 0

    function applyFrame(line) {
        if (!line) return;
        const parts = line.split(";");
        const out = [];
        let mx = 0;
        for (let i = 0; i < parts.length; i++) {
            if (parts[i] === "") continue;
            let v = Number(parts[i]);
            if (!isFinite(v)) v = 0;
            let n = v / root.maxValue;
            n = n > 1 ? 1 : n < 0 ? 0 : n;
            if (n > mx) mx = n;
            out.push(n);
        }
        if (out.length === 0) return;
        root.values = out;
        root.status = "running";
        root.frameCount++;
        if (!root.loggedFrame) { root.loggedFrame = true; console.log("CAVA: first frame, bars =", out.length); }
        else if (root.frameCount % 300 === 0) console.log("CAVA: frame", root.frameCount, "max bar =", mx.toFixed(3));
    }
}
