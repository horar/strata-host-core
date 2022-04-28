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
    id: tangoPalette

    readonly property color chocolate1:     "#e9b96e"
    readonly property color chocolate2:     "#c17d11"
    readonly property color chocolate3:     "#8f5902"
    readonly property color plum1:          "#ad7fa8"
    readonly property color plum2:          "#75507b"
    readonly property color plum3:          "#5c3566"
    readonly property color scarletRed1:    "#ef2929"
    readonly property color scarletRed2:    "#cc0000"
    readonly property color scarletRed3:    "#a40000"
    readonly property color orange1:        "#fcaf3e"
    readonly property color orange2:        "#f57900"
    readonly property color orange3:        "#ce5c00"
    readonly property color butter1:        "#fce94f"
    readonly property color butter2:        "#edd400"
    readonly property color butter3:        "#c4a000"
    readonly property color chameleon1:     "#8ae234"
    readonly property color chameleon2:     "#73d216"
    readonly property color chameleon3:     "#4e9a06"
    readonly property color skyBlue1:       "#729fcf"
    readonly property color skyBlue2:       "#3465a4"
    readonly property color skyBlue3:       "#204a87"
    readonly property color aluminium1:     "#eeeeec"
    readonly property color aluminium2:     "#d3d7cf"
    readonly property color aluminium3:     "#babdb6"
    readonly property color slate1:         "#888a85"
    readonly property color slate2:         "#555753"
    readonly property color slate3:         "#2e3436"

    readonly property color white:          "#ffffff"
    readonly property color black:          "#000000"

    readonly property color error:          scarletRed2
    readonly property color warning:        orange2
    readonly property color success:        chameleon2
    readonly property color highlight:      "#0066ff"
    readonly property color selectedText:   Qt.lighter(highlight, 1.2)
    readonly property color componentBorder: "#bdbdbd"
    readonly property color componentBase:  white

}
