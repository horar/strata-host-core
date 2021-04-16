import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../"

LayoutContainer {

    property alias model: radioButtonObject.model
    property alias textColor: radioButtonObject.textColor     //Default: "black"
    property alias radioColor: radioButtonObject.radioColor   //Default: "black"
    property alias orientation: radioButtonObject.orientation //Default: Qt.Vertical
    property alias checkedIndex: radioButtonObject.checkedIndex  //Default: "1"
    property alias fontSizeMultiplier: radioButtonObject.fontSizeMultiplier  //Default: "1.0"
    property alias pixelSize : radioButtonObject.pixelSize
    property alias radioSize : radioButtonObject.radioSize      //Default: "25"
    property int index

    signal clicked ()

    SGRadioButton {
        id: radioButtonObject

        onClicked: {
            parent.index = index
            parent.clicked()
        }
    }
}

