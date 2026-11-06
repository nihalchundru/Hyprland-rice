import QtQuick

// Reusable Circular Arc Gauge with icon and live percentage
Item {
    id: root

    property real value: 0.5 // 0.0 to 1.0
    property string iconType: "cpu" // "cpu", "temp", "ram", "disk"
    property string label: ""
    property color gaugeColor: Colors.accent

    implicitWidth: 80
    implicitHeight: 80

    Canvas {
        id: canvas
        anchors.fill: parent

        Connections {
            target: root
            function onValueChanged() { canvas.requestPaint(); }
            function onGaugeColorChanged() { canvas.requestPaint(); }
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            const cx = width / 2;
            const cy = height / 2;
            const radius = Math.min(cx, cy) - 8;
            const startAngle = 0.75 * Math.PI;
            const totalAngle = 1.5 * Math.PI;
            const endAngle = startAngle + totalAngle;

            // 1. Background Arc Track
            ctx.strokeStyle = Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.12);
            ctx.lineWidth = 3.5;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(cx, cy, radius, startAngle, endAngle, false);
            ctx.stroke();

            // 2. Active Arc
            const clamped = Math.max(0.0, Math.min(1.0, root.value));
            if (clamped > 0) {
                ctx.strokeStyle = root.gaugeColor;
                ctx.lineWidth = 3.5;
                ctx.beginPath();
                ctx.arc(cx, cy, radius, startAngle, startAngle + totalAngle * clamped, false);
                ctx.stroke();
            }

            // 3. Center Vector Icon
            ctx.strokeStyle = root.gaugeColor;
            ctx.fillStyle = root.gaugeColor;
            ctx.lineWidth = 1.6;

            if (root.iconType === "cpu") {
                // Microchip icon
                ctx.strokeRect(cx - 7, cy - 7, 14, 14);
                ctx.fillRect(cx - 4, cy - 4, 8, 8);
                // Pins
                ctx.strokeRect(cx - 5, cy - 10, 2, 3);
                ctx.strokeRect(cx + 3, cy - 10, 2, 3);
                ctx.strokeRect(cx - 5, cy + 7, 2, 3);
                ctx.strokeRect(cx + 3, cy + 7, 2, 3);
                ctx.strokeRect(cx - 10, cy - 5, 3, 2);
                ctx.strokeRect(cx - 10, cy + 3, 3, 2);
                ctx.strokeRect(cx + 7, cy - 5, 3, 2);
                ctx.strokeRect(cx + 7, cy + 3, 3, 2);
            } else if (root.iconType === "temp") {
                // Thermometer icon
                ctx.beginPath();
                ctx.arc(cx - 2, cy + 4, 4.5, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.strokeRect(cx - 4, cy - 8, 4, 9);
                ctx.beginPath();
                ctx.arc(cx - 2, cy - 8, 2, Math.PI, 0, false);
                ctx.stroke();
                // Degree mark
                ctx.strokeRect(cx + 4, cy - 7, 3, 3);
                ctx.strokeRect(cx + 4, cy - 2, 6, 1.5);
                ctx.strokeRect(cx + 4, cy + 2, 4, 1.5);
            } else if (root.iconType === "ram") {
                // RAM stick icon
                ctx.strokeRect(cx - 9, cy - 6, 18, 12);
                ctx.fillRect(cx - 7, cy - 4, 4, 8);
                ctx.fillRect(cx - 1, cy - 4, 4, 8);
                ctx.fillRect(cx + 5, cy - 4, 4, 8);
            } else if (root.iconType === "disk") {
                // Hard Drive icon
                ctx.strokeRect(cx - 8, cy - 9, 16, 18);
                ctx.beginPath();
                ctx.arc(cx, cy - 1, 4, 0, 2 * Math.PI);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(cx, cy + 5, 1.2, 0, 2 * Math.PI);
                ctx.fill();
            }
        }
    }
}
