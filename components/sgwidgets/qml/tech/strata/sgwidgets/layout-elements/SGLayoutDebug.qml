/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

Rectangle {
    color: Qt.rgba(Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, 1)
    opacity: .2
    anchors {
        fill: parent
    }
    z:1
    visible: false
}
