import QtQuick
import QtQuick.Layouts
import qs.config
import qs.theme

Surface {
    id: root
    default property alias content: row.data
    property int padding: 4
    property alias spacing: row.spacing

    implicitHeight: Config.bar.groupHeight
    implicitWidth: row.implicitWidth + padding * 2
    radius: M3.shape.full
    color: Colors.surfaceContainer

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 2
    }
}