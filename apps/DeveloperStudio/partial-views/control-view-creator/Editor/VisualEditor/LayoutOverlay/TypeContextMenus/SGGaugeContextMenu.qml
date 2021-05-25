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
        text: "Set Min Value"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.text = layoutOverlayRoot.sourceItem.minimumValue
            menuLoader.item.sourceProperty = "minimumValue"
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter the minimum value of the gauge. Minimum value's can only contain positive/negtaive numbers."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Max Value"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.sourceProperty = "maximumValue"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.maximumValue
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter the maximum value of the gauge. Maximum value's can only contain positive/negtaive whole or decimal values."
            menuLoader.item.open()
            contextMenu.close()

        }
    }
    ContextMenuButton {
        text: "Set TickmarkStepSize"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.doubleValidator.bottom = 0
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.text = layoutOverlayRoot.sourceItem.tickmarkStepSize
            menuLoader.item.sourceProperty = "tickmarkStepSize"
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter the tickmarkStepSize value of the gauge. TickmarkStepSize's can only contain postive whole/decimal values."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Initial Value"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.value
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.sourceProperty = "value"
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter the initial value of the gauge. Initial value's can only positive/negtaive whole or decimal values."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Unit"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.unitText
            menuLoader.item.regExpValidator.regExp = /^[a-zA-Z0-9@./#&+-()_ ]*/
            menuLoader.item.validator = menuLoader.item.regExpValidator
            menuLoader.item.sourceProperty = "unitText"
            menuLoader.item.label = "Enter the unit of the gauge. Unit's can only numbers, letters and special characters. "
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
