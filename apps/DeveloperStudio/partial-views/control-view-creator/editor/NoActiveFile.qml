/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#ccc"

    SGIcon {
        anchors.centerIn: parent
        source: "qrc:/sgimages/strata-logo.svg"
        width: 400
        height: 400
    }
}
