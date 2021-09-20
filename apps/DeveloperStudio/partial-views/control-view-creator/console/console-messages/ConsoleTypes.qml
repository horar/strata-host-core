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
import tech.strata.theme 1.0

Item {
    width: typeMetric.width
    height: typeMetric.height

    property alias type: msgType.text
    property color typeColor: "#fff"
    property bool current: true

    SGText {
        id: leftSide
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: '['
        color: typeColor
        fontSizeMultiplier: fontMultiplier
    }

    SGText {
        id: msgType
        anchors.centerIn: parent
        fontSizeMultiplier: fontMultiplier
        color: typeColor
    }

    SGText {
        id: rightSide
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: ']'
        color: typeColor
        fontSizeMultiplier: fontMultiplier
    }

    TextMetrics {
        id: typeMetric
        text: ` [ warning ] `
        font.pixelSize: SGSettings.fontPixelSize * fontMultiplier
    }

    function getMsgColor(type){
        switch(type){
        case "debug": return Theme.palette.lightBlue
        case "warning": return Theme.palette.warning
        case "error": return Theme.palette.error
        case "info": return Theme.palette.onsemiOrange
        default: return "#aaa"
        }
    }

    onTypeChanged: {
        if(current){
            typeColor = getMsgColor(type)
        }
    }

    onCurrentChanged: {
        if(!current){
            typeColor = Theme.palette.gray
            leftSide.enabled = current
            rightSide.enabled = current
            msgType.enabled = current
        }

    }

}
