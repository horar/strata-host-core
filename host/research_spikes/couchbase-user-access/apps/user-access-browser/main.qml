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

    property var username: null
    property var endpoint: null

    property var channels_access_granted: null
    property var channels_access_available: null

    Row {
        spacing: 5

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
                                root.username = strataLoginUsernameTextfield.text
                                root.endpoint = endpointTextfield.text
                                root.processLogin(root.username)
                            } else {
                                root.processLogout()
                                resultText.text = ""
                            }
                        }
                    }
                }

                // Divider bar
                Rectangle {
                    border.width: 4
                    border.color: "lightgrey"
                    height: 5
                    width: inputContainer.width

                    Layout.leftMargin: 5
                    Layout.preferredHeight: 30
                    Layout.bottomMargin: 10
                }

                ColumnLayout {
                    spacing: -10

                    Label {
                        color: "black"
                        visible: true
                        text: "Join existing channel"

                        font.pointSize: 14
                        Layout.leftMargin: 5
                        Layout.topMargin: 5
                        Layout.preferredHeight: 30
                    }

                    RowLayout {
                        spacing: 10

                        ComboBox {
                            id: joinChannelCombobox
                            width: inputContainer.width
                            Layout.leftMargin: 5
                            enabled: loggedIn && root.channels_access_available.length > 0
                            model: root.channels_access_available
                        }

                        Button {
                            id: joinChannelButton
                            height: joinChannelCombobox.height
                            width: 150
                            x: 5
                            enabled: joinChannelCombobox.enabled

                            background: Rectangle {
                                anchors.fill: parent
                                color: joinChannelButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                            }

                            contentItem: Text {
                                text: qsTr("OK")
                                color: joinChannelCombobox.enabled ? "white" : "lightgrey"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: 14
                            }

                            MouseArea {
                                id: joinChannelButtonMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                                onClicked: {
                                    userAccessBrowser.joinChannel(root.username, joinChannelCombobox.currentText)
                                }
                            }
                        }
                    }

                    Label {
                        color: "black"
                        visible: true
                        text: "Create and join channel"

                        font.pointSize: 14
                        Layout.leftMargin: 5
                        Layout.topMargin: 20
                        Layout.bottomMargin: -5
                        Layout.preferredHeight: 30
                    }

                    RowLayout {
                        spacing: 10

                        Rectangle {
                            border.width: 1
                            border.color: "black"
                            Layout.leftMargin: 5
                            Layout.preferredHeight: 30

                            TextField {
                                id: createChannelTextfield
                                text: ""
                                selectByMouse: true
                                width: joinChannelCombobox.width
                                height: 40
                                font.pointSize: 14
                                enabled: loggedIn
                            }
                        }

                        Button {
                            id: createChannelButton
                            height: joinChannelCombobox.height
                            width: 150
                            enabled: createChannelTextfield.text != ""
                            Layout.leftMargin: createChannelTextfield.width
                            Layout.topMargin: 10

                            background: Rectangle {
                                anchors.fill: parent
                                color: createChannelButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                            }

                            contentItem: Text {
                                text: qsTr("OK")
                                color: createChannelTextfield.enabled ? "white" : "lightgrey"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: 14
                            }

                            MouseArea {
                                id: createChannelButtonMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                                onClicked: {
                                    userAccessBrowser.joinChannel(root.username, createChannelTextfield.text)
                                    createChannelTextfield.text = ""
                                }
                            }
                        }
                    }

                    Label {
                        color: "black"
                        visible: true
                        text: "Leave channel"

                        font.pointSize: 14
                        Layout.leftMargin: 5
                        Layout.topMargin: 25
                        Layout.preferredHeight: 30
                    }

                    RowLayout {
                        spacing: 10

                        ComboBox {
                            id: leaveChannelCombobox
                            width: inputContainer.width
                            Layout.leftMargin: 5
                            enabled: loggedIn && root.channels_access_granted.length > 0
                            model: root.channels_access_granted
                        }

                        Button {
                            id: leaveChannelButton
                            height: leaveChannelCombobox.height
                            width: 150
                            x: 5
                            enabled: leaveChannelCombobox.enabled

                            background: Rectangle {
                                anchors.fill: parent
                                color: leaveChannelButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                            }

                            contentItem: Text {
                                text: qsTr("OK")
                                color: leaveChannelCombobox.enabled ? "white" : "lightgrey"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: 14
                            }

                            MouseArea {
                                id: leaveChannelButtonMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                                onClicked: {
                                    userAccessBrowser.leaveChannel(root.username, leaveChannelCombobox.currentText)
                                }
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

                function parseDocs(channelsGranted, docIDs) {
                    resultText.text = ""
                    append("Successfully connected user.")
                    append("<br>Granted access to channels:")
                    for (var i = 0; i < channelsGranted.length; i++) {
                        resultText.append(channelsGranted[i])
                    }

                    append("<br>Number of database documents received: " + docIDs.length)
                    append("<br>Document ID's:")
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

    function processLogin(username, endpoint) {
        userAccessBrowser.login(username)
        root.loggedIn = true
    }

    function processLogout() {
        userAccessBrowser.logout()
        root.loggedIn = false
    }

    Connections {
        target: userAccessBrowser

        onReceivedDbContents: {
            if (allChannelsGranted && allChannelsDenied && allDocumentIDs) {
                root.channels_access_granted = allChannelsGranted
                root.channels_access_available = allChannelsDenied
                resultScrollView.parseDocs(allChannelsGranted, allDocumentIDs)
            } else {
                console.info("Error: received empty document list")
                resultScrollView.parseDocs_Empty()
            }
        }
    }
}
