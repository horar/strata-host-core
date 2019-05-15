import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.fonts 1.0 as StrataFonts
import "./common" as Common
import "./common/SgUtils.js" as SgUtils
import tech.strata.utils 1.0
import "./common/Colors.js" as Colors
import QtQuick.Dialogs 1.3

Item {
    id: wizard

    property string connectionId
    property bool flashLoop: false
    property string firmwarePath
    property int spacing: 10

    signal cancelRequested()

    enum ProcessingStatus {
        NoDevice,
        ProgrammigDevice,
        ProgrammigSucceed,
        ProgrammigFailed
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

    Component {
        id: initPageComponent

        SciBasePage {
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

                Item {
                    id: optionWrapper
                    y: Math.floor(parent.height * 0.3)
                    width: parent.width - 50
                    height: automaticOptionWrapper.y + automaticOptionWrapper.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    Item {
                        id: manualOptionWrapper
                        width: parent.width
                        height: pathEdit.y + pathEdit.height

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

                        Common.SgTextFieldEditor {
                            id: pathEdit
                            anchors {
                                left: manualButton.right
                                leftMargin: wizard.spacing
                            }

                            label: qsTr("Firmware path")
                            itemWidth: Math.floor(optionWrapper.width * 0.7)
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
                                    return qsTr("Firmware path is required")
                                } else if (!SgUtilsCpp.isFile(text)) {
                                    return qsTr("Firmware path does not refer to a file")
                                }

                                return ""
                            }
                        }

                        Common.SgButton {
                            id: selectButton
                            anchors {
                                left: pathEdit.right
                                leftMargin: wizard.spacing
                                verticalCenter: manualButton.verticalCenter
                            }
                            text: "Select"
                            enabled: manualButton.checked
                            focusPolicy: Qt.NoFocus
                            onClicked: {
                                showFileDialog()
                            }
                        }
                    }

                    Item {
                        id: automaticOptionWrapper
                        width: parent.width
                        height: opnEdit.y + opnEdit.height
                        anchors {
                            top: manualOptionWrapper.bottom
                            topMargin: 20
                        }

                        //TODO disabled until we have connection to couchbase
                        enabled: false

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

                        Common.SgTextFieldEditor {
                            id: opnEdit
                            anchors {
                                left: automaticButton.right
                                leftMargin: wizard.spacing
                            }

                            itemWidth: Math.floor(optionWrapper.width * 0.7)
                            label: "Ordering Part Number"
                            enabled: automaticButton.checked
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

                Common.SgButton {
                    text: qsTr("Close")
                    onClicked: cancelRequested()
                    focusPolicy: Qt.NoFocus
                }

                Common.SgButton {
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

                        if (errorList.length) {
                            SgUtils.showMessageDialog(
                                        settingsPage,
                                        Common.SgMessageDialog.Error,
                                        qsTr("Validation Failed"),
                                        errorList.join("\n"))

                        } else {
                            stackView.push(processPageComponent)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: processPageComponent

        SciBasePage {
            id: processPage
            title: qsTr("Programming Device")

            property int verticalSpacing: 8
            property int processingStatus: ProgramDeviceWizard.NoDevice
            property string flashProgressNotification
            property variant warningDialog: null

            hasBack: processingStatus !== ProgramDeviceWizard.ProgrammigDevice

            Connections {
                target: sciModel.boardController

                onActiveBoard: {
                    if (processingStatus === ProgramDeviceWizard.ProgrammigSucceed
                            || processingStatus === ProgramDeviceWizard.ProgrammigFailed)
                    {
                        processingStatus = processingStatus = ProgramDeviceWizard.NoDevice
                    }

                    tryProgramDevice()
                }

                onDisconnectedBoard: {
                    if (processingStatus === ProgramDeviceWizard.ProgrammigSucceed
                            || processingStatus === ProgramDeviceWizard.ProgrammigFailed)
                    {
                        processingStatus = ProgramDeviceWizard.NoDevice
                    }

                    tryProgramDevice()
                }
            }

            Connections {
                target: sciModel

                onNotify: {
                    processPage.flashProgressNotification = message
                }

                onProgramDeviceDone: {
                    if (status) {
                        processingStatus = ProgramDeviceWizard.ProgrammigSucceed
                    } else {
                        processingStatus = ProgramDeviceWizard.ProgrammigFailed
                    }
                }
            }

            function tryProgramDevice() {
                if (warningDialog !== null) {
                    warningDialog.reject()
                }

                if (processingStatus === ProgramDeviceWizard.NoDevice) {
                    if (sciModel.boardController.connectionIds.length === 1) {
                        var connectionInfo = sciModel.boardController.getConnectionInfo(sciModel.boardController.connectionIds[0])

                        if (connectionInfo.applicationVersion.length > 0) {
                            var msg = "Connected device already has a firmware " + connectionInfo.verboseName
                            msg += " of version " + connectionInfo.applicationVersion
                            msg += "\n"
                            msg += "\n"
                            msg += "Do you want to program it anyway ?"

                            warningDialog =SgUtils.showMessageDialog(
                                        processPage,
                                        Common.SgMessageDialog.Warning,
                                        "Device already with firmware",
                                        msg,
                                        Dialog.Yes | Dialog.No,
                                        function() {
                                            doProgramDevice()
                                        })
                        } else {
                            doProgramDevice()
                        }
                    }
                }
            }

            function doProgramDevice() {
                processingStatus = ProgramDeviceWizard.ProgrammigDevice
                sciModel.programDevice(sciModel.boardController.connectionIds[0], firmwarePath)
            }

            Component.onCompleted: {
                tryProgramDevice()
            }

            Common.SgText {
                id: statusText
                y: Math.floor(parent.height * 0.3)
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                fontSizeMultiplier: 2.0
                text: {
                    if (processingStatus === ProgramDeviceWizard.NoDevice) {
                        return "Waiting for device to connect"
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammigDevice) {
                        return "Device programming in progress"
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammigSucceed) {
                        return "Device programmed successfully"
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammigFailed) {
                        return "Device programmed failed"
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

                    running: processingStatus === ProgramDeviceWizard.ProgrammigDevice
                }

                Common.SgIcon {
                    id: iconIndicator
                    width: parent.width
                    height: width

                    source: {
                        if (processingStatus === ProgramDeviceWizard.ProgrammigSucceed) {
                            return "qrc:/images/check.svg"
                        } else if (processingStatus === ProgramDeviceWizard.ProgrammigFailed) {
                            return "qrc:/images/times-circle.svg"
                        }

                        return ""
                    }

                    iconColor: {
                        if (processingStatus === ProgramDeviceWizard.ProgrammigSucceed) {
                            return Colors.STRATA_GREEN
                        } else if (processingStatus === ProgramDeviceWizard.ProgrammigFailed) {
                            return Colors.TANGO_SCARLETRED2
                        }

                        return "black"
                    }
                }
            }

            Common.SgText {
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
                    if (processingStatus === ProgramDeviceWizard.NoDevice) {
                        return "Only single device can be connected while programming"
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammigDevice) {
                        var msg = processPage.flashProgressNotification
                        msg += "\n\n"
                        msg += "Do not unplug the device until process is complete"
                        return msg
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammigSucceed
                               || processingStatus === ProgramDeviceWizard.ProgrammigFailed) {
                        msg = "You can unplug the device now\n\n"
                        msg += "To program another device, simply plug it in and\n new process will start automatically"
                        return msg
                    }

                    return ""
                }
            }

            Common.SgButton {
                id: cancelBtn
                anchors {
                    top: statusSubtext.bottom
                    topMargin: 4 * processPage.verticalSpacing
                    horizontalCenter: parent.horizontalCenter
                }

                text: qsTr("Done")
                visible: processingStatus === ProgramDeviceWizard.NoDevice
                         ||processingStatus === ProgramDeviceWizard.ProgrammigSucceed
                         || processingStatus === ProgramDeviceWizard.ProgrammigFailed

                onClicked: cancelRequested()
            }
        }
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            title: qsTr("Select Firmware Binary")
            folder: shortcuts.home
            nameFilters: ["Binary files (*.bin)","All files (*)"]
        }
    }

    function showFileDialog() {
        var dialog = SgUtils.createDialogFromComponent(wizard, fileDialogComponent)

        dialog.accepted.connect(function() {
            wizard.firmwarePath = SgUtilsCpp.urlToPath(dialog.fileUrl)
            dialog.destroy()})

        dialog.rejected.connect(function() {
            dialog.destroy()
        })

        dialog.open();
    }
}
