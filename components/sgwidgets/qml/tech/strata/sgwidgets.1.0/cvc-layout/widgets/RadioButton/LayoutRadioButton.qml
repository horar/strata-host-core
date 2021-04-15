import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../"

LayoutContainer {

    property alias model: radioButtonObject.model
    property alias radioSize: radioButtonObject.radioSize
    property alias radioColor: radioButtonObject.radioColor
    property alias orientation: radioButtonObject.orientation
    property var index

    signal clicked ()

    SGRadioButton {
        id: radioButtonObject

        onClicked: {
            parent.index = index
            parent.clicked()
        }
    }
}

