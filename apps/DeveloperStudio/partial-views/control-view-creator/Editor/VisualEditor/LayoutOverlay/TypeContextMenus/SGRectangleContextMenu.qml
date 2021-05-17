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
        id: positiveInputValidator
        regExp: /^-?[0-9]\d*(\.\d+)*/
    }

    RegExpValidator {
        id: radiusInputValidator
        regExp: /^-[+-]?[0-9]\d*(\.\d+)*/
    }

    ContextMenuButton {
        text: "Set Border Width"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.border.width
            menuLoader.item.textFieldProperty = "border.width"
            menuLoader.item.validator = positiveInputValidator
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter the border width. A width of 1 creates a thin line. For no line, use a width of 0 or a transparent color."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Border Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.parentProperty = "border.color"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.parentProperty = "color"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set radius"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.radius
            menuLoader.item.textFieldProperty = "radius"
            menuLoader.item.validator = positiveInputValidator
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter the corner radius used to draw a rounded rectangle. If radius is non-zero, the rectangle will be painted as a rounded rectangle, otherwise it will be painted as a normal rectangle"
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
