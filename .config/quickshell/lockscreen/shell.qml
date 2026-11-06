import Quickshell
import Quickshell.Wayland
import "."

// Entry point for the lockscreen.
// Run with: qs -p ~/.config/quickshell/lockscreen/shell.qml
ShellRoot {
    // Shared state (password buffer, PAM, failure flag) for every screen.
    LockContext {
        id: lockContext

        onUnlocked: {
            // Unlock BEFORE quitting, otherwise Hyprland shows its
            // "lockscreen died" fallback that you can't interact with.
            lock.locked = false;
            Qt.quit();
        }
    }

    WlSessionLock {
        id: lock

        // Lock as soon as quickshell starts.
        locked: true

        // WlSessionLock creates one of these per monitor automatically.
        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
