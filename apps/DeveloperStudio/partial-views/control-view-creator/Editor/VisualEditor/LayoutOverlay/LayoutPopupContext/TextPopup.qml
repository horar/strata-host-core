import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."


Popup {
    id: textDialog
    anchors.centerIn: Overlay.overlay
    modal: true
    property var textFieldProperty

    onClosed: contextMenu.close()


    Column {
        spacing: 20
        SGText {
            text: "Set Text"
            fontSizeMultiplier: 1.3
        }
        SGTextField {
            id: textContainer
         onAccepted: {
             visualEditor.fileContents = visualEditor.functions.replaceObjectPropertyValueInString(layoutOverlayRoot.layoutInfo.uuid, textFieldProperty , '"' + textContainer.text + '"')
             visualEditor.functions.saveFile()
             contextMenu.close()
         }
        }
    }
}


