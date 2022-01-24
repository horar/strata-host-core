import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0


SGWidgets.SGDialog {
    id: corruptedFileDialog
    destroyOnClose: true
    headerBgColor: TangoTheme.palette.warning
    headerIcon: "qrc:/sgimages/exclamation-triangle.svg"
    title: "Corrupted INI file"

    modal: true
    focus: true
    closePolicy: Dialog.NoAutoClose

    property alias errorMessage: messageText.text

    Item {
        id: content
        implicitWidth: 400
        implicitHeight: column.height

        Column {
            id: column
            anchors.centerIn: parent
            spacing: 12

            SGWidgets.SGText {
                width: content.width
                text: "Selected INI file is corrupted."
                wrapMode: Text.WordWrap
            }

            SGWidgets.SGText {
                id: messageText
                width: content.width
                wrapMode: Text.WordWrap
                text: errorMessage
            }

            SGWidgets.SGText {
                width: content.width
                text: "Do you want to set the parameter to default value or remove it?"
                wrapMode: Text.WordWrap
            }

            Row {
                spacing: 16
                anchors.horizontalCenter: column.horizontalCenter
                SGWidgets.SGButton {
                    text: "Set to default"
                    onClicked: {
                        corruptedFileDialog.accepted()
                    }
                }
                SGWidgets.SGButton {
                    text: "Remove parameter"
                    onClicked: {
                        corruptedFileDialog.rejected()
                    }
                }
            }
        }
    }
}
