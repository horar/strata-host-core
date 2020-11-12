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

    Row {
        spacing: 10

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

                        Layout.leftMargin: 5
                        Layout.topMargin: 5
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
                            enabled: !loggedIn
                        }
                    }
                }

                Button {
                    id: loginButton
                    height: 60
                    width: 150
                    x: 5

                    enabled: {
                        if (endpointTextfield.text !== "") {
                            return true;
                        } else {
                            return false;
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        color: loginButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                    }

                    contentItem: Text {
                        text: loggedIn ? qsTr("Logout") : qsTr("Login")
                        color: loginButton.enabled ? "white" : "lightgrey"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea {
                        id: loginButtonMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: {
                            if (!loggedIn) {
                                userAccessBrowser.loginAndStartReplication(strataLoginUsernameTextfield.text, endpointTextfield.text)
                                loggedIn = true
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
                    font.pointSize: 12
                    readOnly: true
                }

                function append(message) {
                    // resultText.text += user === couchChat.user_name ? "<b>You</b> say:<br><b>" + message + "</b><br><br>" : "User <b>" + user + "</b> says:<br><b>" + message + "</b><br><br>"
                    // resultText.text += "\nreceived\n"
                    resultText.text += "\n" + message + "\n"
                    var ratio = 1.0 - resultScrollView.visibleArea.heightRatio;
                    resultScrollView.contentY = resultScrollView.contentHeight * ratio; // scroll chatbox text area to bottom
                }
            }
        }
    }

    Connections {
        target: userAccessBrowser

        onReceivedMessage: {
            if (!message) {
                console.info("Received incorrect message")
            } else {
                console.info("Received message: " + message)
                resultScrollView.append(message)
            }
        }
    }
}
