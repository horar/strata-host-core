import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import "../../"

LayoutContainer {

    // pass through all properties
    property alias model: buttonStripObject.model
    readonly property alias count: buttonStripObject.count
    property alias exclusive: buttonStripObject.exclusive
    property alias orientation: buttonStripObject.orientation
    property alias checkedIndices: buttonStripObject.checkedIndices
    signal clicked ()

    SGButtonStrip {
        id: buttonStripObject
        onClicked: {
            parent.clicked()
        }
    }
}

