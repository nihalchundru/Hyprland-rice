pragma Singleton
import QtQuick
import Quickshell

// Which overlays are open. Bar buttons and IPC flip these; panels (stage 5+) read them.
Singleton {
    property bool quickSettingsOpen: false
    property bool notifCenterOpen: false
    property bool launcherOpen: false
    property bool overviewOpen: false
    property bool sessionOpen: false
    property bool calendarOpen: false
    property bool wallpaperOpen: false
    property bool sidebarOpen: false
    property bool settingsOpen: false
    property int sidebarTab: 0   // 0 sidebar, 1 widgets editor
    onSidebarOpenChanged: if (sidebarOpen) { quickSettingsOpen = false; notifCenterOpen = false; calendarOpen = false }
    property int mainPage: 0   // 0 home, 1 media, 2 spaces, 3 keys, 4 inbox

    onNotifCenterOpenChanged: if (notifCenterOpen) { quickSettingsOpen = false; calendarOpen = false }
    onQuickSettingsOpenChanged: if (quickSettingsOpen) { notifCenterOpen = false; calendarOpen = false }
    onCalendarOpenChanged: if (calendarOpen) { quickSettingsOpen = false; notifCenterOpen = false; wallpaperOpen = false }

    onWallpaperOpenChanged: if (wallpaperOpen) { quickSettingsOpen = false; notifCenterOpen = false; calendarOpen = false }

    function closeAll() {
        settingsOpen = false
        wallpaperOpen = false
        quickSettingsOpen = false; notifCenterOpen = false; launcherOpen = false
        overviewOpen = false; sessionOpen = false; calendarOpen = false
    }
    property bool locked: false   // lockscreen (next stage) reads this
}
