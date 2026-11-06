import QtQuick

Rectangle {
    id: titlePill
    visible: barRoot.windowTitleDisplay !== ""
    
    width: Math.min(200, windowText.implicitWidth + 32)
    height: 38
    radius: height / 2
    color: barRoot.colors.bg2
    border.color: barRoot.colors.surface2
    border.width: 1
    antialiasing: true

    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    Text {
        id: windowText
        anchors.centerIn: parent
        width: parent.width - 24
        
        text: barRoot.windowTitleDisplay
        color: barRoot.colors.text
        font.bold: true
        font.pixelSize: 11
        font.family: "JetBrainsMono Nerd Font"
        
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }
}
