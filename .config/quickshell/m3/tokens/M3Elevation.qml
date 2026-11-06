pragma Singleton
import QtQuick
import Quickshell

// M3 = tonal elevation. Level 0..5 -> surface tone. Shadow only for floating layers.
Singleton {
    function tone(level) {
        switch (level) {
        case 0: return M3Colors.surface
        case 1: return M3Colors.surfaceContainerLow
        case 2: return M3Colors.surfaceContainer
        case 3: return M3Colors.surfaceContainerHigh
        default: return M3Colors.surfaceContainerHighest
        }
    }
    readonly property real shadowOpacity: 0.30
    readonly property int shadowBlur: 24
}
