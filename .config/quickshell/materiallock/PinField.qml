import QtQuick
import "shapes.js" as Shapes

// Password field where each typed char becomes the next shape from the sheet.
// Typing: shape springs in. Deleting: shape pops out before removal.
Item {
    id: root

    property color badgeColor: "#d0bcff"
    property color errorColor: "#f2b8b5"
    property bool error: false
    readonly property int count: pinModel.count
    readonly property int maxChars: 14

    ListModel { id: pinModel }

    function press() {
        if (pinModel.count >= maxChars) return
        var n = Shapes.ORDER.length
        var idx = Math.floor(Math.random() * n)
        // avoid an immediate repeat of the previous shape
        if (pinModel.count > 0 && Shapes.ORDER[idx] === pinModel.get(pinModel.count - 1).shape)
            idx = (idx + 1 + Math.floor(Math.random() * (n - 1))) % n
        pinModel.append({ shape: Shapes.ORDER[idx], dying: false })
    }

    function release() {
        for (var i = pinModel.count - 1; i >= 0; i--) {
            if (!pinModel.get(i).dying) {
                pinModel.get(i).dying = true
                return
            }
        }
    }

    function clear() {
        while (pinModel.count > 0) pinModel.remove(0)
    }

    width: implicitWidth
    height: badgeSize
    implicitWidth: row.implicitWidth
    implicitHeight: badgeSize

    property int badgeSize: 30

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Repeater {
            model: pinModel

            delegate: Item {
                id: cell
                required property int index
                required property string shape
                required property bool dying
                width: root.badgeSize
                height: root.badgeSize

                scale: 0
                opacity: 0

                ShapeBadge {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    shape: cell.shape
                    shapeColor: root.error ? root.errorColor : root.badgeColor
                }

                // pop in on type
                NumberAnimation on scale {
                    to: cell.dying ? 0 : 1
                    duration: cell.dying ? 130 : 380
                    easing.type: cell.dying ? Easing.InCubic : Easing.OutBack
                }
                NumberAnimation on opacity {
                    to: cell.dying ? 0 : 1
                    duration: cell.dying ? 130 : 200
                }

                Timer {
                    running: cell.dying && cell.visible
                    interval: 140
                    onTriggered: pinModel.remove(cell.index)
                }
            }
        }
    }
}
