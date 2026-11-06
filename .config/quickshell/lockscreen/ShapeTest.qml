import QtQuick
import QtQuick.Window
import "ShapeList.js" as ShapeList

// Stage 3 test. Standalone window, does NOT lock the session, so it's safe.
// Run with: qs -p ~/.config/quickshell/lockscreen/ShapeTest.qml
// Delete this file once Stage 3 passes.
Window {
    id: win
    title: "Shape test"
    width: 900
    height: 760
    visible: true
    color: Colors.bg
    onClosing: Qt.quit()

    // Big 9-sided cookie: this is the clock shape.
    MShape {
        id: cookie
        x: 40
        y: 40
        size: 300
        shape: "Cookie9Sided"
        color: Colors.surface
    }

    Text {
        x: 40
        y: 350
        text: "Cookie9Sided @ 300px"
        color: Colors.sub
        font.pixelSize: 14
    }

    // Same cookie small, to check it stays crisp at password-char size.
    Row {
        x: 400
        y: 60
        spacing: 12
        Repeater {
            model: [16, 22, 32, 48]
            MShape {
                required property int modelData
                size: modelData
                shape: "Cookie9Sided"
                color: Colors.accent
            }
        }
    }

    // Morph test: click the big cookie to cycle through its look.
    MouseArea {
        x: cookie.x
        y: cookie.y
        width: cookie.width
        height: cookie.height
        onClicked: {
            const i = (ShapeList.all.indexOf(cookie.shape) + 1) % ShapeList.all.length;
            cookie.shape = ShapeList.all[i];
        }
    }

    Text {
        x: 400
        y: 130
        text: "Click the big shape to morph through all 35"
        color: Colors.sub
        font.pixelSize: 14
    }

    // All 35 shapes, coloured like the password characters will be.
    Grid {
        x: 400
        y: 180
        columns: 7
        spacing: 16
        Repeater {
            model: ShapeList.all
            MShape {
                required property string modelData
                required property int index
                size: 48
                shape: modelData
                color: Colors.charColors[index % Colors.charColors.length]
            }
        }
    }
}
