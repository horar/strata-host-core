/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.3

import tech.strata.sgwidgets 1.0

Rectangle {
    id: loadError
    anchors {
        fill: parent
    }
    color: "#ddd"

    property alias error_intro: errorIntro.text
    property alias error_message: error.text

    ColumnLayout {   
        anchors {
            fill: loadError
            margins: 20
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: false
            Layout.fillWidth: false
            Layout.maximumHeight: parent.height
            Layout.maximumWidth: parent.width
            spacing: 15

            SGText {
                id: errorIntro
                color: "#666"
                font.bold: true
                fontSizeMultiplier: 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Failed to load platform user interface: "
            }

            SGText {
                id: error
                color: "#666"
                elide: Text.ElideRight
                fontSizeMultiplier: 1.5
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: Text.Wrap
            }
        }
    }
}
