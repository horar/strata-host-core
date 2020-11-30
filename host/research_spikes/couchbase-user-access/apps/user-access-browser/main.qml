import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import com.onsemi 1.0

Window {
    id: root
    visible: true

    width: 800
    height: 600
    maximumHeight: height
    maximumWidth: width
    minimumHeight: height
    minimumWidth: width
    title: qsTr("Strata User Access Browser")

    property bool loggedIn: false

    property var channels: null
    property var user_access_map: null

    Row {
        spacing: 5

        Component.onCompleted: {
            userAccessBrowser.getUserAccessMap(endpointTextfield.text)
        }

        Rectangle {
            id: inputContainer
            width: 300
            height: root.height
            color: "lightgrey"

            Column {
                spacing: 20

                ColumnLayout {
                    id: usernameInput
                    spacing: -10

                    Label {
                        color: "black"
                        visible: true
                        text: "\"Strata Login\" Username"
                        font.pointSize: 14
                        Layout.leftMargin: 5
                        Layout.topMargin: 10
                        Layout.preferredHeight: 30
                    }

                    Rectangle {
                        border.width: 1
                        border.color: "black"

                        Layout.leftMargin: 5
                        Layout.preferredHeight: 30

                        TextField {
                            id: strataLoginUsernameTextfield
                            text: ""
                            selectByMouse: true
                            width: 290
                            height: 40
                            font.pointSize: 14
                            enabled: !loggedIn
                        }
                    }
                }

                ColumnLayout {
                    id: endpointInput
                    spacing: -10

                    Label {
                        color: "black"
                        visible: true
                        text: "Couchbase server endpoint"
                        font.pointSize: 14
                        Layout.leftMargin: 5
                        Layout.topMargin: 5
                        Layout.preferredHeight: 30
                    }

                    Rectangle {
                        border.width: 1
                        border.color: "black"

                        Layout.leftMargin: 5
                        Layout.preferredHeight: 30
                        Layout.bottomMargin: 10

                        TextField {
                            id: endpointTextfield
                            text: "ws://localhost:4984/platform-list"
                            selectByMouse: true
                            width: 290
                            height: 40
                            font.pointSize: 14
                            enabled: !loggedIn
                        }
                    }
                }

                Button {
                    id: loginButton
                    height: 60
                    width: 150
                    x: 5
                    enabled: strataLoginUsernameTextfield.text !== "" && endpointTextfield.text !== ""

                    background: Rectangle {
                        anchors.fill: parent
                        color: loginButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                    }

                    contentItem: Text {
                        text: loggedIn ? qsTr("Logout") : qsTr("Login")
                        color: loginButton.enabled ? "white" : "lightgrey"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 14
                    }

                    MouseArea {
                        id: loginButtonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: {
                            if (!loggedIn) {
                                let channels = root.authenticate(strataLoginUsernameTextfield.text)
                                if (channels) {
                                    root.channels = channels
                                    userAccessBrowser.loginAndStartReplication(strataLoginUsernameTextfield.text, root.channels, endpointTextfield.text)
                                    loggedIn = true
                                }
                            } else {
                                userAccessBrowser.logoutAndStopReplication()
                                resultText.text = ""
                                loggedIn = false
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: outputContainer
            width: root.width - inputContainer.width
            height: root.height
            color: "white"
            y: -15

            Flickable {
                id: resultScrollView
                height: parent.height
                width: parent.width

                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {}
                TextArea.flickable: TextArea {
                    id: resultText
                    height: 300
                    width: root.width
                    textFormat: TextEdit.RichText
                    font.pointSize: 14
                    readOnly: true
                }

                function append(message) {
                    resultText.text += message
                    var ratio = 1.0 - resultScrollView.visibleArea.heightRatio;
                    resultScrollView.contentY = resultScrollView.contentHeight * ratio; // scroll chatbox text area to bottom
                }

                function parseDocs(docIDs) {
                    resultText.text = ""
                    append("Successfully connected user.")
                    resultText.append("Granted access to channels:")
                    for (var i = 0; i < root.channels.length; i++) {
                        resultText.append(root.channels[i])
                    }

                    append("Number of database documents received: " + docIDs.length)
                    append("Document ID's:")
                    for (var i = 0; i < docIDs.length; i++) {
                        append(docIDs[i])
                    }
                }

                function parseDocs_Empty() {
                    resultText.text = ""
                    append("Successfully connected user.")
                    append("Received no database documents.")
                }
            }
        }
    }

    // Receives username, returns list of channels to which that user has access
    function authenticate(username) {
        resultText.text = ""
        if (!root.user_access_map) {
            console.error("Do not have a valid user access map!")
        }

        const all_channels = root.user_access_map["user_access_map"]
        if (!all_channels) {
            console.error("Do not have a valid user access map!")
        }

        let user_access_channels = []
        Object.keys(all_channels).forEach(function(key) {
            const this_channel = all_channels[key]
            if (this_channel.includes(username)) {
                user_access_channels.push(key)
            }
        })

        if (user_access_channels.length == 0) {
            console.error("Username not found in access map!")
            resultScrollView.append("Username not found in access map!")
            return
        }
        return user_access_channels
    }

    Connections {
        target: userAccessBrowser

        onUserAccessMapReceived: {
            if (user_access_map) {
                root.user_access_map = user_access_map
            } else {
                console.error("Received invalid user access map!")
                resultScrollView.append("Received invalid user access map!")
            }
        }

        onStatusUpdated: {
            if (total_docs != 0) {
                let docIDs = userAccessBrowser.getAllDocumentIDs()
                if (docIDs) {
                    resultScrollView.parseDocs(docIDs)
                } else {
                    console.info("Error: received no documents from getAllDocumentIDs().")
                }
            } else {
                resultScrollView.parseDocs_Empty()
            }
        }
    }
}
