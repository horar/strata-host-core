/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

import tech.strata.sgwidgets 1.0

Item {
    id: root
    visible: status !== "loaded"

    property string status

    Column {
        anchors {
            centerIn: root
        }
        spacing: 20

        AnimatedImage {
            source: "qrc:/images/loading.gif"
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            visible: root.status === "loading"
            playing: visible
        }

        SGIcon {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            source: "qrc:/sgimages/exclamation-circle.svg"
            iconColor: "lightgrey"
            height: 40
            width: 40
            visible: root.status === "error"
        }

        SGText {
            id: status
            color: "lightgrey"
            font.bold: true
            text: {
                switch (root.status) {
                case "loading":
                    return "Loading platform list..."
                case "error":
                    return "Failed to load platform list\nRestart Strata to retry"
                default:
                    return ""
                }
            }
            fontSizeMultiplier: 3
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
