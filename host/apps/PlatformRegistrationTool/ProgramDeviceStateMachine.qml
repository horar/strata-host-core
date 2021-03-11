import QtQml 2.12
import QtQml.StateMachine 1.12 as DSM

DSM.StateMachine {
    id: stateMechine

    property bool stateSettingsActive: stateSettings.active
    property bool stateDownloadActive: stateDownload.active
    property bool stateCheckDeviceActive: stateCheckDevice.active
    property bool stateProgramActive: stateProgram.active
    property bool stateRegistrationActive: stateRegistration.active
    property bool stateErrorActive: stateError.active
    property bool stateLoopFailedActive: stateLoopFailed.active
    property bool stateLoopSucceedActive: stateLoopSucceed.active


    signal updateTextRequested(string text);
    signal updateSubtextRequested(string text);


    property string subtext

    property QtObject prtModel
    property QtObject jLinkConnector

    property QtObject breakButton
    property QtObject continueButton

    signal breakButtonClicked()


    //internal stuff
    signal settingsValid()
    signal deviceCountValid()
    signal deviceCountInvalid()
    signal deviceFirmwareValid()
    signal deviceFirmwareInvalid()
    signal jlinkProcessFailed()

    running: true
    initialState: stateSettings

    DSM.State {
        id: stateSettings

        onEntered: {
            prtModel.clearBinaries();
        }

        DSM.SignalTransition {
            targetState: stateDownload
            signal: stateMechine.settingsValid
        }
    }

    DSM.State {
        id: stateDownload

        property string bootloaderUrl
        property string bootloaderMd5

        initialState: stateGetBootloaderUrl

        onEntered: {
            stateDownload.bootloaderUrl = ""
            stateDownload.bootloaderMd5 = ""
        }

        DSM.SignalTransition {
            targetState: stateSettings
            signal: breakButton.clicked
        }

        DSM.State {
            id: stateGetBootloaderUrl

            onEntered: {
                prtModel.requestBootloaderUrl()
            }

            DSM.SignalTransition {
                targetState: stateGetBinaries
                signal: prtModel.bootloaderUrlRequestFinished
                guard: errorString.length === 0
                onTriggered: {
                    stateDownload.bootloaderUrl = url
                    stateDownload.bootloaderMd5 = md5
                }
            }

            DSM.SignalTransition {
                targetState: stateError
                signal: prtModel.bootloaderUrlRequestFinished
                guard: errorString.length > 0
                onTriggered: {
                    subtext = errorString
                }
            }
        }

        DSM.State {
            id: stateGetBinaries

            onEntered: {
                prtModel.downloadBinaries(
                            stateDownload.bootloaderUrl,
                            stateDownload.bootloaderMd5,
                            wizard.currentFirmwareUrl,
                            wizard.currentFirmwareMd5)
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
                    subtext = errorString
                }
            }
        }
    }

    DSM.State {
        id: stateCheckDevice

        initialState: stateCheckDeviceCount

        DSM.SignalTransition {
            targetState: stateSettings
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
                if (prtModel.deviceCount === 1) {
                    stateMechine.deviceCountValid()
                } else {
                    stateMechine.deviceCountInvalid()
                }
            }

            DSM.SignalTransition {
                targetState: stateCheckFirmware
                signal: stateMechine.deviceCountValid
            }

            DSM.SignalTransition {
                targetState: stateWaitForDevice
                signal: stateMechine.deviceCountInvalid
            }
        }

        DSM.State {
            id: stateWaitForDevice

            onEntered: {
                subtext = ""
            }

            DSM.SignalTransition {
                targetState: stateCheckFirmware
                signal: prtModel.deviceCountChanged
                guard: prtModel.deviceCount === 1
            }
        }

        DSM.State {
            id: stateCheckFirmware

            onEntered: {
                if (prtModel.deviceFirmwareVersion().length > 0) {
                    //device already has firmware
                    showFirmwareWarning(
                                prtModel.deviceFirmwareVersion(),
                                prtModel.deviceFirmwareVerboseName(),
                                function() {
                                    stateMechine.deviceFirmwareValid()
                                },
                                function() {
                                    stateMechine.deviceFirmwareInvalid()
                                })
                } else {
                    stateMechine.deviceFirmwareValid()
                }
            }

            onExited: {
                if (warningDialog !== null) {
                    warningDialog.reject()
                }
            }

            DSM.SignalTransition {
                targetState: stateWaitForJLink
                signal: stateMechine.deviceFirmwareValid
            }

            DSM.SignalTransition {
                targetState: stateWaitForDevice
                signal: stateMechine.deviceFirmwareInvalid
            }
        }

        DSM.State {
            id: stateWaitForJLink

            initialState: stateCheckJLinkConnection

            DSM.State {
                id: stateCheckJLinkConnection

                onEntered: {
                    var run = jLinkConnector.checkConnectionRequested()
                    if (run === false) {
                        stateMechine.jlinkProcessFailed()
                    }
                }

                DSM.SignalTransition {
                    targetState: stateProgram
                    signal: jLinkConnector.checkConnectionProcessFinished
                    guard: exitedNormally && connected
                }

                DSM.SignalTransition {
                    targetState: stateCallJlinkCheckWithDelay
                    signal: stateMechine.jlinkProcessFailed
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
        id: stateProgram

        initialState: stateProgramBootloader

        DSM.State {
            id: stateProgramBootloader

            onEntered: {
                var run = jLinkConnector.programBoardRequested(prtModel.bootloaderFilepath)

                if (run === false) {
                    stateMechine.jlinkProcessFailed()
                }
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: stateMechine.jlinkProcessFailed
                onTriggered: {
                    subtext = "JLink process failed"
                }
            }

            DSM.SignalTransition {
                targetState: stateProgramFirmware
                signal: jLinkConnector.programBoardProcessFinished
                guard: exitedNormally
            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: jLinkConnector.programBoardProcessFinished
                guard: exitedNormally === false
                onTriggered: {
                    subtext = "JLink process failed"
                }
            }
        }

        DSM.State {
            id: stateProgramFirmware

            onEntered: {
                prtModel.programDevice();
            }

            /* Seems like DSM casts class enum arguments to simple int,
                   so "===" doesnt work */
            DSM.SignalTransition {
                signal: prtModel.flasherOperationStateChanged
                onTriggered: {
                    if (operation == FlasherConnector.Preparation ) {
                        if (state == FlasherConnector.Started) {
                            subtext = "Preparations"
                        } else if (state == FlasherConnector.Failed) {
                            subtext = errorString
                        }
                    } else if (operation == FlasherConnector.Flash) {
                        if (state == FlasherConnector.Started) {
                            subtext = "Programming"
                        } else if (state === FlasherConnector.Failed) {
                            subtext = errorString
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
                    subtext = Math.floor((chunk / total) * 100) +"% completed"
                }
            }

            DSM.SignalTransition {
                targetState: stateRegistration
                signal: prtModel.flasherFinished
                guard: result == FlasherConnector.Success

            }

            DSM.SignalTransition {
                targetState: stateLoopFailed
                signal: prtModel.flasherFinished
                guard: result == FlasherConnector.Unsuccess || result == FlasherConnector.Failure
            }
        }
    }

    DSM.State {
        id: stateRegistration

        property string currentPlatformId
        property int currentBoardCount

        initialState: stateNotifyCloudService

        onEntered: {
            stateRegistration.currentPlatformId = CommonCpp.SGUtilsCpp.generateUuid()
            stateRegistration.currentBoardCount = -1
        }

        DSM.State {
            id: stateNotifyCloudService

            onEntered: {
                subtext = "contacting cloud service"
                prtModel.notifyServiceAboutRegistration(
                            wizard.currentClassId,
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
                    subtext = errorString
                }
            }
        }

        DSM.State {
            id: stateStartBootloader

            onEntered: {
                subtext = "starting bootloader"
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
                    subtext = errorString
                }
            }
        }

        DSM.State {
            id: stateWriteRegistrationData

            onEntered: {
                subtext = "writing to device"
                prtModel.setPlatformId(
                            wizard.currentClassId,
                            stateRegistration.currentPlatformId,
                            stateRegistration.currentBoardCount)

                //TODO: or call setAssistedPlatformId based on platform type
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
                    subtext = errorString
                }
            }
        }

        DSM.State {
            id: stateStartApplication

            onEntered: {
                subtext = "starting application firmware"
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
                    subtext = errorString
                }
            }
        }
    }

    DSM.State {
        id: stateError

        DSM.SignalTransition {
            targetState: stateSettings
            signal: breakButton.clicked
        }
    }

    DSM.State {
        id: stateLoopFailed

        DSM.SignalTransition {
            targetState: stateWaitForDevice
            signal: continueButton.clicked
        }
    }

    DSM.State {
        id: stateLoopSucceed

        DSM.SignalTransition {
            targetState: stateSettings
            signal: breakButton.clicked
        }

        DSM.SignalTransition {
            targetState: stateCheckDevice
            signal: prtModel.boardDisconnected
        }
    }


}
