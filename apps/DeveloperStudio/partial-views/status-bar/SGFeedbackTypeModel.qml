/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.3

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

ListModel {

    property string baseColor: String(Theme.palette.onsemiOrange)
    property string hoverColor: String(Qt.darker(Theme.palette.onsemiOrange, 1.15))

    property bool completed: false
        Component.onCompleted: {
            append({
                "type": "Bug",
                "baseColor": baseColor,
                "hoverColor": hoverColor
                });
            append({
                "type": "Feature",
                "baseColor": baseColor,
                "hoverColor": hoverColor
                });
            append({
                "type": "Acknowledgement",
                "baseColor": baseColor,
                "hoverColor": hoverColor
                });
            completed = true;
        }
}
