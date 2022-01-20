/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.commoncpp 1.0

Item {
    anchors.fill: parent
    property var tempSubscription: 0

    SGMqttClient {
            id: client
            hostname: hostnameField.text
            port: portField.text
//            encrypted connection configuration (must use 5.14 and above)
//            sslConfiguration: SGSslConfiguration {
//                rootCertificate: "PATH_TO_ROOT_CERTIFICATE" // file extension crt
//                clientCertificate: "PATH_TO_CLIENT_CERTIFICATE" // file extension crt or pem
//                clientKey: "PATH_TO_CLEINT_PRIVATE_KEY" // file extension key
//            }
    }

    ListModel {
        id: messageModel
    }

    function addMessage(payload)
    {
        messageModel.insert(0, {"payload" : payload})

        if (messageModel.count >= 100)
            messageModel.remove(99)
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 10
        columns: 2

        Label {
            text: "Hostname:"
            enabled: client.state === SGMqttClient.Disconnected
        }

        TextField {
            id: hostnameField
            Layout.fillWidth: true
            text: "test.mosquitto.org"
            placeholderText: "<Enter host running MQTT broker>"
            enabled: client.state === SGMqttClient.Disconnected
        }

        Label {
            text: "Port:"
            enabled: client.state === SGMqttClient.Disconnected
        }

        TextField {
            id: portField
            Layout.fillWidth: true
            text: "1883"
            placeholderText: "<Port>"
            inputMethodHints: Qt.ImhDigitsOnly
            enabled: client.state === SGMqttClient.Disconnected
        }

        Button {
            id: connectButton
            Layout.columnSpan: 2
            Layout.fillWidth: true
            text: client.state === SGMqttClient.Connected ? "Disconnect" : "Connect"
            onClicked: {
                if (client.state === SGMqttClient.Connected) {
                    client.disconnectFromHost()
                    messageModel.clear()
                    if (tempSubscription) {
                        tempSubscription.destroy()
                        tempSubscription = 0
                    }
                } else {
                    client.sslConfiguration ? client.connectToHostSsl() : client.connectToHost()
                }
            }
        }

        GridLayout {
            enabled: client.state === SGMqttClient.Connected
            Layout.columnSpan: 2
            columns: 4

            Label {
                text: "Topic:"
            }

            TextField {
                id: pubField
                placeholderText: "<Publication topic>"
            }

            Label {
                text: "Message:"
            }

            TextField {
                id: msgField
                placeholderText: "<Publication message>"
            }

            Label {
                text: "QoS:"
            }

            ComboBox {
                id: qosItems
                editable: false
                model: [0, 1, 2]
            }

            CheckBox {
                id: retain
                checked: false
                text: "Retain"
            }

            Button {
                id: pubButton
                text: "Publish"
                Layout.fillWidth: true
                onClicked: {
                    if (pubField.text.length === 0) {
                        console.info("No payload to send. Skipping publish...")
                        return
                    }
                    client.publish(pubField.text, msgField.text, qosItems.currentText, retain.checked)
                    addMessage(msgField.text)
                }
            }
        }

        RowLayout {
                    enabled: client.state === SGMqttClient.Connected
                    Layout.columnSpan: 2

                    Label {
                        text: "Topic:"
                    }

                    TextField {
                        id: subField
                        placeholderText: "<Subscription topic>"
                        Layout.preferredWidth: 289
                        enabled: tempSubscription === 0
                    }

                    Button {
                        id: subButton
                        text: "Subscribe"
                        Layout.fillWidth: true
                        enabled: tempSubscription === 0
                        onClicked: {
                            if (subField.text.length === 0) {
                                console.info("No topic specified to subscribe to.")
                                return
                            }
                            tempSubscription = client.subscribe(subField.text)
                            tempSubscription.messageReceived.connect(addMessage)
                        }
                    }
                }

        Label {
            text: "Log Messages:"
        }

        ListView {
            id: messageView
            model: messageModel
            height: 300
            width: 600
            Layout.columnSpan: 2
            clip: true
            delegate: Rectangle {
                width: messageView.width
                height: 30
                color: index % 2 ? "#DDDDDD" : "#888888"
                radius: 5
                Text {
                    text: payload
                    anchors.centerIn: parent
                }
            }
        }

        Label {
            function stateToString(value) {
                if (value === 0)
                    return "Disconnected"
                else if (value === 1)
                    return "Connecting"
                else if (value === 2)
                    return "Connected"
                else
                    return "Unknown"
            }

            Layout.columnSpan: 2
            color: "#333333"
            text: "Status:" + stateToString(client.state)
            enabled: client.state === SGMqttClient.Connected
        }
    }
}
