import QtQuick
import "../core"
import "../components"

Item {
    id: root
    implicitHeight: col.implicitHeight

    Column {
        id: col
        width: parent.width
        spacing: 4

        Section { width: col.width; text: "Cards" }
        Slide {
            width: col.width
            label: "Corner radius"
            value: LayoutStore.radius
            from: 0; to: 40; step: 1
            suffix: " px"
            onEdited: v => LayoutStore.setStyle("radius", v)
        }
        Slide {
            width: col.width
            label: "Opacity"
            value: LayoutStore.cardOpacity
            from: 0.3; to: 1; step: 0.01
            displayScale: 100
            suffix: "%"
            onEdited: v => LayoutStore.setStyle("opacity", v)
        }
        Slide {
            width: col.width
            label: "Padding"
            value: LayoutStore.padding
            from: 4; to: 32; step: 1
            suffix: " px"
            onEdited: v => LayoutStore.setStyle("padding", v)
        }

        Section { width: col.width; text: "Grid" }
        Stepper {
            width: col.width
            label: "Cell size"
            value: LayoutStore.cell
            from: 48; to: 160; step: 4
            suffix: " px"
            onEdited: v => LayoutStore.setGrid("cell", v)
        }
        Stepper {
            width: col.width
            label: "Gap"
            value: LayoutStore.gap
            from: 0; to: 32; step: 2
            suffix: " px"
            onEdited: v => LayoutStore.setGrid("gap", v)
        }
        Stepper {
            width: col.width
            label: "Screen margin"
            value: LayoutStore.margin
            from: 0; to: 80; step: 4
            suffix: " px"
            onEdited: v => LayoutStore.setGrid("margin", v)
        }
        Txt {
            width: col.width
            wrapMode: Text.WordWrap
            text: "Widgets keep their grid cells. If a bigger grid pushes one off-screen, shrink it again to bring it back."
            color: Theme.onSurfaceDim
            font.pixelSize: 11
        }

        Section { width: col.width; text: "Font" }
        Field {
            width: col.width
            text: LayoutStore.fontFamily
            placeholder: "Font family"
            onCommitted: v => { if (v.trim().length > 0) LayoutStore.setStyle("font", v.trim()); }
        }

        Section { width: col.width; text: "Colors" }
        Txt {
            width: col.width
            wrapMode: Text.WordWrap
            text: (Theme.name !== "" ? "Theme: " + Theme.name + ". " : "")
                  + "Colors come from colors.json and update live."
            color: Theme.onSurfaceDim
            font.pixelSize: 12
        }
    }
}