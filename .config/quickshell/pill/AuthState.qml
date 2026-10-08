pragma Singleton
import QtQuick
import Quickshell

// Authentication state seen by the UI. It has no polkit import itself; the
// PolkitBridge fills it in. If the polkit module is missing, this just stays idle.
Singleton {
    id: root

    property var flow: null          // polkit AuthFlow while a request is active
    property bool active: false
    property bool registered: false

    function submit(pw) { if (flow) flow.submit(pw); }
    function cancel() { if (flow) flow.cancelAuthenticationRequest(); }

    // a request takes over the pill; when it ends, the pill goes back to idle
    onActiveChanged: {
        if (active) Pill.open("auth", true);
        else if (Pill.mode === "auth") Pill.close();
    }
}
