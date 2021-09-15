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
        text: "Set Checked Label"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.checkedLabel
            menuLoader.item.sourceProperty = "checkedLabel"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Unchecked Label"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.uncheckedLabel
            menuLoader.item.sourceProperty = "uncheckedLabel"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Groove Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "grooveColor"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.grooveColor
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Groove FillColor"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "grooveFillColor"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.grooveFillColor
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    ContextMenuButton {
        text: "Set Text Color"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "textColor"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.textColor
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
