/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0
import tech.strata.prt.authenticator 1.0
import tech.strata.theme 1.0

FocusScope {
    id: loginScreen

    property int loginStatus: LoginScreen.Logout

    enum LoginStatus {
        Logout,
        InProgress,
        LoginSucceed,
        LoginFailed
    }

    Component.onCompleted: {
        if (prtModel.authenticator.xAccessToken.byteLength > 0) {
            prtModel.authenticator.renewSession()
        }
    }

    Keys.onPressed: {
        if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            login()
            event.accepted = true
        }
    }

    Connections {
        target: prtModel.authenticator

        onRenewSessionStarted: {
            statusText.text = "Renewing session..."
            loginStatus = LoginScreen.InProgress
        }

        onRenewSessionFinished: {
            statusText.text = ""
            if (status === true) {
                loginStatus = LoginScreen.LoginSucceed
            } else {
                if (errorString.length > 0) {
                    loginStatus = LoginScreen.LoginFailed
                    statusText.text = errorString
                } else {
                    loginStatus = LoginScreen.Logout
                }
            }
        }

        onLoginStarted: {
            loginStatus = LoginScreen.InProgress
            statusText.text = "Connecting..."
        }

        onLoginFinished: {
            if (status === true) {
                loginStatus = LoginScreen.LoginSucceed
                passwordEdit.text = ""
            } else {
                loginStatus = LoginScreen.LoginFailed
                statusText.text = errorString
            }
        }

        onLogoutStarted: {
            statusText.text = "Disconnecting..."
            loginStatus = LoginScreen.InProgress
        }

        onLogoutFinished: {
            loginStatus = LoginScreen.Logout
            statusText.text = ""
        }
    }

    Image {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: contentColumn.top
            bottomMargin: 20
        }

        width: 140
        height: width

        source: "qrc:/images/prt-logo.svg"
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(width, height)
    }

    Column {
        id: contentColumn
        anchors {
            top: parent.top
            topMargin: Math.floor(parent.height * 0.3)
            horizontalCenter: parent.horizontalCenter
        }

        spacing: 10

        SGWidgets.SGTextFieldEditor {
            id: usernameEdit
            itemWidth: 400
            label: "Username"
            hasHelperText: false
            contextMenuEnabled: true
            text: prtModel.authenticator.username
            enabled: loginStatus === LoginScreen.Logout
                     || loginStatus === LoginScreen.LoginFailed
        }

        SGWidgets.SGTextFieldEditor {
            id: passwordEdit
            itemWidth: usernameEdit.itemWidth
            label: "Password"
            passwordMode: true
            hasHelperText: false
            contextMenuEnabled: true
            enabled: usernameEdit.enabled
        }

        SGWidgets.SGCheckBox {
            id: autoLoginCheckbox
            text: "Auto login"
            leftPadding: 0
            enabled: usernameEdit.enabled

            Component.onCompleted: {
                checked = prtModel.authenticator.xAccessToken.byteLength > 0
            }
        }

        Item {
            width: parent.width
            height: statusText.y + statusText.height

            Item {
                id: statusIndicator
                width: 50
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter

                BusyIndicator {
                    id: busyIndicator
                    width: parent.width
                    height: parent.height

                    running: loginStatus === LoginScreen.InProgress
                }

                SGWidgets.SGIcon {
                    id: iconIndicator
                    width: parent.width
                    height: width

                    source: {
                        if (loginStatus === LoginScreen.LoginSucceed) {
                            return "qrc:/sgimages/check.svg"
                        } else if (loginStatus === LoginScreen.LoginFailed) {
                            return "qrc:/sgimages/times-circle.svg"
                        }

                        return ""
                    }

                    iconColor: {
                        if (loginStatus === LoginScreen.LoginSucceed) {
                            return TangoTheme.palette.chameleon2
                        } else if (loginStatus === LoginScreen.LoginFailed) {
                            return TangoTheme.palette.scarletRed2
                        }

                        return "black"
                    }
                }
            }

            SGWidgets.SGTag {
                id: statusText
                anchors {
                    top: statusIndicator.bottom
                    topMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }

                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                textColor: {
                    if (loginStatus === LoginScreen.LoginFailed) {
                        return "white"
                    }

                    return statusText.implicitTextColor
                }

                color: {
                    if (loginStatus === LoginScreen.LoginFailed) {
                        return TangoTheme.palette.error
                    }

                    return "transparent"
                }
            }
        }

        SGWidgets.SGButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Log In"
            icon.source: "qrc:/sgimages/sign-in.svg"
            enabled: usernameEdit.enabled
            onClicked: {
                login()
            }
        }
    }

    function login() {
        if (usernameEdit.enabled === false) {
            return
        }

        prtModel.authenticator.login(usernameEdit.text, passwordEdit.text, autoLoginCheckbox.checked);
    }
}
