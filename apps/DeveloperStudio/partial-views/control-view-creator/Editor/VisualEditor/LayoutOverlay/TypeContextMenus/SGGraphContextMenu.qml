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
        regExp: /^[a-zA-Z0-9_]*/
    }
    RegExpValidator {
        id: numberRange
        regExp: /^[+-]?[0-9]*/
    }

    ContextMenuButton {
        text: "Set Title"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.title
            menuLoader.item.textFieldProperty = "title"
            menuLoader.item.label = "Enter graph's title. Title's can contain only letters, numbers and underscores."
            menuLoader.item.open()
            contextMenu.close()
        }
    }


    ContextMenuButton {
        text: "Set X Title"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.xTitle
            menuLoader.item.textFieldProperty = "xTitle"
            menuLoader.item.validator = inputValidator
            menuLoader.item.label = "Enter graph's X Title. X Title's can contain only letters, numbers and underscores."
            menuLoader.item.open()
            contextMenu.close()
        }
    }


    ContextMenuButton {
        text: "Set Y Title"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.yTitle
            menuLoader.item.textFieldProperty = "yTitle"
            menuLoader.item.validator = inputValidator
            menuLoader.item.label = "Enter graph's Y Title. Y Title's can contain only letters, numbers and underscores."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set X Min"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.xMin
            menuLoader.item.textFieldProperty = "xMin"
            menuLoader.item.validator = numberRange
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter graph's X Minimum. X Min can only contain numbers."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set X Max"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.xMax
            menuLoader.item.textFieldProperty = "xMax"
            menuLoader.item.validator = numberRange
            menuLoader.item.label = "Enter graph's X Maximum. X Max can only contain numbers."
            menuLoader.item.open()
            menuLoader.item.isString = false
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Y Min"

        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.yMin
            menuLoader.item.textFieldProperty = "yMin"
            menuLoader.item.validator = numberRange
            menuLoader.item.isString = false
            menuLoader.item.label = "Enter graph's Y Minimum. Y Min can only contain positive/negtative numbers."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Y Max"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.yMax
            menuLoader.item.textFieldProperty = "yMax"
            menuLoader.item.validator = numberRange
            menuLoader.item.label = "Enter graph's Y Maximum. Y max can only contain numbers."
            menuLoader.item.open()
            menuLoader.item.isString = false
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set GridColor"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.parentProperty = "gridColor"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Show/hide X Grid"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/SwitchPopup.qml")
            menuLoader.active = true
            menuLoader.item.textFieldProperty = "xGrid"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Show/hide Y Grid"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/SwitchPopup.qml")
            menuLoader.active = true
            menuLoader.item.textFieldProperty = "yGrid"
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
