import QtQuick
import QtQuick.Layouts

// Scrolling column for settings pages; children are laid out vertically.
Flickable {
    id: root
    default property alias body: col.data
    anchors.fill: parent
    contentWidth: width
    contentHeight: col.implicitHeight + 24
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ColumnLayout {
        id: col
        width: root.width - 8
        spacing: 14
    }
}
