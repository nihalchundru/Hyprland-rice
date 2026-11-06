pragma Singleton

import Quickshell
import Quickshell.Services.Pam

// Owns the PAM conversation. Kept in a singleton (rather than inside the lock
// surface) so there is exactly one authentication in flight no matter how many
// monitors are locked, and so shell.qml can listen for `unlocked` without
// threading a reference through the surface component.
Singleton {
    id: root

    signal unlocked()
    signal failed()

    readonly property bool busy: pam.active
    readonly property bool ready: pam.responseRequired

    // PAM's own message, unless we have something better to say.
    readonly property string message: root.localMessage !== "" ? root.localMessage : pam.message
    readonly property bool messageIsError: root.localMessage !== "" ? root.localError : pam.messageIsError

    property string localMessage: ""
    property bool localError: false

    // Held between start() and the moment PAM actually asks for it -- which can
    // be synchronous or asynchronous, so we cannot respond immediately after
    // start() and expect it to land.
    property string pendingPassword: ""

    function submit(password) {
        if (pam.active || password.length === 0) return;
        root.localMessage = "";
        root.localError = false;
        root.pendingPassword = password;
        if (!pam.start()) {
            root.pendingPassword = "";
            root.localMessage = "could not start authentication";
            root.localError = true;
        }
    }

    function cancel() {
        root.pendingPassword = "";
        if (pam.active) pam.abort();
    }

    // Called when the lock engages, so a stale error from last time isn't
    // still on screen.
    function reset() {
        root.cancel();
        root.localMessage = "";
        root.localError = false;
    }

    PamContext {
        id: pam

        config: Config.pamConfig
        configDirectory: Config.pamDirectory
        // `user` is intentionally left unset so PAM uses the current user.

        onResponseRequiredChanged: {
            if (responseRequired && root.pendingPassword !== "") {
                const pw = root.pendingPassword;
                root.pendingPassword = ""; // never leave it sitting in a property
                pam.respond(pw);
            }
        }

        onCompleted: (result) => {
            root.pendingPassword = "";
            if (result === PamResult.Success) {
                root.unlocked();
                return;
            }
            root.localError = true;
            root.localMessage = result === PamResult.MaxTries
                ? "too many attempts"
                : "incorrect password";
            root.failed();
        }

        onError: (error) => {
            root.pendingPassword = "";
            root.localError = true;
            root.localMessage = "authentication error";
            console.warn("quickshell-lock: pam error", error);
        }
    }
}
