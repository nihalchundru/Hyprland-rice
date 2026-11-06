import QtQuick
import QtQuick.Layouts
import ".."
ColumnLayout {
    id: r
    property string label
    property real value
    property real from: 0
    property real to: 1
    property real step: 0
    property int decimals: 2
    signal moved(real v)
    Layout.fillWidth: true
    spacing: 4
    RowLayout {
        Layout.fillWidth: true
        Text { text: r.label; color: Colors.foreground; font.pixelSize: 12; Layout.fillWidth: true }
        Text { text: r.value.toFixed(r.decimals); color: Colors.primary; font.pixelSize: 12; font.family: "monospace" }
    }
    Item {
        Layout.fillWidth: true; height: 18
        Rectangle { id: track; anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 4; radius: 2; color: Colors.outline
            Rectangle { width: knob.x + knob.width / 2; height: parent.height; radius: 2; color: Colors.primary } }
        Rectangle { id: knob; width: 14; height: 14; radius: 7; anchors.verticalCenter: parent.verticalCenter
            x: (Math.max(0, Math.min(1, (r.value - r.from) / (r.to - r.from)))) * (track.width - width)
            color: ma.pressed ? Colors.secondary : Colors.primary
            scale: ma.containsMouse || ma.pressed ? 1.2 : 1; Behavior on scale { NumberAnimation { duration: 100 } } }
        MouseArea {
            id: ma; anchors.fill: parent; hoverEnabled: true
            function upd(mx) {
                let t = Math.max(0, Math.min(1, (mx - knob.width / 2) / (track.width - knob.width)));
                let v = r.from + t * (r.to - r.from);
                if (r.step > 0) v = Math.round(v / r.step) * r.step;
                r.moved(v);
            }
            onPressed: m => upd(m.x)
            onPositionChanged: m => { if (pressed) upd(m.x) }
        }
    }
}
