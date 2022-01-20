/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.12

SplitView {
    id: splitView

    handleDelegate: Rectangle {
        implicitWidth: 1
        implicitHeight: 1

        color: styleData.pressed ? "#0066ff" : "#9d9d9d"
    }
}
