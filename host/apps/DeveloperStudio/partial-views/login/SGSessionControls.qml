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

    ConnectionStatus {
        id: connectionStatus
        headerText: "Renewing session..."
    }

    Connections {
        target: Signals

        onLoginResult: {
            var resultObject = JSON.parse(result)
            if (resultObject.response === "Connected") {
                Authenticator.settings.token = resultObject.jwt
                Authenticator.settings.first_name = resultObject.first_name
                Authenticator.settings.last_name = resultObject.last_name
                Authenticator.settings.user = resultObject.user_id
            }
        }

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
            } else if (result === "Invalid authentication token") {
                console.info(LoggerModule.Logger.devStudioLoginCategory, "Previous session token not valid")
            } else {
                // result === "No Connection"
                console.error(LoggerModule.Logger.devStudioLoginCategory, "Unable to connect to server to validate token")
            }
            Authenticator.settings.clear()
            root.showLogin()
        }
    }
}
