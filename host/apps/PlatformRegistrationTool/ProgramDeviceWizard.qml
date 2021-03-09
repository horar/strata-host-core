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

    //not sure whether opn is part of data blob
    property string embeddedOpn: ""
    property string controllerOpn: ""
    property string assistedOpn: ""

    property string platformClassId: ""
    property string mcuJlinkDevice: ""
    property int mcuBootloaderStartAddress: 0
    property var firmware: ({})
    property var bootloader: ({})

    property QtObject prtModel

    property int spacing: 10
    property variant warningDialog: null

    property alias jLinkConnector: jLinkConnector

    clip: true

    enum RegistrationMode {
        Unknown,
        Embedded,
        ControllerAndAssisted,
        ControllerOnly
    }

    Component.onCompleted: {
        resolveDataForStateMachine()
        embeddedStateMachine.start()
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    property bool stateDownloadActive: embeddedStateMachine.stateDownloadActive
    property bool stateControllerCheckActive
    property bool stateControllerRegistrationActive
    property bool stateAssistedCheckActive: embeddedStateMachine.stateCheckDeviceActive
    property bool stateAssistedRegistrationActive: embeddedStateMachine.stateRegistrationActive
    property bool stateErrorActive: embeddedStateMachine.stateErrorActive
    property bool stateLoopFailedActive: embeddedStateMachine.stateLoopFailedActive
    property bool stateLoopSucceedActive: embeddedStateMachine.stateLoopSucceedActive

    property string statusText: embeddedStateMachine.statusText
    property string subtext: embeddedStateMachine.subtext

    ProgramDeviceStateMachine {
        id: embeddedStateMachine

        running: false
        prtModel: wizard.prtModel
        jLinkConnector: wizard.jLinkConnector

        firmwareData: wizard.firmware
        bootloaderData: wizard.bootloader
        classId: wizard.platformClassId
        jlinkDevice: wizard.mcuJlinkDevice
        bootloaderStartAddress: wizard.mcuBootloaderStartAddress
        opn: wizard.embeddedOpn

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
        nodeControllerRegistrationHighlight: wizard.stateControllerRegistrationActive
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

            property bool runBusyIndicator: wizard.stateDownloadActive || wizard.stateAssistedRegistrationActive
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
            visible: wizard.stateAssistedCheckActive
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
            visible: wizard.stateDownloadActive || wizard.stateAssistedCheckActive || wizard.stateLoopSucceedActive || wizard.stateErrorActive
        }

        SGWidgets.SGButton {
            id: continueBtn
            text: "Continue"
            visible: wizard.stateLoopFailedActive
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

    function resolveDataForStateMachine() {

        if (registrationMode === ProgramDeviceWizard.Embedded) {
            wizard.platformClassId = wizard.embeddedData.class_id
            //wizard.platformOpn = wizard.embeddedData.name
            wizard.mcuJlinkDevice = wizard.embeddedData.mcu.jlink_device
            wizard.mcuBootloaderStartAddress = wizard.embeddedData.mcu.bootloader_start_address


            var latestFirmwareIndex = findHighestBinary(wizard.embeddedData.firmware)
            if (latestFirmwareIndex < 0) {
                console.error(Logger.prtCategory,"no valid firmware available", JSON.stringify(wizard.embeddedData))
                return
            }

            wizard.firmware = embeddedData.firmware[latestFirmwareIndex]

            var latestBootloaderIndex = findHighestBinary(wizard.embeddedData.bootloader)
            if (latestFirmwareIndex < 0) {
                console.error(Logger.prtCategory,"no valid bootloader available", JSON.stringify(wizard.embeddedData))
                return
            }

            wizard.bootloader = wizard.embeddedData.bootloader[latestFirmwareIndex]


        } else if (registrationMode === ProgramDeviceWizard.ControllerAndAssisted) {

        } else if (registrationMode === ProgramDeviceWizard.ControllerOnly) {

        }

        console.log(Logger.prtCategory, "classId", wizard.platformClassId)
        console.log(Logger.prtCategory, "mcuJlinkDevice", wizard.mcuJlinkDevice)
        console.log(Logger.prtCategory, "mcuBootloaderStartAddress", wizard.mcuBootloaderStartAddress)
        console.log(Logger.prtCategory, "firmware", wizard.firmware.version, wizard.firmware.file, wizard.firmware.timestamp)
        console.log(Logger.prtCategory, "bootloader", wizard.bootloader.version, wizard.bootloader.file, wizard.bootloader.timestamp)
    }

    function findHighestBinary(binaryList) {
        var latestBinaryIndex = -1
        for (var i = 1; i < binaryList.length; ++i) {
            if (isBinaryValid(binaryList[i]) === false) {
                console.error(Logger.prtCategory,"entry is not valid", JSON.stringify(binaryList[i]))
                continue
            }

            if (latestBinaryIndex < 0) {
                latestBinaryIndex = i
            } else if (CommonCpp.SGVersionUtils.greaterThan(binaryList[i].version, binaryList[latestBinaryIndex].version)) {
                latestBinaryIndex = i
            }
        }

        return latestBinaryIndex
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
