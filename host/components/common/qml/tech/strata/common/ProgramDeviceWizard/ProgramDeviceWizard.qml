import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import QtQuick.Dialogs 1.3
import tech.strata.common 1.0
import Qt.labs.platform 1.1 as QtLabsPlatform

Item {
    id: wizard

    property variant boardManager: null
    property string binaryPathForJlink
    property string jlinkExePath
    property bool useJLink: false
    property int spacing: 10
    property bool closeButtonVisible: false
    property bool requestCancelOnClose: false
    property int processingStatus: ProgramDeviceWizard.SetupProgramming
    property bool loopMode: true
    property bool checkFirmware: true
    property bool useCurrentConnectionId: false
    property int currentConnectionId

    signal cancelRequested()

    enum ProcessingStatus {
        SetupProgramming,
        WaitingForDevice,
        WaitingForJLink,
        ProgrammingWithJlink,
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

        property alias binaryPathForJlink: wizard.binaryPathForJlink
        property alias jlinkExePath: wizard.jlinkExePath
        property alias useJLink: wizard.useJLink
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
            height: loopMode ? 40 : 0
            x: state2.x - padding + Math.round(state2.width/2) - wingWidth - 2

            visible: loopMode
            padding: 2
            color: baseColor
        }

        WorkflowNode {
            id: state1
            anchors {
                horizontalCenter: label1.horizontalCenter
                top: loopMode ? feedbackArrow.bottom : parent.top
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
            width: loopMode ? undefined : 0
            anchors {
                left: state4.right
                verticalCenter: state1.verticalCenter
            }


            visible: loopMode
            color: baseColor
            tailLength: Math.round(arrowTailLength/2)
        }

        WorkflowNodeText {
            anchors {
                left: arrow5.right
                verticalCenter: state1.verticalCenter
            }

            color: baseColor
            text: loopMode ? "End" : ""
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

            text: loopMode ? "Connect New\nDevice" : "Device Check"
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
    }

    CommonCpp.SGJLinkConnector {
        id: jLinkConnector
    }

    Component {
        id: initPageComponent

        FocusScope {
            id: settingsPage

            Connections {
                target: settingsPage.StackView.visible ? wizard.boardManager : null

                onBoardDisconnected: {
                    if (isCancelable(connectionId)) {
                        cancelRequested()
                    }
                }
            }

            Flickable {
                id: flick

                anchors {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                    bottom: footer.top
                    margins: 12
                }

                clip: true
                boundsBehavior: Flickable.StopAtBounds
                contentWidth: content.width
                contentHeight: content.height

                Component.onCompleted: {
                    manualButton.checked = true
                }

                ScrollBar.vertical: ScrollBar {
                    parent: flick.parent
                    anchors {
                        top: flick.top
                        bottom: flick.bottom
                        left: flick.right
                        leftMargin: 1
                    }

                    policy: ScrollBar.AlwaysOn
                    interactive: false
                    width: 8
                    visible: flick.height < flick.contentHeight
                }

                ButtonGroup {
                    buttons: [manualButton, automaticButton]
                }

                Column {
                    id: content
                    width: flick.width

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
                                y: firmwarePathEdit.itemY + (firmwarePathEdit.item.height - height) / 2

                                onCheckedChanged: {
                                    if (checked) {
                                        firmwarePathEdit.forceActiveFocus()
                                    }
                                }
                            }

                            SGWidgets.SGTextFieldEditor {
                                id: firmwarePathEdit

                                label: qsTr("Firmware data file")
                                itemWidth: optionWrapper.width - manualButton.width - selectButton.width - 2*wizard.spacing
                                enabled: manualButton.checked
                                inputValidation: true
                                placeholderText: "Enter path..."
                                text: wizard.binaryPathForJlink
                                onTextChanged: {
                                    wizard.binaryPathForJlink = text
                                }

                                Binding {
                                    target: firmwarePathEdit
                                    property: "text"
                                    value: wizard.binaryPathForJlink
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
                                                resolveAbsoluteFileUrl(wizard.binaryPathForJlink),
                                                function(path) {
                                                    wizard.binaryPathForJlink = path
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
                                itemWidth: firmwarePathEdit.itemWidth
                                label: "Ordering Part Number"
                                enabled: automaticButton.checked
                            }
                        }
                    }

                    SGWidgets.SGText {
                        id: bootloaderHeader

                        text: "J-Link"
                        fontSizeMultiplier: 2.0
                    }

                    Item {
                        id: jlinkWrapper

                        width: parent.width
                        height: jlinkInputColumn.y + jlinkInputColumn.height

                        Column {
                            id: jlinkInputColumn
                            anchors {
                                right: parent.right
                            }

                            Row {
                                spacing: wizard.spacing

                                SGWidgets.SGTextFieldEditor {
                                    id: jlinkExePathEdit

                                    itemWidth: firmwarePathEdit.itemWidth
                                    label: "SEGGER J-Link Commander executable (JLink.exe)"
                                    placeholderText: "Enter path..."
                                    inputValidation: true
                                    text: wizard.jlinkExePath
                                    onTextChanged: {
                                        wizard.jlinkExePath = text
                                    }

                                    Binding {
                                        target: jlinkExePathEdit
                                        property: "text"
                                        value: wizard.jlinkExePath
                                    }

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
                                                    resolveAbsoluteFileUrl(wizard.jlinkExePath),
                                                    function(path) {
                                                        wizard.jlinkExePath = path
                                                    })
                                    }
                                }
                            }
                        }
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

                        if (firmwarePathEdit.enabled) {
                            var error = firmwarePathEdit.inputValidationErrorMsg()
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
                target: wizard.boardManager

                onBoardReady: {
                    callTryProgramDevice()
                }

                onBoardDisconnected: {
                    if (isCancelable(connectionId)) {
                        cancelRequested()
                        return
                    }

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
                target: jLinkConnector

                onFlashBoardFinished: {
                    console.log(Logger.pdwCategory, "JLink flash finished with status=", status)
                    if (status) {
                        processingStatus = ProgramDeviceWizard.ProgrammingSucceed
                    } else {
                        processingStatus = ProgramDeviceWizard.ProgrammingFailed
                        subtextNote = "Firmware programming error"
                    }
                }

                onCheckConnectionFinished: {
                    console.log(Logger.pdwCategory, "JLink check connection finished with status=", status, "connected=", connected)
                    if (status && connected) {


                        var effectiveConnectionId = useCurrentConnectionId ? currentConnectionId : wizard.boardManager.readyConnectionIds[0]
                        var connectionInfo = wizard.boardManager.getConnectionInfo(effectiveConnectionId)

                        var hasFirmware = connectionInfo.applicationVersion.length > 0

                        if (checkFirmware && hasFirmware) {
                            showFirmwareWarning(false, connectionInfo.applicationVersion, connectionInfo.verboseName)
                            return
                        }

                        doProgramDeviceJlink()
                    } else {
                        jLinkCheckTimer.restart()
                    }
                }
            }

            function callTryProgramDevice() {
                if (loopMode === false && processingStatus === ProgramDeviceWizard.ProgrammingSucceed) {
                    return
                }

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
                        && processingStatus !== ProgramDeviceWizard.WaitingForJLink)
                {
                    return
                }

                if (wizard.boardManager.readyConnectionIds.length === 0) {
                    processingStatus = ProgramDeviceWizard.WaitingForDevice
                    return
                }

                if (useCurrentConnectionId && wizard.boardManager.readyConnectionIds.indexOf(currentConnectionId) < 0) {
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

                var run = jLinkConnector.flashBoardRequested(wizard.binaryPathForJlink, true)
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
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingWithJlink) {
                        var msg = processPage.subtextNote
                        msg += "\n\n"
                        msg += "Do not unplug the device until process is complete"
                        return msg
                    } else if (processingStatus === ProgramDeviceWizard.ProgrammingSucceed) {
                        if (loopMode) {
                            msg = "To program another device, simply plug it in and\n new process will start automatically\n\n"
                            msg += "or "
                            msg += "press End."
                            return msg
                        }
                    } else if(processingStatus === ProgramDeviceWizard.ProgrammingFailed) {
                        if (loopMode) {
                            msg = processPage.subtextNote
                            msg += "\n\n"
                            msg += "Unplug the device and press Continue"
                            return msg
                        }
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

                source: "qrc:/tech/strata/common/ProgramDeviceWizard/images/jlink-connect-schema.svg"
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

                    text: loopMode ? qsTr("End") : qsTr("Close")
                    visible: processingStatus === ProgramDeviceWizard.ProgrammingSucceed
                             || (loopMode === false && processingStatus === ProgramDeviceWizard.ProgrammingFailed)

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
                    visible: loopMode && processingStatus === ProgramDeviceWizard.ProgrammingFailed

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
            //"file:" scheme has length of 5
            folder: folderRequested.length > 5 ? folderRequested : shortcuts.documents

            property string folderRequested
        }
    }

    function getFilePath(title, nameFilterList, folder, callback) {

        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(
                    wizard,
                    fileDialogComponent,
                    {
                        "title": title,
                        "nameFilters": nameFilterList,
                        "folderRequested": folder
                    })

        dialog.accepted.connect(function() {
            if (callback) {
                callback(CommonCpp.SGUtilsCpp.urlToLocalFile(dialog.fileUrl))
            }

            dialog.destroy()
        })

        dialog.rejected.connect(function() {
            dialog.destroy()
        })

        dialog.open();
    }

    function isCancelable(connectionId) {
        return loopMode === false
                && useCurrentConnectionId
                && connectionId === currentConnectionId
                && (processingStatus === ProgramDeviceWizard.SetupProgramming
                    || processingStatus === ProgramDeviceWizard.WaitingForDevice
                    || processingStatus === ProgramDeviceWizard.WaitingForJLink)
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

        console.log(Logger.pdwCategory, "exeName", exeName)
        console.log(Logger.pdwCategory, "pathList", JSON.stringify(pathList))

        var url = QtLabsPlatform.StandardPaths.findExecutable(exeName, pathList)
        if (url && url.toString().length > 0) {
            url = CommonCpp.SGUtilsCpp.urlToLocalFile(url)
            console.log(Logger.pdwCategory, "JLink exe path", url)
            return url
        } else {
            console.log(Logger.pdwCategory, "JLink exe path could not be found")
        }

        return ""
    }
}
