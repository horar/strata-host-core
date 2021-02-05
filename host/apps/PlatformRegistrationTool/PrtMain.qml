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
            stackView.push(wizardComponent)
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
        id: wizardComponent

        ProgramDeviceWizard {
            focus: true
            prtModel: prtMain.prtModel
        }
    }

 Rectangle {
        id: testServerWarningContainer
        anchors {
            left: parent.left 
            top: parent.top
            margins: 10
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

                iconColor: TangoTheme.palette.white
                source: "qrc:/sgimages/exclamation-circle.svg"
            }

            SGWidgets.SGText {
                id: testServerWarning
                
                color: TangoTheme.palette.white
                font.bold: true
                text: "Non-production server in use."
            }            
        }
    }
}
