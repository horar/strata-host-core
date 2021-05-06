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
        text: "Set X Min"
        onClicked: {
            textDialog.open()
        }

    }

    TextPopup {
        id: textDialog

    }


//    ContextMenuButton {
//        text: "Set Y Min"

//    }


}
