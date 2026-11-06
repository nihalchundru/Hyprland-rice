import QtQuick
import "viz.js" as Viz

// The visualizer on the media card: ten bars that rest as dots and stretch with the music.
// "Static loop" is a travelling wave; "Music synced" follows the real audio (via cava).
Row {
    id: root

    spacing: 4

    readonly property int count: Visualizer.bars
    readonly property bool useSynced: Visualizer.synced && Visualizer.live
    property real phase: 0

    // loops forever, so it keeps a fixed length and is switched off by Reduce motion
    NumberAnimation on phase {
        from: 0
        to: Math.PI * 2
        duration: 1600
        loops: Animation.Infinite
        running: root.visible && Media.playing && !Theme.reduce && !root.useSynced
    }

    Repeater {
        model: root.count

        Item {
            id: bar
            required property int index
            width: 3
            height: 26

            readonly property real level: root.useSynced ? (Visualizer.levels[index] || 0)
                                          : (Media.playing ? Viz.loopLevel(index, root.phase) : 0)

            Rectangle {
                anchors.centerIn: parent
                width: 3
                height: 3 + bar.level * 22
                radius: 1.5
                color: Theme.accent
                opacity: 0.3 + 0.7 * bar.level
                Behavior on height { NumberAnimation { duration: Theme.ms(60) } }
            }
        }
    }
}
