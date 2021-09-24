/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    property alias textColor: comboBoxObject.textColor
    property alias indicatorColor: comboBoxObject.indicatorColor
    property alias borderColor: comboBoxObject.borderColor
    property alias borderColorFocused: comboBoxObject.borderColorFocused
    property alias boxColor: comboBoxObject.boxColor
    property alias dividers: comboBoxObject.dividers
    property alias model: comboBoxObject.model
    property alias currentIndex: comboBoxObject.currentIndex
    property alias currentText: comboBoxObject.currentText
    property alias placeholderText: comboBoxObject.placeholderText
    property alias fontSizeMultiplier: comboBoxObject.fontSizeMultiplier
    property alias textRole: comboBoxObject.textRole

    // private members for advanced customization
    property alias iconImage: comboBoxObject.iconImage
    property alias textField: comboBoxObject.textField
    property alias textFieldBackground: comboBoxObject.textFieldBackground
    property alias backgroundItem: comboBoxObject.backgroundItem
    property alias popupItem: comboBoxObject.popupItem
    property alias popupBackground: comboBoxObject.popupBackground

    signal activated()

    contentItem: SGComboBox {
         id: comboBoxObject
         onActivated: parent.activated()
    }
}

