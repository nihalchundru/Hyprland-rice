import QtQuick
import qs.theme

Item {
    id: root
    property string icon: ""
    property string variant: "standard"   // standard | filled | tonal | outlined
    property bool checkable: false
    property bool checked: false
    property real size: 36
    property real iconSize: 20

    signal clicked()
    signal rightClicked()

    implicitWidth: size
    implicitHeight: size

    readonly property bool _off: checkable && !checked

    readonly property color containerColor: {
        switch (variant) {
        case "filled":   return _off ? Colors.surfaceContainerHighest : Colors.primary
        case "tonal":    return _off ? Colors.surfaceContainerHighest : Colors.secondaryContainer
        case "outlined": return checked ? Colors.inverseSurface : Qt.alpha(Colors.surface, 0)
        default:         return Qt.alpha(Colors.surface, 0)
        }
    }
    readonly property color contentColor: {
        switch (variant) {
        case "filled":   return _off ? Colors.primary : Colors.onPrimary
        case "tonal":    return _off ? Colors.onSurfaceVariant : Colors.onSecondaryContainer
        case "outlined": return checked ? Colors.inverseOnSurface : Colors.onSurfaceVariant
        default:         return checked ? Colors.primary : Colors.onSurfaceVariant
        }
    }

    Surface {
        anchors.fill: parent
        radius: M3.shape.full
        color: root.containerColor
        border.width: root.variant === "outlined" && !root.checked ? 1 : 0
        border.color: Colors.outline
    }

    M3Icon {
        anchors.centerIn: parent
        name: root.icon
        size: root.iconSize
        filled: root.checked
        color: root.contentColor
    }

    StateLayer {
        anchors.fill: parent
        radius: M3.shape.full
        color: root.contentColor
        onClicked: root.clicked()
        onRightClicked: root.rightClicked()
    }
}