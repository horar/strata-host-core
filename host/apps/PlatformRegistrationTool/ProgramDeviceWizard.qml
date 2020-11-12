import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
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

    property string currentOpn
    property string currentVerboseName
    property string currentClassId
    property string currentFirmwareUrl
    property string currentFirmwareMd5

    property string platsEndpointReplySchema: '{
        "$schema": "http://json-schema.org/draft-04/schema#",
        "type": "object",
        "properties": {
            "opn": {"type": "string"},
            "class_id": {"type": "string"},
            "verbose_name": {"type": "string"},

            "firmware": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "file": {"type": "string"},
                        "filename": {"type": "string"},
                        "filesize": {"type": "integer"},
                        "md5": {"type": "string"},
                        "timestamp": {"type": "string"},
                        "version": {"type": "string"}
                    },
                    "required": ["file","md5", "timestamp","version"]
                }
            }
        },
        "required": ["opn","class_id", "verbose_name","firmware"]
    }'

    clip: true

    Component.onCompleted: {
        if (jlinkExePath.length === 0) {
            jlinkExePath = searchJLinkExePath()
        }
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

                onEntered: {
                    wizard.subtextNote = ""
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
                    var run = jLinkConnector.programBoardRequested(wizard.prtModel.bootloaderFilepath)

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
                    signal: jLinkConnector.programBoardProcessFinished
                    guard: exitedNormally
                }

                DSM.SignalTransition {
                    targetState: stateLoopFailed
                    signal: jLinkConnector.programBoardProcessFinished
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
                    wizard.subtextNote = "contacting cloud service"
                    prtModel.notifyServiceAboutRegistration(
                                wizard.currentClassId,
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
                                wizard.currentClassId,
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
        eraseBeforeProgram: true
        device: "EFM32GG380F1024"
        speed: 4000
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

                text: "Platform"
                fontSizeMultiplier: 2.0
            }

            Item {
                id: searchWrapper
                height: searchEdit.height
                width: settingsPage.width
                anchors {
                    top: platformTitle.bottom
                    topMargin: wizard.spacing
                }

                SGWidgets.SGTextFieldEditor {
                    id: searchEdit
                    itemWidth: parent.width - searchButton.width - 10

                    label: "Orderable Part Number"
                    textFieldLeftIconSource: "qrc:/sgimages/zoom.svg"
                    placeholderText: "OPN..."

                    Keys.onEnterPressed: {
                        findPlatform(searchEdit.text)
                    }

                    Keys.onReturnPressed: {
                        findPlatform(searchEdit.text)
                    }

                    onTextChanged: {
                        clearSearchState()
                    }

                    textFieldBusyIndicatorRunning: enabled === false

                    function clearSearchState() {
                        searchEdit.setIsUnknown()
                        wizard.currentOpn = ""
                        wizard.currentVerboseName = ""
                        wizard.currentClassId = ""
                        wizard.currentFirmwareUrl = ""
                        wizard.currentFirmwareMd5 = ""
                    }
                }

                SGWidgets.SGButton {
                    id: searchButton
                    y: searchEdit.itemY + (searchEdit.item.height - height) / 2
                    anchors {
                        right: parent.right
                    }

                    enabled: searchEdit.enabled
                    text: "Set"
                    onClicked: {
                        findPlatform(searchEdit.text)
                    }
                }
            }

            GridLayout {
                anchors {
                    top: searchWrapper.bottom
                }

                rowSpacing: 4
                columnSpacing: 4
                columns: 2

                SGWidgets.SGText {
                    text: "OPN:"
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                }

                SGWidgets.SGText {
                    text: wizard.currentOpn
                    fontSizeMultiplier: 1.2
                    Layout.alignment: Qt.AlignBottom
                    font.bold: true
                }

                SGWidgets.SGText {
                    text: "Title:"
                    Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                }

                SGWidgets.SGText {
                    text: wizard.currentVerboseName
                    fontSizeMultiplier: 1.2
                    Layout.alignment: Qt.AlignBottom
                }
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

        if (wizard.currentClassId.length === 0) {
            searchEdit.setIsInvalid("OPN not set")
            error = "OPN not set"
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
        searchEdit.enabled = false
        searchEdit.clearSearchState()
        findPlatformDelayTimer.opn = opn
        findPlatformDelayTimer.restart()
    }

    function doFindPlatform(opn) {

        var endpoint = "plats/"+opn.toUpperCase()

        console.log("endpoint", endpoint)

        var deferred = prtModel.restClient.get(endpoint)

        deferred.finishedSuccessfully.connect(function(status, data) {
            //when OPN is not found, empty array is returned

            console.log(Logger.prtCategory,"platform info:", status, data)

            searchEdit.clearSearchState()

            try {
                var response = JSON.parse(data)
            } catch(error) {
                console.log(Logger.prtCategory, "cannot parse reply from server")

                searchEdit.setIsInvalid("Cannot validate OPN. Reply not valid.")
                searchEdit.enabled = true
                return "Cannot validate OPN. Reply not valid."
            }

            if (Array.isArray(response)) {
                searchEdit.setIsInvalid("OPN not found.")
            } else {
                var isValid = CommonCpp.SGUtilsCpp.validateJson(data, wizard.platsEndpointReplySchema)
                if (isValid) {
                    setLatestFirmware(response["firmware"])

                    wizard.currentOpn = response["opn"]
                    wizard.currentVerboseName = response["verbose_name"]
                    wizard.currentClassId = response["class_id"]

                    searchEdit.setIsValid()
                } else {
                    searchEdit.setIsInvalid("Cannot validate OPN. Reply not valid.")
                }
            }

            searchEdit.enabled = true
        })

        deferred.finishedWithError.connect(function(status ,errorString) {
            console.error(Logger.prtCategory, status, errorString)

            searchEdit.enabled = true
            searchEdit.setIsInvalid("Cannot validate OPN. Request failed. status: "+ status)
        })
    }


    function setLatestFirmware(firmwareList) {
        var latestFirmwareIndex = 0
        var latestFirmwareTimestamp = new Date(firmwareList[latestFirmwareIndex]["timestamp"])

        for (var i = 1; i < firmwareList.length; ++i) {
            var timestamp = new Date(firmwareList[i]["timestamp"])

            if (latestFirmwareTimestamp < timestamp) {
                latestFirmwareIndex = i
                latestFirmwareTimestamp = timestamp
            }
        }

        wizard.currentFirmwareUrl = firmwareList[latestFirmwareIndex]["file"]
        wizard.currentFirmwareMd5 = firmwareList[latestFirmwareIndex]["md5"]
    }
}
