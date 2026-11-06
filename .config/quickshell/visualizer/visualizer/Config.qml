pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    // All files live in the same folder as shell.qml (the config dir quickshell loads).
    readonly property string cavaConf: Quickshell.shellPath("cava.conf")
    property alias s: adapter
    property bool settingsOpen: false

    FileView {
        path: Quickshell.shellPath("settings.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoaded: writeAdapter() // create settings.json with defaults on first run
        printErrors: false

        JsonAdapter {
            id: adapter
            // general
            property bool enabled: true
            property string style: "bars"   // bars, mirror, blocks, dots, line, wave, area, circle, radial, spectrum
            property string monitor: "all"
            property string position: "bottom" // bottom, top, left, right, center
            property bool debugBox: false // diagnostic red border (set true to debug)
            // layout
            property int height: 150
            property int marginX: 48
            property int marginY: 28
            property int bars: 48
            property real barWidth: 0.85
            property real roundness: 0.5
            property real opacity: 0.9
            property bool reverse: false
            property bool fullscreenLayer: false // overlaps windows instead of sitting on the desktop
            // style specific
            property real lineWidth: 3
            property int blockSize: 8
            property real innerRadius: 0.35
            property real rotation: 0
            property bool glow: true
            property real glowAmount: 0.5
            property bool peaks: true
            property real minHeight: 0.02
            // colors
            property string colorSource: "theme"   // theme, custom
            property string colorMode: "gradient"  // solid, gradient, palette, rainbow, height
            property string customA: "#89b4fa"
            property string customB: "#f38ba8"
            property bool useBackdrop: false
            property real backdropOpacity: 0.25
            // audio
            property real sensitivity: 1.0
            property real smoothing: 0.5
            property int framerate: 60
            property real noiseReduction: 0.77
            property bool monstercat: false
            property bool waves: false
            property string inputMethod: "pulse"
            property string inputSource: "auto"
            property int lowCutoff: 50
            property int highCutoff: 10000
            property bool stereo: false
        }
    }
}
