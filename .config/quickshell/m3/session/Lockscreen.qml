import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Lock via the session menu, or: qs -c m3 ipc call ui lock
// SAFETY: from a TTY you can always run:  qs -c m3 ipc call ui unlock
// Testing: M3_LOCK_TEST=1 qs -c m3  auto-unlocks 20s after locking.
Scope {
    WlSessionLock {
        locked: UiState.locked
        WlSessionLockSurface {
            color: "black"
            LockContent {}
        }
    }
    Connections { target: LockCtx; function onUnlocked() { UiState.locked = false } }
    Timer {
        interval: 20000
        running: UiState.locked && Quickshell.env("M3_LOCK_TEST") === "1"
        onTriggered: UiState.locked = false
    }
}
