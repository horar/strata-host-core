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
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sglayout 1.0

Item {
    anchors {
        fill: parent
    }
    clip: true

    property alias text: txt.text

    ScrollView {
        id: rootScroll
        anchors {
            fill: parent
            margins: 7
        }

        ScrollBar.vertical: ScrollBar {
            height: rootScroll.height
            anchors.right: parent.right
        }

        TextEdit {
            id: txt
            readOnly: true
            selectByMouse: true
            font.pixelSize: 11
        }
    }
}
