import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    // pass through all properties
    property alias iconColor: icon.iconColor
    property alias source: icon.source

    SGIcon {
        id: icon
    }
}

