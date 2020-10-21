import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.prt 1.0 as PrtCommon
import tech.strata.sgwidgets 1.0 as SGWidgets

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
}
