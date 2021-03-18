import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.prt 1.0 as PrtCommon
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

import "./jsonSchemas.js" as JsonSchemas

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
            id: settingsWizard
            focus: true
            prtModel: prtMain.prtModel

            onRegistrationEmbeddedRequested: {
                console.log("EMBEDDED")
                var properties = {
                    "registrationMode": ProgramDeviceWizard.Embedded,
                    "jlinkExePath": settingsWizard.jlinkExePath,
                    "embeddedData": settingsWizard.embeddedData,
                }

                console.log("jLinkExePath", properties.jLinkExePath)
                startRegistrationProcess(properties)
            }

            onRegistrationAssistedAndControllerRequested: {
                console.log("not implemented yet")
            }

            onRegistrationControllerRequested: {
                console.log("not implemented yet")
            }

            function startRegistrationProcess(properties) {
                //TODO implement in future tickets

                stackView.push(programWizardComponent, properties)
            }
        }
    }

    Component {
        id: programWizardComponent

        ProgramDeviceWizard {
            focus: true
            prtModel: prtMain.prtModel

            //TEMPORARY just to skip settings step
//            registrationMode: ProgramDeviceWizard.Embedded
//            embeddedData: JsonSchemas.fakeEmbeddedData
//            jlinkExePath: "/Applications/SEGGER/JLink/JLinkExe"
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
        visible: prtModel.debugBuild ? prtModel.serverType === "production" : prtModel.serverType !== "production"

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
                text: prtModel.debugBuild ? "Production server in use" : "Non-production server in use"
            }            
        }
    }

    function resolveFirmwareAndBootloader(registrationMode, embeddedData, assistedData, controllerData) {

        if (registrationMode === ProgramDeviceWizard.Embedded) {
            latestFirmwareIndex =

            console.log("best firmware:", embeddedData.firmware[latestFirmwareIndex].version, embeddedData.firmware[latestFirmwareIndex].timestamp)

        } else if (registrationMode === ProgramDeviceWizard.ControllerAndAssisted) {

        } else if (registrationMode === ProgramDeviceWizard.ControllerOnly) {

        }
    }


}
