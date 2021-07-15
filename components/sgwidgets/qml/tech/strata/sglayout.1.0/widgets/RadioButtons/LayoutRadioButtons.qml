import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../"

LayoutContainer {

    property alias model: radioButtonObject.model
    property alias textColor: radioButtonObject.textColor     //Default: "black"
    property alias radioColor: radioButtonObject.radioColor   //Default: "black"
    property alias orientation: radioButtonObject.orientation //Default: Qt.Vertical
    property alias fontSizeMultiplier: radioButtonObject.fontSizeMultiplier  //Default: "1.0"
    property alias pixelSize : radioButtonObject.pixelSize
    property alias radioSize : radioButtonObject.radioSize      //Default: "25"
    /* Holds indexes of checked buttons in power of 2 format:
       for example:
       0         - no button checked
       1 = 2^0   - first button checked
       2 = 2^1   - second button checked
       4 = 2^2   - third button checked
       8 = 2^3   - fourth button checked
       16  = 2^4 - fifth button checked
    */
    property alias checkedIndex: radioButtonObject.checkedIndex  //Default: "1"

    signal clicked (int index)

    contentItem: SGRadioButtons {
        id: radioButtonObject

        onClicked: {
            parent.clicked(index)
        }
    }
}

