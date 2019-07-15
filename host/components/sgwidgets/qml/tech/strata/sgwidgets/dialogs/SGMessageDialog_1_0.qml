import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0

/*
  In most cases, it would be sufficient to call showMessageDialog() from SGDialogJS.

  example:

    SGDialogJS.showMessageDialog(
                parent,
                SGMessageDialog.Info,
                "Time limit reached",
                "Do you want conninue ?",
                Dialog.Yes | Dialog.No,
                function () {
                    console.log("ACCEPTED")
                },
                function () {
                    console.log("REJECTED")
                })
*/

SGDialog {
    id: dialog

    /* Dialog type */
    property int type: SGMessageDialog.Info

    /* Title of a dialog */
    title: ""

    /* Text in body */
    property alias text: messageText.text

    /* Buttons in footer. Check DialogButtonBox documentation
       for all possible flags */
    standardButtons: Dialog.Ok

    enum DialogType {
        Info,
        Warning,
        Error
    }

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    headerBgColor: {
        if (dialog.type === SGMessageDialog.Warning) {
            return SGColorsJS.WARNING_COLOR
        } else if (dialog.type === SGMessageDialog.Error) {
            return SGColorsJS.ERROR_COLOR
        }

        return SGColorsJS.STRATA_BLUE
    }

    headerIcon: {
        if (dialog.type === SGMessageDialog.Warning) {
            return "qrc:/sgimages/exclamation-triangle.svg"
        } else if (dialog.type === SGMessageDialog.Error) {
            return "qrc:/sgimages/times-circle.svg"
        }

        return ""
    }

    Item {
        id: content
        implicitWidth: 400
        implicitHeight: column.height


        Column {
            id: column
            anchors.centerIn: parent

            spacing: 12

            Item {
                id: body

                width: content.width
                height: messageText.paintedHeight + 12

                SGText {
                    id: messageText
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: 12
                        right: parent.right
                        rightMargin: 12
                    }

                    fontSizeMultiplier: 1.1
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    footer: DialogButtonBox {
        id: dialogBox
        delegate: SGButton {
            width: implicitWidth
        }

        alignment: Qt.AlignHCenter
        background: null
        spacing: 16
    }
}
