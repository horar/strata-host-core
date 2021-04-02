import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    // pass through all properties
    property int status: 6
    property color customColor: "white"
    property bool flatStyle: false


    SGStatusLight {
        id: statusLightObject
        status : parent.status
        customColor: parent.customColor
        flatStyle: parent.flatStyle
    }
}

