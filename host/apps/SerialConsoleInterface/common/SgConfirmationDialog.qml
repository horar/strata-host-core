import QtQuick 2.12
import QtQuick.Controls 2.12
import "./Colors.js" as Colors

SgMessageDialog {
    id: dialog

    property string acceptButtonText
    property string rejectButtonText

    standardButtons: Dialog.NoButton
    closePolicy: Dialog.NoAutoClose

    footer: DialogButtonBox {
        alignment: Qt.AlignHCenter
        background: null
        spacing: 16

        SgButton {
            text: acceptButtonText
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }

        SgButton {
            text: rejectButtonText
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }
}
