import QtQuick 2.7
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import Qt.labs.settings 1.0
import "qrc:/partial-views/login/"
import "qrc:/js/login_utilities.js" as Authenticator
import "qrc:/js/navigation_control.js" as NavigationControl

import tech.strata.fonts 1.0
import tech.strata.logger 1.0 as LoggerModule
import tech.strata.sgwidgets 1.0

Item {
    id: root
    Layout.preferredHeight: connectionStatus.implicitHeight
    Layout.preferredWidth: connectionStatus.implicitWidth
    Layout.alignment: Qt.AlignHCenter

    property bool connecting: connectionStatus.visible

    Component.onCompleted: {
        if (!Authenticator.initialized) {
            // on Strata startup, pass previous session JWT to Authenticator for re-validation
            Authenticator.initialized = true
            if (authSettings.token !== "") {
                Authenticator.set_token(authSettings.token)
                Authenticator.validate_token()
            } else {
                showLogin()
            }
        } else {
            // if not startup, user has logged out
            console.log(LoggerModule.Logger.devStudioLoginCategory, "logged out!")
            clearAuthSettings()
            showLogin()
        }
    }

    function showLogin() {
        loginControls.visible = true
        root.visible = false
    }

    function clearAuthSettings () {
        authSettings.token = ""
        authSettings.first_name = ""
        authSettings.last_name = ""
        authSettings.user = ""
    }

    Settings {
        id: authSettings
        category: "Login"
        property string token: ""
        property string first_name: ""
        property string last_name: ""
        property string user: ""
    }

    ConnectionStatus {
        id: connectionStatus
        headerText: "Renewing session..."
    }

    Connections {
        target: Authenticator.signals

        onLoginResult: {
            var resultObject = JSON.parse(result)
            if (resultObject.response === "Connected") {
                authSettings.token = resultObject.jwt
                authSettings.first_name = resultObject.first_name
                authSettings.last_name = resultObject.last_name
                authSettings.user = resultObject.user_id
            }
        }

        onValidationResult: {
            if (result === "Current token is valid") {
                console.log(LoggerModule.Logger.devStudioLoginCategory, "Previous session token validated")
                connectionStatus.text = "Authenticated, Loading UI..."

                var data = { "user_id": authSettings.user, "first_name": authSettings.first_name, "last_name": authSettings.last_name }
                NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
            } else if (result === "Invalid authentication token") {
                console.info(LoggerModule.Logger.devStudioLoginCategory, "Previous session token not valid")
                clearAuthSettings()
                root.showLogin()
            } else {
                // result === "No Connection"
                console.error(LoggerModule.Logger.devStudioLoginCategory, "Unable to connect to server to validate token")
                clearAuthSettings()
                root.showLogin()
            }
        }
    }
}
