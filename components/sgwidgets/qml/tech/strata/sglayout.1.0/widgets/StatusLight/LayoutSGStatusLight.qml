import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    // pass through all properties
    property alias status: statusLightObject.status
    property alias customColor: statusLightObject.customColor
    property alias flatStyle: statusLightObject.flatStyle

    enum IconStatus {
        Blue,
        Green,
        Red,
        Yellow,
        Orange,
        CustomColor,
        Off
    }

    contentItem: SGStatusLight {
        id: statusLightObject
    }
}

