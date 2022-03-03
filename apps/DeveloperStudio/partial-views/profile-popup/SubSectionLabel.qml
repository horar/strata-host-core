/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

SGText {
    text: ""
    color: "grey"

    Layout.columnSpan: 1
    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
    Layout.bottomMargin: parent.rowSpacing
    Layout.minimumWidth: 250
}
