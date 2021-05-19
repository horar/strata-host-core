import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."
import "../LayoutPopupContext"

ColumnLayout {
    spacing: 1

//    RegExpValidator {
//        id: inputValidator
//        regExp: /^[+-]?[0-9]*/
//    }

//    DoubleValidator {
//        id: positiveInputValidator
//        bottom:  -2147483647
//        top: 2147483647
//    }



//    //    RegExpValidator {
//    //        id: positiveInputValidator
//    //        regExp: /^-?[0-9]\d*(\.\d+)*/
//    //    }
//    RegExpValidator {
//        id: specialInputValidator
//        regExp: /^[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]*$/
//    }



    ContextMenuButton {
        text: "Set Min Value"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/SpinBoxPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.minimumValue
            menuLoader.item.decimals = 0
            menuLoader.item.textFieldProperty = "minimumValue"
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter the minimum value of the gauge."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Max Value"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/SpinBoxPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.maximumValue
            menuLoader.item.textFieldProperty = "maximumValue"
            menuLoader.item.isString = false
            menuLoader.item.label = "Select the maximum value of the gauge"
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
            menuLoader.item.textFieldProperty = "tickmarkStepSize"
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter the tickmarkStepSize value of the gauge.Text can only contain decimal values."
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
            menuLoader.item.textFieldProperty = "value"
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter the Initial value of the gauge.Text can only numbers, letters and any special characters. "
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
            menuLoader.item.textFieldProperty = "unitText"
            menuLoader.item.label = "Enter the unit of the gauge. Text can only numbers, letters and any special characters. "
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
