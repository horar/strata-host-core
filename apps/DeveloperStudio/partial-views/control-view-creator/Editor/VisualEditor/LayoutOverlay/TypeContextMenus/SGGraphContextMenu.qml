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
            textDialog.open()
        }
    }

    TextPopup {
        id: titleDialog
        textFieldProperty: "title:"
    }

    ContextMenuButton {
        text: "Set X Title"
        onClicked: {
            xtitleDialog.open()
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
