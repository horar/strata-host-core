/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
pragma Singleton

import QtQuick 2.12
import Qt.labs.settings 1.1 as QtLabsSettings

Item {
    id: root

    property int fontPixelSize: defaultFontPixelSize

    readonly property int defaultFontPixelSize: 13

    QtLabsSettings.Settings {
        category: "SGWidgets"
        property alias fontPixelSize: root.fontPixelSize
    }

    function resetToDefaultValues() {
        fontPixelSize = defaultFontPixelSize
    }
}
