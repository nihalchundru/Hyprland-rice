import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.components

// Icon + title/subtitle on the left, whatever you put inside on the right.
Item {
    id: root
    property string icon: ""
    property string title: ""
    property string sub: ""
    default property alias trailing: tr.data
    Layout.fillWidth: true
    implicitHeight: sub !== "" ? 64 : 56
    RowLayout {
        anchors.fill: parent
        spacing: 14
        Icon { visible: root.icon !== ""; name: root.icon; size: 22; color: M3Colors.fgSurfaceVariant }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            M3Text { Layout.fillWidth: true; elide: Text.ElideRight; text: root.title; role: M3Type.bodyLarge }
            M3Text { Layout.fillWidth: true; visible: root.sub !== ""; elide: Text.ElideRight; text: root.sub; role: M3Type.bodySmall; color: M3Colors.fgSurfaceVariant }
        }
        Row { id: tr; spacing: 8 }
    }
}
