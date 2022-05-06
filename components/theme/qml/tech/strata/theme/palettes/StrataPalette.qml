/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQml 2.12

QtObject {
    id: mainPalette

    // palette used in mainly in Strata Developer Studio
    // color palette from Corporate Style Guide revision 14
    readonly property color onsemiOrange:   "#E97D2E"
    readonly property color onsemiDark:     "#465E66"
    readonly property color onsemiYellow:   "#DBAC17"
    readonly property color onsemiBrown:    "#A84626"
    readonly property color onsemiBlue:     "#3880F6"
    readonly property color onsemiDarkBlue: "#276990"
    readonly property color onsemiCyan:     "#009691"
    readonly property color onsemiLightBlue:"#34A6CA"

    readonly property color white:          "#ffffff"
    readonly property color black:          "#000000"

    // shades of gray used in Developer Studio
    readonly property color dark:           "#252627"
    readonly property color darkGray:       "#66686A"
    readonly property color gray:           "#a7a9ac"
    readonly property color lightGray:      "#d3d4d6"

    // colors for error, warning and success used from Tango palette
    readonly property color error:          "#cc0000"   // scarletRed2
    readonly property color warning:        "#f57900"   // orange2
    readonly property color success:        "#73d216"   // chameleon2
    readonly property color highlight:      onsemiBlue
}
