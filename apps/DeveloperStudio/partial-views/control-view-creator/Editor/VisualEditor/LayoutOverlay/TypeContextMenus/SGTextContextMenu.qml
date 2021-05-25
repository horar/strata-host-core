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
        text: "Set Text"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "text"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.text
            menuLoader.item.regExpValidator.regExp = /^[a-z_ ][a-zA-Z0-9@./#&+-()_ ]*/
            menuLoader.item.validator = menuLoader.item.regExpValidator
            menuLoader.item.label = "Enter the text. Text can contain only letters, numbers, and special characters."
            menuLoader.item.open()
            contextMenu.close()
        }
    }
    ContextMenuButton {
        text: "Set Text Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "color"
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
