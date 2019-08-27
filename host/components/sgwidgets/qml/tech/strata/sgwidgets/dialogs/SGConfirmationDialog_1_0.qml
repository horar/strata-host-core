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
