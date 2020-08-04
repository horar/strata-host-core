import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/partial-views"
import "qrc:/partial-views/login/registration"
import "qrc:/js/login_utilities.js" as Registration
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: root
    Layout.preferredHeight: fieldGrid.implicitHeight
    Layout.fillWidth: true

    property bool connecting: registrationStatus.visible
    property bool animationsRunning: alertAnimation.running || hideAlertAnimation.running

    onVisibleChanged: {
        if (visible) {
            focus = true
            firstNameField.focus = true
        }
    }

    ColumnLayout {
        id: fieldGrid
        spacing: 20
        width: parent.width

        Rectangle {
            Accessible.role: Accessible.AlertMessage
            Accessible.name: "RegisterError"
            Accessible.description: alertText.text

            id: alertRect
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

        RowLayout {
            spacing: 15

            ValidationField {
                id: firstNameField
                placeholderText: "First Name"
                valid: text !== ""
                Layout.preferredWidth: 50
            }

            ValidationField {
                id: lastNameField
                placeholderText: "Last Name"
                valid: text !== ""
                Layout.preferredWidth: 50
            }
        }

        ValidationField {
            id: companyField
            placeholderText: "Company"
            Layout.fillWidth: true
            valid: text !== ""
        }

        ValidationField {
            id: titleField
            placeholderText: "Title (Optional)"
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

        ValidationField {
            id: passwordField
            Layout.fillWidth: true
            echoMode: TextInput.Password
            placeholderText: "Password"
            showIcon: false

            SGIcon {
                id: showPasswordIcon
                source: passwordField.echoMode === TextInput.Password ? "qrc:/images/icons/eye-solid.svg" : "qrc:/images/icons/eye-slash-solid.svg"
                iconColor: showPassword.containsMouse ? "lightgrey" : "#ddd"
                anchors {
                    verticalCenter: passwordField.verticalCenter
                    rightMargin: 5
                    right: passwordField.right
                }
                height: passwordField.height*.75
                width: height

                MouseArea {
                    id: showPassword
                    anchors.fill: showPasswordIcon
                    hoverEnabled: true
                    onClicked: {
                        if (passwordField.echoMode === TextInput.Password) {
                            passwordField.echoMode = confirmPasswordField.echoMode = TextInput.Normal
                        } else {
                            passwordField.echoMode = confirmPasswordField.echoMode = TextInput.Password
                        }
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        ValidationField {
            id: confirmPasswordField
            echoMode: TextInput.Password
            KeyNavigation.tab: policyCheck
            valid: passReqs.passwordValid
            placeholderText: "Confirm Password"
        }

        RowLayout{
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 10

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
                        source: "qrc:/images/icons/check-solid.svg"
                    }

                    Rectangle {
                        color: "transparent"
                        border.color: "#33b13b"
                        anchors.centerIn: parent
                        visible: policyCheck.focus
                        width: parent.width + 4
                        height: parent.height + 4
                    }
                }
            }

            Text {
                text: "I agree that the information that I provide will be used in accordance with the terms of the ON Semiconductor <a href='https://www.onsemi.com/PowerSolutions/content.do?id=1109'>Privacy Policy</a>."
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                linkColor: "#545960"

                onLinkActivated: { privacyPolicy.open() }

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
                Accessible.onPressAction: function() {
                    clicked()
                }

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

                Keys.onReturnPressed:{
                    registerButton.clicked()
                }

                onClicked: {
                    hideAlertAnimation.start()
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

    Popup {
        id: passReqsPopup
        width: confirmPasswordField.width
        height: passReqs.height
        visible: passwordField.focus || confirmPasswordField.focus
        x: confirmPasswordField.x
        y: confirmPasswordField.y + confirmPasswordField.height + 5
        padding: 0
        background: Item {}

        PasswordRequirements {
            id: passReqs
            width: passReqsPopup.width
            onClicked: {
                passwordField.focus = confirmPasswordField.focus = false
            }
        }
    }

    ConnectionStatus {
        id: registrationStatus
        visible: !fieldGrid.visible
        anchors.centerIn: parent
    }


    NumberAnimation{
        id: alertAnimation
        target: alertRect
        property: "Layout.preferredHeight"
        to: registerButton.height + 10
        duration: 100
    }

    NumberAnimation{
        id: hideAlertAnimation
        target: alertRect
        property: "Layout.preferredHeight"
        to: 0
        duration: 100
        onStarted: alertText.text = ""
    }

    Connections {
        target: Registration.signals
        onRegistrationResult: {
            registrationStatus.text = ""
            fieldGrid.visible = true
            if (result === "Registered") {
                alertRect.color = "#57d445"
                alertText.text = "Account successfully registered to " + emailField.text + "!"
                root.resetForm()
            } else {
                alertRect.color = "red"
                if (result === "No Connection") {
                    alertText.text = "Connection to registration server failed"
                } else if (result === "Account already exists for this email address") {
                    alertText.text = "Account already exists for this email address"
                } else {
                    alertText.text = "Registration server did not create user account"
                }
            }
            alertAnimation.start()
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
