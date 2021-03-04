import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.logger 1.0
import tech.strata.flasherConnector 1.0
import tech.strata.theme 1.0
import QtQml.StateMachine 1.12 as DSM

FocusScope {
    id: wizard

    property QtObject prtModel
    property int platformIndex: -1
    property string jlinkExePath
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

    property alias jLinkConnector: jLinkConnector
    Component.onCompleted: {
        if (jlinkExePath.length === 0) {
            jlinkExePath = searchJLinkExePath()
        }

        if (jlinkExePath.length > 0) {
            searchEdit.forceActiveFocus()
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

    ProgramDeviceStateMachine {
        id: stateMechine

        prtModel: wizard.prtModel
        jLinkConnector: wizard.jLinkConnector

        breakButton: breakBtn
        continueButton: continueBtn
    }

    Workflow {
        id: workflow
        anchors {
            top: parent.top
            topMargin: 8
            horizontalCenter: parent.horizontalCenter
        }

        nodeSettingsHighlight: stateMechine.stateSettingsActive
        nodeDownloadHighlight: stateMechine.stateDownloadActive
        nodeDeviceCheckHighlight: stateMechine.stateCheckDeviceActive
        nodeProgramHighlight: stateMechine.stateProgramActive
        nodeRegistrationHighlight: stateMechine.stateRegistrationActive
        nodeDoneHighlight: stateMechine.stateLoopSucceedActive || stateMechine.stateLoopFailedActive || stateMechine.stateErrorActive
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

//TODO this should be set based on info from cloud service
//        device: "RSL10"
//        speed: 1000
//        startAddress: parseInt("00100000",16)

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

            enabled: stateMechine.stateSettingsActive
            opacity: stateMechine.stateSettingsActive ? 1 : 0
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

            enabled: stateMechine.stateSettingsActive === false
            opacity: stateMechine.stateSettingsActive ? 0 : 1
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
                    if (stateMechine.stateDownloadActive) {
                        return "Downloading..."
                    } else if (stateMechine.stateWaitForDeviceActive) {
                        return "Waiting for device to connect"
                    } else if (stateMechine.stateWaitForJLinkActive) {
                        return "Waiting for JLink connection"
                    } else if (stateMechine.stateProgramBootloaderActive) {
                        return "Programming bootloader..."
                    } else if (stateMechine.stateProgramFirmwareActive) {
                        return "Programming firmware..."
                    } else if (stateMechine.stateRegistrationActive) {
                        return "Registering..."
                    } else if (stateMechine.stateLoopSucceedActive) {
                        return "Platfrom Registered Successfully"
                    } else if (stateMechine.stateLoopFailedActive || stateMechine.stateErrorActive) {
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
                property bool runBusyIndicator: stateMechine.stateDownloadActive ||  stateMechine.stateProgramActive  ||  stateMechine.stateRegistrationActive
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
                        if (stateMechine.stateLoopSucceedActive) {
                            return "qrc:/sgimages/check.svg"
                        } else if (stateMechine.stateLoopFailedActive || stateMechine.stateErrorActive) {
                            return "qrc:/sgimages/times-circle.svg"
                        }

                        return ""
                    }

                    iconColor: {
                        if (stateMechine.stateLoopSucceedActive) {
                            return Theme.palette.green
                        } else if (stateMechine.stateLoopFailedActive || stateMechine.stateErrorActive) {
                            return TangoTheme.palette.scarletRed2
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
                    if (stateMechine.stateCheckDeviceActive) {
                        var msg = "Only single device with MCU EFM32GG380F1024 can be connected while programming\n"

                        if (prtModel.deviceCount > 1) {
                            msg += "Multiple devices detected !"
                        }
                        return msg
                    } else if (stateMechine.stateProgramActive || stateMechine.stateRegistrationActive) {
                        msg = stateMechine.subtext
                        msg += "\n\n"
                        msg += "Do not unplug device"
                        return msg
                    } else if (stateMechine.stateLoopSucceedActive) {
                        msg = "You can unplug device now\n\n"
                        msg += "To program another device, simply plug it in and\n"
                        msg += "process will start automatically\n\n"
                        msg += "or press End."
                        return msg
                    } else if (stateMechine.stateLoopFailedActive) {
                        msg = stateMechine.subtext
                        msg += "\n\n"
                        msg += "Unplug device and press Continue"
                        return msg
                    } else if (stateMechine.stateErrorActive) {
                        msg = stateMechine.subtext
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
                visible: stateMechine.stateCheckDeviceActive
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
            visible: stateMechine.stateSettingsActive
            onClicked: {
                validateSettings()
            }
        }

        SGWidgets.SGButton {
            id: breakBtn
            text: "End"
            visible: stateMechine.stateDownloadActive || stateMechine.stateCheckDeviceActive || stateMechine.stateLoopSucceedActive || stateMechine.stateErrorActive
        }

        SGWidgets.SGButton {
            id: continueBtn
            text: "Continue"
            visible: stateMechine.stateLoopFailedActive
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
            CommonCpp.SGUtilsCpp.parentDirectoryPath(path))
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
