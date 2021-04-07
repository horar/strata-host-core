import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import QtQml 2.12

import "../../"

LayoutContainer {

    // pass through all properties
    property alias fontSizeMultiplier: infoObject.fontSizeMultiplier
    property alias text: infoObject.text
    property alias horizontalAlignment: infoObject.horizontalAlignment
    property alias placeholderText: infoObject.placeholderText
    property alias readOnly: infoObject.readOnly
    property alias boxColor: infoObject.boxColor

    SGInfoBox {
        id: infoObject
    }


}

