import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.fonts 1.0 as StrataFonts
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp

import QtQuick.Dialogs 1.3
import tech.strata.logger 1.0

Item {
    id: wizard

    property string connectionId
    property string firmwarePath
    property string bootloaderPath
    property bool useJLink: false
    property int spacing: 10

    signal cancelRequested()

    enum ProcessingStatus {
        WaitingForDevice,
        WaitingForJLink,
        ProgrammingBootloader,
        ProgrammingApplication,
        ProgrammingSucceed,
        ProgrammingFailed
    }

    clip: true

    Component.onCompleted: {
        stackView.push(initPageComponent)
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    StackView {
        id: stackView
        anchors {
            fill:parent
        }
    }

    CommonCpp.SGJLinkConnector {
        id: jLinkConnector
    }

    Component {
        id: initPageComponent

        SGWidgets.SGPage {
            id: settingsPage

            title: qsTr("Program Device Settings")
            hasBack: false

            Item {
                anchors.fill: parent

                Component.onCompleted: {
                    manualButton.checked = true
                }

                ButtonGroup {
                    buttons: [manualButton, automaticButton]
                }

                Column {
                    anchors {
                        top: parent.top
                        topMargin: wizard.spacing
                        horizontalCenter: parent.horizontalCenter
                    }

                    width: parent.width - 50

                    spacing: wizard.spacing

                    SGWidgets.SGText {
                        id: firmwareHeader

                        text: "Firmware"
                        fontSizeMultiplier: 2.0
                    }

                    Column {
                        id: optionWrapper
                        width: parent.width

                        Row {
                            id: manualOptionWrapper

                            spacing: wizard.spacing

                            RadioButton {
                                id: manualButton

                                //vertical center to pathEdit
                                y: pathEdit.itemY + (pathEdit.item.height - height) / 2

                                onCheckedChanged: {
                                    if (checked) {
                                        pathEdit.forceActiveFocus()
                                    }
                                }
                            }

                            SGWidgets.SGTextFieldEditor {
                                id: pathEdit

                                label: qsTr("Firmware data file")
                                itemWidth: optionWrapper.width - manualButton.width - selectButton.width - 2*wizard.spacing //Math.floor(optionWrapper.width - 200)
                                enabled: manualButton.checked
                                inputValidation: true
                                placeholderText: "Enter path..."
                                text: wizard.firmwarePath
                                onTextChanged: {
                                    wizard.firmwarePath = text
                                }

                                Binding {
                                    target: pathEdit
                                    property: "text"
                                    value: wizard.firmwarePath
                                }

                                function inputValidationErrorMsg() {
                                    if (text.length === 0) {
                                        return qsTr("Firmware data file is required")
                                    } else if (!CommonCpp.SGUtilsCpp.isFile(text)) {
                                        return qsTr("Firmware data file path does not refer to a file")
                                    }

                                    return ""
                                }
                            }

                            SGWidgets.SGButton {
                                id: selectButton
                                anchors {
                                    verticalCenter: manualButton.verticalCenter
                                }

                                text: "Select"
                                enabled: manualButton.checked
                                focusPolicy: Qt.NoFocus
                                onClicked: {
                                    getFilePath("Select Firmware Binary",
                                                ["Binary files (*.bin)","All files (*)"],
                                                function(path) {
                                                    wizard.firmwarePath = path
                                                })
                                }
                            }
                        }

                        Row {
                            id: automaticOptionWrapper

                            //TODO disabled until we have connection to couchbase
                            enabled: false

                            spacing: wizard.spacing

                            RadioButton {
                                id: automaticButton
                                //vertical center to opnEditText
                                y: opnEdit.itemY + (opnEdit.item.height - height) / 2

                                onCheckedChanged: {
                                    if (checked) {
                                        opnEdit.forceActiveFocus()
                                    }
                                }
                            }

                            SGWidgets.SGTextFieldEditor {
                                id: opnEdit
                                itemWidth: pathEdit.itemWidth
                                label: "Ordering Part Number"
                                enabled: automaticButton.checked
                            }
                        }
                    }

                    SGWidgets.SGText {
                        id: bootloaderHeader

                        text: "Bootloader"
                        fontSizeMultiplier: 2.0
                    }

                    Item {
                        id: jlinkWrapper

                        width: parent.width
                        height: jlinkInputColumn.y + jlinkInputColumn.height

                        SGWidgets.SGCheckBox {
                            id: jlinkCheck
                            text: qsTr("Use SEGGER JLink to program bootloader")
                            checked: wizard.useJLink
                            onCheckedChanged: {
                                wizard.useJLink = checked
                            }

                            Binding {
                                target: jlinkCheck
                                property: "checked"
                                value: wizard.useJLink
                            }
                        }

                        Column {

                            id: jlinkInputColumn
                            anchors {
                                top: jlinkCheck.bottom
                                right: parent.right
                            }

                            Row {
                                enabled: jlinkCheck.checked
                                spacing: wizard.spacing

                                SGWidgets.SGTextFieldEditor {
                                    id: jlinkExePathEdit

                                    itemWidth: pathEdit.itemWidth
                                    label: "JLink Commander executable (JLink.exe)"
                                    placeholderText: "Enter path..."
                                    inputValidation: true

                                    function inputValidationErrorMsg() {
                                        if (text.length === 0) {
                                            return qsTr("JLink Commander is required")
                                        } else if (!CommonCpp.SGUtilsCpp.isFile(text)) {
                                            return qsTr("JLink Commander is not a valid file")
                                        } else if(!CommonCpp.SGUtilsCpp.isExecutable(text)) {
                                            return qsTr("JLink Commander is not executable")
                                        }

                                        return ""
                                    }
                                }

                                SGWidgets.SGButton {
                                    id: selectJFlashLiteButton
                                    y: jlinkExePathEdit.itemY + (jlinkExePathEdit.item.height - height) / 2

                                    text: "Select"
                                    focusPolicy: Qt.NoFocus
                                    onClicked: {
                                        getFilePath("Select JLink Commander executable",
                                                    undefined,
                                                    function(path) {
                                                        jlinkExePathEdit.text = path
                                                    })
                                    }
                                }
                            }

                            Row {
                                enabled: jlinkCheck.checked && manualButton.checked
                                spacing: wizard.spacing

                                SGWidgets.SGTextFieldEditor {
                                    id: bootloaderPathEdit
                                    anchors.verticalCenter: parent.verticalCenter

                                    itemWidth: pathEdit.itemWidth
                                    label: "Bootloader data file"
                                    placeholderText: "Enter path..."
                                    inputValidation: true

                                    text: wizard.bootloaderPath
                                    onTextChanged: {
                                        wizard.bootloaderPath = text
                                    }

                                    Binding {
                                        target: bootloaderPathEdit
                                        property: "text"
                                        value: wizard.bootloaderPath
                                    }

                                    function inputValidationErrorMsg() {
                                        if (text.length === 0) {
                                            return qsTr("Bootloader data file is required")
                                        } else if (!CommonCpp.SGUtilsCpp.isFile(text)) {
                                            return qsTr("Bootloader data file does not refer to a file")
                                        }

                                        return ""
                                    }
                                }

                                SGWidgets.SGButton {
                                    y: bootloaderPathEdit.itemY + (bootloaderPathEdit.item.height - height) / 2

                                    text: "Select"

                                    focusPolicy: Qt.NoFocus
                                    onClicked: {
                                        getFilePath("Select Bootloader Binary",
                                                    ["Binary files (*.bin)","All files (*)"],
                                                    function(path) {
                                                        wizard.bootloaderPath = path
                                                    })
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Row {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }

                spacing: 20

                SGWidgets.SGButton {
                    text: qsTr("Close")
                    onClicked: cancelRequested()
                    focusPolicy: Qt.NoFocus
                }

                SGWidgets.SGButton {
                    text: qsTr("Begin")
                    focusPolicy: Qt.NoFocus

                    onClicked: {
                        var errorList = []

                        if (pathEdit.enabled) {
                            var error = pathEdit.inputValidationErrorMsg()
                            if (error.length) {
                                errorList.push(error)
                            }
                        }

                        if (opnEdit.enabled) {
                            error = opnEdit.inputValidationErrorMsg()
                            if (error.length) {
                                errorList.push(error)
                            }
                        }

                        if (jlinkExePathEdit.enabled) {
                            error = jlinkExePathEdit.inputValidationErrorMsg()
                            if (error.length) {
                                errorList.push(error)
                            }
                        }

                        if (bootloaderPathEdit.enabled) {
                            error = bootloaderPathEdit.inputValidationErrorMsg()
                            if (error.length) {
                                errorList.push(error)
                            }
                        }

                        if (errorList.length) {
                            SGWidgets.SGDialogJS.showMessageDialog(
                                        settingsPage,
                                        SGWidgets.SGMessageDialog.Error,
                                        qsTr("Validation Failed"),
                                        SGWidgets.SGUtilsJS.generateHtmlUnorderedList(errorList))

                        } else {
                            if (wizard.useJLink) {
                                jLinkConnector.exePath = CommonCpp.SGUtilsCpp.urlToPath(jlinkExePathEdit.text)
                            }

                            stackView.push(processPageComponent)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: processPageComponent

        SGWidgets.SGPage {
            id: processPage
            title: qsTr("Programming Device")
            hasBack: processingStatus !== ProgramDeviceWizard.ProgrammingApplication

            property int verticalSpacing: 8
            property int processingStatus: ProgramDeviceWizard.WaitingForDevice
            property string subtextNote
            property variant warningDialog: null

            Connections {
                target: sciModel.boardController

                onConnectedBoard: {
                    waitForActiveBoardTimer.connectionId = connectionId
                    waitForActiveBoardTimer.restart()
                }

                onActiveBoard: {
                    waitForActiveBoardTimer.stop()

                    callTryProgramDevice()
                }

                onDisconnectedBoard: {
                    waitForActiveBoardTimer.stop()
                    callTryProgramDevice()
                }
            }

            Timer {
                id: waitForActiveBoardTimer
                interval: 1000

                property string connectionId

                onTriggered: {
                    callTryProgramDevice()
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
                target: sciModel

                onNotify: {
                    processPage.subtextNote = message
                }

                onProgramDeviceDone: {
                    console.log(Logger.sciCategory, "program device done", status)
                    if (status) {
                        processingStatus = ProgramDeviceWizard.ProgrammingSucceed
                    } else {
                        processingStatus = ProgramDeviceWizard.ProgrammingFailed
                        subtextNote = "Firmware programming error"
                    }
                }
            }

            Connections {
                target: jLinkConnector

                onProcessFinished: {

                    console.log(Logger.sciCategory, "JLink process finished with status=", status)
                    if (status) {
                        doProgramDeviceApplication()
                    } else {
                        processingStatus = ProgramDeviceWizard.ProgrammingFailed
                        subtextNote = "Bootloader programming error"
                    }
                }

                onNotify: {
                    console.log(Logger.sciCategory, "flash notification", message)
                }
            }

            function callTryProgramDevice() {
                if (processingStatus === ProgramDeviceWizard.ProgrammingSucceed)
                {
                    processingStatus = ProgramDeviceWizard.WaitingForDevice
                }

                tryProgramDevice()
            }

            function tryProgramDevice() {
                if (warningDialog !== null) {
                    warningDialog.reject()
                }

                if (processingStatus === ProgramDeviceWizard.WaitingForDevice
                        || processingStatus === ProgramDeviceWizard.WaitingForJLink) {

                    if (sciModel.boardController.connectionIds.length === 1) {
                        if (wizard.useJLink) {
                            processingStatus = ProgramDeviceWizard.WaitingForJLink
                            var jLinkConnected = jLinkConnector.isBoardConnected()
                            if (jLinkConnected === false) {
                                jLinkCheckTimer.restart()
                                return
                            }
                        }

                        var connectionInfo = sciModel.boardController.getConnectionInfo(sciModel.boardController.connectionIds[0])
                        var bootloaderWarning = wizard.useJLink && connectionInfo.bootloaderVersion.length > 0
                        var firmwareWarning = connectionInfo.applicationVersion.length > 0

                        if (bootloaderWarning || firmwareWarning) {
                            var msg = "Connected device already has a "

                            if (bootloaderWarning) {
                                msg += "bootloader of version " + connectionInfo.bootloaderVersion
                            } else {
                                msg += "firmware " + connectionInfo.verboseName
                                msg += " of version " + connectionInfo.applicationVersion
                            }

                            msg += "\n"
                            msg += "\n"
                            msg += "Do you want to program it anyway ?"

                            warningDialog = SGWidgets.SGDialogJS.showMessageDialog(
                                        processPage,
                                        SGWidgets.SGMessageDialog.Warning,
                                        "Device already with firmware",
                                        msg,
                                        Dialog.Yes | Dialog.No,
                                        function() {
                                            startProgramDevice()
                                        },
                                        function() {
                                            processingStatus = ProgramDeviceWizard.WaitingForDevice
                                        })
                        } else {
                            if (wizard.useJLink == false && connectionInfo.bootloaderVersion.length === 0) {
                                msg = "Connected device does not have a bootloader and cannot be programmed.\n\n"
                                msg += "In order to program this device, please go back and check bootloader option."

                                warningDialog = SGWidgets.SGDialogJS.showMessageDialog(
                                            processPage,
                                            SGWidgets.SGMessageDialog.Error,
                                            "Device without bootloader",
                                            msg,
                                            Dialog.Ok,
                                            function() {
                                                processingStatus = ProgramDeviceWizard.WaitingForDevice
                                            })
                            } else {
                                startProgramDevice()
                            }
                        }
                    } else {
                        processingStatus = ProgramDeviceWizard.WaitingForDevice
                    }
                }
            }

            function startProgramDevice() {
                if (wizard.useJLink) {
                    doProgramDeviceBootloader()
                } else {
                    doProgramDeviceApplication()
                }
            }

            function doProgramDeviceBootloader() {
                processingStatus = ProgramDeviceWizard.ProgrammingBootloader
                processPage.subtextNote = "Programming"
                jLinkConnector.flashBoardRequested(wizard.bootloaderPath, true)
            }

            function doProgramDeviceApplication() {
                processingStatus = ProgramDeviceWizard.ProgrammingApplication
                sciModel.programDevice(sciModel.boardController.connectionIds[0], firmwarePath)
            }

            Component.onCompleted: {
                tryProgramDevice()
            }

            SGWidgets.SGText {
                id: statusText
                y: Math.floor(parent.height * 0.3)
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                fontSizeMultiplier: 2.0
                text: {
                    if (processingStatus === ProgramDeviceWizard.WaitingForDevice) {
                        return "Waiting for device to connect"
                    } else if (processingStatus === ProgramDeviceWizard.WaitingForJLink) {
                            return "Waiting for JLink connection"
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingBootloader) {
                        return "Programming bootloader..."
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingApplication) {
                        return "Programming firmware..."
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingSucceed) {
                        return "Programming successful"
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingFailed) {
                        return "Programming failed"
                    }
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

                    running: processingStatus === ProgramDeviceWizard.ProgrammingBootloader
                             || processingStatus === ProgramDeviceWizard.ProgrammingApplication
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
                        return "Only single device with MCU EFM32GG380F1024 can be connected while programming"
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingBootloader
                               || processingStatus === ProgramDeviceWizard.ProgrammingApplication) {
                        var msg = processPage.subtextNote
                        msg += "\n\n"
                        msg += "Do not unplug the device until process is complete"
                        return msg
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingSucceed) {
                        msg = "To program another device, simply plug it in and\n new process will start automatically\n\n"
                        msg += "Press Done if you don't want to program another device"
                        return msg
                    } else if(processingStatus === ProgramDeviceWizard.ProgrammingFailed) {
                        msg = processPage.subtextNote
                        msg += "\n\n"
                        msg += "Unplug the device and press Continue"
                        return msg
                    }

                    return ""
                }
            }

            Row {
                anchors {
                    top: statusSubtext.bottom
                    topMargin: 4 * processPage.verticalSpacing
                    horizontalCenter: parent.horizontalCenter
                }

                spacing: wizard.spacing

                SGWidgets.SGButton {
                    id: cancelBtn

                    text: qsTr("Done")
                    visible: processingStatus === ProgramDeviceWizard.WaitingForDevice
                             || processingStatus === ProgramDeviceWizard.WaitingForJLink
                             || processingStatus === ProgramDeviceWizard.ProgrammingSucceed

                    onClicked: cancelRequested()
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

    Component {
        id: fileDialogComponent
        FileDialog {
            folder: shortcuts.documents
        }
    }

    function getFilePath(title, nameFilterList, callback) {
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(
                    wizard,
                    fileDialogComponent,
                    {
                        "title": title,
                        "nameFilters": nameFilterList,
                    })

        dialog.accepted.connect(function() {
            if (callback) {
                callback(CommonCpp.SGUtilsCpp.urlToPath(dialog.fileUrl))
            }

            dialog.destroy()
        })

        dialog.rejected.connect(function() {
            dialog.destroy()
        })

        dialog.open();
    }
}
