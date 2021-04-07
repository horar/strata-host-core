import QtQuick 2.12
import tech.strata.sgwidgets 1.0
import QtQuick.Layouts 1.12
import QtQml 2.12

import "../../"

LayoutContainer {

    // pass through all properties
    property alias fontSizeMultiplier: infoObject.fontSizeMultiplier
    property alias validator: infoObject.validator
    property alias text: infoObject.text
    property alias horizontalAlignment: infoObject.horizontalAlignment
    property alias placeholderText: infoObject.placeholderText
    property alias readOnly: infoObject.readOnly
    property alias boxColor: infoObject.boxColor
    property alias infoBoxObject: infoObject.infoBoxObject
    property alias floatValue: infoObject.floatValue
    property alias intValue: infoObject.intValue
    signal accepted(string text)
    signal editingFinished(string text)

    SGSubmitInfoBox {
        id: infoObject
        onAccepted: parent.accepted(infoObject.text)
        onEditingFinished: parent.editingFinished(infoObject.text)
        Component.onCompleted: {
            infoBoxObject.Layout.fillHeight = true

        }

    }
}

