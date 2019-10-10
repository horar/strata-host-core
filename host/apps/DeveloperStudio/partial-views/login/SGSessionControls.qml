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
            if (jwtSettings.token !== "") {
                Authenticator.set_token(jwtSettings.token)
                Authenticator.validate_token()
            } else {
                showLogin()
            }
        } else {
            // if not startup, user has logged out
            console.log(LoggerModule.Logger.devStudioLoginCategory, "logged out!")
            jwtSettings.token = ""
            showLogin()
        }
    }

    function showLogin() {
        loginControls.visible = true
        root.visible = false
    }

    Settings {
        id: jwtSettings
        category: "JWT"
        property string token: ""
    }

    ConnectionStatus {
        id: connectionStatus
        headerText: "Renewing session..."
    }

    Connections {
        target: Authenticator.signals

        onLoginJWT: {
            jwtSettings.token = jwt_string
        }

        onValidationResult: {
            if (result === "Current token is valid") {
                console.log(LoggerModule.Logger.devStudioLoginCategory, "Previous session token validated")
                connectionStatus.text = "Authenticated, Loading UI..."

                // derive email from JWT
                var token = jwtSettings.token
                var base64Url = token.split('.')[1];
                var base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');anchors
                var jsonPayload = decodeURIComponent(Qt.atob(base64).split('').map(function(c) {
                    return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
                }).join(''));
                jsonPayload = JSON.parse(jsonPayload)

                var data = { user_id: jsonPayload._id }
                NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
            } else if (result === "Invalid authentication token") {
                console.info(LoggerModule.Logger.devStudioLoginCategory, "Previous session token not valid")
                jwtSettings.token = ""
                root.showLogin()
            } else {
                // result === "No Connection"
                console.error(LoggerModule.Logger.devStudioLoginCategory, "Unable to connect to server to validate token")
                jwtSettings.token = ""
                root.showLogin()
            }
        }
    }
}
