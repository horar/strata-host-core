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
    signal accepted(string text)
    signal editingFinished(string text)

    SGSubmitInfoBox {
        id: infoObject
        fontSizeMultiplier: parent.fontSizeMultiplier

        onAccepted: parent.accepted(infoObject.text)
        onEditingFinished: parent.editingFinished(infoObject.text)

    }
}

