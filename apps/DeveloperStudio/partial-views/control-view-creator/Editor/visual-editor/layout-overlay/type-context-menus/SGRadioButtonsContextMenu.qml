import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."
import "../layout-popup-context"

ColumnLayout {
    spacing: 1

    ContextMenuButton {
        text: "Set Orientation"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ComboBoxPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "orientation"
            menuLoader.item.open()
            menuLoader.item.label = "Select the orientation."
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set RadioButton Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "radioColor"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.radioColor
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Text Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "textColor"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.textColor
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set radioSize"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "radioSize"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.radioSize
            menuLoader.item.open()
            menuLoader.item.intValidator.bottom = 0
            menuLoader.item.intValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.intValidator
            menuLoader.item.label = "Enter a radioSize. Must be a whole number."
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set fontSizeMultiplier"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "fontSizeMultiplier"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.fontSizeMultiplier
            menuLoader.item.open()
            menuLoader.item.doubleValidator.bottom = 0
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.label = "Enter a fontSizeMultiplier of the labels. Must be a positive whole or decimal number."
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            contextMenu.close()
        }
    }
}
