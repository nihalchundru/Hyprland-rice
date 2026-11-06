import QtQuick

// Pill-shaped password field with Material 3 expressive animations.
// Stage 6:
//  - Characters animate in (scale overshoot + rotation settle + fade)
//  - Characters animate out on delete (scale down + spin + fade + width collapse)
//  - Pill width transitions smoothly using the M3 expressive spatial curve
Rectangle {
    id: root

    required property LockContext context

    readonly property int count: context.chars.count

    // Layout numbers
    readonly property real pillHeight: 64
    readonly property real emptyWidth: 200
    readonly property real maxWidth: 640
    readonly property real padding: 24
    readonly property real spacing: 10
    readonly property real charSize: 24

    // Content width matches exactly the number of characters
    readonly property real contentWidth: count === 0 ? 0
        : count * (charSize + spacing) - spacing

    height: pillHeight
    // When empty, compact snug pill with "Password". As characters are added,
    // it smoothly expands based directly on character count.
    width: count === 0 ? emptyWidth
        : Math.min(maxWidth, Math.max(emptyWidth, contentWidth + 2 * padding))
    radius: height / 2
    color: Colors.surface

    border.width: 2
    border.color: context.showFailure ? Colors.red : "transparent"

    // Failure Shake Animation
    property real shakeOffset: 0
    transform: Translate { x: root.shakeOffset }

    SequentialAnimation {
        id: shakeAnim
        loops: 1
        NumberAnimation { target: root; property: "shakeOffset"; to: -14; duration: 45; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: 14; duration: 45; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: -10; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: 10; duration: 40; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: -4; duration: 35; easing.type: Easing.InOutQuad }
        NumberAnimation { target: root; property: "shakeOffset"; to: 0; duration: 35; easing.type: Easing.OutQuad }
    }

    Connections {
        target: root.context
        function onFailed() {
            shakeAnim.restart();
        }
    }

    // Material 3 Expressive spatial curve for pill width changes
    Behavior on width {
        NumberAnimation {
            duration: 350
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
        }
    }

    Behavior on border.color {
        ColorAnimation { duration: 180 }
    }

    // Placeholder while empty with smooth fade
    Text {
        anchors.centerIn: parent
        text: "Password"
        color: Colors.sub
        font.pixelSize: 20
        font.weight: Font.Medium
        opacity: root.count === 0 ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }
    }

    // Dynamic row holding character instances with entry/exit animations
    Row {
        id: charRow
        anchors.centerIn: parent
        spacing: 0 // Spacing is built into PasswordChar's width for seamless collapsing

        // Sync local visual items with context.chars
        // This ensures deletion animations can play before an item is destroyed!
        property var items: []

        function syncVisuals() {
            const modelCount = root.context.chars.count;

            // Add new character shapes
            while (items.length < modelCount) {
                const idx = items.length;
                const charData = root.context.chars.get(idx);
                const component = Qt.createComponent("PasswordChar.qml");
                if (component.status === Component.Ready) {
                    const obj = component.createObject(charRow, {
                        shapeName: charData.shapeName,
                        colorIdx: charData.colorIdx,
                        targetSize: root.charSize,
                        spacing: root.spacing
                    });
                    items.push(obj);
                }
            }

            // Remove deleted character shapes with exit animation
            while (items.length > modelCount) {
                const dyingItem = items.pop();
                if (dyingItem) {
                    dyingItem.removing = true;
                    dyingItem.removeFinished.connect(() => {
                        dyingItem.destroy();
                    });
                }
            }

            // Update sizing on existing characters
            for (let i = 0; i < items.length; ++i) {
                if (items[i]) {
                    items[i].targetSize = root.charSize;
                    items[i].spacing = root.spacing;
                }
            }
        }

        Connections {
            target: root.context.chars
            function onCountChanged() {
                charRow.syncVisuals();
            }
        }

        Component.onCompleted: charRow.syncVisuals()
    }
}
