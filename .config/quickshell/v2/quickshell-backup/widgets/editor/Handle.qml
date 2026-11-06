import QtQuick
import "../core"

MouseArea {
    id: h

    property string wid: ""
    property var overlay
    property int ex: 0      // -1 left, 0 middle, 1 right
    property int ey: 0      // -1 top,  0 middle, 1 bottom

    readonly property real t: 18
    readonly property bool corner: ex !== 0 && ey !== 0

    // edges span between the corners, corners sit centered on the corner point
    width:  ex === 0 ? Math.max(0, parent.width - 2 * t) : t
    height: ey === 0 ? Math.max(0, parent.height - 2 * t) : t
    x: ex < 0 ? -t / 2 : ex > 0 ? parent.width - t / 2 : t
    y: ey < 0 ? -t / 2 : ey > 0 ? parent.height - t / 2 : t

    cursorShape: corner ? (ex * ey > 0 ? Qt.SizeFDiagCursor : Qt.SizeBDiagCursor)
               : ey === 0 ? Qt.SizeHorCursor : Qt.SizeVerCursor

    Rectangle {
        anchors.centerIn: parent
        width: h.corner ? 12 : (h.ey === 0 ? 6 : 28)
        height: h.corner ? 12 : (h.ey === 0 ? 28 : 6)
        radius: Math.min(width, height) / 2
        color: Theme.accent
        border.width: 2
        border.color: Theme.card
    }

    onPressed: m => {
        const p = mapToItem(h.overlay, m.x, m.y);
        h.overlay.begin(h.wid, "resize", h.ex, h.ey, p.x, p.y);
    }
    onPositionChanged: m => {
        if (!pressed) return;
        const p = mapToItem(h.overlay, m.x, m.y);
        h.overlay.update(p.x, p.y);
    }
    onReleased: h.overlay.finish()
    onCanceled: h.overlay.finish()
}