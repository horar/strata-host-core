import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."

ColorDialog {
    id: colorDialog
    title: "Please choose a color"

    property string parentProperty

    onAccepted: {
        visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, parentProperty, '"' + colorDialog.color + '"')
    }

    onRejected: {
        menuLoader.active = false
    }

}

