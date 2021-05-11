import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."

Item {
    property string parentProperty
    function open() {
        colorDialog.open()
    }
    ColorDialog {
        id: colorDialog
        title: "Please choose a color"
        onAccepted: {
            visualEditor.fileContents = visualEditor.functions.replaceObjectPropertyValueInString(layoutOverlayRoot.layoutInfo.uuid, parent.parentProperty, '"' + colorDialog.color + '"')
            visualEditor.functions.saveFile()
            contextMenu.close()
        }
        onRejected: {
            contextMenu.close()
        }
    }
}
