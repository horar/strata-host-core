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
        regExp: /^[a-z_][a-zA-Z0-9_]*/
    }

    ContextMenuButton {
        text: "Set Text"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.text
            menuLoader.item.textFieldProperty = "text: "
            menuLoader.item.validator = inputValidator
            menuLoader.item.label = "Enter the text.Text can contain only letters, numbers, underscores and spaces."
            menuLoader.item.open()
            contextMenu.close()
        }
    }
    ContextMenuButton {
        text: "Set Text Color"
        onClicked: {
            colorDialog.parentProperty = "textColor:"
            colorDialog.open()
        }
    }
    ContextMenuButton {
        text: "Set Background Color"
        onClicked: {
            colorDialog.parentProperty = "color:"
            colorDialog.open()
        }
    }

    ColorPopup {
        id: colorDialog
    }

}
