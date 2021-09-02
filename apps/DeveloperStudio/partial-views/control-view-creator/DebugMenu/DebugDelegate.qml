import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0

Item {
    id: debugDelegateRoot
    width: parent.width
    height: column.height

    property string type: "Command"
    property string name: ""
    property alias payload: payloadRepeater.model
    property var payloadJSON: ({})

    ColumnLayout {
        id: column
        width: debugDelegateRoot.width

        Item {
            Layout.preferredHeight: 10
            Layout.fillWidth: true
        }

        Repeater {
            id: payloadRepeater
            delegate: PayloadDelegate {
                id: payloadDelegate
                Layout.fillWidth: true
            }
        }

        Item {
            Layout.preferredHeight: 10
            Layout.fillWidth: true
        }

        SGButton {
            id: execute
            Layout.preferredHeight: 35
            Layout.preferredWidth: 250
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
            text: `Send ${type}`

            onClicked: {
                if (type === "Command") {
                    debugMenuRoot.updateAndCreatePayload({"cmd": name, "payload": payloadJSON})
                } else {
                    debugMenuRoot.updateAndCreatePayload({"value": name, "payload": payloadJSON})
                }
            }
        }
    }

    function updatePartialPayload (partialJson) {
        Object.assign(payloadJSON, partialJson)  // copy/merge contents of partialJson into payloadJSON
    }
}

