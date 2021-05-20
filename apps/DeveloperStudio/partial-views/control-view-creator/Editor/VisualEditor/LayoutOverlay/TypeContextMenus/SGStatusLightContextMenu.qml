import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."
import "../LayoutPopupContext"

ColumnLayout {
    spacing: 1

    ContextMenuButton {
        text: "Set StatusLight"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ComboBoxPopup.qml")
            menuLoader.active = true
            menuLoader.item.parentProperty = "status"
            menuLoader.item.model = ["SGStatusLight.Yellow","SGStatusLight.Green", "SGStatusLight.Blue", "SGStatusLight.Orange", "SGStatusLight.Red"]
            menuLoader.item.open()
            menuLoader.item.label = "Select the color of the status light."
            contextMenu.close()
        }
    }
}
