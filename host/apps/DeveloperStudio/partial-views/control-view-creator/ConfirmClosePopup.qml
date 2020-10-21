import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0

import "../"

SGConfirmationPopup {
    modal: true
    padding: 0
    closePolicy: Popup.NoAutoClose

    acceptButtonColor: SGColorsJS.STRATA_GREEN
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
    property color closeButtonColor: "#db2e1e"
    property color closeButtonHoverColor: Qt.darker(closeButtonColor, 1.25)
    property string closeButtonText: "Don't save"

    readonly property int closeFilesReason: 2
}
