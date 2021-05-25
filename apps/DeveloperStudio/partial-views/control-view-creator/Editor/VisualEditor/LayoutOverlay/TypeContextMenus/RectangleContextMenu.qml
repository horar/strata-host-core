import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."

ColumnLayout {
    spacing: 1

    ContextMenuButton {
        text: "Set Color"
        onClicked: {
            colorDialog.open()
        }
    }

    ColorDialog {
        id: colorDialog
        title: "Please choose a color"

        onAccepted: {
            visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, "color", '"' + colorDialog.color + '"')
            contextMenu.close()
        }

        onRejected: {
            contextMenu.close()
        }
    }
}
