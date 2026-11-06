import QtQuick
import QtQuick.Effects
import Quickshell
import "."

// Blurred wallpaper background with subtle indigo scrim for Deck lockscreen
Item {
    id: root

    readonly property string imagePath: Quickshell.env("HOME") + "/.config/rofi/images/a.png"

    clip: true

    Rectangle {
        anchors.fill: parent
        color: Colors.bg
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file://" + root.imagePath
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        sourceSize.width: root.width
        sourceSize.height: root.height
        visible: false

        onStatusChanged: if (status === Image.Error)
            console.warn("[lockscreen3] could not load wallpaper:", root.imagePath)
    }

    MultiEffect {
        source: wallpaper
        anchors.fill: parent
        visible: wallpaper.status === Image.Ready
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        blurMultiplier: 1.0
        autoPaddingEnabled: false
        scale: 1.06
    }

    // Scrim overlay for deck readability
    Rectangle {
        anchors.fill: parent
        color: Colors.bg
        opacity: 0.58
    }
}
