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

SGWidgets.SGMessageDialog {
    id: dialog

    property string acceptButtonText
    property string rejectButtonText

    standardButtons: Dialog.NoButton
    closePolicy: Dialog.NoAutoClose

    footer: DialogButtonBox {
        alignment: Qt.AlignHCenter
        background: null
        spacing: 16

        SGWidgets.SGButton {
            text: acceptButtonText
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }

        SGWidgets.SGButton {
            text: rejectButtonText
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }
}
