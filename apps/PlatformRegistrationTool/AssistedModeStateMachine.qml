/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQml 2.12
import QtQml.StateMachine 1.12 as DSM
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.logger 1.0

BaseStateMachine {
    id: stateMachine

    property bool stateDownloadActive: stateDownload.active
    property bool stateControllerCheckActive: stateControllerCheck.active
    property bool stateControllerRegistrationActive: stateControllerRegistration.active
    property bool stateControllerAlreadyRegisteredActive: stateControllerAlreadyRegistered.active
    property bool stateAssistedDeviceCheckActive: stateAssistedDeviceCheck.active
    property bool stateAssistedDeviceRegistrationActive: stateAssistedDeviceRegistration.active
    property bool stateErrorActive: stateError.active
    property bool stateLoopFailedActive: stateLoopFailed.active
    property bool stateLoopSucceedActive: stateLoopSucceed.active

    property string statusText
    property string bottomLeftText
    property string internalSubtext: ""
    property string subtext: {
        var t = ""
        if (stateCheckDeviceCount.active || stateWaitForController.active) {
            t = "Connect single controller with MCU "+ jlinkDevice.toUpperCase()

            if (prtModel.deviceCount > 1) {
                t += "\n"
                t += "Multiple devices detected !"
            }
        } else if (stateWaitForJLink.active) {
            t = "Connect single JLink Base to program device"
        } else if (stateControllerAlreadyRegistered.active) {
            t = "controller already registered"
        } else if (stateControllerRegistration.active) {
            t = internalSubtext
            t += "\n\n"
            t += "Do not unplug controller or JLink Base"
        } else if (stateAssistedDeviceCheck.active) {
            if (controllerWasRegistered) {
                t = "Controller succesfully registered as\n" + controllerOpn.toUpperCase() + "\n"
            } else {
                t = "Controller\n" + controllerOpn.toUpperCase() + "\n\n"
            }

            t += "Connect assisted device into controller"
        } else if (stateAssistedDeviceRegistration.active) {
            t = internalSubtext
            t += "\n\n"
            t += "Do not unplug controller, assisted device or JLink Base"
        } else if (stateLoopSucceed.active) {
            t = "Controller\n" + controllerOpn.toUpperCase() + "\n\n"
            t += "Assisted device\n" + assistedDeviceOpn.toUpperCase() + "\n\n"
            t += "You can unplug controller now\n\n"
            t += "To program another device, simply plug it in and process will start automatically\n\n"
            t += "or press End to finish current session"
        } else if (stateLoopFailed.active) {
            t = internalSubtext
            t += "\n\n"
            t += "Unplug device and press Continue"
        } else if (stateError.active) {
            t = internalSubtext
        }

        return t
    }

    running: false
    initialState: stateValidateInput

    property QtObject prtModel
    property QtObject jLinkConnector
    property QtObject breakButton
    property QtObject continueButton
    property QtObject taskbarButton

    property string jlinkExePath: ""
    property var firmwareData: ({})
    property var bootloaderData: ({})

    property string assistedDeviceClassId: ""
    property string assistedDeviceOpn: ""

    property string controllerClassId: ""
    property string controllerOpn: ""

    property string jlinkDevice: ""
    property int bootloaderStartAddress: -1

    property bool controllerWasRegistered

    signal exitWizardRequested()

    //internal stuff
    signal settingsValid()
    signal settingsInvalid(string errorString)
    signal deviceCountValid()
    signal deviceCountInvalid()
    signal jlinkProcessFailed()
    signal controllerRegistered()
    signal controllerNotRegistered()

    signal assistedDeviceConnected()
    signal assistedDeviceNotConnected()
    signal controllerNotConnected()


    DSM.State {
        id: stateValidateInput

        onEntered: {
            prtModel.clearBinaries();
            taskbarButton.progress.resume()
            taskbarButton.progress.show()

            var errorString = ""
            if (jlinkExePath.length === 0) {
                errorString = "Path to JLink.exe not set"
            } else if (Object.keys(firmwareData).length === 0) {
                errorString = "No valid firmware available"
            } else if (Object.keys(bootloaderData).length === 0) {
                errorString = "No valid bootloader available"
            } else if (assistedDeviceClassId.length === 0) {
                errorString = "Platform class id not set"
            } else if (assistedDeviceOpn.length === 0) {
                errorString = "Platform OPN not set"
            } else if (controllerClassId.length === 0) {
                errorString = "Controller class id not set"
            } else if (controllerOpn.length === 0) {
                errorString = "Controller OPN not set"
            } else if (jlinkDevice.length === 0) {
                errorString = "MCU device type not set"
            } else if (bootloaderStartAddress < 0) {
                errorString = "Bootloader start address not set"
            }

            if (errorString.length > 0) {
                console.error(Logger.prtCategory, "settings are not valid:", errorString)
                stateMachine.settingsInvalid(errorString)
            } else {
                stateMachine.settingsValid()
            }
        }

        DSM.SignalTransition {
            targetState: stateDownload
            signal: stateMachine.settingsValid
        }

        DSM.SignalTransition {
            targetState: stateError
            signal: stateMachine.settingsInvalid
            onTriggered: {
                stateMachine.internalSubtext = errorString
            }
        }
    }

    DSM.State {
        id: stateDownload

        onEntered: {
            stateMachine.statusText = "Downloading"

            console.debug(Logger.prtCategory, "binaries download about to start")
            prtModel.downloadBinaries(
                        stateMachine.bootloaderData.file,
                        stateMachine.bootloaderData.md5,
                        stateMachine.firmwareData.file,
                        stateMachine.firmwareData.md5)
        }

        DSM.SignalTransition {
            targetState: exitState
            signal: breakButton.clicked
            onTriggered: {
                prtModel.abortDownload()
            }
        }

        DSM.SignalTransition {
            targetState: stateControllerCheck
            signal: prtModel.downloadFirmwareFinished
            guard: errorString.length === 0
            onTriggered: {
                console.debug(Logger.prtCategory, "binaries download finished succesfully",)
            }
        }

        DSM.SignalTransition {
            targetState: stateError
            signal: prtModel.downloadFirmwareFinished
            guard: errorString.length > 0
            onTriggered: {
                console.error(Logger.prtCategory, "download failed:", errorString)
                stateMachine.internalSubtext = errorString
            }
        }
    }

    DSM.State {
        id: stateControllerCheck

        initialState: stateCheckDeviceCount

        DSM.SignalTransition {
            targetState: exitState
            signal: breakButton.clicked
        }

        DSM.SignalTransition {
            targetState: stateWaitForController
            signal: prtModel.deviceCountChanged
            guard: prtModel.deviceCount !== 1
        }

        DSM.State {
            id: stateCheckDeviceCount
            onEntered: {
                stateMachine.statusText = "Waiting for controller"
                taskbarButton.progress.resume()
                taskbarButton.progress.pause()
                taskbarButton.progress.show()

                console.debug(Logger.prtCategory, "device count:", prtModel.deviceCount)

                if (prtModel.deviceCount === 1) {
                    stateMachine.deviceCountValid()
                } else {
                    stateMachine.deviceCountInvalid()
                }
            }

            DSM.SignalTransition {
                targetState: stateDelayControllerCheck
                signal: stateMachine.deviceCountValid
            }

            DSM.SignalTransition {
                targetState: stateWaitForController
                signal: stateMachine.deviceCountInvalid
            }
        }

        DSM.State {
            id: stateDelayControllerCheck
            DSM.TimeoutTransition {
                targetState: stateCheckIfControllerAlreadyRegistered
                timeout: 1000
            }
        }

        DSM.State {
            id: stateWaitForController
            onEntered: {
                stateMachine.statusText = "Waiting for controller"
                console.debug(Logger.prtCategory, "waiting for controller")
            }

            DSM.SignalTransition {
                targetState: stateCheckIfControllerAlreadyRegistered
                signal: prtModel.deviceCountChanged
                guard: prtModel.deviceCount === 1
            }
        }

        DSM.State {
            id: stateCheckIfControllerAlreadyRegistered

            onEntered: {
                if (prtModel.deviceControllerPlatformId().length > 0 && prtModel.deviceControllerClassId().length > 0) {
                    if (stateMachine.controllerClassId === prtModel.deviceControllerClassId()) {
                         stateMachine.controllerRegistered()
                    } else {
                        console.warn(Logger.prtCategory, "controller is already registered with wrong class_id", prtModel.deviceControllerClassId())
                        stateMachine.controllerNotRegistered()
                    }
                } else {
                    stateMachine.controllerNotRegistered()
                }
            }

            DSM.SignalTransition {
                targetState: stateWaitForJLink
                signal: stateMachine.controllerNotRegistered
            }

            DSM.SignalTransition {
                targetState: stateControllerAlreadyRegistered
                signal: stateMachine.controllerRegistered
            }
        }

        DSM.State {
            id: stateWaitForJLink

            initialState: stateCheckJLinkConnection

            property var outputInfo: ({})

            onEntered: {
                stateWaitForJLink.outputInfo = {}
                stateMachine.statusText = "Waiting for JLink connection"
                jLinkConnector.device = stateMachine.jlinkDevice
                jLinkConnector.startAddress = stateMachine.bootloaderStartAddress

                console.debug(Logger.prtCategory, "waiting for jlink")
            }

            DSM.State {
                id: stateCheckJLinkConnection

                onEntered: {
                    var run = jLinkConnector.checkConnectionRequested()
                    if (run === false) {
                        stateMachine.jlinkProcessFailed()
                    }
                }

                DSM.SignalTransition {
                    targetState: stateControllerRegistration
                    signal: jLinkConnector.checkConnectionProcessFinished
                    guard: exitedNormally && connected
                    onTriggered: {
                        stateWaitForJLink.outputInfo = jLinkConnector.latestOutputInfo()
                    }
                }

                DSM.SignalTransition {
                    targetState: stateCallJlinkCheckWithDelay
                    signal: stateMachine.jlinkProcessFailed
                }

                DSM.SignalTransition {
                    targetState: stateCallJlinkCheckWithDelay
                    signal: jLinkConnector.checkConnectionProcessFinished
                    guard: exitedNormally === false || connected === false
                }
            }

            DSM.State {
                id: stateCallJlinkCheckWithDelay
                DSM.TimeoutTransition {
                    targetState: stateCheckJLinkConnection
                    timeout: 2000
                }
            }
        }
    }


    DSM.State {
        id: stateControllerAlreadyRegistered

        onEntered: {
            stateMachine.controllerWasRegistered = false
            stateMachine.statusText = "Registering Controller"

            console.debug(Logger.prtCategory, "controller already registered")
        }

        DSM.TimeoutTransition {
            targetState: stateAssistedDeviceCheck
            timeout: 1000
        }
    }

    DSM.State {
        id: stateControllerRegistration

        initialState: stateProgramBootloader

        property string currentPlatformId
        property int currentBoardCount

        signal jlinkProcessFailed()

        DSM.State {
            id: stateProgramBootloader
            onEntered: {
                stateMachine.controllerWasRegistered = true
                stateMachine.statusText = "Programming bootloader"
                stateMachine.internalSubtext = ""
                stateMachine.bottomLeftText = resolveJLinkInfoStatus(stateWaitForJLink.outputInfo)
                taskbarButton.progress.resume()

                console.debug(Logger.prtCategory, "bootloader on controller is about to be programmed")

                var run = jLinkConnector.programBoardRequested(prtModel.bootloaderFilepath)
                if (run === false) {
                    stateMachine.jlinkProcessFailed()
                }
            }

            onExited: {
                stateMachine.bottomLeftText = ""
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: stateMachine.jlinkProcessFailed
                onTriggered: {
                    stateMachine.internalSubtext = "JLink process failed"
                    console.error(Logger.prtCategory, "jlink process failed")
                }
            }

            DSM.SignalTransition {
                targetState: stateNotifyCloudService
                signal: jLinkConnector.programBoardProcessFinished
                guard: exitedNormally
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: jLinkConnector.programBoardProcessFinished
                guard: exitedNormally === false
                onTriggered: {
                    stateMachine.internalSubtext = "JLink process failed"
                    console.error(Logger.prtCategory, "jlink process failed")
                }
            }
        }

        DSM.State {
            id: stateNotifyCloudService

            onEntered: {
                stateMachine.statusText = "Registering Controller"
                stateMachine.internalSubtext = "contacting cloud service"
                stateControllerRegistration.currentPlatformId = CommonCpp.SGUtilsCpp.generateUuid()
                stateControllerRegistration.currentBoardCount = -1

                console.debug(Logger.prtCategory, "cloud service is about to be notified for controller registration")

                prtModel.notifyServiceAboutRegistration(
                            stateMachine.controllerClassId,
                            stateControllerRegistration.currentPlatformId)
            }

            DSM.SignalTransition {
                targetState: stateWriteRegistrationData
                signal: prtModel.notifyServiceFinished
                guard: boardCount > 0 && errorString.length === 0
                onTriggered: {
                    stateControllerRegistration.currentBoardCount = boardCount
                }
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.notifyServiceFinished
                guard: errorString.length > 0
                onTriggered: {
                    stateMachine.internalSubtext = errorString
                }
            }
        }

        DSM.State {
            id: stateWriteRegistrationData

            onEntered: {
                stateMachine.internalSubtext = "writing to device"

                var data = {
                    "controller_class_id": stateMachine.controllerClassId,
                    "controller_platform_id": stateControllerRegistration.currentPlatformId,
                    "controller_board_count": stateControllerRegistration.currentBoardCount
                }

                console.debug(Logger.prtCategory, "controller is about to be registered", JSON.stringify(data))

                prtModel.setAssistedPlatformId(data)
            }

            DSM.SignalTransition {
                targetState: stateAssistedDeviceCheck
                signal: prtModel.setAssistedPlatformIdFinished
                guard: statusString === "ok"
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.setAssistedPlatformIdFinished
                guard: statusString !== "ok"
                onTriggered: {
                    if (statusString == "failed") {
                        stateMachine.internalSubtext = "Registration refused by controller"
                    } else if (statusString == "already_initialized") {
                        stateMachine.internalSubtext = "Controller has already been registered"
                    } else if (statusString == "device_not_connected") {
                        stateMachine.internalSubtext = "Assisted device not connected"
                    } else if (statusString) {
                        stateMachine.internalSubtext = "Error: " + statusString
                    }

                    console.error(Logger.prtCategory, "controller registration failed:", statusString)
                }
            }
        }
    }

    DSM.State {
        id: stateAssistedDeviceCheck

        initialState: checkAssistedDeviceIsConnected

        DSM.SignalTransition {
            targetState: exitState
            signal: breakButton.clicked
        }

        DSM.State {
            id: checkAssistedDeviceIsConnected

            onEntered: {
                stateMachine.statusText = "Waiting for assisted device"
                taskbarButton.progress.resume()
                taskbarButton.progress.pause()
                taskbarButton.progress.show()

                console.debug(Logger.prtCategory, "checking assisted device")

                if (prtModel.deviceCount !== 1) {
                    stateMachine.controllerNotConnected()
                } else if (prtModel.isAssistedDeviceConnected()) {
                    stateMachine.assistedDeviceConnected()
                } else {
                    stateMachine.assistedDeviceNotConnected()
                }
            }
        }

        DSM.SignalTransition {
            targetState: stateControllerCheck
            signal: stateMachine.controllerNotConnected
        }

        DSM.SignalTransition {
            targetState: stateDelayRegistration
            signal: stateMachine.assistedDeviceConnected
        }

        DSM.SignalTransition {
            targetState: stateWaitForAssistedDevice
            signal: stateMachine.assistedDeviceNotConnected
        }

        DSM.State {
            id: stateDelayRegistration
            DSM.TimeoutTransition {
                targetState: stateAssistedDeviceRegistration
                timeout: 1000
            }
        }

        DSM.State {
            id: stateWaitForAssistedDevice
            onEntered: {
                stateMachine.statusText = "Waiting for assisted device"
                console.debug(Logger.prtCategory, "waiting for assisted device")
            }

            DSM.SignalTransition {
                targetState: checkAssistedDeviceIsConnected
                signal: prtModel.deviceInfoChanged
            }

            DSM.SignalTransition {
                targetState: checkAssistedDeviceIsConnected
                signal: prtModel.deviceCountChanged
            }
        }
    }

    DSM.State {
        id: stateAssistedDeviceRegistration

        initialState: stateNotifyCloudServiceAssistedDebice

        onEntered: {
            stateMachine.statusText = "Registering Assisted Device"
            taskbarButton.progress.resume()
        }

        property string currentPlatformId
        property int currentBoardCount

        DSM.State {
            id: stateNotifyCloudServiceAssistedDebice

            onEntered: {
                stateMachine.internalSubtext = "contacting cloud service"
                stateAssistedDeviceRegistration.currentPlatformId = CommonCpp.SGUtilsCpp.generateUuid()
                stateAssistedDeviceRegistration.currentBoardCount = -1

                console.debug(Logger.prtCategory, "cloud service is about to be notified for assisted device registration")

                prtModel.notifyServiceAboutRegistration(
                            stateMachine.assistedDeviceClassId,
                            stateAssistedDeviceRegistration.currentPlatformId)
            }

            DSM.SignalTransition {
                targetState: stateWriteRegistrationDataForAssistedDevice
                signal: prtModel.notifyServiceFinished
                guard: boardCount > 0 && errorString.length === 0
                onTriggered: {
                    stateAssistedDeviceRegistration.currentBoardCount = boardCount
                }
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.notifyServiceFinished
                guard: errorString.length > 0
                onTriggered: {
                    stateMachine.internalSubtext = errorString
                }
            }
        }

        DSM.State {
            id: stateWriteRegistrationDataForAssistedDevice

            onEntered: {
                stateMachine.internalSubtext = "writing to device"

                var data = {
                    "class_id": stateMachine.assistedDeviceClassId,
                    "platform_id": stateAssistedDeviceRegistration.currentPlatformId,
                    "board_count": stateAssistedDeviceRegistration.currentBoardCount
                }

                console.debug(Logger.prtCategory, "assisted device is about to be registered", JSON.stringify(data))

                prtModel.setAssistedPlatformId(data)
            }

            DSM.SignalTransition {
                targetState: stateLoopSucceed
                signal: prtModel.setAssistedPlatformIdFinished
                guard: statusString === "ok"
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.setAssistedPlatformIdFinished
                guard: statusString !== "ok"
                onTriggered: {
                    if (statusString == "failed") {
                        stateMachine.internalSubtext = "Registration refused by controller"
                    } else if (statusString == "already_initialized") {
                        stateMachine.internalSubtext = "Assisted device has already been registered"
                    } else if (statusString == "device_not_connected") {
                        stateMachine.internalSubtext = "Assisted device not connected"
                    } else if (statusString) {
                        stateMachine.internalSubtext = "Error: " + statusString
                    }

                    console.error(Logger.prtCategory, "assisted device registration failed:", statusString)
                }
            }
        }
    }

    DSM.State {
        id: stateError

        onEntered: {
            stateMachine.statusText = "Assisted Platform Registration Failed"
            taskbarButton.progress.stop()
        }

        DSM.SignalTransition {
            targetState: exitState
            signal: breakButton.clicked
        }
    }

    DSM.State {
        id: stateLoopFailed

        onEntered: {
            stateMachine.statusText = "Assisted Platform Registration Failed"
            taskbarButton.progress.stop()
        }

        DSM.SignalTransition {
            targetState: stateControllerCheck
            signal: continueButton.clicked
            guard: prtModel.deviceCount === 0
        }
    }

    DSM.State {
        id: stateLoopSucceed

        onEntered: {
            stateMachine.statusText = "Assisted Platform Registration Successful"
            console.debug(Logger.prtCategory, "registration successful")
            taskbarButton.progress.hide()
            taskbarButton.progress.reset()
        }

        DSM.SignalTransition {
            targetState: exitState
            signal: breakButton.clicked
        }

        DSM.SignalTransition {
            targetState: stateControllerCheck
            signal: prtModel.boardDisconnected
        }

        DSM.SignalTransition {
            targetState: stateAssistedDeviceCheck
            signal: prtModel.deviceInfoChanged
        }
    }

    DSM.FinalState {
        id: exitState
        onEntered: {
            stateMachine.exitWizardRequested()
        }
    }
}
