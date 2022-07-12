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
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.logger 1.0
import tech.strata.theme 1.0
import QtQml.StateMachine 1.12 as DSM
import "./jsonSchemas.js" as JsonSchemas

FocusScope {
    id: wizard

    clip: true

    property var latestData: ({})

    property var embeddedData: ({})
    property var assistedData: ({})
    property var controllerData: ({})

    property string jlinkExePath

    signal registrationEmbeddedRequested()
    signal registrationAssistedAndControllerRequested()
    signal registrationControllerRequested()

    ListModel {
        id: wizardModel
        dynamicRoles: true
    }

    QtLabsSettings.Settings {
        id: settings
        category: "app"

        property alias jlinkExePath: wizard.jlinkExePath
    }

    CommonCpp.SGJLinkConnector {
        id: jlinkConnectorHelper
        exePath: wizard.jlinkExePath
    }

    DSM.StateMachine {
        id: stateMachine

        running: true
        initialState: stateStep1

        signal findPlatformReplyNotValid(string errorString)
        signal findPlatformOpnValid(int controllerType)
        signal findPlatformOpnNotValid(string errorString)

        DSM.State {
            id: stateStep1

            initialState: stateWaitForUserOpn

            onEntered: {
                firstOpnDelegate.title = "Orderable Part Number"
                firstOpnDelegate.isSet = false
                firstOpnDelegate.show()
            }

            DSM.State {
                id: stateWaitForUserOpn

                onEntered: {
                    wizard.embeddedData = {}
                    wizard.assistedData = {}
                    wizard.controllerData = {}
                }

                DSM.SignalTransition {
                    targetState: stateWaitForFindPlatform
                    signal: firstOpnDelegate.checkOpnRequested
                    onTriggered: {
                        firstOpnDelegate.isSearching = true
                        wizard.findPlatform(opn)
                    }
                }
            }

            DSM.State {
                id: stateWaitForFindPlatform

                onExited: {
                    firstOpnDelegate.isSearching = false
                }

                DSM.SignalTransition {
                    targetState: stateEmbeddedStep2
                    signal: stateMachine.findPlatformOpnValid
                    guard: controllerType === 1
                    onTriggered: {
                        wizard.embeddedData = wizard.latestData
                    }
                }

                DSM.SignalTransition {
                    targetState: stateAssistedStep2
                    signal: stateMachine.findPlatformOpnValid
                    guard: controllerType === 2
                    onTriggered: {
                        wizard.assistedData = wizard.latestData
                    }
                }

                DSM.SignalTransition {
                    targetState: stateControllerStep2
                    signal: stateMachine.findPlatformOpnValid
                    guard: controllerType === 3
                    onTriggered: {
                        wizard.controllerData = wizard.latestData
                    }
                }

                DSM.SignalTransition {
                    targetState: stateWaitForUserOpn
                    signal: stateMachine.findPlatformOpnNotValid
                    onTriggered: {
                        firstOpnDelegate.isSet = false
                        firstOpnDelegate.errorText = errorString
                    }
                }

                DSM.SignalTransition {
                    targetState: stateWaitForUserOpn
                    signal: stateMachine.findPlatformReplyNotValid
                    onTriggered: {
                        firstOpnDelegate.isSet = false
                        firstOpnDelegate.errorText = errorString
                    }
                }
            }
        }

        DSM.State {
            id: stateEmbeddedStep2
            onEntered: {
                firstOpnDelegate.titleWhenSet = "Embedded Platform OPN"
                firstOpnDelegate.isSet = true

                jlinkPathDelegate.jlinkExePath = wizard.jlinkExePath
                jlinkPathDelegate.show()
            }

            DSM.SignalTransition {
                targetState: stateStep1
                signal: backButton.clicked
                onTriggered: {
                    wizard.jlinkExePath = jlinkPathDelegate.isSet ? jlinkPathDelegate.jlinkExePath : ""
                    jlinkPathDelegate.hide()
                }
            }

            DSM.SignalTransition {
                signal: beginButton.clicked
                onTriggered: {
                    wizard.jlinkExePath = jlinkPathDelegate.jlinkExePath
                    wizard.registrationEmbeddedRequested()
                }
            }
        }

        DSM.State {
            id: stateAssistedStep2

            initialState: stateAssistedStep2Wait

            onEntered: {
                firstOpnDelegate.titleWhenSet = "Assisted Platform OPN"
                firstOpnDelegate.isSet = true

                secondOpnDelegate.title = "Controller Platform OPN"
                secondOpnDelegate.titleWhenSet = "Controller Platform OPN"
                secondOpnDelegate.isSet = false
                secondOpnDelegate.show()
            }

            DSM.SignalTransition {
                targetState: stateStep1
                signal: backButton.clicked
                onTriggered: {
                    secondOpnDelegate.hide()
                    secondOpnDelegate.opn = ""
                }
            }

            DSM.State {
                id: stateAssistedStep2Wait

                onEntered: {
                    wizard.controllerData = {}
                }

                DSM.SignalTransition {
                    targetState: stateAssistedStep2WaitForResult
                    signal: secondOpnDelegate.checkOpnRequested
                    onTriggered: {
                        secondOpnDelegate.isSearching = true
                        wizard.findPlatform(opn)
                    }
                }
            }

            DSM.State {
                id: stateAssistedStep2WaitForResult

                onExited: {
                    secondOpnDelegate.isSearching = false
                }

                DSM.SignalTransition {
                    targetState: stateAssistedStep3
                    signal: stateMachine.findPlatformOpnValid
                    guard: controllerType === 3
                    onTriggered: {
                        secondOpnDelegate.isSet = true
                        wizard.controllerData = wizard.latestData
                    }
                }

                DSM.SignalTransition {
                    targetState: stateAssistedStep2Wait
                    signal: stateMachine.findPlatformOpnValid
                    guard: controllerType !== 3
                    onTriggered: {
                        secondOpnDelegate.errorText = "OPN of controller platform is required."
                    }
                }

                DSM.SignalTransition {
                    targetState: stateAssistedStep2Wait
                    signal: stateMachine.findPlatformOpnNotValid
                    onTriggered: {
                        secondOpnDelegate.isSet = false
                        secondOpnDelegate.errorText = errorString
                    }
                }

                DSM.SignalTransition {
                    targetState: stateAssistedStep2Wait
                    signal: stateMachine.findPlatformReplyNotValid
                    onTriggered: {
                        secondOpnDelegate.isSet = false
                        secondOpnDelegate.errorText = errorString
                    }
                }
            }
        }

        DSM.State {
            id: stateControllerStep2
            onEntered: {
                firstOpnDelegate.titleWhenSet = "Controller Platform OPN"
                firstOpnDelegate.isSet = true
                onlyControllerQuestionDelegate.show()
            }

            DSM.SignalTransition {
                targetState: stateControllerStep3A
                signal: onlyControllerQuestionDelegate.userResponse
                guard: onlyController === true
                onTriggered: {
                    onlyControllerQuestionDelegate.hide()
                }
            }

            DSM.SignalTransition {
                targetState: stateControllerStep3B
                signal: onlyControllerQuestionDelegate.userResponse
                guard: onlyController === false
                onTriggered: {
                    onlyControllerQuestionDelegate.hide()
                }
            }

            DSM.SignalTransition {
                targetState: stateStep1
                signal: backButton.clicked
                onTriggered: {
                    onlyControllerQuestionDelegate.hide()
                }
            }
        }

        DSM.State {
            id: stateControllerStep3A
            onEntered: {
                jlinkPathDelegate.jlinkExePath = wizard.jlinkExePath
                jlinkPathDelegate.show()
            }

            DSM.SignalTransition {
                targetState: stateControllerStep2
                signal: backButton.clicked
                onTriggered: {
                    wizard.jlinkExePath = jlinkPathDelegate.isSet ? jlinkPathDelegate.jlinkExePath : ""
                    jlinkPathDelegate.hide()
                }
            }

            DSM.SignalTransition {
                signal: beginButton.clicked
                onTriggered: {
                    wizard.jlinkExePath = jlinkPathDelegate.jlinkExePath
                    wizard.registrationControllerRequested()
                }
            }
        }

        DSM.State {
            id: stateAssistedStep3

            onEntered: {
                jlinkPathDelegate.jlinkExePath = wizard.jlinkExePath
                jlinkPathDelegate.show()
            }

            DSM.SignalTransition {
                targetState: stateAssistedStep2
                signal: backButton.clicked
                onTriggered: {
                    wizard.jlinkExePath = jlinkPathDelegate.isSet ? jlinkPathDelegate.jlinkExePath : ""
                    jlinkPathDelegate.hide()
                }
            }

            DSM.SignalTransition {
                signal: beginButton.clicked
                onTriggered: {
                    wizard.jlinkExePath = jlinkPathDelegate.jlinkExePath
                    wizard.registrationAssistedAndControllerRequested()
                }
            }
        }

        DSM.State {
            id: stateControllerStep3B

            initialState: stateControllerStep3BWait

            onEntered: {
                secondOpnDelegate.title = "Assisted Platform OPN"
                secondOpnDelegate.titleWhenSet = "Assisted Platform OPN"
                secondOpnDelegate.isSet = false
                secondOpnDelegate.show()
            }

            DSM.SignalTransition {
                targetState: stateControllerStep2
                signal: backButton.clicked
                onTriggered: {
                    secondOpnDelegate.hide()
                    secondOpnDelegate.opn = ""
                }
            }

            DSM.State {
                id: stateControllerStep3BWait

                onEntered: {
                    wizard.assistedData = {}
                }

                DSM.SignalTransition {
                    targetState: stateControllerStep3BWaitForResult
                    signal: secondOpnDelegate.checkOpnRequested
                    onTriggered: {
                        secondOpnDelegate.isSearching = true
                        wizard.findPlatform(opn)
                    }
                }
            }

            DSM.State {
                id: stateControllerStep3BWaitForResult

                onExited: {
                    secondOpnDelegate.isSearching = false
                }

                DSM.SignalTransition {
                    targetState: stateControllerStep4B
                    signal: stateMachine.findPlatformOpnValid
                    guard: controllerType === 2
                    onTriggered: {
                        secondOpnDelegate.isSet = true
                        wizard.assistedData = wizard.latestData
                    }
                }

                DSM.SignalTransition {
                    targetState: stateControllerStep3BWait
                    signal: stateMachine.findPlatformOpnValid
                    guard: controllerType !== 2
                    onTriggered: {
                        secondOpnDelegate.errorText = "OPN of assisted platform is required."
                    }
                }

                DSM.SignalTransition {
                    targetState: stateControllerStep3BWait
                    signal: stateMachine.findPlatformOpnNotValid
                    onTriggered: {
                        secondOpnDelegate.isSet = false
                        secondOpnDelegate.errorText = "OPN not valid"
                    }
                }

                DSM.SignalTransition {
                    targetState: stateControllerStep3BWait
                    signal: stateMachine.findPlatformReplyNotValid
                    onTriggered: {
                        secondOpnDelegate.isSet = false
                        secondOpnDelegate.errorText = errorString
                    }
                }
            }
        }

        DSM.State {
            id: stateControllerStep4B

            onEntered: {
                jlinkPathDelegate.jlinkExePath = wizard.jlinkExePath
                jlinkPathDelegate.show()
            }

            DSM.SignalTransition {
                targetState: stateControllerStep3B
                signal: backButton.clicked
                onTriggered: {
                    wizard.jlinkExePath = jlinkPathDelegate.isSet ? jlinkPathDelegate.jlinkExePath : ""
                    jlinkPathDelegate.hide()
                }
            }

            DSM.SignalTransition {
                signal: beginButton.clicked
                onTriggered: {
                    wizard.jlinkExePath = jlinkPathDelegate.jlinkExePath
                    wizard.registrationAssistedAndControllerRequested()
                }
            }
        }
    }

    SGWidgets.SGText {
        id: header
        anchors {
            top: parent.top
            topMargin: 8
            left: parent.left
            leftMargin: 8
        }

        text: "Registration Settings"
        font.bold: true
        fontSizeMultiplier: 1.6
    }

    Column {
        id: contentColumn

        anchors {
            right: parent.right
            left: parent.left
            top: header.bottom
            margins: 8
        }

        spacing: 4

        ProgramSettingsOpnDelegate {
            id: firstOpnDelegate
            width: parent.width
        }

        ProgramSettingsQuestionDelegate {
            id: onlyControllerQuestionDelegate
            width: parent.width
        }

        ProgramSettingsOpnDelegate {
            id: secondOpnDelegate
            width: parent.width
        }

        ProgramSettingsJlinkPathDelegate {
            id: jlinkPathDelegate
            width: parent.width

            jlinkConnector: jlinkConnectorHelper
        }
    }

    SGWidgets.SGButton {
        id: backButton
        anchors {
            top: contentColumn.bottom
            topMargin: 10
            left: contentColumn.left

        }
        enabled: stateStep1.active === false
        icon.source: "qrc:/sgimages/chevron-left.svg"
        text: "Back"
    }

    Row {
        id: footer
        anchors {
            bottom: parent.bottom
            margins: 12
            horizontalCenter: parent.horizontalCenter
        }

        spacing: 10

        SGWidgets.SGButton {
            id: beginButton
            text: "Begin"
            icon.source: "qrc:/sgimages/chip-flash.svg"
            enabled: jlinkPathDelegate.isSet
                     && (stateEmbeddedStep2.active
                         || stateControllerStep3A.active
                         || stateAssistedStep3.active
                         || stateControllerStep4B.active)
        }
    }

    Timer {
        id: findPlatformDelayTimer
        repeat: false
        interval: 2000

        property string opn

        onTriggered: {
            doFindPlatform(opn)
        }
    }

    function findPlatform(opn) {
        findPlatformDelayTimer.opn = opn.trim()
        findPlatformDelayTimer.restart()
    }

    function doFindPlatform(opn) {
        //opn needs to be sent in uppercase
        var endpoint = "plats/"+opn.toUpperCase()

        console.log("endpoint", endpoint)

        var deferred = prtModel.restClient.get(endpoint)

        deferred.finishedSuccessfully.connect(function(status, data) {
            console.log(Logger.prtCategory,"platform info:", status, data)

            processReplyData(opn.toLowerCase(), data);
        })

        deferred.finishedWithError.connect(function(status, errorString, data) {
            console.error(Logger.prtCategory, status, errorString, data)

            let errStr = "OPN not found"
            if (data.toString().length) {
                try {
                    var dataObject = JSON.parse(data)
                    if (dataObject.hasOwnProperty("message")) {
                        errStr = dataObject["message"]
                    }
                } catch(error) {
                    errStr = "Reply from server not valid"
                }
            }

            stateMachine.findPlatformReplyNotValid(errStr)
        })
    }

    function processReplyData(opn, dataString) {
        console.log(dataString)

        try {
            var dataObject = JSON.parse(dataString)
        } catch(error) {
            console.error(Logger.prtCategory, "cannot parse reply from server")
            stateMachine.findPlatformReplyNotValid("Reply from server not valid")
            return
        }

        if (dataObject.hasOwnProperty("controller_type") === false) {
            console.error(Logger.prtCategory, "controller_type is missing")
            stateMachine.findPlatformReplyNotValid("Reply from server not valid")
            return
        }

        var controller_type = dataObject["controller_type"]

        var validationSchema = {}
        if (controller_type === 1) {
            validationSchema = JsonSchemas.documentEmbeddedSchema
        } else if (controller_type === 2) {
            validationSchema = JsonSchemas.documentAssistedSchema
        } else if (controller_type === 3) {
            validationSchema = JsonSchemas.documentControllerSchema
        } else {
            let errStr = "Unknown controller type"
            console.error(Logger.prtCategory, errStr, controller_type)
            stateMachine.findPlatformReplyNotValid(errStr)
            return
        }

        var isValid = CommonCpp.SGUtilsCpp.validateJson(dataString, JSON.stringify(validationSchema))
        if (isValid) {
            var errStr = ""
            if (controller_type === 1 || controller_type === 2) {
                if (dataObject.hasOwnProperty("firmware") === false) {
                    errStr = "No firmware available. Platform cannot be registerd."
                }
            } else if (controller_type === 1 || controller_type === 3) {
                if (dataObject.hasOwnProperty("bootloader") === false) {
                    errStr = "No bootloader available. Platform cannot be registerd."
                }
            }

            if (errStr.length) {
                console.info(Logger.prtCategory, errStr)
                stateMachine.findPlatformOpnNotValid(errStr)
                return
            }

            wizard.latestData = dataObject
            stateMachine.findPlatformOpnValid(dataObject.controller_type)
            wizard.latestData = {}
        } else {
            let errStr = "Cannot validate OPN. Reply from server not valid."
            console.error(Logger.prtCategory, errStr)
            stateMachine.findPlatformReplyNotValid(errStr)
            return
        }
    }
}
