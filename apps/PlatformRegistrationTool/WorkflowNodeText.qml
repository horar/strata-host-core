/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: nodeText
    width: standalone ? textItem.paintedWidth : dummyText.paintedWidth * 1.4
    height: standalone ? textItem.paintedHeight :  dummyText.paintedHeight * 1.4

    property alias text: textItem.text
    property color highlightColor: "#0571ff"
    property color color: "#303030"
    property bool highlight: false
    property bool standalone: false

    SGWidgets.SGText {
        id: dummyText
        text: textItem.text
        visible: false
    }

    SGWidgets.SGText {
        id: textItem
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        fontSizeMultiplier: highlight ? 1.3 : 1.1
        color: highlight ? highlightColor : nodeText.color
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }
}
