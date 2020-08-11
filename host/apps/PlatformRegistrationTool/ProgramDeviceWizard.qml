import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.logger 1.0
import tech.strata.flasherConnector 1.0
import QtQml.StateMachine 1.12 as DSM

FocusScope {
    id: wizard

    property QtObject prtModel
    property int platformIndex: -1
    property string jlinkExePath
    property string subtextNote
    property int spacing: 10
    property variant warningDialog: null

    clip: true

    Component.onCompleted: {
        if (jlinkExePath.length === 0) {
            jlinkExePath = searchJLinkExePath()
        }

        prtModel.opnListModel.populate();
    }

    QtLabsSettings.Settings {
        id: settings
        category: "app"

        property alias jlinkExePath: wizard.jlinkExePath
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    DSM.StateMachine {
        id: stateMechine

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
                signal: breakBtn.clicked
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
                        wizard.subtextNote = errorString
                    }
                }
            }

            DSM.State {
                id: stateGetBinaries

                onEntered: {
                    prtModel.downloadBinaries(
                                stateDownload.bootloaderUrl,
                                stateDownload.bootloaderMd5,
                                wizard.platformIndex)
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
                        wizard.subtextNote = errorString
                    }
                }
            }
        }

        DSM.State {
            id: stateCheckDevice

            initialState: stateCheckDeviceCount

            DSM.SignalTransition {
                targetState: stateSettings
                signal: breakBtn.clicked
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
                    var run = jLinkConnector.flashBoardRequested(wizard.prtModel.bootloaderFilepath, true)

                    if (run === false) {
                        stateMechine.jlinkProcessFailed()
                    }
                }

                DSM.SignalTransition {
                    targetState: stateLoopFailed
                    signal: stateMechine.jlinkProcessFailed
                    onTriggered: {
                        wizard.subtextNote = "JLink process failed"
                    }
                }

                DSM.SignalTransition {
                    targetState: stateProgramFirmware
                    signal: jLinkConnector.flashBoardProcessFinished
                    guard: exitedNormally
                }

                DSM.SignalTransition {
                    targetState: stateLoopFailed
                    signal: jLinkConnector.flashBoardProcessFinished
                    guard: exitedNormally === false
                    onTriggered: {
                        wizard.subtextNote = "JLink process failed"
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
                                wizard.subtextNote = "Preparations"
                            } else if (state == FlasherConnector.Failed) {
                                wizard.subtextNote = errorString
                            }
                        } else if (operation == FlasherConnector.Flash) {
                            if (state == FlasherConnector.Started) {
                                wizard.subtextNote = "Programming"
                            } else if (state === FlasherConnector.Failed) {
                                wizard.subtextNote = errorString
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
                        wizard.subtextNote = Math.floor((chunk / total) * 100) +"% completed"
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

            property string currentClassId
            property string currentPlatformId
            property int currentBoardCount

            initialState: stateNotifyCloudService

            onEntered: {
                stateRegistration.currentClassId = prtModel.opnListModel.data(wizard.platformIndex, "classId")
                stateRegistration.currentPlatformId = prtModel.generateUuid()
                stateRegistration.currentBoardCount = -1
            }

            DSM.State {
                id: stateNotifyCloudService

                onEntered: {
                    wizard.subtextNote = "contacting cloud service"
                    prtModel.notifyServiceAboutRegistration(
                                stateRegistration.currentClassId,
                                stateRegistration.currentPlatformId)
                }

                DSM.SignalTransition {
                    targetState: stateWriteRegistrationData
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
                        wizard.subtextNote = errorString
                    }
                }
            }

            DSM.State {
                id: stateWriteRegistrationData

                onEntered: {
                    wizard.subtextNote = "writing to device"
                    prtModel.writeRegistrationData(
                                stateRegistration.currentClassId,
                                stateRegistration.currentPlatformId,
                                stateRegistration.currentBoardCount)
                }

                DSM.SignalTransition {
                    targetState: stateLoopSucceed
                    signal: prtModel.writeRegistrationDataFinished
                    guard: errorString.length === 0
                }

                DSM.SignalTransition {
                    targetState: stateLoopFailed
                    signal: prtModel.writeRegistrationDataFinished
                    guard: errorString.length > 0
                    onTriggered: {
                        wizard.subtextNote = errorString
                    }
                }
            }
        }

        DSM.State {
            id: stateError

            DSM.SignalTransition {
                targetState: stateSettings
                signal: breakBtn.clicked
            }
        }

        DSM.State {
            id: stateLoopFailed

            DSM.SignalTransition {
                targetState: stateWaitForDevice
                signal: continueBtn.clicked
            }
        }

        DSM.State {
            id: stateLoopSucceed

            DSM.SignalTransition {
                targetState: stateSettings
                signal: breakBtn.clicked
            }

            DSM.SignalTransition {
                targetState: stateCheckDevice
                signal: prtModel.boardDisconnected
            }
        }
    }

    Workflow {
        id: workflow
        anchors {
            top: parent.top
            topMargin: 8
            horizontalCenter: parent.horizontalCenter
        }

        nodeSettingsHighlight: stateSettings.active
        nodeDownloadHighlight: stateDownload.active
        nodeDeviceCheckHighlight: stateCheckDevice.active
        nodeProgramHighlight: stateProgram.active
        nodeRegistrationHighlight: stateRegistration.active
        nodeDoneHighlight: stateLoopSucceed.active || stateLoopFailed.active || stateError.active
    }

    UserMenuButton {
        anchors {
            top: parent.top
            topMargin: 8
            right: parent.right
            rightMargin: 8
        }
    }

    CommonCpp.SGJLinkConnector {
        id: jLinkConnector
    }

    Item {
        id: content
        anchors {
            top: workflow.bottom
            bottom: footer.top
            left: parent.left
            right: parent.right
            margins: 12
        }

        Item {
            id: settingsPage
            anchors.fill: parent

            enabled: stateSettings.active
            opacity: stateSettings.active ? 1 : 0
            Behavior on opacity { OpacityAnimator { duration: 200}}

            SGWidgets.SGText {
                id: jLinkTitle
                anchors {
                    top: parent.top
                }

                text: "J-Link"
                fontSizeMultiplier: 2.0
            }

            SGWidgets.SGFileSelector {
                id: jlinkExePathEdit
                width: settingsPage.width
                anchors {
                    top: jLinkTitle.bottom
                    topMargin: wizard.spacing
                }

                focus: true
                label: "SEGGER J-Link Commander executable (JLink.exe)"
                placeholderText: "Enter path..."
                inputValidation: true
                dialogLabel: "Select JLink Commander executable"
                dialogSelectExisting: true

                Binding {
                    target: jlinkExePathEdit
                    property: "filePath"
                    value: wizard.jlinkExePath
                }

                onFilePathChanged: {
                    wizard.jlinkExePath = filePath
                }

                function inputValidationErrorMsg() {
                    if (filePath.length === 0) {
                        return qsTr("JLink Commander is required")
                    } else if (!CommonCpp.SGUtilsCpp.isFile(filePath)) {
                        return qsTr("JLink Commander is not a valid file")
                    } else if(!CommonCpp.SGUtilsCpp.isExecutable(filePath)) {
                        return qsTr("JLink Commander is not executable")
                    }

                    return ""
                }
            }

            SGWidgets.SGText {
                id: platformTitle
                anchors {
                    top: jlinkExePathEdit.bottom
                    topMargin: wizard.spacing
                }

                text: "Platform OPN"
                fontSizeMultiplier: 2.0
            }

            OpnView {
                id: opnView
                width: settingsPage.width
                anchors {
                    top: platformTitle.bottom
                    topMargin: wizard.spacing
                    bottom: parent.bottom

                }

                prtModel: wizard.prtModel
            }
        }

        Item {
            id: processPage
            anchors.fill: parent

            property int verticalSpacing: 8

            enabled: stateSettings.active === false
            opacity: stateSettings.active ? 0 : 1
            Behavior on opacity { OpacityAnimator { duration: 200}}

            SGWidgets.SGText {
                id: statusText
                anchors {
                    top: parent.top
                    topMargin: 80
                    horizontalCenter: parent.horizontalCenter
                }

                fontSizeMultiplier: 2.0
                text: {
                    if (stateDownload.active) {
                        return "Downloading..."
                    } else if (stateWaitForDevice.active) {
                        return "Waiting for device to connect"
                    } else if (stateWaitForJLink.active) {
                        return "Waiting for JLink connection"
                    } else if (stateProgramBootloader.active) {
                        return "Programming bootloader..."
                    } else if (stateProgramFirmware.active) {
                        return "Programming firmware..."
                    } else if (stateRegistration.active) {
                        return "Registering..."
                    } else if (stateLoopSucceed.active) {
                        return "Platfrom Registered Successfully"
                    } else if (stateLoopFailed.active || stateError.active) {
                        return "Platform Registration Failed"
                    }

                    return ""
                }
            }

            Item {
                id: statusIndicator
                width: 100
                height: 100
                anchors {
                    top: statusText.bottom
                    topMargin: processPage.verticalSpacing
                    horizontalCenter: parent.horizontalCenter
                }

                visible: busyIndicator.running || iconIndicator.status === Image.Ready

                /* QtBug-85860: When "running" property is changed too fast,
                    BusyIndicator stays hidden, even though "running" property is "true".*/
                property bool runBusyIndicator: stateDownload.active ||  stateProgram.active  ||  stateRegistration.active
                onRunBusyIndicatorChanged: fixRunIndicatorTimer.start()

                Timer {
                    id: fixRunIndicatorTimer
                    interval: 1
                    onTriggered:  {
                        busyIndicator.running = statusIndicator.runBusyIndicator
                    }
                }

                BusyIndicator {
                    id: busyIndicator
                    width: parent.width
                    height: parent.height
                }

                SGWidgets.SGIcon {
                    id: iconIndicator
                    width: parent.width
                    height: width

                    source: {
                        if (stateLoopSucceed.active) {
                            return "qrc:/sgimages/check.svg"
                        } else if (stateLoopFailed.active || stateError.active) {
                            return "qrc:/sgimages/times-circle.svg"
                        }

                        return ""
                    }

                    iconColor: {
                        if (stateLoopSucceed.active) {
                            return SGWidgets.SGColorsJS.STRATA_GREEN
                        } else if (stateLoopFailed.active || stateError.active) {
                            return SGWidgets.SGColorsJS.TANGO_SCARLETRED2
                        }

                        return "black"
                    }
                }
            }

            SGWidgets.SGText {
                id: statusSubtext
                anchors {
                    top: statusIndicator.visible ? statusIndicator.bottom : statusText.bottom
                    topMargin: processPage.verticalSpacing
                    horizontalCenter: parent.horizontalCenter
                }

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMultiplier: 1.2
                font.italic: true
                text: {
                    if (stateCheckDevice.active) {
                        var msg = "Only single device with MCU EFM32GG380F1024 can be connected while programming\n"

                        if (prtModel.deviceCount > 1) {
                            msg += "Multiple devices detected !"
                        }
                        return msg
                    } else if (stateProgram.active || stateRegistration.active) {
                        msg = wizard.subtextNote
                        msg += "\n\n"
                        msg += "Do not unplug the device"
                        return msg
                    } else if (stateLoopSucceed.active) {
                        msg = "You can unplug the device now\n\n"
                        msg += "To program another device, simply plug it in and\n"
                        msg += "process will start automatically\n\n"
                        msg += "or press End."
                        return msg
                    } else if (stateLoopFailed.active) {
                        msg = wizard.subtextNote
                        msg += "\n\n"
                        msg += "Unplug the device and press Continue"
                        return msg
                    } else if (stateError.active) {
                        msg = wizard.subtextNote
                        return msg
                    }

                    return ""
                }
            }

            Image {
                width: parent.width
                height: 200
                anchors {
                    top: statusSubtext.bottom
                    margins: 10
                }

                source: "qrc:/images/jlink-connect-schema.svg"
                fillMode: Image.PreserveAspectFit
                sourceSize: Qt.size(width, height)
                smooth: true
                visible: stateCheckDevice.active
            }
        }
    }

    Row {
        id: footer
        anchors {
            bottom: parent.bottom
            margins: 12
            horizontalCenter: parent.horizontalCenter
        }

        spacing: wizard.spacing

        SGWidgets.SGButton {
            text: "Begin"
            icon.source: "qrc:/sgimages/chip-flash.svg"
            visible: stateSettings.active
            onClicked: {
                validateSettings()
            }
        }

        SGWidgets.SGButton {
            id: breakBtn
            text: "End"
            visible: stateDownload.active || stateCheckDevice.active || stateLoopSucceed.active || stateError.active
        }

        SGWidgets.SGButton {
            id: continueBtn
            text: "Continue"
            visible: stateLoopFailed.active
        }
    }

    function validateSettings() {

        var errorList = []

        var error = jlinkExePathEdit.inputValidationErrorMsg()
        if (error.length) {
            errorList.push(error)
        }

        if (opnView.checkedOpnIndex < 0) {
            error = "OPN not chosen"
            errorList.push(error)
        }

        if (errorList.length === 1) {
            var errorString = errorList[0]
        } else {
            errorString = SGWidgets.SGUtilsJS.generateHtmlUnorderedList(errorList)
        }

        if (errorList.length) {
            SGWidgets.SGDialogJS.showMessageDialog(
                        wizard,
                        SGWidgets.SGMessageDialog.Error,
                        qsTr("Settings Validation Failed"),
                        errorString)

        } else {
            jLinkConnector.exePath = wizard.jlinkExePath
            wizard.platformIndex = opnView.checkedOpnIndex

            stateMechine.settingsValid()
        }
    }

    function showFirmwareWarning(version, name, callback, callbackError) {
        var title = "Device already with firmware"
        var msg = "Connected device already has firmware " + name + " of version " + version
        msg += "\n"
        msg += "\n"
        msg += "Do you want to program it anyway ?"

        warningDialog = SGWidgets.SGDialogJS.showConfirmationDialog(
                    wizard,
                    title,
                    msg,
                    "Program it",
                    function() {
                        callback()
                    },
                    "Cancel",
                    function() {
                        callbackError()
                    },
                    SGWidgets.SGMessageDialog.Warning,
                    )
    }

    function resolveAbsoluteFileUrl(path) {
        return CommonCpp.SGUtilsCpp.pathToUrl(
            CommonCpp.SGUtilsCpp.fileAbsolutePath(path))
    }

    function searchJLinkExePath() {
        var standardPathList = QtLabsPlatform.StandardPaths.standardLocations(
                    QtLabsPlatform.StandardPaths.ApplicationsLocation)

        if (Qt.platform.os == "windows") {
            standardPathList.push("file:///C:/Program Files (x86)")
        }

        var pathList = []

        for (var i =0 ; i < standardPathList.length; ++i) {
            var path = CommonCpp.SGUtilsCpp.urlToLocalFile(standardPathList[i])
            pathList.push(path)

            path = CommonCpp.SGUtilsCpp.joinFilePath(path, "SEGGER/JLink")
            pathList.push(path)
        }

        if (Qt.platform.os === "windows") {
            var exeName = "JLink"
        } else {
            exeName = "JLinkExe"
        }

        console.log(Logger.prtCategory, "exeName", exeName)
        console.log(Logger.prtCategory, "pathList", JSON.stringify(pathList))

        var url = QtLabsPlatform.StandardPaths.findExecutable(exeName, pathList)
        if (url && url.toString().length > 0) {
            url = CommonCpp.SGUtilsCpp.urlToLocalFile(url)
            console.log(Logger.prtCategory, "JLink exe path", url)
            return url
        } else {
            console.log(Logger.prtCategory, "JLink exe path could not be found")
        }

        return ""
    }
}
