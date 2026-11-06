import QtQuick
import Quickshell
import qs.config
import qs.theme
import qs.services
import qs.components

Chip {
    icon: Audio.icon
    text: Math.round(Audio.volume * 100) + "%"
    content: Audio.muted ? Colors.onSurfaceVariant : Colors.onSurface

    onClicked: Audio.toggleMute()
    onRightClicked: Quickshell.execDetached(Config.cmd.audio)

    WheelHandler {
        onWheel: e => Audio.setVolume(Audio.volume + (e.angleDelta.y > 0 ? 0.05 : -0.05))
    }
}