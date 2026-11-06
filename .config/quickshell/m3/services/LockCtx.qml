pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pam

Singleton {
    id: root
    property string password: ""
    property bool busy: false
    property bool failed: false
    signal unlocked()

    function submit() {
        if (busy || password === "") return
        busy = true; failed = false
        pam.start()
    }

    PamContext {
        id: pam
        configDirectory: Quickshell.env("HOME") + "/.config/quickshell/m3/pam"
        config: "password.conf"
        onPamMessage: { if (responseRequired) respond(root.password) }
        onCompleted: result => {
            root.busy = false
            root.password = ""
            if (result === PamResult.Success) root.unlocked()
            else root.failed = true
        }
    }
}
