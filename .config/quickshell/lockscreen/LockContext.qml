import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import "ShapeList.js" as ShapeList

// Shared lock state. Lives once, all LockSurfaces read/write it.
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

    // Initial hardware query for caps lock on Hyprland
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

    // Hide the failure message as soon as the user types again.
    onCurrentTextChanged: {
        syncChars();
        if (currentText !== "") showFailure = false;
    }

    // ---- Password characters: one random shape per typed char ----
    // Shared here (not per screen) so every monitor shows the same shapes.
    // Roles: shapeName (string), colorIdx (int, index into Colors.charColors).
    readonly property alias chars: charModel
    ListModel { id: charModel }

    // Shuffled pool of all shapes. Each char takes one; the pool is refilled
    // (reshuffled) only when empty, so no shape repeats until all were used.
    property var shapePool: []
    property string lastShape: ""
    property int colorCounter: 0

    function shuffled(list) {
        const a = list.slice();
        for (let i = a.length - 1; i > 0; --i) {
            const j = Math.floor(Math.random() * (i + 1));
            [a[i], a[j]] = [a[j], a[i]];
        }
        return a;
    }

    function nextShape() {
        if (shapePool.length === 0) {
            const p = shuffled(ShapeList.all);
            // Avoid the same shape twice in a row across a refill.
            // (pop() takes from the end, so keep the last item != lastShape)
            if (p[p.length - 1] === lastShape)
                [p[0], p[p.length - 1]] = [p[p.length - 1], p[0]];
            shapePool = p;
        }
        const p = shapePool;
        const s = p.pop();
        shapePool = p;
        lastShape = s;
        return s;
    }

    // Keep the model length equal to the password length.
    function syncChars() {
        const n = currentText.length;
        while (charModel.count < n)
            charModel.append({ shapeName: nextShape(), colorIdx: (colorCounter++) % 4 });
        while (charModel.count > n)
            charModel.remove(charModel.count - 1);
    }

    function tryUnlock() {
        if (currentText === "" || unlockInProgress) return;
        unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam

        // Custom PAM config in ./pam/password.conf (password only, via pam_unix).
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
