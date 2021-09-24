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

    // pass through all properties
    property alias fontSizeMultiplier: switchObject.fontSizeMultiplier
    property alias handleColor: switchObject
    property alias textColor: switchObject.textColor
    property alias labelsInside: switchObject.labelsInside
    property alias pressed: switchObject.pressed
    property alias down: switchObject.down
    property alias checked: switchObject.checked
    property alias checkedLabel: switchObject.checkedLabel
    property alias uncheckedLabel: switchObject.uncheckedLabel
    property alias grooveFillColor: switchObject.grooveFillColor
    property alias grooveColor: switchObject.grooveColor

    signal released()
    signal canceled()
    signal clicked()
    signal toggled()
    signal press()
    signal pressAndHold()

    contentItem: SGSwitch {
        id: switchObject
        onReleased: parent.released()
        onCanceled: parent.canceled()
        onClicked: parent.clicked()
        onToggled: parent.toggled()
        onPressAndHold: parent.pressAndHold()
    }
}

