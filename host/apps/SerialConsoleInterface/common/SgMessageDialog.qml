import QtQuick 2.12
import QtQuick.Controls 2.12

import "./Colors.js" as Colors

/*
  In most cases, it would be sufficient to call showMessageDialog() from SgUtils.

  example:

    SgUtils.showMessageDialog(
                parent,
                SgMessageDialog.Info,
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

SgDialog {
    id: dialog

    /* Dialog type */
    property int type: SgDialog.Info

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

    headerBgColor: {
        if (dialog.type === SgMessageDialog.Warning) {
            return Colors.WARNING_COLOR
        } else if (dialog.type === SgMessageDialog.Error) {
            return Colors.ERROR_COLOR
        }

        return Colors.STRATA_BLUE
    }

    headerIcon: {
        if (dialog.type === SgMessageDialog.Warning) {
            return "qrc:/images/exclamation-triangle.svg"
        } else if (dialog.type === SgMessageDialog.Error) {
            return "qrc:/images/times-circle.svg"
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

                SgText {
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
        delegate: SgButton {
            width: implicitWidth
        }

        alignment: Qt.AlignHCenter
        background: null
        spacing: 16
    }
}
