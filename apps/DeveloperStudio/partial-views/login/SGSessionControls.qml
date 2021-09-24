/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.7
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import Qt.labs.settings 1.0
import "qrc:/partial-views/login/"
import "qrc:/partial-views/general/"
import "qrc:/js/login_utilities.js" as Authenticator
import "qrc:/js/navigation_control.js" as NavigationControl

import tech.strata.fonts 1.0
import tech.strata.logger 1.0 as LoggerModule
import tech.strata.signals 1.0
import tech.strata.sgwidgets 1.0

Item {
    id: root
    Layout.preferredHeight: connectionStatus.implicitHeight
    Layout.preferredWidth: connectionStatus.implicitWidth
    Layout.alignment: Qt.AlignHCenter

    property bool connecting: connectionStatus.visible

    Component.onCompleted: {
        if (Authenticator.initialized === false) {
            Authenticator.initialized = true

            // on Strata startup, pass previous session JWT to Authenticator for re-validation if 'remember me' enabled
            if (Authenticator.settings.token !== "") {
                if (Authenticator.settings.rememberMe) {
                    connectionStatus.currentId = Authenticator.getNextId()
                    Authenticator.set_token(Authenticator.settings.token)
                    Authenticator.validate_token()
                    return
                }
            }
        } else {
            // if not startup, user has logged out
            console.log(LoggerModule.Logger.devStudioLoginCategory, "logged out!")
        }
        Authenticator.settings.clear()
        showLogin()
    }

    function showLogin() {
        loginControls.visible = true
        root.visible = false
    }

    function loginSuccess (resultObject) {
        Authenticator.settings.token = resultObject.jwt
        Authenticator.settings.first_name = resultObject.first_name
        Authenticator.settings.last_name = resultObject.last_name
        Authenticator.settings.user = resultObject.user_id
    }

    ConnectionStatus {
        id: connectionStatus
        headerText: "Renewing session..."
    }

    Connections {
        target: Signals

        onValidationResult: {
            if (result === "Current token is valid") {
                console.log(LoggerModule.Logger.devStudioLoginCategory, "Previous session token validated")
                connectionStatus.text = "Authenticated, Loading UI..."

                var data = {
                    "user_id": Authenticator.settings.user,
                    "first_name": Authenticator.settings.first_name,
                    "last_name": Authenticator.settings.last_name
                }
                NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
                return
            } else if (result === "No Connection") {
                console.info(LoggerModule.Logger.devStudioLoginCategory, "Unable to connect to server to validate token")
            } else if (result === "Server Error") {
                console.info(LoggerModule.Logger.devStudioLoginCategory, "Server is unable to validate your token at this time")
            } else if (result === "Invalid Authentication") {
                console.info(LoggerModule.Logger.devStudioLoginCategory, "Previous session token not valid")
            } else {
                // result === "Error"
                console.info(LoggerModule.Logger.devStudioLoginCategory, "Error while validating token")
            }
            Authenticator.settings.clear()
            root.showLogin()
        }
    }
}
