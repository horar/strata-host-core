import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.prt 1.0 as PrtCommon
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {
    id: prtMain

    property int currentPage: PrtMain.LoginPage
    property alias prtModel: prtModel

    enum LoginStatus {
        LoginPage,
        WizardPage
    }

    PrtCommon.PrtModel {
        id: prtModel
    }

    Connections {
        target: prtModel.authenticator

        onLoginFinished: {
            if (status === true) {
                delayWizardPushTimer.start()
            }
        }

        onLogoutStarted: {
            stackView.pop(null)
        }

        onRenewSessionFinished: {
            if (status === true) {
                delayWizardPushTimer.start()
            }
        }
    }

    //some delay to finish login animation
    Timer {
        id: delayWizardPushTimer
        interval: 500
        onTriggered: {
            stackView.push(settingsComponent)
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent

        focus: true
        initialItem: loginPageComponent
        pushEnter: null
        pushExit: null
        popEnter: null
        popExit: null
    }

    Component {
        id: loginPageComponent

        LoginScreen {
            focus: true
        }
    }

    Component {
        id: settingsComponent

        ProgramSettingsWizard {
            focus: true
            prtModel: prtMain.prtModel

            onRegistrationEmbeddedRequested: {
                console.log("not implemented yet")
            }

            onRegistrationAssistedAndControllerRequested: {
                console.log("not implemented yet")
            }

            onRegistrationControllerRequested: {
                console.log("not implemented yet")
            }

            function startRegistrationProcess() {
                //TODO implement in future tickets

                stackView.push(wizardComponent)
            }
        }
    }

    Component {
        id: wizardComponent

        ProgramDeviceWizard {
            focus: true
            prtModel: prtMain.prtModel
        }
    }

    UserMenuButton {
        id: userMenuButton
        anchors {
            top: parent.top
            topMargin: 8
            right: parent.right
            rightMargin: 8
        }

        visible: stackView.depth > 1
    }

    Rectangle {
        id: testServerWarningContainer
        anchors {
            right: userMenuButton.left
            rightMargin: 10
            verticalCenter: userMenuButton.verticalCenter
        }
        height: testServerWarningRow.height + 10
        width: testServerWarningRow.width + 16

        color: TangoTheme.palette.error
        radius: 5
        visible: prtModel.serverType !== "production"

        Row {
            id: testServerWarningRow
            anchors.centerIn: parent

            spacing: 5
            SGWidgets.SGIcon {
                id: testServerWarningIcon
                height: testServerWarning.height
                width: height

                iconColor: "white"
                source: "qrc:/sgimages/exclamation-circle.svg"
            }

            SGWidgets.SGText {
                id: testServerWarning
                
                alternativeColorEnabled: true
                font.bold: true
                text: "Non-production server in use."
            }            
        }
    }
}
