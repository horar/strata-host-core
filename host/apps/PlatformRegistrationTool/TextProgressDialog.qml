import QtQuick 2.12
import QtQuick.Controls 2.12

import "./common/" as Common

Common.SgDialog {
    id: flasherDialog

    property alias text: outputProgress.text

    title: "Registering Platform"
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    Column {
        spacing: 10

        Common.SgTextEdit {
            id: outputProgress
            width: 500
            height: 200

            placeholderText: ""
            readOnly: true
            keepCursorAtEnd: true
        }

        Row {
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            Common.SgButton {
                text: "OK"

                onClicked: {
                    flasherDialog.accept()
                }
            }
        }
    }
}
