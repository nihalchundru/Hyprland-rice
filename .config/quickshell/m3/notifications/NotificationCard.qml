import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.tokens
import qs.services
import qs.components

Rectangle {
    id: root
    required property var notif
    signal closeRequested()
    signal activated()

    readonly property bool critical: notif && notif.urgency === NotificationUrgency.Critical
    readonly property color fg: critical ? M3Colors.fgErrorContainer : M3Colors.fgSurface
    readonly property color fgVar: critical ? M3Colors.fgErrorContainer : M3Colors.fgSurfaceVariant
    readonly property string iconSource: {
        if (!notif) return ""
        if (notif.image) return notif.image
        if (!notif.appIcon) return ""
        return notif.appIcon.startsWith("/") ? "file://" + notif.appIcon : Quickshell.iconPath(notif.appIcon, "dialog-information")
    }
    readonly property var extraActions: {
        const out = []
        if (!notif) return out
        const a = notif.actions
        for (let i = 0; i < a.length; i++) if (a[i].identifier !== "default") out.push(a[i])
        return out
    }

    radius: 24
    color: critical ? M3Colors.errorContainer : M3Colors.surfaceContainerHigh
    implicitHeight: content.implicitHeight + 28
    ColorBehavior on color {}

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const a = root.notif.actions
            for (let i = 0; i < a.length; i++) if (a[i].identifier === "default") a[i].invoke()
            root.activated()
        }
    }

    RowLayout {
        id: content
        x: 14; y: 14
        width: parent.width - 28
        spacing: 12

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 40; Layout.preferredHeight: 40
            radius: 20
            color: M3Colors.primaryContainer
            Image {
                visible: root.iconSource !== ""
                anchors.fill: parent; anchors.margins: 6
                source: root.iconSource
                fillMode: Image.PreserveAspectFit
                sourceSize.width: 64; sourceSize.height: 64
            }
            Icon { visible: root.iconSource === ""; anchors.centerIn: parent; name: "notifications"; size: 22; color: M3Colors.fgPrimaryContainer; fill: 1 }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            RowLayout {
                Layout.fillWidth: true
                M3Text { Layout.fillWidth: true; elide: Text.ElideRight; text: root.notif.appName; role: M3Type.labelMedium; color: root.fgVar }
                M3Text { text: Notifs.ago(root.notif.id); role: M3Type.labelSmall; color: root.fgVar }
            }
            M3Text { Layout.fillWidth: true; text: root.notif.summary; role: M3Type.titleSmall; color: root.fg; wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight }
            M3Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.notif.body
                textFormat: Text.StyledText
                role: M3Type.bodyMedium
                color: root.fgVar
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
            }
            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 6
                visible: root.extraActions.length > 0
                spacing: 8
                Repeater {
                    model: root.extraActions
                    M3Button {
                        required property var modelData
                        text: modelData.text; variant: "tonal"; size: "xs"
                        onClicked: { modelData.invoke(); root.activated() }
                    }
                }
            }
        }

        M3Button { Layout.alignment: Qt.AlignTop; icon: "close"; variant: "text"; size: "xs"; onClicked: root.closeRequested() }
    }
}
