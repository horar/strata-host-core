import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../"

LayoutContainer {

    property alias model: radioButtonObject.model
    //property alias radioSize: radioButtonObject.radioSize
    property alias textColor: radioButtonObject.textColor
    property alias radioColor: radioButtonObject.radioColor
    property alias orientation: radioButtonObject.orientation
    property alias checkedIndex: radioButtonObject.checkedIndex
    property int index
    property alias fontSizeMultiplier: radioButtonObject.fontSizeMultiplier
    property alias pixelSize : radioButtonObject.pixelSize
    property alias radioSize : radioButtonObject.radioSize
    signal clicked ()

    SGRadioButton {
        id: radioButtonObject

        onClicked: {
            parent.index = index
            parent.clicked()
        }
    }
}

