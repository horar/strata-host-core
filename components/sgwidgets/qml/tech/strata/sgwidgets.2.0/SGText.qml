/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Text {
    id: text

    readonly property color implicitColor: Theme.palette.black
    property real fontSizeMultiplier: 1.0

    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * fontSizeMultiplier
    color: implicitColor
}
