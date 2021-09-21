/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0

Item {
    width: parent.width
    height: row.height

    property bool initialized: false

    property alias name: labelText.text
    property alias value: payloadEnabled.checked

    RowLayout {
        id: row
        width: parent.width
        spacing: 10

        SGText {
            id: labelText
            font.bold: true
            fontSizeMultiplier: 1.2
            Layout.fillWidth: true
            elide: Text.ElideRight
            Layout.leftMargin: 10
        }

        SGSwitch {
            id: payloadEnabled
            checkedLabel: "true"
            uncheckedLabel: "false"
            Layout.preferredWidth: 100
            Layout.preferredHeight: 35
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
