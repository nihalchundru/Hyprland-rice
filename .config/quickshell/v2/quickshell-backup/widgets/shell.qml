import Quickshell
import Quickshell.Io
import "core"
import "desktop"

ShellRoot {
    WidgetLayer {}

    IpcHandler {
        target: "widgets"

        function toggleEdit(): void { LayoutStore.editMode = !LayoutStore.editMode; }
        function edit(): void       { LayoutStore.editMode = true; }
        function done(): void       { LayoutStore.editMode = false; }
        function undo(): void       { LayoutStore.undo(); }
        function redo(): void       { LayoutStore.redo(); }

        function profile(name: string): void { LayoutStore.switchProfile(name); }

        function nextProfile(): void {
            const n = LayoutStore.profileNames;
            if (n.length < 2) return;
            LayoutStore.switchProfile(n[(n.indexOf(LayoutStore.activeProfile) + 1) % n.length]);
        }
    }
}