import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root
    property bool open: false
    readonly property var s: Config.s
    readonly property bool stereo: s.stereo
    readonly property bool canRound: ["bars", "mirror", "blocks", "dots", "radial"].indexOf(s.style) >= 0
    readonly property bool canPeaks: ["bars", "mirror", "blocks", "dots"].indexOf(s.style) >= 0
    readonly property bool canLine: s.style === "line" || s.style === "wave" || s.style === "circle" || s.style === "radial"
    readonly property bool canBlocks: s.style === "blocks" || s.style === "dots"
    readonly property bool canCircle: s.style === "circle" || s.style === "radial"

    opacity: open ? 1 : 0
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: 160 } }
    scale: open ? 1 : 0.97
    Behavior on scale { NumberAnimation { duration: 160 } }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.background, 0.96)
        border.width: 1; border.color: Colors.outline
        radius: 12
        clip: true
    }
    RowLayout {
        anchors.fill: parent; anchors.margins: 10; spacing: 10
        Rectangle { // left strip of draggable bars
            Layout.fillHeight: true; width: 8; radius: 4; color: Colors.outline; opacity: 0.5
            MouseArea { anchors.fill: parent; onPressed: m => root.Window.window.startSystemMove() }
            Column { anchors.centerIn: parent; spacing: 3
                Repeater { model: 3; Rectangle { width: 4; height: 12; radius: 2; color: Colors.primary } } }
        }
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 8
            RowLayout {
                Text { text: "Visualizer"; color: Colors.foreground; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
                Text { text: "✕"; color: Colors.foreground; font.pixelSize: 14
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Config.settingsOpen = false } }
            }
            Flickable {
                Layout.fillWidth: true; Layout.fillHeight: true
                contentWidth: width; contentHeight: col.height
                clip: true
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded
                    contentItem: Rectangle { color: Colors.outline; radius: 3 } }
                ColumnLayout {
                    id: col
                    width: parent.parent.width
                    spacing: 8

                    SSection { title: "General" }
                    SSwitch { label: "Enabled"; checked: s.enabled; onToggled: v => s.enabled = v }
                    SChoice { label: "Style"; current: s.style; onPicked: v => s.style = v
                        options: ["bars", "mirror", "blocks", "dots", "line", "wave", "area", "circle", "radial", "spectrum"] }
                    SChoice { label: "Position"; current: s.position; onPicked: v => s.position = v
                        options: ["bottom", "top", "left", "right", "center"] }
                    SSwitch { label: "Fullscreen layer (on top of everything)"; checked: s.fullscreenLayer; onToggled: v => s.fullscreenLayer = v }

                    SSection { title: "Layout" }
                    SSlider { label: "Height"; from: 40; to: 600; step: 4; value: s.height; onMoved: v => s.height = v }
                    SSlider { label: "Margin X"; from: 0; to: 200; step: 2; value: s.marginX; onMoved: v => s.marginX = v }
                    SSlider { label: "Margin Y"; from: 0; to: 200; step: 2; value: s.marginY; onMoved: v => s.marginY = v }
                    SSlider { label: "Bars"; from: 8; to: 256; step: 2; value: s.bars; decimals: 0; onMoved: v => s.bars = v }
                    SSlider { label: "Bar width"; from: 0.1; to: 1.0; step: 0.05; value: s.barWidth; onMoved: v => s.barWidth = v }
                    SSlider { label: "Roundness"; from: 0; to: 1; step: 0.05; value: s.roundness; visible: canRound; onMoved: v => s.roundness = v }
                    SSlider { label: "Opacity"; from: 0.05; to: 1; step: 0.05; value: s.opacity; onMoved: v => s.opacity = v }
                    SSwitch { label: "Reverse"; checked: s.reverse; onToggled: v => s.reverse = v }
                    SSlider { label: "Line width"; from: 1; to: 12; step: 1; value: s.lineWidth; decimals: 0; visible: canLine; onMoved: v => s.lineWidth = v }
                    SSlider { label: "Block size"; from: 3; to: 20; step: 1; value: s.blockSize; decimals: 0; visible: canBlocks; onMoved: v => s.blockSize = v }
                    SSlider { label: "Inner radius"; from: 0.1; to: 0.9; step: 0.05; value: s.innerRadius; visible: canCircle; onMoved: v => s.innerRadius = v }
                    SSlider { label: "Rotation"; from: 0; to: 360; step: 5; value: s.rotation; decimals: 0; visible: canCircle; onMoved: v => s.rotation = v }

                    SSection { title: "Effects" }
                    SSwitch { label: "Glow"; checked: s.glow; onToggled: v => s.glow = v }
                    SSlider { label: "Glow amount"; from: 0; to: 1.5; step: 0.05; value: s.glowAmount; onMoved: v => s.glowAmount = v }
                    SSwitch { label: "Peaks"; checked: s.peaks; visible: canPeaks; onToggled: v => s.peaks = v }
                    SSlider { label: "Min height"; from: 0; to: 0.3; step: 0.01; value: s.minHeight; onMoved: v => s.minHeight = v }

                    SSection { title: "Colors" }
                    SChoice { label: "Color source"; current: s.colorSource; onPicked: v => s.colorSource = v
                        options: ["theme", "custom"] }
                    SChoice { label: "Color mode"; current: s.colorMode; onPicked: v => s.colorMode = v
                        options: ["solid", "gradient", "palette", "rainbow", "height"] }
                    SText { label: "Color A"; value: s.customA; visible: s.colorSource === "custom"; onEdited: v => s.customA = v }
                    SText { label: "Color B"; value: s.customB; visible: s.colorSource === "custom"; onEdited: v => s.customB = v }
                    SSwitch { label: "Backdrop tint"; checked: s.useBackdrop; onToggled: v => s.useBackdrop = v }
                    SSlider { label: "Backdrop opacity"; from: 0; to: 0.8; step: 0.05; value: s.backdropOpacity; visible: s.useBackdrop; onMoved: v => s.backdropOpacity = v }

                    SSection { title: "Audio" }
                    SSlider { label: "Sensitivity"; from: 0.2; to: 4; step: 0.05; value: s.sensitivity; onMoved: v => s.sensitivity = v }
                    SSlider { label: "Smoothing"; from: 0; to: 0.95; step: 0.05; value: s.smoothing; onMoved: v => s.smoothing = v }
                    SSlider { label: "Noise reduction"; from: 0; to: 100; step: 1; value: s.noiseReduction * 100; decimals: 0; onMoved: v => s.noiseReduction = v / 100 }
                    SSwitch { label: "MonsterCat"; checked: s.monstercat; onToggled: v => s.monstercat = v }
                    SSwitch { label: "Waves"; checked: s.waves; onToggled: v => s.waves = v }
                    SChoice { label: "Input method"; current: s.inputMethod; onPicked: v => s.inputMethod = v
                        options: ["pulse", "alsa", "portaudio", "sndio", "pipewire"] }
                    SText { label: "Input source"; value: s.inputSource; onEdited: v => s.inputSource = v }
                    SSlider { label: "Low cutoff"; from: 20; to: 500; step: 5; value: s.lowCutoff; decimals: 0; onMoved: v => s.lowCutoff = v }
                    SSlider { label: "High cutoff"; from: 1000; to: 20000; step: 100; value: s.highCutoff; decimals: 0; onMoved: v => s.highCutoff = v }
                    SSlider { label: "Framerate"; from: 15; to: 120; step: 1; value: s.framerate; decimals: 0; onMoved: v => s.framerate = v }
                    SSwitch { label: "Stereo"; checked: s.stereo; onToggled: v => s.stereo = v }

                    SSection { title: "Help" }
                    Text { color: Colors.foreground; font.pixelSize: 11; wrapMode: Text.Wrap
                        text: "Settings are saved to ~/.config/quickshell/visualizer/settings.json and hot-applied.\n"
                            + "Colors are read live from ~/.config/quickshell/topbar/colors.json.\n"
                            + "Press the gear button in the visualizer's corner (or use your keybind) to open this panel.\n"
                            + "Requires cava installed and working audio input."
                        Layout.fillWidth: true }
                }
            }
        }
    }
}
