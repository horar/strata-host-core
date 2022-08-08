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
    id: sectionDelegate
    height: headerText.y + headerText.contentHeight + 4

    property alias text: headerText.text
    property bool isFirst: false

    SGWidgets.SGText {
        id: headerText
        width: parent.width
        anchors {
            top: parent.top
            topMargin: sectionDelegate.isFirst ? 8 : 16
            left: parent.left
            leftMargin: 5
        }

        //alternativeColorEnabled: true
        elide: Text.ElideMiddle
        font.capitalization: Font.Capitalize
        font.bold: true
    }

    Rectangle {
        id: headerUnderline
        anchors {
            bottom: parent.bottom
        }

        color: Theme.palette.onsemiOrange
        height: 1
        width: parent.width
    }
}
