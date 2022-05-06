/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/partial-views"
import "qrc:/partial-views/general/"
import "qrc:/js/login_utilities.js" as LoginUtils
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.signals 1.0

SGStrataPopup {
    id: root
    headerText: "Request Password Reset"
    width: 500
    modal: true
    glowColor: "#666"
    closePolicy: Popup.CloseOnEscape

    onClosed: {
        emailField.text = ""
        alertRect.hide()
    }

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

            SGNotificationToast {
                id: alertRect
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: fieldGrid.width
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

                Keys.onPressed: {
                    if (alertRect.height !==0) {
                        alertRect.hide()
                    }
                }
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
                        border.color: submitButton.activeFocus ? Theme.palette.success : "transparent"
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

                    Keys.onReturnPressed: pressAction()
                    Accessible.onPressAction: pressAction()

                    function pressAction() {
                        submitButton.clicked()
                    }

                    onClicked: {
                        var reset_info = {username:emailField.text}
                        submitStatus.currentId = LoginUtils.getNextId()
                        LoginUtils.password_reset_request(reset_info)
                        alertRect.hide()
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

    Connections {
        target: Signals
        onResetResult: {
            submitStatus.text = ""
            fieldGrid.visible = true
            if (result === "Reset Requested") {
                alertRect.color = Theme.palette.success
                alertRect.text = "Email with password reset instructions is being sent to " + emailField.text
                root.resetForm()
            } else {
                if (result === "No Connection") {
                    alertRect.text = "Connection to registration server failed. Please check your internet connection and try again."
                } else if (result === "Server Error") {
                    alertRect.text = "Registration server is unable to process your request at this time. Please try again later."
                } else if (result === "Unable to send email") {
                    alertRect.text = "Registration server is unable to send mail at this time. Please try again later."
                } else {
                    alertRect.text = "No user found with email " + emailField.text
                }
                alertRect.color =  Theme.palette.error
            }
            alertRect.show()
        }
    }

    function resetForm() {
        emailField.text = ""
    }
}
