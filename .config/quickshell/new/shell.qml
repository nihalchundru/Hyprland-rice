import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Networking


PanelWindow {
    id: bar
    anchors {
        top: true
        left: true
        right: true

    }




    


    implicitHeight: 37
    implicitWidth: 40



    
    Rectangle {
        anchors.fill: parent
        color: "#000000"

        Text {
            id: yeyyeysjspodjaopdjpasojdsaojdaspodjpaosdjaspodjaspodjaspodjapodsjosapdjposadjpaodj
            text: "CLick Me for free virus"
            anchors.left: parent.left
            color: "#F5F5DC"
        }



        Text {
            id: clock
            anchors.centerIn: parent
            color: "#F5F5DC"
            font.pixelSize: 15
            font.family: "SF Pro Display"

            Process {
                id: timeProc

                command: ["date", "+%I:%M %p  %a %b %d"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: clock.text = this.text
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat:true 

                onTriggered: timeProc.running = true
            }
        }
    }
}