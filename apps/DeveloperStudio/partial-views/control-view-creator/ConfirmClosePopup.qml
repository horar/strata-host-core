/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick.Controls 2.12
import tech.strata.theme 1.0
import "../"

SGConfirmationPopup {
    modal: true
    padding: 0
    closePolicy: Popup.NoAutoClose
    popupText: "Your changes will be lost if you choose to not save them."
    acceptButtonColor: Theme.palette.onsemiCyan
    acceptButtonHoverColor: Qt.darker(acceptButtonColor, 1.25)
    acceptButtonText: "Save"
    cancelButtonText: "Cancel"
    buttons: [...defaultButtons.slice(0, 1), closeButtonObject, ...defaultButtons.slice(1)]

    property var closeButtonObject: ({
        buttonText: closeButtonText,
        buttonColor: closeButtonColor,
        buttonHoverColor: closeButtonHoverColor,
        closeReason: closeFilesReason
    })
    property color closeButtonColor: Theme.palette.error
    property color closeButtonHoverColor: Qt.darker(closeButtonColor, 1.25)
    property string closeButtonText: "Don't save"

    readonly property int closeFilesReason: 2
}
