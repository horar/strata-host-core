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
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.fonts 1.0

Rectangle {
    id: root

    color: mouseArea.containsMouse ? "#aaa" : "transparent"

    property alias source: icon.source
    property alias iconRotation: icon.rotation
    signal clicked()

    SGIcon {
        id: icon
        iconColor: "#ddd"
        anchors.centerIn: parent
        width: 20
        height: width
        rotation: 0
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            parent.clicked()
        }
    }
}
