import QtQuick
import "../core"
import "../components"

Item {
    id: root

    readonly property bool open: LayoutStore.editMode && LayoutStore.panelOpen

    width: 360
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    x: open ? parent.width - width : parent.width + 8
    Behavior on x { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

    Component { id: libraryC;    LibraryTab {} }
    Component { id: propertiesC; PropertiesTab {} }
    Component { id: styleC;      StyleTab {} }
    Component { id: profilesC;   ProfilesTab {} }

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        anchors.rightMargin: 16
        radius: 22
        color: Qt.alpha(Theme.card, 0.97)
        border.width: 1
        border.color: Qt.alpha(Theme.onSurface, 0.08)

        // swallows clicks so they don't deselect, and drops focus from text fields
        MouseArea {
            anchors.fill: parent
            onPressed: LayoutStore.focusEditor()
        }

        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 56

            Txt {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: "Customize"
                font.pixelSize: 18
                font.weight: Font.Bold
            }
            Txt {
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: LayoutStore.activeProfile
                color: Theme.onSurfaceDim
                font.pixelSize: 11
            }
        }

        Row {
            id: tabs
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 6

            Repeater {
                model: ["Library", "Properties", "Style", "Profiles"]

                Rectangle {
                    required property string modelData
                    required property int index

                    width: (tabs.width - 18) / 4
                    height: 32
                    radius: 12
                    color: LayoutStore.panelTab === index ? Theme.accent : Theme.cardAlt
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Txt {
                        anchors.centerIn: parent
                        text: parent.modelData
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: LayoutStore.panelTab === parent.index
                            ? Theme.onAccent : Theme.onSurfaceDim
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: LayoutStore.panelTab = parent.index
                    }
                }
            }
        }

        Flickable {
            id: flick
            anchors.top: tabs.bottom
            anchors.topMargin: 14
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.bottomMargin: 16
            clip: true
            contentWidth: width
            contentHeight: tabLoader.height
            boundsBehavior: Flickable.StopAtBounds

            Loader {
                id: tabLoader
                width: flick.width
                sourceComponent: [libraryC, propertiesC, styleC, profilesC][LayoutStore.panelTab]
            }
        }
    }
}