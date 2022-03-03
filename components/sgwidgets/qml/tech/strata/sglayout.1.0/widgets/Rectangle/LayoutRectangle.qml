/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../"

LayoutContainer {

    property alias color: rect.color
    property alias border: rect.border
    property alias radius: rect.radius
    property alias gradient: rect.gradient

    contentItem: Rectangle {
        id: rect
    }
}

