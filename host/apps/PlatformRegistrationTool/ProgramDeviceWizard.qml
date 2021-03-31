import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.logger 1.0
import tech.strata.theme 1.0

FocusScope {
    id: wizard

    property int registrationMode: ProgramDeviceWizard.Unknown
    property string jlinkExePath: ""

    property var embeddedData: ({})
    property var assistedData: ({})
    property var controllerData: ({})

    property QtObject prtModel

    property int spacing: 10

    property alias jLinkConnector: jLinkConnector

    property bool stateDownloadActive: embeddedStateMachine.stateDownloadActive || assistedStateMachine.stateDownloadActive
    property bool stateControllerCheckActive: assistedStateMachine.stateControllerCheckActive
    property bool stateControllerRegistrationActive: assistedStateMachine.stateControllerRegistrationActive
    property bool stateControllerAlreadyRegisteredActive: assistedStateMachine.stateControllerAlreadyRegisteredActive
    property bool stateAssistedCheckActive: embeddedStateMachine.stateCheckDeviceActive || assistedStateMachine.stateAssistedDeviceCheckActive
    property bool stateAssistedRegistrationActive: embeddedStateMachine.stateRegistrationActive || assistedStateMachine.stateAssistedDeviceRegistrationActive
    property bool stateErrorActive: embeddedStateMachine.stateErrorActive || assistedStateMachine.stateErrorActive
    property bool stateLoopFailedActive: embeddedStateMachine.stateLoopFailedActive || assistedStateMachine.stateLoopFailedActive
    property bool stateLoopSucceedActive: embeddedStateMachine.stateLoopSucceedActive || assistedStateMachine.stateLoopSucceedActive

    property string statusText: {
        if (registrationMode === ProgramDeviceWizard.Embedded) {
            return embeddedStateMachine.statusText
        }

        return assistedStateMachine.statusText
    }

    property string subtext: {
        if (registrationMode === ProgramDeviceWizard.Embedded) {
            return embeddedStateMachine.subtext
        }

        return assistedStateMachine.subtext
    }

    clip: true

    enum RegistrationMode {
        Unknown,
        Embedded,
        ControllerAndAssisted,
        ControllerOnly
    }

    Component.onCompleted: {
        resolveDataForStateMachine()

        if (registrationMode === ProgramDeviceWizard.Embedded) {

            console.log(Logger.prtCategory, "classId", embeddedStateMachine.classId)
            console.log(Logger.prtCategory, "opn", embeddedStateMachine.opn)
            console.log(Logger.prtCategory, "mcuJlinkDevice", embeddedStateMachine.jlinkDevice)
            console.log(Logger.prtCategory, "mcuBootloaderStartAddress", embeddedStateMachine.bootloaderStartAddress)
            console.log(Logger.prtCategory, "firmware", embeddedStateMachine.firmwareData.version, embeddedStateMachine.firmwareData.file, embeddedStateMachine.firmwareData.timestamp)
            console.log(Logger.prtCategory, "bootloader", embeddedStateMachine.bootloaderData.version, embeddedStateMachine.bootloaderData.file, embeddedStateMachine.bootloaderData.timestamp)

            embeddedStateMachine.start()
        } else if (registrationMode === ProgramDeviceWizard.ControllerAndAssisted) {

            console.log(Logger.prtCategory, "assistedDeviceClassId", assistedStateMachine.assistedDeviceClassId)
            console.log(Logger.prtCategory, "assistedDeviceOpn", assistedStateMachine.assistedDeviceOpn)
            console.log(Logger.prtCategory, "controllerClassId", assistedStateMachine.controllerClassId)
            console.log(Logger.prtCategory, "controllerOpn", assistedStateMachine.controllerOpn)
            console.log(Logger.prtCategory, "mcuJlinkDevice", assistedStateMachine.jlinkDevice)
            console.log(Logger.prtCategory, "mcuBootloaderStartAddress", assistedStateMachine.bootloaderStartAddress)
            console.log(Logger.prtCategory, "firmware", assistedStateMachine.firmwareData.version, assistedStateMachine.firmwareData.file, assistedStateMachine.firmwareData.timestamp)
            console.log(Logger.prtCategory, "bootloader", assistedStateMachine.bootloaderData.version, assistedStateMachine.bootloaderData.file, assistedStateMachine.bootloaderData.timestamp)

            assistedStateMachine.start()
        } else if (registrationMode === ProgramDeviceWizard.ControllerOnly) {
            console.error(Logger.prtCategory, "controller only mode is not implemented yet")
        }
    }

    EmbeddedModeStateMachine {
        id: embeddedStateMachine

        running: false
        prtModel: wizard.prtModel
        jLinkConnector: wizard.jLinkConnector
        registrationMode: wizard.registrationMode
        jlinkExePath: wizard.jlinkExePath
        breakButton: breakBtn
        continueButton: continueBtn
        onExitWizardRequested: {
            closeWizard()
        }
    }

    AssistedModeStateMachine {
        id: assistedStateMachine

        running: false
        prtModel: wizard.prtModel
        jLinkConnector: wizard.jLinkConnector
        registrationMode: wizard.registrationMode
        jlinkExePath: wizard.jlinkExePath
        breakButton: breakBtn
        continueButton: continueBtn

        onExitWizardRequested: {
            closeWizard()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    SGWidgets.SGText {
        id: header
        anchors {
            top: parent.top
            topMargin: 8
            left: parent.left
            leftMargin: 8
        }

        text: "Registration"
        font.bold: true
        fontSizeMultiplier: 1.6
    }


    ProgramWorkflow {
        id: programWorkflow
        anchors {
            top: header.bottom
            topMargin: 8
            horizontalCenter: parent.horizontalCenter
        }

        nodeDownloadHighlight: wizard.stateDownloadActive

        nodeControllerCheckHighlight: wizard.stateControllerCheckActive
        nodeControllerRegistrationHighlight: wizard.stateControllerRegistrationActive || wizard.stateControllerAlreadyRegisteredActive
        nodeAssistedCheckHighlight: wizard.stateAssistedCheckActive
        nodeAssistedRegistrationHighlight: wizard.stateAssistedRegistrationActive

        nodeDoneHighlight: wizard.stateLoopSucceedActive || wizard.stateLoopFailedActive || wizard.stateErrorActive

        showControllerNodes: registrationMode === ProgramDeviceWizard.ControllerAndAssisted || registrationMode === ProgramDeviceWizard.ControllerOnly
        showAssistedNodes: registrationMode === ProgramDeviceWizard.ControllerAndAssisted || registrationMode === ProgramDeviceWizard.Embedded
    }

    CommonCpp.SGJLinkConnector {
        id: jLinkConnector
        eraseBeforeProgram: true
        exePath: wizard.jlinkExePath

        //for all MCUs
        speed: 1000
    }

    Item {
        id: content
        anchors {
            top: programWorkflow.bottom
            bottom: footer.top
            left: parent.left
            right: parent.right
            margins: 12
        }

        property int verticalSpacing: 8

        SGWidgets.SGText {
            id: statusTextItem
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            fontSizeMultiplier: 2.0
            text: wizard.statusText
        }

        Item {
            id: statusIndicator
            width: 100
            height: 100
            anchors {
                top: statusTextItem.bottom
                topMargin: parent.verticalSpacing
                horizontalCenter: parent.horizontalCenter
            }

            visible: busyIndicator.running || iconIndicator.status === Image.Ready

            /* QtBug-85860: When "running" property is changed too fast,
                    BusyIndicator stays hidden, even though "running" property is "true".*/

            property bool runBusyIndicator: wizard.stateDownloadActive || wizard.stateControllerRegistrationActive || wizard.stateAssistedRegistrationActive
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
                    if (wizard.stateLoopSucceedActive) {
                        return "qrc:/sgimages/check.svg"
                    } else if (wizard.stateLoopFailedActive || wizard.stateErrorActive) {
                        return "qrc:/sgimages/times-circle.svg"
                    }

                    return ""
                }

                iconColor: {
                    if (wizard.stateLoopSucceedActive) {
                        return Theme.palette.green
                    } else if (wizard.stateLoopFailedActive || wizard.stateErrorActive) {
                        return TangoTheme.palette.scarletRed2
                    }

                    return "black"
                }
            }
        }

        SGWidgets.SGText {
            id: statusSubtext
            anchors {
                top: statusIndicator.visible ? statusIndicator.bottom : statusTextItem.bottom
                topMargin: parent.verticalSpacing
                horizontalCenter: parent.horizontalCenter
            }

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMultiplier: 1.2
            font.italic: true
            text: wizard.subtext
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
            visible: wizard.stateAssistedCheckActive || wizard.stateControllerCheckActive
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
            id: breakBtn
            text: "End"
            visible: wizard.stateDownloadActive || wizard.stateAssistedCheckActive || wizard.stateControllerCheckActive || wizard.stateLoopSucceedActive || wizard.stateErrorActive
        }

        SGWidgets.SGButton {
            id: continueBtn
            text: "Continue"
            visible: wizard.stateLoopFailedActive
        }
    }

    function resolveDataForStateMachine() {

        if (registrationMode === ProgramDeviceWizard.Embedded) {
            embeddedStateMachine.classId = wizard.embeddedData.class_id
            embeddedStateMachine.opn = wizard.embeddedData.opn
            embeddedStateMachine.jlinkDevice = wizard.embeddedData.mcu.jlink_device
            embeddedStateMachine.bootloaderStartAddress = wizard.embeddedData.mcu.bootloader_start_address

            var highestFirmwareIndex = findHighestBinary(wizard.embeddedData.firmware)
            if (highestFirmwareIndex < 0) {
                console.error(Logger.prtCategory,"no valid firmware available", JSON.stringify(wizard.embeddedData))
                return
            }

            embeddedStateMachine.firmwareData = wizard.embeddedData.firmware[highestFirmwareIndex]

            var highestBootloaderIndex = findHighestBinary(wizard.embeddedData.bootloader)
            if (highestFirmwareIndex < 0) {
                console.error(Logger.prtCategory,"no valid bootloader available", JSON.stringify(wizard.embeddedData))
                return
            }

            embeddedStateMachine.bootloaderData = wizard.embeddedData.bootloader[highestBootloaderIndex]
        } else if (registrationMode === ProgramDeviceWizard.ControllerAndAssisted) {

            assistedStateMachine.controllerClassId = wizard.controllerData.class_id
            assistedStateMachine.controllerOpn = wizard.controllerData.opn

            assistedStateMachine.jlinkDevice = wizard.controllerData.mcu.jlink_device
            assistedStateMachine.bootloaderStartAddress = wizard.controllerData.mcu.bootloader_start_address

            var highestBootloaderIndex = findHighestBinary(wizard.controllerData.bootloader)
            if (highestBootloaderIndex < 0) {
                console.error(Logger.prtCategory,"no valid bootloader available", JSON.stringify(wizard.controllerData))
                return
            }

            assistedStateMachine.bootloaderData = wizard.controllerData.bootloader[highestBootloaderIndex]

            var controller_class_id = assistedStateMachine.bootloaderData.controller_class_id

            var highestFirmwareIndex = findHighestBinary(wizard.assistedData.firmware, controller_class_id)
            if (highestFirmwareIndex < 0) {
                console.error(Logger.prtCategory,"no intersection for firmware and controller combination", JSON.stringify(wizard.assistedData))
                return
            }

            assistedStateMachine.firmwareData = wizard.assistedData.firmware[highestFirmwareIndex]
            assistedStateMachine.assistedDeviceClassId = wizard.assistedData.class_id
            assistedStateMachine.assistedDeviceOpn = wizard.assistedData.opn


        } else if (registrationMode === ProgramDeviceWizard.ControllerOnly) {

        }
    }

    function findHighestBinary(binaryList, controller_class_id) {
        var highestBinaryIndex = -1
        for (var i = 0; i < binaryList.length; ++i) {
            if (isBinaryValid(binaryList[i]) === false) {
                console.error(Logger.prtCategory,"entry is not valid", JSON.stringify(binaryList[i]))
                continue
            }

            if (highestBinaryIndex < 0) {
                if (controller_class_id === undefined || binaryList[i].controller_class_id === controller_class_id) {
                    highestBinaryIndex = i
                }
            } else {
                if (controller_class_id === undefined || binaryList[i].controller_class_id === controller_class_id) {
                    if (CommonCpp.SGVersionUtils.greaterThan(binaryList[i].version, binaryList[highestBinaryIndex].version)) {
                        highestBinaryIndex = i
                    }
                }
            }
        }

        return highestBinaryIndex
    }

    function isBinaryValid(firmware) {
        if (firmware.md5.length === 0) {
            return false
        }

        if (firmware.file.length === 0) {
            return false
        }

        if (CommonCpp.SGVersionUtils.valid(firmware.version) === false) {
            return false
        }

        return true
    }

    function closeWizard() {
        StackView.view.pop();
    }

}
