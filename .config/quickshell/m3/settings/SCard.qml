import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.components

Rectangle {
    property string title: ""
    default property alias body: inner.data
    Layout.fillWidth: true
    implicitHeight: inner.implicitHeight + 28
    radius: 28
    color: Qt.alpha(M3Colors.surfaceContainerHigh, 0.92)
    ColumnLayout {
        id: inner
        x: 18; y: 14
        width: parent.width - 36
        spacing: 4
        M3Text { visible: parent.parent.title !== ""; text: parent.parent.title; role: M3Type.titleSmall; color: M3Colors.primary; Layout.bottomMargin: 4 }
    }
}
