import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/partial-views"
import "qrc:/js/login_utilities.js" as Password
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

SGStrataPopup {
    id: root
    headerText: "Request Password Reset"
    width: 500
    modal: true
    glowColor: "#666"
    closePolicy: Popup.CloseOnEscape

    onVisibleChanged: {
        if (visible) {
            focus = true
            emailField.focus = true
        }
    }

    contentItem: Item {
        implicitHeight: fieldGrid.implicitHeight

        GridLayout {
            id: fieldGrid
            rowSpacing: 10
            columnSpacing: 10
            columns: 2
            width: parent.width

            Rectangle {
                id: alertRect
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: fieldGrid.width * 0.75
                Layout.preferredHeight: 0
                color: "red"
                visible: Layout.preferredHeight > 0
                clip: true

                SGIcon {
                    id: alertIcon
                    source: Qt.colorEqual(alertRect.color, "red") ? "qrc:/images/icons/exclamation-circle-solid.svg" : "qrc:/images/icons/check-circle-solid.svg"
                    anchors {
                        left: alertRect.left
                        verticalCenter: alertRect.verticalCenter
                        leftMargin: alertRect.height/2 - height/2
                    }
                    height: 30
                    width: 30
                    iconColor: "white"
                }

                Text {
                    id: alertText
                    font {
                        pixelSize: 10
                        family: Fonts.franklinGothicBold
                    }
                    wrapMode: Label.WordWrap
                    anchors {
                        left: alertIcon.right
                        right: alertRect.right
                        rightMargin: 5
                        verticalCenter: alertRect.verticalCenter
                    }
                    horizontalAlignment:Text.AlignHCenter
                    text: ""
                    color: "white"
                }
            }

            Text {
                text: "Enter the email address associated with the account:"
                Layout.columnSpan: 2
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            ValidationField {
                id: emailField
                placeholderText: "example@onsemi.com"
                valid: text !== "" && acceptableInput && validEmail
                Layout.columnSpan: 2
                Layout.fillWidth: true
                validator: RegExpValidator {
                    // regex from https://emailregex.com/
                    regExp: /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/
                }

                property bool validEmail: text.match(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)

                onAccepted: { submitButton.clicked() }
            }

            Item {
                id: submitButtonContainer
                Layout.preferredHeight: submitButton.height
                Layout.preferredWidth: submitButton.width
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignHCenter

                Button {
                    id: submitButton
                    height: 40
                    width: 120
                    enabled: emailField.valid
                    text:"Submit"

                    background: Rectangle {
                        color: !submitButton.enabled ? "#dbdbdb" : submitButton.down ? "#666" : "#888"
                        border.color: submitButton.activeFocus ? "#219647" : "transparent"
                    }

                    contentItem: Text {
                        text: submitButton.text
                        color: !submitButton.enabled ? "#f2f2f2" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        font {
                            pixelSize: 15
                            family: Fonts.franklinGothicBold
                        }
                    }

                    Keys.onReturnPressed:{
                        submitButton.clicked()
                    }

                    onClicked: {
                        var reset_info = {username:emailField.text}
                        Password.password_reset_request(reset_info)
                        hideAlertAnimation.start()
                        fieldGrid.visible = false
                    }

                    MouseArea {
                        id: submitButtonMouse
                        anchors.fill: submitButton
                        onPressed:  mouse.accepted = false
                        cursorShape: Qt.PointingHandCursor
                    }

                    ToolTip {
                        text: {
                            if (!emailField.valid ){
                                return "Email address invalid"
                            } else {
                                return""
                            }
                        }
                        visible: registerToolTipShow.containsMouse && !submitButton.enabled
                    }
                }

                MouseArea {
                    id: registerToolTipShow
                    anchors.fill: submitButton
                    hoverEnabled: true
                    visible: !submitButton.enabled
                }
            }
        }

        ConnectionStatus {
            id: submitStatus
            visible: !fieldGrid.visible
            anchors.centerIn: parent
        }
    }

    NumberAnimation{
        id: alertAnimation
        target: alertRect
        property: "Layout.preferredHeight"
        to: submitButton.height + 10
        duration: 200
    }

    NumberAnimation{
        id: hideAlertAnimation
        target: alertRect
        property: "Layout.preferredHeight"
        to: 0
        duration: 200
        onStarted: alertText.text = ""
    }

    Connections {
        target: Password.signals
        onResetResult: {
            submitStatus.text = ""
            fieldGrid.visible = true
            if (result === "Reset Requested") {
                alertRect.color = "#0ec40c"
                alertText.text = "Email with password reset instructions is being sent to " + emailField.text
                root.resetForm()
            } else {
                if (result === "No Connection") {
                    alertText.text = "Connection to registration server failed"
                } else {
                    alertText.text = "No user found with email " + emailField.text
                }
                alertRect.color = "red"
            }
            alertAnimation.start()
        }
    }

    function resetForm() {
        emailField.text = ""
    }
}
