import QtQuick

// Bottom carousel of lockscreen styles matching the reference screenshot
Item {
    id: root

    property string selectedStyleId: "veil"
    property string activeStyleId: "veil"

    signal styleSelected(string id)

    implicitHeight: 126
    implicitWidth: carouselRow.implicitWidth

    Row {
        id: carouselRow
        anchors.centerIn: parent
        spacing: 16

        // 1. Veil (Available)
        StyleCard {
            styleId: "veil"
            styleName: "Veil"
            isSelected: root.selectedStyleId === "veil"
            isInUse: root.activeStyleId === "veil"
            isAvailable: true
            onClicked: root.styleSelected("veil")
        }

        // 2. Bloom (Coming soon)
        StyleCard {
            styleId: "bloom"
            styleName: "Bloom"
            isSelected: root.selectedStyleId === "bloom"
            isInUse: root.activeStyleId === "bloom"
            isAvailable: false
            onClicked: root.styleSelected("bloom")
        }

        // 3. Orbit (Coming soon)
        StyleCard {
            styleId: "orbit"
            styleName: "Orbit"
            isSelected: root.selectedStyleId === "orbit"
            isInUse: root.activeStyleId === "orbit"
            isAvailable: false
            onClicked: root.styleSelected("orbit")
        }

        // 4. Darkroom (Coming soon)
        StyleCard {
            styleId: "darkroom"
            styleName: "Darkroom"
            isSelected: root.selectedStyleId === "darkroom"
            isInUse: root.activeStyleId === "darkroom"
            isAvailable: false
            onClicked: root.styleSelected("darkroom")
        }

        // 5. Deck (Available - Media Island)
        StyleCard {
            styleId: "deck"
            styleName: "Deck"
            isSelected: root.selectedStyleId === "deck"
            isInUse: root.activeStyleId === "deck"
            isAvailable: true
            onClicked: root.styleSelected("deck")
        }

        // 6. Tessera (Available - Cyberpunk Bento)
        StyleCard {
            styleId: "tessera"
            styleName: "Tessera"
            isSelected: root.selectedStyleId === "tessera"
            isInUse: root.activeStyleId === "tessera"
            isAvailable: true
            onClicked: root.styleSelected("tessera")
        }
    }
}
