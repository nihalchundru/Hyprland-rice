pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Persistent settings -> ~/.config/quickshell/m3/config.json
Singleton {
    id: root
    property alias mode: adapter.mode            // dark | light
    property alias scheme: adapter.scheme        // tonal-spot, content, expressive, fidelity, fruit-salad, monochrome, neutral, rainbow
    property alias barFloating: adapter.barFloating
    property alias dockAutoHide: adapter.dockAutoHide
    property alias terminal: adapter.terminal
    property alias tempUnit: adapter.tempUnit
    property alias pinned: adapter.pinned
    property alias clock24: adapter.clock24
    property alias fontFamily: adapter.fontFamily
    property alias fontScale: adapter.fontScale
    property alias motionScale: adapter.motionScale
    property alias workspaceCount: adapter.workspaceCount
    property alias barMedia: adapter.barMedia
    property alias barTray: adapter.barTray
    property alias barTitle: adapter.barTitle
    property alias barDate: adapter.barDate
    property alias weatherLocation: adapter.weatherLocation
    property alias cavaMethod: adapter.cavaMethod
    property alias lockNotifPreview: adapter.lockNotifPreview
    property alias dockMagnify: adapter.dockMagnify
    property alias widgetsEnabled: adapter.widgetsEnabled
    property alias widgetPos: adapter.widgetPos
    property alias widgetList: adapter.widgetList
    property alias widgetsLocked: adapter.widgetsLocked
    property alias widgetGrid: adapter.widgetGrid
    property alias widgetSnap: adapter.widgetSnap
    property alias widgetShowGrid: adapter.widgetShowGrid
    property alias todos: adapter.todos
    readonly property string debugMode: Quickshell.env("M3_DEBUG") || ""

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/m3/config.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => { if (error === FileViewError.FileNotFound) writeAdapter() }
        adapter: JsonAdapter {
            id: adapter
            property string mode: "dark"
            property string scheme: "tonal-spot"
            property bool barFloating: false
            property bool dockAutoHide: true
            property string terminal: "kitty"
            property string tempUnit: "F"
            property var pinned: ["kitty", "firefox"]
            property bool clock24: true
            property string fontFamily: "Roboto Flex"
            property real fontScale: 1.0
            property real motionScale: 1.0
            property int workspaceCount: 5
            property bool barMedia: true
            property bool barTray: true
            property bool barTitle: true
            property bool barDate: true
            property string weatherLocation: ""
            property string cavaMethod: "pulse"
            property bool lockNotifPreview: true
            property bool dockMagnify: true
            property bool widgetsEnabled: true
            property var widgetPos: ({})
            property var widgetList: "default"
            property bool widgetsLocked: false
            property int widgetGrid: 24
            property bool widgetSnap: true
            property bool widgetShowGrid: true
            property var todos: []
        }
    }
}
