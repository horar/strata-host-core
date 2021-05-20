import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."
import "../LayoutPopupContext"

ColumnLayout {
    spacing: 1

    RegExpValidator {
        id: inputValidator
        regExp: /^[0-9_]*/
    }

    ContextMenuButton {
        text: "Set Orientation"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ComboBoxPopup.qml")
            menuLoader.active = true
            menuLoader.item.parentProperty = "orientation"
            menuLoader.item.open()
            menuLoader.item.label = "Select the divider orientation."
            contextMenu.close()
        }
    }
    ContextMenuButton {
        text: "Set RadioButton Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.parentProperty = "radioColor"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Text Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.parentProperty = "textColor"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set radioSize"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.textFieldProperty = "radioSize"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.radioSize
            menuLoader.item.open()
            menuLoader.item.intValidator.bottom = 0
            menuLoader.item.intValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.intValidator
            menuLoader.item.label = "Enter a radioSize. RadioSize can only contain a numbers."
            menuLoader.item.isString = false
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set fontSizeMultiplier"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.textFieldProperty = "fontSizeMultiplier"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.fontSizeMultiplier
            menuLoader.item.open()
            menuLoader.item.intValidator.bottom = 0
            menuLoader.item.intValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.intValidator
            menuLoader.item.label = "Enter a fontSizeMultiplier of the labels. FontSizeMultiplier can only contain a numbers."
            menuLoader.item.isString = false
            contextMenu.close()
        }
    }
}
