import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/partial-views"
import "qrc:/partial-views/login/registration"
import "qrc:/partial-views/general/"
import "qrc:/js/login_utilities.js" as Registration
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0

Item {
    id: root
    Layout.preferredHeight: fieldGrid.implicitHeight
    Layout.fillWidth: true

    property bool connecting: registrationStatus.visible
    property bool animationsRunning: alertRect.running

    onVisibleChanged: {
        if (visible) {
            focus = true
            firstNameField.focus = true
        }
        passReqsPopup.close()
    }

    ColumnLayout {
        id: fieldGrid
        spacing: 20
        width: parent.width

        SGNotificationToast {
            id: alertRect
            Layout.preferredWidth: fieldGrid.width
        }

        RowLayout {
            spacing: 15

            ValidationField {
                id: firstNameField
                placeholderText: "First Name"
                valid: text.match(/\S/)
                Layout.preferredWidth: 50
            }

            ValidationField {
                id: lastNameField
                placeholderText: "Last Name"
                valid: text.match(/\S/)
                Layout.preferredWidth: 50
            }
        }

        ValidationField {
            id: companyField
            placeholderText: "Company"
            Layout.fillWidth: true
            valid: text.match(/\S/)
        }

        ValidationField {
            id: titleField
            placeholderText: "Occupation (Optional)"
            Layout.fillWidth: true
            showIcon: false
        }

        ValidationField {
            id: emailField
            placeholderText: "Email"
            valid: text !== "" && acceptableInput && validEmail

            property bool validEmail: text.match(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)

            validator: RegExpValidator {
                // regex from https://emailregex.com/
                regExp: /^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/
            }
        }

        RowLayout{
            id: newPasswordRow
            spacing: 15

            ValidationField {
                id: passwordField
                placeholderText: "Password"
                showIcon: false
                passwordMode: true
                Layout.preferredWidth: 50
                Component {
                    id: revealPasswordComponent
                    SGIcon {
                        id: showPasswordIcon
                        source: passwordField.echoMode === TextInput.Password ? "qrc:/sgimages/eye.svg" : "qrc:/sgimages/eye-slash.svg"
                        iconColor: showPassword.containsMouse ? "lightgrey" : "#ddd"
                        height: passwordField.height*.75
                        width: height

                        MouseArea {
                            id: showPassword
                            anchors.fill: showPasswordIcon
                            hoverEnabled: true
                            onPressedChanged: {
                                if (passwordField.echoMode === TextInput.Password) {
                                    passwordField.echoMode = confirmPasswordField.echoMode
                                    passwordField.echoMode = TextInput.Normal
                                } else {
                                    passwordField.echoMode = confirmPasswordField.echoMode
                                    passwordField.echoMode = TextInput.Password
                                }
                            }
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                onPressed: {
                    passReqsPopup.openPopup()
                }
            }

            ValidationField {
                id: confirmPasswordField
                echoMode: passwordField.echoMode
                KeyNavigation.tab: policyCheck
                valid: passReqs.passwordValid
                placeholderText: "Confirm Password"
                Layout.preferredWidth: 50

                onPressed: {
                    passReqsPopup.openPopup()
                }

                onValidChanged: {
                    if (valid) {
                        passReqsPopup.close()
                    } else {
                        passReqsPopup.openPopup()
                    }
                }
            }

            Popup {
                id: passReqsPopup
                width: newPasswordRow.width
                height: passReqs.height
                y: passwordField.height + 5
                padding: 0
                background: Item {}
                closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnEscape

                property bool acquiredFocus: passwordField.focus || confirmPasswordField.focus

                PasswordRequirements {
                    id: passReqs
                    width: passReqsPopup.width
                    onClicked: {
                        passReqsPopup.close()
                    }
                }

                onAcquiredFocusChanged: {
                    if (acquiredFocus) {
                        passReqsPopup.openPopup()
                    } else {
                        passReqsPopup.close()
                    }
                }

                function openPopup() {
                    if ((passReqsPopup.opened === false) && (passReqs.passwordValid === false)) {
                        passReqsPopup.open()
                    }
                }
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Layout.columnSpan: 2
            spacing: 13

            CheckBox {
                id: policyCheck
                KeyNavigation.tab: registerButton.enabled ? registerButton : firstNameField
                implicitHeight: 20
                implicitWidth: 20

                indicator: Rectangle {
                    implicitWidth: 20
                    implicitHeight: implicitWidth
                    border.color: "#ccc"

                    SGIcon {
                        width: parent.width * .8
                        height: width
                        anchors.centerIn: parent
                        iconColor: "#777"
                        visible: policyCheck.checked
                        source: "qrc:/sgimages/check.svg"
                    }

                    Rectangle {
                        color: "transparent"
                        border.color: Theme.palette.onsemiOrange
                        anchors.centerIn: parent
                        visible: policyCheck.focus
                        width: parent.width + 4
                        height: parent.height + 4
                    }
                }
            }

            Text {
                text: "I agree that the information that I provide will be used in accordance with the terms of the onsemi <a href='" + sdsModel.urls.privacyPolicyUrl + "'>Privacy Policy</a>."
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                linkColor: "#545960"

                onLinkActivated: { Qt.openUrlExternally(sdsModel.urls.privacyPolicyUrl)}

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
        }

        Item {
            id: registerButtonContainer
            Layout.preferredHeight: registerButton.height
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: registerButton
                height: 32
                width: parent.width
                enabled: passReqs.passwordValid && firstNameField.valid && lastNameField.valid && emailField.valid && companyField.valid && policyCheck.checked
                text: "Register"

                background: Rectangle {
                    color: !registerButton.enabled ? "#dbdbdb" : registerButton.down ? "#666" : "#545960"

                    Rectangle {
                        color: "transparent"
                        anchors {
                            fill: parent
                        }
                        border.width: 2
                        border.color: "white"
                        opacity: .5
                        visible: registerButton.focus
                    }
                }

                contentItem: Text {
                    text: registerButton.text
                    color: !registerButton.enabled ? "#f2f2f2" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                }

                Keys.onReturnPressed: pressRegisterButton()
                Accessible.onPressAction: pressRegisterButton()

                function pressRegisterButton() {
                    registerButton.clicked()

                }

                onClicked: {
                    alertRect.hide()
                    fieldGrid.visible = false
                    var register_info = {
                        firstname: firstNameField.text,
                        lastname: lastNameField.text,
                        company: companyField.text,
                        title: titleField.text,
                        admin:1,
                        username:emailField.text,
                        password:passwordField.text
                    }
                    registrationStatus.currentId = Registration.getNextId()
                    Registration.register(register_info)
                }

                MouseArea {
                    id: registerButtonMouse
                    anchors.fill: registerButton
                    onPressed:  mouse.accepted = false
                    cursorShape: Qt.PointingHandCursor
                }

                ToolTip {
                    text: {
                        var result = ""

                        if (!firstNameField.valid ){
                            result += "First name required"
                        }
                        if (!lastNameField.valid ){
                            result += (result === "" ? "" : "<br>")
                            result += "Last name required"
                        }
                        if (!emailField.valid ){
                            result += (result === "" ? "" : "<br>")
                            result += "Email address invalid"
                        }
                        if (!companyField.valid ){
                            result += (result === "" ? "" : "<br>")
                            result += "Company name required"
                        }
                        if (!passReqs.passwordValid){
                            result += (result === "" ? "" : "<br>")
                            result += "Password invalid"
                        }
                        if (!policyCheck.checked){
                            result += (result === "" ? "" : "<br>")
                            result += "Must accept terms"
                        }
                        return result
                    }
                    visible: registerToolTipShow.containsMouse && !registerButton.enabled
                }
            }

            MouseArea {
                id: registerToolTipShow
                anchors.fill: registerButton
                hoverEnabled: true
                visible: !registerButton.enabled
            }
        }
    }

    ConnectionStatus {
        id: registrationStatus
        visible: !fieldGrid.visible
        anchors.centerIn: parent
    }

    Connections {
        target: Signals
        onRegistrationResult: {
            registrationStatus.text = ""
            fieldGrid.visible = true
            if (result === "Registered") {
                alertRect.color = "#57d445"
                alertRect.text = "Account successfully registered to " + emailField.text + "!"
                root.resetForm()
            } else {
                alertRect.color = "red"
                if (result === "No Connection") {
                    alertRect.text = "Connection to registration server failed. Please check your internet connection and try again."
                } else if (result === "Server Error") {
                    alertRect.text = "Registration server is unable to process your request at this time. Please try again later."
                } else if (result === "Account already exists for this email address") {
                    alertRect.text = "Account already exists for this email address."
                } else {
                    alertRect.text = "Registration server was not able to create user account. Please verify your input and try again."
                }
            }
            alertRect.show()
        }
    }

    function resetForm() {
        firstNameField.text = ""
        lastNameField.text = ""
        passwordField.text = ""
        emailField.text = ""
        titleField.text = ""
        companyField.text = ""
        confirmPasswordField.text = ""
        policyCheck.checked = false
    }
}
