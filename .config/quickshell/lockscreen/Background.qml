import QtQuick
import QtQuick.Effects
import Quickshell

// Blurred wallpaper + darkening scrim.
// The image is static, so the blur is computed once, not every frame.
Item {
    id: root

    readonly property string imagePath: Quickshell.env("HOME") + "/.config/rofi/images/a.png"

    clip: true

    // Shown if the image is missing, and underneath while it loads.
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
        // Decode at screen size, not full resolution, to save memory.
        sourceSize.width: root.width
        sourceSize.height: root.height
        visible: false // drawn through the blur below

        onStatusChanged: if (status === Image.Error)
            console.warn("[lockscreen] could not load wallpaper:", root.imagePath)
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
        // Blur pulls in transparent pixels at the edges, darkening them.
        // Scaling up slightly pushes those edges off-screen.
        scale: 1.08
    }

    // Scrim for contrast.
    Rectangle {
        anchors.fill: parent
        color: Colors.bg
        opacity: 0.35
    }
}
