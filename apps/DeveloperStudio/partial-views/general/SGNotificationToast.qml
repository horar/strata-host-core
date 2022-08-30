/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQml 2.12
import QtQuick.Layouts 1.3

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import tech.strata.fonts 1.0

Rectangle {
    id: alertToast
    implicitHeight: 0
    color: Theme.palette.error
    visible: implicitHeight > 0
    clip: true
    Accessible.name: text
    Accessible.role: Accessible.AlertMessage

    property alias text: alertText.text
    property bool running: alertAnimation.running || hideAlertAnimation.running
    property alias interval: closeAlertTimer.interval

    onVisibleChanged: {
        if (!visible && closeAlertTimer.running) {
            closeAlertTimer.stop()
        }
    }

    SGIcon {
        id: alertIcon
        source: Qt.colorEqual(alertToast.color, Theme.palette.error) ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/check-circle.svg"
        anchors {
            left: alertToast.left
            verticalCenter: alertToast.verticalCenter
            leftMargin: alertToast.height/2 - height/2
        }
        height: 30
        width: 30
        iconColor: "white"
    }

    SGText {
        id: alertText
        font {
            family: Fonts.franklinGothicBold
        }
        wrapMode: Text.WordWrap
        anchors {
            left: alertIcon.right
            right: alertToast.right
            rightMargin: 5
            verticalCenter: alertToast.verticalCenter
        }
        horizontalAlignment:Text.AlignHCenter
        color: "white"
    }
    // this will allow end user to close the toast
    MouseArea {
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.fill: alertToast

        onPressed: {
            hide()
        }
    }
    // this will default close the toast after 10 seconds
    Timer {
        id: closeAlertTimer

        interval: 0
        repeat: false

        onTriggered: {
            hide()
        }
    }

    NumberAnimation {
        id: alertAnimation
        target: alertToast
        property: "implicitHeight"
        to: alertIcon.height + 10
        duration: 100

        onFinished: {
            if(interval > 0){
                closeAlertTimer.start()
            }
        }
    }

    NumberAnimation {
        id: hideAlertAnimation
        target: alertToast
        property: "implicitHeight"
        to: 0
        duration: 100
        onStarted: alertToast.text = ""
    }

    function show() {
        alertAnimation.start()
    }

    function hide () {
        hideAlertAnimation.start()
    }

    function hideInstantly () {
        alertToast.text = ""
        alertToast.implicitHeight = 0
    }
}
