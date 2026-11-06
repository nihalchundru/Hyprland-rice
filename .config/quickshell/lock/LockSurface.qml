import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// One of these exists per monitor while the session is locked.
//
// The root MUST be a WlSessionLockSurface -- WlSessionLock requires it.
WlSessionLockSurface {
    id: surface

    // Opaque base colour. An explicit `color` beats a transparent window here:
    // transparent lock surfaces behave oddly on some compositors, and the
    // wallpaper Image covers this anyway.
    color: M3Theme.palette.surface

    Component.onCompleted: {
        // Start the frame clock and reset any error left over from last lock.
        TimeSource.active = true;
        Auth.reset();
        password.forceFocus();
    }

    Component.onDestruction: TimeSource.active = false

    // ------------------------------------------------------------- background
    Image {
        anchors.fill: parent
        source: "file://" + Config.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }

    // Material scrim, so text stays legible over a busy wallpaper.
    Rectangle {
        anchors.fill: parent
        color: M3Theme.palette.scrim
        opacity: Config.wallpaperScrim
    }

    // Click anywhere to bring focus back to the password box. Declared before
    // the widgets so they sit above it and still receive their own clicks.
    MouseArea {
        anchors.fill: parent
        onClicked: password.forceFocus()
    }

    // ------------------------------------------------------------- header
    Item {
        id: userPill

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 40
        width: userLabel.implicitWidth + 44
        height: 48

        M3Shape {
            anchors.fill: parent
            kind: "pill"
            fillColor: M3Theme.palette.surfaceContainerHigh
        }

        Text {
            id: userLabel
            anchors.centerIn: parent
            text: Config.user + "  ·  locked"
            color: M3Theme.palette.onSurface
            font.family: M3Theme.font
            font.pixelSize: M3Theme.labelLarge
        }
    }

    // ------------------------------------------------------------- weather
    WeatherWidget {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        visible: Config.weatherEnabled
    }

    // ------------------------------------------------------------- media
    MediaWidget {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 56
    }

    // ------------------------------------------------------------- centre
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24

        AnalogClock {
            Layout.alignment: Qt.AlignHCenter
            diameter: Math.max(200, Math.min(surface.width, surface.height) * 0.30)
        }

        DigitalTime {
            Layout.alignment: Qt.AlignHCenter
        }

        PasswordField {
            id: password
            Layout.alignment: Qt.AlignHCenter
            onSubmitted: (pw) => Auth.submit(pw)
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 420
            text: Auth.message !== ""
                ? Auth.message
                : "press enter to unlock"
            color: Auth.messageIsError
                ? M3Theme.palette.error
                : M3Theme.palette.onSurfaceVariant
            font.family: M3Theme.font
            font.pixelSize: M3Theme.bodyMedium
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
