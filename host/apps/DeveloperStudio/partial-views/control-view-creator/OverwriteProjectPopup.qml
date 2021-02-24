import QtQuick.Controls 2.12
import tech.strata.theme 1.0
import "../"

SGConfirmationPopup {
    modal: true
    padding: 0
    closePolicy: Popup.NoAutoClose
    cancelButtonText: "Cancel"
    buttons: [closeButtonObject, ...defaultButtons.slice(1)]

    property var closeButtonObject: ({
        buttonText: closeButtonText,
        buttonColor: closeButtonColor,
        buttonHoverColor: closeButtonHoverColor,
        closeReason: overwriteReason
    })
    property color closeButtonColor: Theme.palette.red
    property color closeButtonHoverColor: Qt.darker(closeButtonColor, 1.25)
    property string closeButtonText

    readonly property int overwriteReason: 1
}
