import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.logger 1.0
import tech.strata.flasherConnector 1.0

FocusScope {
    id: wizard

    property string firmwareBinaryPath
    property string bootloaderBinaryPath
    property string jlinkExePath

    property int spacing: 10
    property bool closeButtonVisible: false
    property bool requestCancelOnClose: false
    property int processingStatus: ProgramDeviceWizard.SetupProgramming

    enum ProcessingStatus {
        SetupProgramming,
        WaitingForDevice,
        WaitingForJLink,
        ProgrammingWithJlink,
        ProgrammingWithFlasher,
        ProgrammingSucceed,
        ProgrammingFailed
    }

    clip: true

    Component.onCompleted: {
        stackView.push(initPageComponent)

        if (jlinkExePath.length === 0) {
            jlinkExePath = searchJLinkExePath()
        }
    }

    QtLabsSettings.Settings {
        id: settings
        category: "app"

        property alias bootloaderBinaryPath: wizard.bootloaderBinaryPath
        property alias firmwareBinaryPath: wizard.firmwareBinaryPath
        property alias jlinkExePath: wizard.jlinkExePath
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    property color baseColor: "#303030"
    property int arrowTailLength: 2*state4Label.width

    Item {
        id: workflow
        anchors {
            top: parent.top
            topMargin: 8
            horizontalCenter: parent.horizontalCenter
        }

        width: childrenRect.width
        height: childrenRect.height

        focus: false

        FeedbackArrow {
            id: feedbackArrow
            width: state4.x - state2.x + 2*padding + wingWidth + 4
            height: 40
            x: state2.x - padding + Math.round(state2.width/2) - wingWidth - 2

            padding: 2
            color: baseColor
        }

        WorkflowNode {
            id: state1
            anchors {
                horizontalCenter: label1.horizontalCenter
                top: feedbackArrow.bottom
            }

            source: "qrc:/sgimages/cog.svg"
            color: baseColor
            iconColor: baseColor
            highlight: processingStatus === ProgramDeviceWizard.SetupProgramming
        }

        Arrow {
            id: arrow2
            anchors {
                left: state1.right
                verticalCenter: state1.verticalCenter
            }

            color: baseColor
            tailLength: arrowTailLength
        }

        WorkflowNode {
            id: state2
            anchors {
                verticalCenter: state1.verticalCenter
                left: arrow2.right
            }

            source: "qrc:/sgimages/plug.svg"
            color: baseColor
            iconColor: baseColor
            highlight: processingStatus === ProgramDeviceWizard.WaitingForDevice
                       || processingStatus === ProgramDeviceWizard.WaitingForJLink
        }

        Arrow {
            id: arrow3
            anchors {
                left: state2.right
                verticalCenter: state1.verticalCenter
            }

            color: baseColor
            tailLength: arrowTailLength
        }

        WorkflowNode {
            id: state3
            anchors {
                verticalCenter: state1.verticalCenter
                left: arrow3.right
            }

            source: "qrc:/sgimages/bolt.svg"
            color: baseColor
            iconColor: baseColor
            highlight: processingStatus === ProgramDeviceWizard.ProgrammingWithJlink
                       || processingStatus === ProgramDeviceWizard.ProgrammingWithFlasher
        }

        Arrow {
            id: arrow4
            anchors {
                left: state3.right
                verticalCenter: state1.verticalCenter
            }

            color: baseColor
            tailLength: arrowTailLength
        }

        WorkflowNode {
            id: state4
            anchors {
                left: arrow4.right
                verticalCenter: state1.verticalCenter
            }

            source: "qrc:/sgimages/check.svg"
            color: baseColor
            iconColor: baseColor
            highlight: processingStatus === ProgramDeviceWizard.ProgrammingSucceed
                       || processingStatus === ProgramDeviceWizard.ProgrammingFailed
        }

        Arrow {
            id: arrow5
            anchors {
                left: state4.right
                verticalCenter: state1.verticalCenter
            }

            color: baseColor
            tailLength: Math.round(arrowTailLength/2)
        }

        WorkflowNodeText {
            anchors {
                left: arrow5.right
                verticalCenter: state1.verticalCenter
            }

            color: baseColor
            text: "End"
            standalone: true
        }

        WorkflowNodeText {
            id: label1
            anchors {
                left: parent.left
                top: state1.bottom
            }

            text: "Settings"
            color: baseColor
            highlight: state1.highlight
        }

        WorkflowNodeText {
            anchors {
                horizontalCenter: state2.horizontalCenter
                top: state2.bottom
            }

            text: "Connect New\nDevice"
            color: baseColor
            highlight: state2.highlight
        }

        WorkflowNodeText {
            anchors {
                horizontalCenter: state3.horizontalCenter
                top: state3.bottom
            }

            text: "Programming"
            color: baseColor
            highlight: state3.highlight
        }

        WorkflowNodeText {
            id: state4Label
            anchors {
                horizontalCenter: state4.horizontalCenter
                top: state4.bottom
            }

            text: "Done"
            color: baseColor
            highlight: state4.highlight
        }
    }

    StackView {
        id: stackView
        anchors {
            top: workflow.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        focus: true
    }

    CommonCpp.SGJLinkConnector {
        id: jLinkConnector
    }

    Component {
        id: initPageComponent

        Item {
            id: settingsPage

            Column {
                id: content
                width: parent.width - 24
                anchors {
                    top: parent.top
                    topMargin: 12
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: wizard.spacing

                SGWidgets.SGText {
                    id: bootloaderHeader

                    text: "Bootloader"
                    fontSizeMultiplier: 2.0
                }

                SGWidgets.SGFileSelector {
                    id: jlinkExePathEdit
                    width: content.width

                    focus: true
                    label: "SEGGER J-Link Commander executable (JLink.exe)"
                    placeholderText: "Enter path..."
                    inputValidation: true

                    Binding {
                        target: jlinkExePathEdit
                        property: "filePath"
                        value: wizard.jlinkExePath
                    }

                    onFilePathChanged: {
                        wizard.jlinkExePath = filePath
                    }

                    dialogLabel: "Select JLink Commander executable"
                    dialogSelectExisting: true

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

                SGWidgets.SGFileSelector {
                    id: bootloaderPathEdit
                    width: content.width

                    label: "Bootloader data file"
                    placeholderText: "Enter path..."
                    inputValidation: true
                    filePath: wizard.bootloaderBinaryPath
                    onFilePathChanged: {
                        wizard.bootloaderBinaryPath = filePath
                    }

                    dialogLabel: "Select Bootloader Binary"
                    dialogSelectExisting: true
                    dialogNameFilters: ["Binary files (*.bin)","All files (*)"]

                    function inputValidationErrorMsg() {
                        if (filePath.length === 0) {
                            return qsTr("Bootloader data file is required")
                        } else if (!CommonCpp.SGUtilsCpp.isFile(filePath)) {
                            return qsTr("Bootloader data file path does not refer to a file")
                        }

                        return ""
                    }
                }


                SGWidgets.SGText {
                    id: firmwareHeader

                    text: "Firmware"
                    fontSizeMultiplier: 2.0
                }

                SGWidgets.SGFileSelector {
                    id: firmwarePathEdit
                    width: content.width
                    label: "Firmware data file"
                    placeholderText: "Enter path..."
                    inputValidation: true
                    filePath: wizard.firmwareBinaryPath
                    onFilePathChanged: {
                        wizard.firmwareBinaryPath = filePath
                    }

                    dialogLabel: "Select Firmware Binary"
                    dialogSelectExisting: true
                    dialogNameFilters: ["Binary files (*.bin)","All files (*)"]

                    function inputValidationErrorMsg() {
                        if (filePath.length === 0) {
                            return qsTr("Firmware data file is required")
                        } else if (!CommonCpp.SGUtilsCpp.isFile(filePath)) {
                            return qsTr("Firmware data file path does not refer to a file")
                        }

                        return ""
                    }
                }
            }

            Row {
                id: footer
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }

                spacing: 20

                SGWidgets.SGButton {
                    text: qsTr("Close")
                    onClicked: {
                        if(requestCancelOnClose) {
                            cancelRequested()
                        }
                    }
                    focusPolicy: Qt.NoFocus
                    visible: closeButtonVisible
                }

                SGWidgets.SGButton {
                    text: qsTr("Begin")
                    icon.source: "qrc:/sgimages/chip-flash.svg"
                    focusPolicy: Qt.NoFocus

                    onClicked: {
                        var errorList = []

                        var error = bootloaderPathEdit.inputValidationErrorMsg()
                        if (error.length) {
                            errorList.push(error)
                        }

                        error = jlinkExePathEdit.inputValidationErrorMsg()
                        if (error.length) {
                            errorList.push(error)
                        }

                        error = firmwarePathEdit.inputValidationErrorMsg()
                        if (error.length) {
                            errorList.push(error)
                        }

                        if (errorList.length) {
                            SGWidgets.SGDialogJS.showMessageDialog(
                                        wizard,
                                        SGWidgets.SGMessageDialog.Error,
                                        qsTr("Validation Failed"),
                                        SGWidgets.SGUtilsJS.generateHtmlUnorderedList(errorList))

                        } else {
                            jLinkConnector.exePath = wizard.jlinkExePath

                            processingStatus = ProgramDeviceWizard.WaitingForDevice
                            stackView.push(processPageComponent)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: processPageComponent

        FocusScope {
            id: processPage

            property int verticalSpacing: 8
            property string subtextNote
            property variant warningDialog: null

            Connections {
                target: prtModel

                onBoardReady: {
                    callTryProgramDevice()
                }

                onBoardDisconnected: {
                    callTryProgramDevice()
                }

                onFlasherProgress: {
                    if (operation === FlasherConnector.Preparation ) {
                        if (state === FlasherConnector.Started) {
                            subtextNote = "Preparations"
                        } else if (state === FlasherConnector.Failed) {
                            subtextNote = errorString
                        }
                    } else if (operation === FlasherConnector.Flash) {
                        if (state === FlasherConnector.Started) {
                            subtextNote = "Programming"
                        } else if (state === FlasherConnector.Failed) {
                            subtextNote = errorString
                        }
                    } else if ( FlasherConnector.BackupBeforeFlash
                               || operation === FlasherConnector.RestoreFromBackup) {
                        console.warn(Logger.sciCategory, "unsupported state")
                    } else {
                        console.warn(Logger.sciCategory, "unknown state")
                    }
                }

                onFlasherFinished: {
                    if (result === FlasherConnector.Success) {
                        processingStatus = ProgramDeviceWizard.ProgrammingSucceed
                    } else if (result === FlasherConnector.Unsuccess
                               || result === FlasherConnector.Failure) {
                        processingStatus = ProgramDeviceWizard.ProgrammingFailed
                    }
                }
            }

            Timer {
                id: jLinkCheckTimer
                interval: 1000
                repeat: false
                onTriggered: {
                    tryProgramDevice()
                }
            }

            Connections {
                target: jLinkConnector

                onFlashBoardProcessFinished: {
                    console.log(Logger.prtCategory, "JLink flash finished with exitedNormally=", exitedNormally)
                    if (exitedNormally) {
                        var errorString = prtModel.programDevice(firmwareBinaryPath);
                        if (errorString.length === 0) {
                            processingStatus = ProgramDeviceWizard.ProgrammingWithFlasher
                        } else {
                            processingStatus = ProgramDeviceWizard.ProgrammingFailed
                            subtextNote = errorString
                        }
                    } else {
                        processingStatus = ProgramDeviceWizard.ProgrammingFailed
                        subtextNote = "Bootloader programming error"
                    }
                }

                onCheckConnectionProcessFinished: {
                    console.log(Logger.prtCategory, "JLink check connection finished with exitedNormally=", exitedNormally, "connected=", connected)
                    if (exitedNormally && connected) {

                        if (prtModel.deviceFirmwareVersion().length > 0) {
                            //device already has firmware
                            showFirmwareWarning(false, prtModel.deviceFirmwareVersion(), prtModel.deviceFirmwareVerboseName())
                            return
                        }

                        doProgramDeviceJlink()
                    } else {
                        jLinkCheckTimer.restart()
                    }
                }
            }

            function callTryProgramDevice() {
                if (processingStatus === ProgramDeviceWizard.ProgrammingSucceed) {
                    processingStatus = ProgramDeviceWizard.WaitingForDevice
                }

                tryProgramDevice()
            }

            function tryProgramDevice() {
                if (warningDialog !== null) {
                    warningDialog.reject()
                }

                if (processingStatus !== ProgramDeviceWizard.WaitingForDevice
                        && processingStatus !== ProgramDeviceWizard.WaitingForJLink) {

                    return
                }

                if (prtModel.deviceCount === 0 || prtModel.deviceCount > 1) {
                    processingStatus = ProgramDeviceWizard.WaitingForDevice
                    return
                }

                processingStatus = ProgramDeviceWizard.WaitingForJLink

                var run = jLinkConnector.checkConnectionRequested();
                if (run === false) {
                    jLinkCheckTimer.restart();
                }
            }

            function showFirmwareWarning(isBootloader, version, name) {
                var msg = "Connected device already has a "
                var title = "Device already with "

                if (isBootloader) {
                    msg += "bootloader of version " + version
                    title += "bootloader"
                } else {
                    msg += "firmware " + name
                    msg += " of version " + version
                    title += "firmware"
                }

                msg += "\n"
                msg += "\n"
                msg += "Do you want to program it anyway ?"

                warningDialog = SGWidgets.SGDialogJS.showConfirmationDialog(
                            wizard,
                            title,
                            msg,
                            "Program it",
                            function() {
                                doProgramDeviceJlink()
                            },
                            "Cancel",
                            function() {
                                processingStatus = ProgramDeviceWizard.WaitingForDevice
                            },
                            SGWidgets.SGMessageDialog.Warning,
                            )
            }

            function doProgramDeviceJlink() {
                var run = jLinkConnector.flashBoardRequested(wizard.bootloaderBinaryPath, true)
                if (run) {
                    processingStatus = ProgramDeviceWizard.ProgrammingWithJlink
                    processPage.subtextNote = "Programming"
                } else {
                    jLinkCheckTimer.restart()
                }
            }

            Component.onCompleted: {
                tryProgramDevice()
            }

            SGWidgets.SGText {
                id: statusText
                anchors {
                    top: parent.top
                    topMargin: 80
                    horizontalCenter: parent.horizontalCenter
                }

                fontSizeMultiplier: 2.0
                text: {
                    if (processingStatus === ProgramDeviceWizard.WaitingForDevice) {
                        return "Waiting for device to connect"
                    } else if (processingStatus === ProgramDeviceWizard.WaitingForJLink) {
                        return "Waiting for JLink connection"
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingWithJlink) {
                        return "Programming bootloader..."
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingWithFlasher) {
                        return "Programming firmware..."
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingSucceed) {
                        return "Programming successful"
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingFailed) {
                        return "Programming failed"
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

                BusyIndicator {
                    id: busyIndicator
                    width: parent.width
                    height: parent.height

                    running: processingStatus === ProgramDeviceWizard.ProgrammingWithJlink
                             || processingStatus === ProgramDeviceWizard.ProgrammingWithFlasher
                }

                SGWidgets.SGIcon {
                    id: iconIndicator
                    width: parent.width
                    height: width

                    source: {
                        if (processingStatus === ProgramDeviceWizard.ProgrammingSucceed) {
                            return "qrc:/sgimages/check.svg"
                        } else if (processingStatus === ProgramDeviceWizard.ProgrammingFailed) {
                            return "qrc:/sgimages/times-circle.svg"
                        }

                        return ""
                    }

                    iconColor: {
                        if (processingStatus === ProgramDeviceWizard.ProgrammingSucceed) {
                            return SGWidgets.SGColorsJS.STRATA_GREEN
                        } else if (processingStatus === ProgramDeviceWizard.ProgrammingFailed) {
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
                    if (processingStatus === ProgramDeviceWizard.WaitingForDevice
                            || processingStatus === ProgramDeviceWizard.WaitingForJLink) {

                        var msg = "Only single device with MCU EFM32GG380F1024 can be connected while programming\n"

                        if (prtModel.deviceCount > 1) {
                            msg += "Multiple devices detected !"
                        }
                        return msg
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingWithJlink
                               || processingStatus === ProgramDeviceWizard.ProgrammingWithFlasher) {
                        msg = processPage.subtextNote
                        msg += "\n\n"
                        msg += "Do not unplug the device until process is complete"
                        return msg
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingSucceed) {
                        msg = "You can unplug the device now\n\n"
                        msg += "To program another device, simply plug it in and\n"
                        msg += "process will start automatically\n\n"
                        msg += "or press End."
                        return msg
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingFailed) {
                        msg = processPage.subtextNote
                        msg += "\n\n"
                        msg += "Unplug the device and press Continue"
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
                visible: processingStatus === ProgramDeviceWizard.WaitingForDevice
                         || processingStatus === ProgramDeviceWizard.WaitingForJLink
            }

            Row {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }

                spacing: wizard.spacing

                SGWidgets.SGButton {
                    id: cancelBtn

                    text: qsTr("End")
                    visible: processingStatus === ProgramDeviceWizard.ProgrammingSucceed

                    onClicked: {
                        if (requestCancelOnClose) {
                            cancelRequested()
                            return
                        }

                        processingStatus = ProgramDeviceWizard.SetupProgramming
                        stackView.pop(stackView.initialItem)
                    }
                }

                SGWidgets.SGButton {
                    id: backBtn

                    text: qsTr("Back")
                    visible: processingStatus === ProgramDeviceWizard.WaitingForDevice
                             || processingStatus === ProgramDeviceWizard.WaitingForJLink

                    onClicked: {
                        processingStatus = ProgramDeviceWizard.SetupProgramming
                        stackView.pop(stackView.initialItem)
                    }
                }

                SGWidgets.SGButton {
                    id: confirmErrorBtn

                    text: qsTr("Continue")
                    visible: processingStatus === ProgramDeviceWizard.ProgrammingFailed

                    onClicked: {
                        processingStatus = ProgramDeviceWizard.WaitingForDevice
                    }
                }
            }
        }
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
