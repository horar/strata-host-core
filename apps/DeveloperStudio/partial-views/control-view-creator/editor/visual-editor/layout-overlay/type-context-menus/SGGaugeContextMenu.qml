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
        text: "Set Min Value"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.text = layoutOverlayRoot.sourceItem.minimumValue
            menuLoader.item.sourceProperty = "minimumValue"
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            menuLoader.item.label = "Enter the minimum value of the gauge. Must be a whole or decimal number."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Max Value"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.sourceProperty = "maximumValue"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.maximumValue
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            menuLoader.item.label = "Enter the maximum value of the gauge. Must be a whole or decimal number."
            menuLoader.item.open()
            contextMenu.close()

        }
    }
    ContextMenuButton {
        text: "Set TickmarkStepSize"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.doubleValidator.bottom = 0
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.text = layoutOverlayRoot.sourceItem.tickmarkStepSize
            menuLoader.item.sourceProperty = "tickmarkStepSize"
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            menuLoader.item.label = "Enter the tickmarkStepSize value of the gauge. Must be a positive whole or decimal number."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Initial Value"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.value
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.sourceProperty = "value"
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            menuLoader.item.label = "Enter the initial value of the gauge. Must be a whole or decimal number."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Unit"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.unitText
            menuLoader.item.sourceProperty = "unitText"
            menuLoader.item.label = "Enter the unit of the gauge."
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
