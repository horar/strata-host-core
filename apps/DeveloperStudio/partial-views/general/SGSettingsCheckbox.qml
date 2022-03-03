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

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

RowLayout {
    id: checkboxRoot

    property alias text: text.text
    property alias checked: checkBox.checked

    CheckBox {
        id: checkBox
        palette.highlight: Theme.palette.onsemiOrange
    }

    SGText {
        id: text
        Layout.fillWidth: true
        wrapMode: Text.Wrap
    }
}
