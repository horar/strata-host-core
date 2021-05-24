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
            menuLoader.item.sourceProperty = "checkedLabel"
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.label = "Enter The Text.Text can contain only letters, numbers, underscores and spaces."
            menuLoader.item.open()
            contextMenu.close()
        }
    }
    ContextMenuButton {
        text: "Set PlaceholderText"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.placeholderText
            menuLoader.item.sourceProperty = "placeholderText"
            menuLoader.item.regExpValidator.regExp = /^[0-9-0-9]*/
            menuLoader.item.validator = menuLoader.item.regExpValidator
            menuLoader.item.label = "Enter The PlaceholderText .Text can contain only letters, numbers, underscores and spaces."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set TextColor"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "textColor"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set BoxColor"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "boxColor"
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
