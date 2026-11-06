pragma Singleton

import Quickshell

// Everything you're likely to want to change lives here.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME") ? Quickshell.env("HOME") : "/home"
    readonly property string user: Quickshell.env("USER") ? Quickshell.env("USER") : "user"

    // ---- wallpaper ---------------------------------------------------------
    property string wallpaper: home + "/.config/rofi/images/a.png"
    // dims the wallpaper behind the UI so text stays readable over a busy image
    property real wallpaperScrim: 0.45

    // ---- weather -----------------------------------------------------------
    property bool weatherEnabled: true
    // Set these to your own coordinates (any two decimal values work).
    property real latitude: 51.5072
    property real longitude: -0.1276
    property int weatherRefreshMinutes: 15

    // ---- authentication ----------------------------------------------------
    // PAM uses the `quickshell` config file inside the `pam` folder that ships
    // next to this config (PamContext resolves relative paths against this
    // file's directory).
    property string pamConfig: "quickshell"
    property string pamDirectory: "pam"

    // ---- lock behaviour ----------------------------------------------------
    property int maxPasswordLength: 24
    // Set true to lock the moment the shell starts. See the README: if PAM
    // isn't wired up yet this will lock you out of the session.
    property bool lockOnStart: false
}
