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

    Rectangle {
        id: testServerWarningContainer
        color: "red"
        anchors {
            left: parent.left
            right: undefined
            top: parent.top
            margins: 30
        }
        height: testServerWarning.height + 30
        width: parent.width/3.5
        visible: prtModel.serverType !== "prod"

        Text {
            id: testServerWarning
            color: "white"
            font.bold: true
            anchors {
                centerIn: parent
            }
            text: "Non-production server in use."
        }
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
