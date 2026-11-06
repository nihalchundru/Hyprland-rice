import Quickshell
import Quickshell.Wayland
import "."

// Entry point for Deck lockscreen (lockscreen3)
// Test with: qs -p ~/.config/quickshell/lockscreen3/shell.qml
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
