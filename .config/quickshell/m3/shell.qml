import QtQuick
import Quickshell
import qs.services
import qs.debug
import qs.bar
import qs.osd
import qs.launcher
import qs.notifications
import qs.quicksettings
import qs.session
import qs.dock
import qs.overview
import qs.picker
import qs.panel
import qs.widgets
import qs.sidebar
import qs.settings

ShellRoot {
    Component.onCompleted: { Matugen.start(); Weather.refresh() }

    M3Ipc {}
    Bar {}
    Osd {}
    Launcher {}
    Popups {}
    NotificationCenter {}
    QuickSettings {}
    SessionMenu {}
    Lockscreen {}
    Dock {}
    Overview {}
    WallpaperPicker {}
    MainPanel {}
    DesktopWidgets {}
    Sidebar {}
    SettingsApp {}

    // M3_DEBUG=1 | gallery | services   qs -c m3
    LazyLoader { active: M3Config.debugMode === "1"; Swatches {} }
    LazyLoader { active: M3Config.debugMode === "gallery"; Gallery {} }
    LazyLoader { active: M3Config.debugMode === "services"; Services {} }
}
