import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

// Shared unlock state and PAM authentication for lockscreen3
Scope {
    id: root

    signal unlocking()
    signal unlocked()
    signal failed()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property bool capsLock: false

    Timer {
        id: unlockDelayTimer
        interval: 220
        repeat: false
        onTriggered: root.unlocked()
    }

    // Initial caps lock query on Hyprland
    Process {
        command: ["sh", "-c", "hyprctl devices -j 2>/dev/null | grep -q '\"capsLock\": true' && echo 1 || echo 0"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim();
                if (s === "1") root.capsLock = true;
                else if (s === "0") root.capsLock = false;
            }
        }
    }

    onCurrentTextChanged: {
        if (currentText !== "") showFailure = false;
    }

    function tryUnlock() {
        if (currentText === "" || unlockInProgress) return;
        unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam
        configDirectory: "pam"
        config: "password.conf"

        onPamMessage: {
            if (this.responseRequired)
                this.respond(root.currentText);
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlocking();
                unlockDelayTimer.start();
            } else {
                root.currentText = "";
                root.showFailure = true;
                root.failed();
            }
            root.unlockInProgress = false;
        }
    }
}
