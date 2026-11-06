import QtQuick
import QtQuick.Layouts
import ".."
ColumnLayout {
    property string title
    Layout.fillWidth: true
    spacing: 8
    Text { text: title.toUpperCase(); color: Colors.primary; font.pixelSize: 11; font.bold: true; font.letterSpacing: 1.5; Layout.topMargin: 10 }
    Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outline; opacity: 0.6 }
}
