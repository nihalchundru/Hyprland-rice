import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Entry point for the lock screen.
//
// This is a separate config from the bar so the two can be developed and
// restarted independently. Run it as a daemon (it sits idle and costs nothing
// while unlocked) and engage it on demand:
//
//     qs -c firecrust-lock &
//     qs ipc call lock lock
//
Scope {
    id: shell

    WlSessionLock {
        id: sessionLock

        // Deliberately not locked at startup unless Config says so -- see the
        // README warning about locking yourself out before PAM is wired up.
        locked: Config.lockOnStart

        // WlSessionLock's default property is `surface`, so this becomes the
        // per-monitor component. LockSurface.qml's root is a
        // WlSessionLockSurface, which is required.
        LockSurface {}
    }

    // Unlocking happens wherever the PAM conversation finishes (which may be
    // the surface on any monitor), so listen on the singleton rather than
    // wiring a reference through the component.
    Connections {
        target: Auth

        function onUnlocked() {
            sessionLock.locked = false;
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            sessionLock.locked = true;
        }

        function unlock(): void {
            sessionLock.locked = false;
        }

        function toggle(): void {
            sessionLock.locked = !sessionLock.locked;
        }

        // `secure` only becomes true once the compositor confirms every screen
        // is painted, which is what makes the lock trustworthy.
        function isLocked(): bool {
            return sessionLock.locked;
        }

        function isSecure(): bool {
            return sessionLock.secure;
        }
    }
}
