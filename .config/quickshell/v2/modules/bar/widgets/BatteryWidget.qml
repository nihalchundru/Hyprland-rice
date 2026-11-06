import QtQuick
import qs.theme
import qs.services
import qs.components

Chip {
    visible: Battery.present
    icon: Battery.icon
    text: Battery.percent + "%"
    container: Battery.low ? Colors.errorContainer : Qt.alpha(Colors.surface, 0)
    content: Battery.low ? Colors.onErrorContainer
           : Battery.charging ? Colors.success : Colors.onSurface
}