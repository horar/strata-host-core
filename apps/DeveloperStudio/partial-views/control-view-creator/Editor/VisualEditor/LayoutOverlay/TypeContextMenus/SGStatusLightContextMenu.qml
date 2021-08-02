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
        text: "Set status"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ComboBoxPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "status"
            menuLoader.item.model = ["LayoutSGStatusLight.Yellow","LayoutSGStatusLight.Green", "LayoutSGStatusLight.Blue", "LayoutSGStatusLight.Orange", "LayoutSGStatusLight.Red", "LayoutSGStatusLight.Off"]
            menuLoader.item.open()
            menuLoader.item.label = "Select the color of the status light."
            contextMenu.close()
        }
    }
}
