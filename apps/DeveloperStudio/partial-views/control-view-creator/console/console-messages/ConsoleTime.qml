/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
    width: timeMetrics.width
    height:timeMetrics.height

    property alias time: msgTime.text
    property alias current: msgTime.enabled

    SGText {
        id: msgTime
        fontSizeMultiplier: fontMultiplier
        width: timeMetrics.width
        height: timeMetrics.height
        color: current ? "black" : "#777"
    }

    TextMetrics {
        id: timeMetrics
        text: "24:59:59.999"
        font.pixelSize: SGSettings.fontPixelSize * fontMultiplier
    }
}
// 24:59:59.999
//
