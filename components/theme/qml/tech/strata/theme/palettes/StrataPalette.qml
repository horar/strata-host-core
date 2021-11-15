/*
 * Copyright (c) 2018-2021 onsemi.
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

    readonly property color green:          "#53b948"
    readonly property color dark:           "#252627"
    readonly property color darkGray:       "#66686A"
    readonly property color gray:           "#a7a9ac"
    readonly property color lightGray:      "#d3d4d6"
    readonly property color white:          "#ffffff"
    readonly property color black:          "#000000"
    readonly property color orange:         "#f57900"
    readonly property color red:            "#cc0000"
    readonly property color darkBlue:       "#2d5282"
    readonly property color lightBlue:      "#5b8fcb"
    readonly property color error:          red
    readonly property color warning:        orange
    readonly property color success:        "#28a745"
    readonly property color highlight:      lightBlue
    readonly property color onsemiOrange:   "#E97D2E"
    readonly property color onsemiHighlight:"#276990"
    readonly property color onsemiDark:     "#3a4d54"
}
