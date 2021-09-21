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
    property alias fontSizeMultiplier: sliderObject.fontSizeMultiplier
    property alias textColor:sliderObject.textColor
    property alias mirror: sliderObject.mirror
    property alias handleSize: sliderObject.handleSize
    property alias orientation: sliderObject.orientation
    property alias value: sliderObject.value
    property alias from: sliderObject.from
    property alias to: sliderObject.to
    property alias horizontal: sliderObject.horizontal
    property alias vertical: sliderObject.vertical
    property alias showTickmarks: sliderObject.showTickmarks
    property alias showLabels: sliderObject.showLabels
    property alias showInputBox: sliderObject.showInputBox
    property alias showToolTip: sliderObject.showToolTip
    property alias stepSize: sliderObject.stepSize
    property alias live: sliderObject.live
    property alias visualPosition: sliderObject.visualPosition
    property alias position: sliderObject.position
    property alias snapMode: sliderObject.snapMode
    property alias pressed: sliderObject.pressed
    property alias grooveColor: sliderObject.grooveColor
    property alias fillColor: sliderObject.fillColor

    property alias slider: sliderObject.slider
    property alias inputBox: sliderObject.inputBox
    property alias fromText: sliderObject.fromText
    property alias toText: sliderObject.toText
    property alias tickmarkRepeater: sliderObject.tickmarkRepeater
    property alias inputBoxWidth: sliderObject.inputBoxWidth
    property alias toolTip: sliderObject.toolTip
    property alias toolTipText: sliderObject.toolTipText
    property alias toolTipBackground: sliderObject.toolTipBackground
    property alias validatorObject: sliderObject.validatorObject
    property alias handleObject: sliderObject.handleObject
    property alias contextMenuEnabled: sliderObject.contextMenuEnabled

    signal userSet()
    signal moved()

    contentItem: SGSlider {
        id: sliderObject
        onMoved: parent.moved()
        onUserSet: parent.userSet()

    }
}

