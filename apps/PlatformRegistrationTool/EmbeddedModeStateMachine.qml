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
import tech.strata.flasherConnector 1.0
import tech.strata.logger 1.0

BaseStateMachine {
    id: stateMachine

    property bool stateDownloadActive: stateDownload.active
    property bool stateCheckDeviceActive: stateCheckDevice.active
    property bool stateRegistrationActive: stateRegistration.active
    property bool stateErrorActive: stateError.active
    property bool stateLoopFailedActive: stateLoopFailed.active
    property bool stateLoopSucceedActive: stateLoopSucceed.active

    property string statusText
    property string bottomLeftText
    property string internalSubtext: ""
    property string subtext: {
        var t = ""
        if (stateCheckDeviceCount.active || stateWaitForDevice.active) {
            t = "Connect single device with MCU "+ jlinkDevice.toUpperCase()

            if (prtModel.deviceCount > 1) {
                t += "\n"
                t += "Multiple devices detected !"
            }
        } else if (stateWaitForJLink.active) {
            t = "Connect single JLink Base to program device"
        } else if (stateRegistrationActive) {
            t = internalSubtext
            t += "\n\n"
            t += "Do not unplug device or JLink Base"
        } else if (stateLoopSucceedActive) {
            t = "Device registered as platform " + opn.toUpperCase() + "\n\n"
            t += "You can unplug device now\n\n"
            t += "To program another device, simply plug it in and process will start automatically\n\n"
            t += "or press End to finish current session"
        } else if (stateLoopFailedActive) {
            t = internalSubtext
            t += "\n\n"
            if (prtModel.deviceCount === 0) {
                t += "Press Continue"
            } else {
                t += "Unplug device and press Continue"
            }
        } else if (stateErrorActive) {
            t = internalSubtext
        }

        return t
    }

    property QtObject prtModel
    property QtObject jLinkConnector
    property QtObject breakButton
    property QtObject continueButton
    property QtObject taskbarButton

    property string jlinkExePath: ""

    property var firmwareData: ({})
    property var bootloaderData: ({})
    property string classId: ""
    property string opn: ""

    property string jlinkDevice: ""
    property int bootloaderStartAddress: -1

    signal exitWizardRequested()

    //internal stuff
    signal settingsValid()
    signal settingsInvalid(string errorString)
    signal deviceCountValid()
    signal deviceCountInvalid()
    signal deviceFirmwareValid()
    signal deviceFirmwareInvalid()
    signal jlinkProcessFailed()

    running: false
    initialState: stateValidateInput


    DSM.State {
        id: stateValidateInput

        onEntered: {
            prtModel.clearBinaries();
            taskbarButton.progress.resume()
            taskbarButton.progress.show()
            continueButton.visible = false

            var errorString = ""
            if (jlinkExePath.length === 0) {
                errorString = "Path to JLink.exe not set"
            } else if (Object.keys(firmwareData).length === 0) {
                errorString = "No valid firmware available"
            } else if (Object.keys(bootloaderData).length === 0) {
                errorString = "No valid bootloader available"
            } else if (classId.length === 0) {
                errorString = "Class id not set"
            } else if (jlinkDevice.length === 0) {
                errorString = "MCU device type not set"
            } else if (bootloaderStartAddress < 0) {
                errorString = "Bootloader start address not set"
            } else if (opn.length === 0) {
                errorString = "OPN not set"
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
            targetState: stateCheckDevice
            signal: prtModel.downloadFirmwareFinished
            guard: errorString.length === 0
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
        id: stateCheckDevice

        initialState: stateCheckDeviceCount

        DSM.SignalTransition {
            targetState: exitState
            signal: breakButton.clicked
        }

        DSM.SignalTransition {
            targetState: stateWaitForDevice
            signal: prtModel.deviceCountChanged
            guard: prtModel.deviceCount !== 1
        }

        DSM.State {
            id: stateCheckDeviceCount
            onEntered: {
                stateMachine.statusText = "Waiting for device to connect"
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
                targetState: stateWaitForJLink
                signal: stateMachine.deviceCountValid
            }

            DSM.SignalTransition {
                targetState: stateWaitForDevice
                signal: stateMachine.deviceCountInvalid
            }
        }

        DSM.State {
            id: stateWaitForDevice

            onEntered: {
                stateMachine.statusText = "Waiting for device to connect"

                console.debug(Logger.prtCategory, "waiting for device")
            }

            DSM.SignalTransition {
                targetState: stateWaitForJLink
                signal: prtModel.deviceCountChanged
                guard: prtModel.deviceCount === 1
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
                    targetState: stateRegistration
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
        id: stateRegistration

        initialState: stateProgramBootloader

        property string currentPlatformId
        property int currentBoardCount

        DSM.State {
            id: stateProgramBootloader

            onEntered: {
                stateMachine.statusText = "Programming bootloader"
                stateMachine.internalSubtext = ""
                stateMachine.bottomLeftText = resolveJLinkInfoStatus(stateWaitForJLink.outputInfo)
                taskbarButton.progress.resume()

                console.debug(Logger.prtCategory, "bootloader about to be programmed")

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
                targetState: stateValidateBootloader
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
            id: stateValidateBootloader

            onEntered: {
                console.debug(Logger.prtCategory, "programmed bootloader about to be validated")
                prtModel.identifyBootloader()
            }

            DSM.SignalTransition {
                targetState: stateProgramFirmware
                signal: prtModel.identifyBootloaderFinished
                guard: errorString.length === 0
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.identifyBootloaderFinished
                guard: errorString.length > 0
                onTriggered: {
                    stateMachine.internalSubtext = "Programmed bootloader not valid"
                    console.error(Logger.prtCategory, "programmed bootloader not valid.")
                }
            }
        }

        DSM.State {
            id: stateProgramFirmware

            onEntered: {
                stateMachine.statusText = "Programming firmware"

                console.debug(Logger.prtCategory, "firmware about to be programmed")

                prtModel.programDevice();
            }

            /* Seems like DSM casts class enum arguments to simple int,
                   so "===" doesnt work */
            DSM.SignalTransition {
                signal: prtModel.flasherOperationStateChanged
                onTriggered: {
                    if (operation == FlasherConnector.Preparation ) {
                        if (state == FlasherConnector.Started) {
                            stateMachine.internalSubtext = "Preparations"
                        } else if (state == FlasherConnector.Failed) {
                            stateMachine.internalSubtext = errorString
                        }
                    } else if (operation == FlasherConnector.Flash) {
                        if (state == FlasherConnector.Started) {
                            stateMachine.internalSubtext = "Programming"
                        } else if (state == FlasherConnector.Failed) {
                            stateMachine.internalSubtext = errorString
                        }
                    } else if (operation == FlasherConnector.BackupBeforeFlash
                               || operation == FlasherConnector.RestoreFromBackup) {
                        console.warn(Logger.prtCategory, "unsupported operation", operation, state)
                    } else {
                        console.warn(Logger.prtCategory, "unknown operation", operation, state)
                    }
                }
            }

            DSM.SignalTransition {
                signal: prtModel.flasherProgress
                onTriggered: {
                    stateMachine.internalSubtext = (total < 1 ? 0 : Math.floor((chunk / total) * 100)) +"% completed"
                }
            }

            DSM.SignalTransition {
                targetState: stateNotifyCloudService
                signal: prtModel.flasherFinished
                guard: result == FlasherConnector.Success
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.flasherFinished
                guard: result == FlasherConnector.Unsuccess || result == FlasherConnector.Failure
            }
        }

        DSM.State {
            id: stateNotifyCloudService

            onEntered: {
                stateMachine.statusText = "Registering"
                stateMachine.internalSubtext = "contacting cloud service"
                stateRegistration.currentPlatformId = CommonCpp.SGUtilsCpp.generateUuid()
                stateRegistration.currentBoardCount = -1

                console.debug(Logger.prtCategory, "cloud service is about to be notified")

                prtModel.notifyServiceAboutRegistration(
                            stateMachine.classId,
                            stateRegistration.currentPlatformId)
            }

            DSM.SignalTransition {
                targetState: stateStartBootloader
                signal: prtModel.notifyServiceFinished
                guard: boardCount > 0 && errorString.length === 0
                onTriggered: {
                    stateRegistration.currentBoardCount = boardCount
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
            id: stateStartBootloader

            onEntered: {
                stateMachine.internalSubtext = "starting bootloader"
                prtModel.startBootloader()
            }

            DSM.SignalTransition {
                targetState: stateWriteRegistrationData
                signal: prtModel.startBootloaderFinished
                guard: errorString.length === 0
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.startBootloaderFinished
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

                console.debug(Logger.prtCategory, "device is about to be registered")

                prtModel.setPlatformId(
                            stateMachine.classId,
                            stateRegistration.currentPlatformId,
                            stateRegistration.currentBoardCount)
            }

            DSM.SignalTransition {
                targetState: stateStartApplication
                signal: prtModel.setPlatformIdFinished
                guard: errorString.length === 0
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.setPlatformIdFinished
                guard: errorString.length > 0
                onTriggered: {
                    stateMachine.internalSubtext = errorString
                    console.error(Logger.prtCategory, "device registration failed:", errorString)
                }
            }
        }

        DSM.State {
            id: stateStartApplication

            onEntered: {
                stateMachine.internalSubtext = "starting application firmware"
                prtModel.startApplication()
            }

            DSM.SignalTransition {
                targetState: stateLoopSucceed
                signal: prtModel.startApplicationFinished
                guard: errorString.length === 0
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.startApplicationFinished
                guard: errorString.length > 0
                onTriggered: {
                    stateMachine.internalSubtext = errorString
                }
            }
        }
    }

    DSM.State {
        id: stateError

        onEntered: {
            stateMachine.statusText = "Platform Registration Failed"
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
            stateMachine.statusText = "Platform Registration Failed"
            taskbarButton.progress.stop()
            continueButton.visible = true
        }

        onExited: {
            continueButton.visible = false
        }

        Binding {
            target: continueButton
            property: "enabled"
            value: prtModel.deviceCount === 0
            when: stateLoopFailed.active
        }

        DSM.SignalTransition {
            targetState: stateCheckDevice
            signal: continueButton.clicked
            guard: prtModel.deviceCount === 0
        }

        DSM.SignalTransition {
            targetState: exitState
            signal: breakButton.clicked
        }
    }

    DSM.State {
        id: stateLoopSucceed

        onEntered: {
            stateMachine.statusText = "Platform Registration Successful"
            console.debug(Logger.prtCategory, "registration successful")
            taskbarButton.progress.hide()
            taskbarButton.progress.reset()
        }

        DSM.SignalTransition {
            targetState: exitState
            signal: breakButton.clicked
        }

        DSM.SignalTransition {
            targetState: stateCheckDevice
            signal: prtModel.boardDisconnected
        }
    }

    DSM.FinalState {
        id: exitState
        onEntered: {
            taskbarButton.progress.hide()
            taskbarButton.progress.resume()
            stateMachine.exitWizardRequested()
        }
    }
}
