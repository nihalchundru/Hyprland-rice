import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.tokens
import qs.services
import qs.components

PanelWindow {
    id: win
    WlrLayershell.namespace: "m3-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    anchors.bottom: true
    margins.bottom: 96
    implicitWidth: 340
    implicitHeight: 80
    color: "transparent"
    mask: Region {}
    visible: card.opacity > 0.01

    property bool shown: false
    property bool armed: false
    property string kind: "volume"
    readonly property real value: kind === "volume" ? (Audio.muted ? 0 : Audio.volume) : Brightness.value
    readonly property string iconName: kind === "volume" ? Audio.icon : Brightness.icon

    function show(k) {
        if (!armed) return
        kind = k
        shown = true
        hideTimer.restart()
    }
    Timer { id: armTimer; interval: 2500; running: true; onTriggered: win.armed = true }
    Timer { id: hideTimer; interval: 1600; onTriggered: win.shown = false }

    Connections {
        target: Audio
        function onVolumeChanged() { win.show("volume") }
        function onMutedChanged() { win.show("volume") }
    }
    Connections {
        target: Brightness
        function onValueChanged() { win.show("brightness") }
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        y: win.shown ? 12 : 36
        width: 300; height: 56; radius: 28
        color: M3Colors.surfaceContainerHigh
        opacity: win.shown ? 1 : 0
        scale: win.shown ? 1 : 0.9
        FadeBehavior on opacity { time: M3Motion.short4 }
        SpatialBehavior on y {}
        SpatialBehavior on scale { eps: 0.002 }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18; anchors.rightMargin: 20
            spacing: 14
            Icon { name: win.iconName; size: 24; color: M3Colors.fgSurface; fill: 1 }
            M3Progress { Layout.fillWidth: true; thickness: 8; value: win.value }
            M3Text { text: Math.round(win.value * 100); role: M3Type.labelLarge; Layout.preferredWidth: 28; horizontalAlignment: Text.AlignRight }
        }
    }
}
