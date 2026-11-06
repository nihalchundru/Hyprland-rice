import QtQuick
import Quickshell
import qs.config
import qs.theme
import qs.services
import qs.components

Chip {
    icon: Network.icon
    text: Network.type === "wifi" ? Network.name : ""
    maxTextWidth: 120
    content: Network.connected ? Colors.onSurface : Colors.onSurfaceVariant
    onClicked: Quickshell.execDetached(Config.cmd.network)
}