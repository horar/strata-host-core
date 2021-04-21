import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import QtQml 2.12

import "../../"

LayoutContainer {

    // pass through all properties
    property alias fontSizeMultiplier: infoObject.fontSizeMultiplier
    property alias text: infoObject.text
    property alias placeholderText: infoObject.placeholderText
    property alias readOnly: infoObject.readOnly
    property alias textColor: infoObject.textColor
    property alias textPadding: infoObject.textPadding
    property alias invalidTextColor: infoObject.invalidTextColor
    property alias boxColor: infoObject.boxColor
    property alias boxBorderColor: infoObject.boxBorderColor
    property alias boxBorderWidth:  infoObject.boxBorderWidth
    property alias unit: infoObject.unit
    property alias validator: infoObject.validator
    property alias horizontalAlignment: infoObject.horizontalAlignment
    property alias contextMenuEnabled: infoObject.contextMenuEnabled

    signal accepted()
    signal editingFinished()

    contentItem: SGInfoBox {
        id: infoObject
        onAccepted: parent.accepted()
        onEditingFinished: parent.editingFinished()
    }
}

