import Quickshell
import Quickshell.Wayland
import "."

// Entry point for lockscreen2
// Test with: qs -p ~/.config/quickshell/lockscreen2/shell.qml
ShellRoot {
    LockContext {
        id: lockContext

        onUnlocked: {
            lock.locked = false;
            Qt.quit();
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
