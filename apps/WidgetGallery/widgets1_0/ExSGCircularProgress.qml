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

Item {
    width: contentColumn.width
    height: contentColumn.height

    Column {
        id: contentColumn

        spacing: 10

        SGWidgets.SGCircularProgress {
            anchors.horizontalCenter: parent.horizontalCenter
            value: slider.value
        }

        SGWidgets.SGText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Default Circular Progress"
        }

        Slider {
            id: slider
            anchors.horizontalCenter: parent.horizontalCenter

            from: 0
            to: 1
            value: 0.1
        }
    }
}
