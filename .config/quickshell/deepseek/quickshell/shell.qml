import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Entry point. Drop this folder at ~/.config/quickshell/<name>/ and run
// `qs -c <name>`, or put the files directly in ~/.config/quickshell/ and
// just run `qs`.
//
// Scope is a non-visual root: it holds windows, singletons and IPC handlers
// without being a window itself.
Scope {
    // One bar instance per connected monitor. Because Quickshell.screens is
    // reactive, bars appear and disappear as you plug monitors in and out.
    Variants {
        model: Quickshell.screens

        // Variants' `delegate` is its default property, so the window goes
        // here directly.
        //
        // Do NOT declare `modelData` here: Bar.qml already declares it as a
        // required property and binds `screen` to it. Re-declaring it in this
        // instance shadows that property, Variants then populates the shadow,
        // and Bar.qml's own required property is left uninitialized --
        // "Required property modelData was not initialized".
        Bar {}
    }

    // `qs ipc call bar reload`
    IpcHandler {
        target: "bar"

        function reload(): void {
            // false = soft reload; existing windows are reused rather than
            // torn down, so the bar doesn't flicker.
            Quickshell.reload(false);
        }

        function togglePlay(): void {
            const players = Mpris.players.values;
            if (players.length > 0 && players[0].canTogglePlaying)
                players[0].togglePlaying();
        }
    }
}
