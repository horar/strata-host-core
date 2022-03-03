/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

Item {
    width: column.width
    height: column.height

    Column {
        id: column
        spacing: 2

        Repeater {
            model: 5
            delegate: Rectangle {
                width: 2
                height: 2
                color : "black"
                opacity: 0.3
            }
        }
    }
}
