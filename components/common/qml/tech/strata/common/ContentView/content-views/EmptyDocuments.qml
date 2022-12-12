/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.commoncpp 1.0
import tech.strata.sgwidgets 2.0 as SGWidgets2
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    color: navigationSidebar.color

    property bool hasDownloads: false
    property alias errorText: errText.text

    ColumnLayout {
        anchors.centerIn: root

        SGWidgets2.SGIcon{
            Layout.alignment: Qt.AlignHCenter
            source: "qrc:/sgimages/exclamation-triangle.svg"
            width: 80
            height: 80
            iconColor: Qt.lighter(navigationSidebar.color, 1.25)
            visible: hasDownloads === false
        }

        SGWidgets2.SGText {
            id: errText
            Layout.alignment: Qt.AlignHCenter
            text: hasDownloads ? "No PDF documents found for this platform" : "No PDF documents or downloadable<br>files found for this platform"
            fontSizeMultiplier: 2.0
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            color: Qt.lighter(navigationSidebar.color, 1.5)
        }
    }
}
