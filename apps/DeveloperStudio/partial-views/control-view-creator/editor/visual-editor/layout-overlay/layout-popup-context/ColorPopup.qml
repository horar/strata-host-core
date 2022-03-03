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
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."

ColorDialog {
    id: colorDialog
    title: "Please choose a color"

    property string sourceProperty

    onAccepted: {
        visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, sourceProperty, '"' + colorDialog.color + '"')
        menuLoader.active = false
    }

    onRejected: {
        menuLoader.active = false
    }
}

