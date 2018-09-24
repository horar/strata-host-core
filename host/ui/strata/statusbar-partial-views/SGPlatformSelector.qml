import QtQuick 2.9
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/statusbar-partial-views"

SGComboBox {
    id: cbSelector

    textRole: "text"

    model: ListModel{} // temporary ListModel to init combobox without it complaining
    Component.onCompleted: {
        model = PlatformSelection.platformListModel
        currentIndex = Qt.binding( function() { return PlatformSelection.platformListModel.currentIndex })
    }

//    currentIndex: PlatformSelection.platformListModel.currentIndex
    TextMetrics { id: textMetrics }

    onActivated: { PlatformSelection.sendSelection(currentIndex) }
}
