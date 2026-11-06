import QtQuick
import "../core"

Rectangle {
    id: root

    // 0: lowest, 1: low, 2: container, 3: high, 4: highest, 5: primaryContainer, 6: secondaryContainer, 7: tertiaryContainer
    property int level: 2
    property bool outlined: false
    property bool interactive: false

    signal clicked()

    radius: Motion.radiusLargeIncreased
    color: {
        switch (level) {
            case 0: return Theme.surfaceContainerLowest;
            case 1: return Theme.surfaceContainerLow;
            case 2: return Theme.surfaceContainer;
            case 3: return Theme.surfaceContainerHigh;
            case 4: return Theme.surfaceContainerHighest;
            case 5: return Theme.primaryContainer;
            case 6: return Theme.secondaryContainer;
            case 7: return Theme.tertiaryContainer;
            default: return Theme.surfaceContainer;
        }
    }

    border.width: outlined ? 1 : 0
    border.color: Theme.outlineVariant

    Behavior on color {
        ColorAnimation {
            duration: Motion.durationColor
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Motion.durationColor
            easing.type: Easing.OutCubic
        }
    }

    M3StateLayer {
        anchors.fill: parent
        visible: root.interactive
        cornerRadius: root.radius
        stateColor: root.level >= 5 ? Theme.onPrimaryContainer : Theme.onSurface
        onClicked: root.clicked()
    }
}
