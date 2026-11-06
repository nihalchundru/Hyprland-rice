import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.components

Group {
    M3Text {
        Layout.leftMargin: 14
        text: Clock.timeText
        role: "titleSmall"
        color: Colors.onSurface
    }
    Rectangle {
        Layout.preferredWidth: 4
        Layout.preferredHeight: 4
        radius: 2
        color: Colors.outline
    }
    M3Text {
        Layout.rightMargin: 14
        text: Clock.dateText
        role: "labelLarge"
        color: Colors.onSurfaceVariant
    }
}