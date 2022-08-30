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
import tech.strata.theme 1.0

import "./jsonSchemas.js" as JsonSchemas

Item {
    id: prtMain

    property int currentPage: PrtMain.LoginPage
    property QtObject taskbarButtonHelper

    enum LoginStatus {
        LoginPage,
        WizardPage
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

            onPushSettingsPageRequested: {
                stackView.push(settingsComponent)
            }
        }
    }

    Component {
        id: settingsComponent

        ProgramSettingsWizard {
            id: settingsWizard
            focus: true

            onRegistrationEmbeddedRequested: {
                var properties = {
                    "registrationMode": ProgramDeviceWizard.Embedded,
                    "jlinkExePath": settingsWizard.jlinkExePath,
                    "embeddedData": settingsWizard.embeddedData,
                }

                startRegistrationProcess(properties)
            }

            onRegistrationAssistedAndControllerRequested: {
                var properties = {
                    "registrationMode": ProgramDeviceWizard.Assisted,
                    "jlinkExePath": settingsWizard.jlinkExePath,
                    "controllerData": settingsWizard.controllerData,
                    "assistedData": settingsWizard.assistedData,
                }

                startRegistrationProcess(properties)
            }

            onRegistrationControllerRequested: {
                var properties = {
                    "registrationMode": ProgramDeviceWizard.ControllerOnly,
                    "jlinkExePath": settingsWizard.jlinkExePath,
                    "controllerData": settingsWizard.controllerData,
                }

                startRegistrationProcess(properties)
            }

            function startRegistrationProcess(properties) {
                stackView.push(programWizardComponent, properties)
            }
        }
    }

    Component {
        id: programWizardComponent

        ProgramDeviceWizard {
            focus: true
            taskbarButton: prtMain.taskbarButtonHelper

            StackView.onActivated: {
                prtModel.startDeviceScan()
            }

            StackView.onDeactivated: {
                prtModel.stopDeviceScan()
            }
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
}
