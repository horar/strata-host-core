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

ListView {
    id: root
    
    implicitWidth: 700
    implicitHeight: 480
    
    clip: true
    
    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }
    
    highlight: Rectangle {
        color: "#eee"
        radius: 5
    }
}
