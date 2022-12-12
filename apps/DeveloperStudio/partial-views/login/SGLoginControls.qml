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
import QtQuick.Controls 2.0
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.12
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/login_utilities.js" as LoginUtils
import "qrc:/js/login_storage.js" as UsernameStorage
import "qrc:/partial-views/login/"
import "qrc:/partial-views/general/"
import "qrc:/partial-views/"

import tech.strata.fonts 1.0
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0

Item {
    id: root
    Layout.preferredHeight: loginControls.implicitHeight
    Layout.fillWidth: true

    property bool animationsRunning: loginErrorRect.running
    property bool connecting: connectionStatus.visible

    ColumnLayout {
        id: loginControls
        width: root.width
        spacing: 20

        LoginComboBox {
            id: usernameField
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            font {
                pixelSize: 15
                family: Fonts.franklinGothicBook
            }
            borderColor: "transparent"
            model: ListModel {}
            textRole: "name"
            placeholderText: "Username/Email"
            editable: true

            property string text: ""

            onEditTextChanged: {
                editText = limitStringLength(editText)
                text = editText
            }

            onCurrentTextChanged: text = currentText

            onActivated: {
                if(index >= 0) {
                    usernameField.editText = model.get(index).name
                }
            }

            Keys.onPressed: {
                loginErrorRect.hide()
            }

            Keys.onReturnPressed:{
                loginButton.submit()
            }

            KeyNavigation.tab: passwordField

            // CTOR
            Component.onCompleted: {
                UsernameStorage.populateSavedUsernames(model, usernameFieldSettings.userNameStore)
                currentIndex = usernameFieldSettings.userNameIndex
                if (usernameField.text === "") {
                    forceActiveFocus()
                } else {
                    passwordField.forceActiveFocus()
                }
            } // end CTOR

            // DTOR
            Component.onDestruction: {
                usernameFieldSettings.setValue("userNameStore", UsernameStorage.saveSessionUsernames(model, usernameFieldSettings.userNameStore)) // save logins from session into userNameStore
                usernameFieldSettings.setValue("userNameIndex", currentIndex);     // point to last login
            } // end DTOR

            function updateModel() {
                var lowerCase = text.toLowerCase()
                if (find(lowerCase) === -1) {
                    model.append({"name": lowerCase})
                    currentIndex = model.count-1
                } else {
                    currentIndex = find(lowerCase)
                }
            }

            function limitStringLength(string) {
                var newString = string
                if (string.length > 256) {
                    newString = newString.substring(0,255)
                }
                return newString
            }

            Settings {
                id: usernameFieldSettings
                category: "Usernames"
                property string userNameStore: "[]"
                property int userNameIndex: -1
            }
        }

        ValidationField {
            id: passwordField
            Layout.fillWidth: true
            activeFocusOnTab: true
            selectByMouse: true
            KeyNavigation.tab: rememberCheckBox
            placeholderText: qsTr("Password")
            showIcon: false
            passwordMode: true

            Keys.onPressed: {
                loginErrorRect.hide()
            }

            Keys.onReturnPressed:{
                loginButton.submit()
            }
        }

        SGNotificationToast {
            id: loginErrorRect
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: usernameField.width
        }

        RowLayout {
            id: rowLoginControls
            Layout.fillHeight: false

            CheckBox {
                id: rememberCheckBox
                text: qsTr("Remember Me")
                checked: LoginUtils.settings.rememberMe
                KeyNavigation.tab: loginButton.enabled ? loginButton : usernameField
                onCheckedChanged: {
                    LoginUtils.settings.rememberMe = checked
                }
                padding: 0
                palette.highlight: Theme.palette.onsemiOrange
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Text {
                id: forgotLink
                text: "Forgot Password"
                color: forgotLink.pressed ? "#ddd" : "#545960"
                font.underline: forgotMouse.containsMouse
                Accessible.name: forgotLink.text
                Accessible.role: Accessible.Button
                Accessible.onPressAction: onClick()

                function onClick() {
                    forgotPopup.visible = true
                }

                MouseArea {
                    id: forgotMouse
                    anchors.fill: forgotLink
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: forgotLink.onClick()
                }
            }
        }

        Item {
            id: loginButtonContainer
            Layout.preferredHeight: loginButton.height
            Layout.preferredWidth: loginButton.width

            Button {
                id: loginButton
                width: usernameField.width
                height: usernameField.height
                text:"Login"
                activeFocusOnTab: true
                enabled: passwordField.text !== "" && usernameField.text !== ""

                background: Rectangle {
                    color: !loginButton.enabled ? "#dbdbdb" : loginButton.down ? "#666" : "#545960"

                    Rectangle {
                        color: "transparent"
                        anchors {
                            fill: parent
                        }
                        border.width: 2
                        border.color: "white"
                        opacity: .5
                        visible: loginButton.focus
                    }
                }

                contentItem: Text {
                    text: loginButton.text
                    color: !loginButton.enabled ? "#f2f2f2" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font {
                        pixelSize: 15
                        family: Fonts.franklinGothicBook
                    }
                }

                onClicked: {
                    loginControls.visible = false
                    var timezone = -(new Date(new Date().getFullYear(), 0, 1)).getTimezoneOffset()/60
                    // API currently accepts an int, round towards zero:
                    if (timezone < 0) {
                        timezone = Math.ceil(timezone)
                    } else {
                        timezone = Math.floor(timezone)
                    }
                    var login_info = { user: usernameField.text, password: passwordField.text, timezone: timezone }
                    connectionStatus.currentId = LoginUtils.getNextId()
                    LoginUtils.login(login_info)
                }

                Keys.onReturnPressed:{
                    loginButton.submit()
                }
                Accessible.onPressAction: submit()

                function submit() {
                    if (loginButton.enabled) {
                        loginButton.clicked()
                    }
                }

                MouseArea {
                    id: loginButtonMouse
                    anchors.fill: loginButton
                    onPressed:  mouse.accepted = false
                    cursorShape: Qt.PointingHandCursor
                }

                ToolTip {
                    text: {
                        var result = ""

                        if (usernameField.text === "" ){
                            result += "Username required"
                        }
                        if (passwordField.text === "" ){
                            result += (result === "" ? "" : "<br>")
                            result += "Password required"
                        }
                        return result
                    }
                    visible: loginToolTipShow.containsMouse && !loginButton.enabled && !forgotPopup.visible
                }
            }

            MouseArea {
                id: loginToolTipShow
                anchors.fill: loginButton
                hoverEnabled: true
                visible: !loginButton.enabled
            }
        }
    }

    ConnectionStatus {
        id: connectionStatus
        anchors {
            centerIn: parent
        }
        visible: !loginControls.visible
    }

    Connections {
        target: Signals
        onLoginResult: {
            var resultObject = JSON.parse(result)
            //console.log(Logger.devStudioCategory, "Login result received")
            if (resultObject.response === "Connected") {
                connectionStatus.text = "Registering Client..."
                console.log(Logger.devStudioLoginCategory, "Registering client with hcs")

                registerClient(
                            function(result) {
                                console.log(Logger.devStudioLoginCategory, "Registration with server was successful")

                                connectionStatus.text = "Connected, Loading UI..."
                                usernameField.updateModel()
                                sessionControls.loginSuccess(resultObject)

                                let data = {
                                    "user_id": resultObject.user_id,
                                    "first_name":resultObject.first_name,
                                    "last_name": resultObject.last_name
                                }
                                NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
                                sdsModel.hcsErrorTracker.clearErrors()
                                sdsModel.hcsErrorTracker.checkHcsStatus()
                            },
                            function(error) {
                                console.log("Registration with server failed", JSON.stringify(error))
                                showLoginError("Registration with Host Controller Service failed.")
                            })
            } else {
                if (resultObject.response === "No Connection") {
                    var errorString = "Connection to authentication server failed. Please check your internet connection and try again."
                } else if (resultObject.response === "Server Error") {
                    errorString = "Authentication server is unable to process your request at this time. Please try again later."
                } else {
                    errorString = "Username and/or password is incorrect. Please try again."
                }

                showLoginError(errorString);
            }
        }
    }

    function showLoginError(errorString) {
        loginControls.visible = true
        connectionStatus.text = ""
        loginErrorRect.color = Theme.palette.error
        loginErrorRect.text = errorString
        loginErrorRect.show()
    }

    function registerClient(callbackResult, callbackError) {
        var reply = sdsModel.strataClient.sendRequest("register_client", {"api_version":"2.0"});

        reply.finishedSuccessfully.connect(function(result) {
            callbackResult(result)
        })

        reply.finishedWithError.connect(function(error) {
            callbackError(error)
        })
    }
}
