import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    // pass through all properties
    property real fontSizeMultiplier: 1.0
    property alias text: infoObject.text
    property alias horizontalAlignment: infoObject.horizontalAlignment
    property alias placeholderText: infoObject.placeholderText
    property alias readOnly: infoObject.readOnly
    property alias boxColor: infoObject.boxColor

    SGInfoBox {
        id: infoObject
        fontSizeMultiplier: parent.fontSizeMultiplier
        //elide: Text.ElideRight
        // wrapMode: Text.Wrap
        //  text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
    }
}

