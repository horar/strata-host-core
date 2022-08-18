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
import tech.strata.sgwidgets 2.0
import tech.strata.logger 1.0
import tech.strata.theme 1.0

Item {
    ButtonGroup {
        id: downloadButtonGroup
        exclusive: false
        checkState: selectAll.checkState
    }

    Column {
        id: contentColumn
        spacing: 10
        enabled: enabledCheckBox.checked

        SGText {
            text: "CheckBox group:"
            fontSizeMultiplier: 1.2
        }

        SGCheckBox {
            id: selectAll
            text: "Select All"
            checkState: downloadButtonGroup.checkState
        }

        Column {
            width: parent.width
            leftPadding: 10
            spacing: 5

            SGCheckBox {
                text: "First"

                ButtonGroup.group: downloadButtonGroup
            }

            SGCheckBox {
                text: "Second"

                ButtonGroup.group: downloadButtonGroup
            }

            SGCheckBox {
                text: "Third"

                ButtonGroup.group: downloadButtonGroup
            }
        }
    }

    SGCheckBox {
        id: enabledCheckBox
        anchors {
            top: contentColumn.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
    }
}
