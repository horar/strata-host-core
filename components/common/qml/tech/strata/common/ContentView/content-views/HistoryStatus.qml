/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtQuick.Controls 2.3

import tech.strata.theme 1.0

Rectangle {
    width: historyText.implicitWidth + height
    height: 14
    radius: height/2
    color: "green"
    visible: model.historyState !== "seen"

    property alias text: historyText.text

    Label {
        id: historyText
        anchors.centerIn: parent
        text: {
            if (model.historyState === "new_document") {
                return "NEW"
            }
            if (model.historyState === "different_md5") {
                return "UPDATED"
            }
            return ""
        }
        color: "white"
        font.bold: true
        font.pointSize: 10
    }
}
