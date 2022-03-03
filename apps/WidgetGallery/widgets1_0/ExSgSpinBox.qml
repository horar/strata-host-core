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
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP

Item {

    width: contentColumn.width
    height: editEnabledCheckBox.y + editEnabledCheckBox.height

    Column {
        id: contentColumn
        spacing: 10
        enabled: editEnabledCheckBox.checked

        SGWidgets.SGText {
            text: "SpinBox with values from 0 to 999"
            fontSizeMultiplier: 1.3
        }

        SGWidgets.SGSpinBox {
            from: 0
            to: 999
        }
    }

    SGWidgets.SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: contentColumn.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
    }
}
