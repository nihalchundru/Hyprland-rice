import Quickshell
import Quickshell.Io
import qs.services

Scope {
    IpcHandler {
        target: "launcher"
        function toggle(): void { Panels.toggle("launcher") }
        function close(): void  { Panels.close() }
    }
    IpcHandler {
        target: "theme"
        function toggle(): void { Panels.toggle("theme") }
        function close(): void  { Panels.close() }
    }
    IpcHandler {
        target: "wallpaper"
        function toggle(): void { Panels.toggle("wallpaper") }
        function close(): void  { Panels.close() }
    }
}