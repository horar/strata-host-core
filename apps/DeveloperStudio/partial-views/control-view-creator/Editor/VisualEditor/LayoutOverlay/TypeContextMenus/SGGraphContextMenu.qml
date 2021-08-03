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
        text: "Set Title"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.title
            menuLoader.item.sourceProperty = "title"
            menuLoader.item.label = "Enter graph's title."
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
            menuLoader.item.sourceProperty = "xTitle"
            menuLoader.item.label = "Enter graph's X Title."
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
            menuLoader.item.sourceProperty = "yTitle"
            menuLoader.item.label = "Enter graph's Y Title."
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
            menuLoader.item.sourceProperty = "xMin"
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            menuLoader.item.label = "Enter graph's X Minimum. Must be a whole or decimal number."
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
            menuLoader.item.sourceProperty = "xMax"
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.label = "Enter graph's X Maximum. Must be a whole or decimal number."
            menuLoader.item.open()
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Y Min"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.yMin
            menuLoader.item.sourceProperty = "yMin"
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            menuLoader.item.label = "Enter graph's Y Minimum. Must be a whole or decimal number."
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
            menuLoader.item.sourceProperty = "yMax"
            menuLoader.item.doubleValidator.bottom = -2147483647
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.label = "Enter graph's Y Maximum. Must be a whole or decimal number."
            menuLoader.item.open()
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set GridColor"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.color = layoutOverlayRoot.sourceItem.gridColor
            menuLoader.item.sourceProperty = "gridColor"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Show/hide X Grid"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/SwitchPopup.qml")
            menuLoader.active = true
            menuLoader.item.switchChecked = layoutOverlayRoot.sourceItem.xGrid
            menuLoader.item.label = "Toggle switch to show/hide X Grid"
            menuLoader.item.sourceProperty = "xGrid"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Show/hide Y Grid"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/SwitchPopup.qml")
            menuLoader.active = true
            menuLoader.item.switchChecked = layoutOverlayRoot.sourceItem.yGrid
            menuLoader.item.label = "Toggle switch to show/hide Y Grid"
            menuLoader.item.sourceProperty = "yGrid"
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
