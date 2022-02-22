/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.0

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

Rectangle {
    id: errorAndWarningCountDisplay
    anchors.top:parent.top
    anchors.left: parent.left
    anchors.leftMargin: 5
    anchors.topMargin: 5
    width: parent.width
    height: width
    radius: 25
    color: type === "error" ? Theme.palette.error : Theme.palette.warning
    visible: !isConsoleLogOpen && count > 0 && parent.enabled

    property int count: 0
    property string type: ""

    SGText {
        anchors.fill: errorAndWarningCountDisplay
        color: "white"
        text: count > 99 ? "99+" : count
        font.bold: true
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
