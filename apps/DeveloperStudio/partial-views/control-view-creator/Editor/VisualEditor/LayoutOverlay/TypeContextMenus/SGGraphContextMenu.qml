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
            renameLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
            renameLoader.active = true
            renameLoader.item.text = layoutOverlayRoot.sourceItem.title
            renameLoader.item.textFieldProperty = "title:"
            renameLoader.item.open()
            contextMenu.close()
        }
    }


    ContextMenuButton {
        text: "Set X Title"
        onClicked: {
        }
    }

    TextPopup {
        id: xtitleDialog
        textFieldProperty: "xTitle:"
    }

    ContextMenuButton {
        text: "Set Y Title"
    }

    TextPopup {
        id: ytitleDialog
        textFieldProperty: "yTitle:"
    }


}
