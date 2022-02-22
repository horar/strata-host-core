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
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

MouseArea {
    Layout.fillWidth: true
    implicitHeight: faultCol.implicitHeight
    hoverEnabled: true

    property alias toolTipText: toolTip.text
    property alias text: title.text
    property alias status: statusLight.status

    ToolTip {
        id: toolTip
        visible: parent.containsMouse && text
        delay: 200
    }

    ColumnLayout {
        id: faultCol
        width: parent.width
        spacing: 0

        SGStatusLight {
            id: statusLight
            flatStyle: true
            implicitHeight: 20
            implicitWidth: 20
            Layout.alignment: Qt.AlignHCenter
            status: model.status
        }

        Text {
            id: title
            color: "white"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
