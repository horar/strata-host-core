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
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {
    id: splashScreen
    anchors {
        fill: parent
    }

    property int exitStatus: -1
    property int exitCode: -1

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/images/grey-white-fade-background.svg"
    }

    Image {
        id: onSemiLogo
        source: "qrc:/images/on-semi-logo-horiz.svg"
        anchors {
            left: parent.left
            leftMargin: 15
            top: parent.top
            topMargin: 15
        }
        height:  100
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }

    Column {
        anchors.centerIn: parent
        spacing: 30

        Image {
            id: disconnectImage
            source: "qrc:/images/no-hcs-connection.svg"

            height:  160
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(width, height)
            mipmap: true
        }

        SGWidgets.SGTag {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Not Connected"
            textColor: "white"
            color: Theme.palette.error
            fontSizeMultiplier: 2.0
            radius: 12
            verticalPadding: 6
            horizontalPadding: 10
        }

        SGWidgets.SGText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {

                if (exitStatus === 0) {
                    return "HCS finished with exit code " + exitCode
                }

                if (exitStatus === 1) {
                    return "HCS crashed with exit code " + exitCode
                }

                return ""
            }
            fontSizeMultiplier: 1.2
            visible: exitStatus >= 0 && exitCode >= 0
        }
    }
}
