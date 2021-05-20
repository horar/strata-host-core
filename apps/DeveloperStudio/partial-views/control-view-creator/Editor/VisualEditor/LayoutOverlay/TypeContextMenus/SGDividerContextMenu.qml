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
        regExp: /^[0-9]*/
    }

    ContextMenuButton {
        text: "Set Divider Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.parentProperty = "color"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Thickness"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.textFieldProperty = "thickness"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.thickness
            menuLoader.item.intValidator.bottom = 0
            menuLoader.item.intValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.intValidator
            menuLoader.item.open()
            menuLoader.item.label = "Enter the thickness for divider. Thickness can only contain integer value."
            menuLoader.item.isString = false
            contextMenu.close()
        }
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
}
