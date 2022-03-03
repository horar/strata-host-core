/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Window {
    id: root
    visible: true
    width: 1000
    height: 500
    title: qsTr("Telestrator 1")

    Row {
        SGTelestrator {
            width: root.width/2
            height: 500
        }

        SGTelestrator {
            width: root.width/2
            height: 500
        }
    }

    Server {
        id: server
    }
}
