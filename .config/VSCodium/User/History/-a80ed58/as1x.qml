import Quickshell
import Quickshell.Io
import QtQuick

Scope{
    id: root

    property string command: ""
    property int interval: 3000
    property string valuee: ""

    Process{
        id: proc
        command: ["sh", "-c", root.command]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.value = this.text.trim()
        }
    }
    
    Timer{
        interval: root.interval
        running: true
        repeat: true
        onTrigerred: proc.running = true
    }

}