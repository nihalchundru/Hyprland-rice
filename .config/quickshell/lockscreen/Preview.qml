import QtQuick
import "."

// Lightweight sandbox preview for the Material 3 Iris lockscreen ("Veil")
// Directly embeds the authentic LockSurface without creating a WlSessionLock.
Item {
    id: root
    anchors.fill: parent
    enabled: false

    LockContext {
        id: lockContext
    }

    LockSurface {
        anchors.fill: parent
        context: lockContext
    }
}
