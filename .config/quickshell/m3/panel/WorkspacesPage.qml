import QtQuick
import QtQuick.Layouts
import qs.tokens
import qs.services
import qs.overview

Page {
    id: page
    OverviewView {
        anchors.fill: parent
        live: page.active && UiState.calendarOpen
        onPicked: UiState.calendarOpen = false
    }
}
