import QtQuick
import Quickshell.Services.Polkit

// Loaded through a Loader in shell.qml so a missing polkit module cannot break
// the rest of the pill. Registers as the session's polkit agent.
Item {
    PolkitAgent { id: agent }

    Binding { target: AuthState; property: "flow"; value: agent.flow }
    Binding { target: AuthState; property: "active"; value: agent.isActive }
    Binding { target: AuthState; property: "registered"; value: agent.isRegistered }
}
