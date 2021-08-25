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

    onPayloadJSONChanged: {
        if (!payloadJSON.hasOwnProperty(debugDelegateRoot.name)) {
            payloadJSON[debugDelegateRoot.name] = {}
        }
    }

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
                payloadIndex: debugDelegateRoot.name
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
            text: `Send ${type}`

            onClicked: {
                if (type === "Command") {
                    debugMenuRoot.updateAndCreatePayload({"cmd": name, "payload": payloadJSON[name]})
                } else {
                    debugMenuRoot.updateAndCreatePayload({"value": name, "payload": payloadJSON[name]})
                }
            }
        }

        Item {
            Layout.preferredHeight: 10
            Layout.fillWidth: true
        }
    }

    function updatePartialPayload (partialJson, cmdName) {
        if (payload !== null && debugDelegateRoot.name === cmdName) {
            if (!payloadJSON.hasOwnProperty(cmdName)) {
                payloadJSON[cmdName] = {}
            }
            payloadJSON[cmdName] = Object.assign(payloadJSON[cmdName], partialJson)
        }
    }
}

