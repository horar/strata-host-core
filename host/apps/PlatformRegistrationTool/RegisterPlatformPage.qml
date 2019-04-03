import QtQuick 2.12
import QtQuick.Controls 2.12

import "./common" as Common
import tech.strata.prt 1.0 as PrtCommon
import "./common/SgUtils.js" as SgUtils

PrtBasePage {
    id: page

    title: qsTr("Register Platfrom")

    property string outputStr
    property string bootloadeId
    property string firmwareId
    property string platformId
    property bool registrationInProgress: false
    property bool jLinkDone: false

    Timer {
        id: waitTimer
        interval: 1000
        onTriggered: {
            registrationFlashInit()
        }
    }

    Timer {
        id: fakeDownloadTimer
        interval: 2000
        onTriggered: {
            registrationFlash()
        }
    }

    PrtCommon.SgJLinkConnector {
        id: jlinkConnector

        onBoardFlashFinished: {
            if (registrationInProgress) {
                if (success) {
                    outputStr += "JLink process finished.\n"
                    //we can continue with registering
                    registrationCheckBoard(true)
                } else {
                    finishRegistration(false)
                }
            }
        }

        onNotify: {
            //JLink includes \b to trim char from previous output.

            var newMsg = outputStr

            for(var i = 0; i < message.length; ++i) {
                if (message[i] === "\b") {
                    newMsg = newMsg.slice(0, newMsg.length - 1)
                } else {
                    newMsg += message[i]
                }
            }

            outputStr = newMsg
        }
    }

    Connections {
        target: prtModel

        onFlashTaskDone: {
            if (registrationInProgress) {
                if (status) {
                    outputStr += "Flashing process finished.\n"
                    registrationCheckBoard();
                } else {
                    finishRegistration(false)
                }
            }
        }

        onNotify: {
            outputStr += message
        }

        onMessageArrived: {
            if (prtModel.connectionIds[0] !== connectionId) {
                console.log("onMessageArrived() notification from another device => skipped")
                return
            }

            var data = JSON.parse(message)

            if (!data.hasOwnProperty("notification")) {
                return
            }

            var type = data["notification"]["value"]
            if (type === "get_firmware_info") {
                var value = data["notification"]["payload"]["bootloader"]["version"]
                if (!value) {
                    value = ""
                }
                page.bootloadeId = value

                value = data["notification"]["payload"]["application"]["version"]
                if (!value) {
                    value = ""
                }
                page.firmwareId = value
            } else if (type === "get_platform_id") {
                value = data["notification"]["payload"]["platform_id"]
                if (!value) {
                    value = ""
                }

                page.platformId = value
            }
        }
    }

    ListModel {
        id: platformModel

        Component.onCompleted: {
            append({"opn":"STR-USBC-2PORT-100W-EVK","name":"USB-PD Dual 100W Power Only", "version":"1.0"})
            append({"opn":"STR-USBC-4PORT-200W-EVK","name":"USB-PD 200W 4-Port Source", "version":"1.1"})
            append({"opn":"STR-LOGIC-GATES-EVK","name":"Logic Gates", "version":"1.0"})
            append({"opn":"STR-4LED-SOL-EVAL-EVK","name":"LED Demo Board", "version":"1.0"})
            append({"opn":"STR-XDFN-LDO-EVK","name":"XDFN LDO", "version":"1.0"})
            append({"opn":"STR-15A-SWITCHER-EVK","name":"15A Switcher", "version":"1.0"})
            append({"opn":"STR-5A-SWITCHER-EVK","name":"5A Switcher", "version":"1.1"})
        }
    }

    Item {
        anchors {
            fill: parent
            margins: 6
        }

        Common.SgBaseEditor {
            id: opnFilterEditor
            anchors.horizontalCenter: parent.horizontalCenter

            label: qsTr("Ordering Part Number")
            helperText: qsTr("? - any single char\n* - zero or more of any chars")

            property string text

            editor: Common.SgTextField {
                id: editor
                width: 400

                text: opnFilterEditor.text
                onTextChanged: opnFilterEditor.text = text
                Binding {
                    target: opnFilterEditor
                    property: "text"
                    value: editor.text
                }

                suggestionListModel: opnSortFilterModel
                suggestionModelTextRole: "opn"

                onSuggestionDelegateSelected: {
                    var sourceIndex = opnSortFilterModel.mapIndexToSource(index)
                    if(sourceIndex < 0) {
                        return
                    }

                    opnFilterEditor.text = platformModel.get(sourceIndex)[suggestionModelTextRole]

                    //fake data
                    boardStatus.firmwareId = "1.0.2"
                    boardStatus.verboseName = "USB-PD Dual 100W Power Only"
                    boardStatus.boardRevision = "1.1"
                    boardStatus.opn = platformModel.get(sourceIndex)[suggestionModelTextRole]
                    boardStatus.year = 2018
                    boardStatus.boardImageSrc = "qrc:/images/board1.jpg"
                    boardStatus.applicationTagList = ["automotive","networkingtelecom"]
                    boardStatus.productTagList = ["ac","audio","imagesensors"]
                    boardStatus.description = "Very long description.Very long description.Very long description.Very long description.Very long description.Very long description.Very long description.Very long description.Very long description.Very long description."
                    boardStatus.visible = true
                    registerBtn.visible = true
                }

                PrtCommon.SgSortFilterProxyModel {
                    id: opnSortFilterModel
                    sourceModel: platformModel
                    sortRole: "opn"
                    filterRole: "opn"
                    filterPattern: "*" + opnFilterEditor.text + "*"
                    filterPatternSyntax: PrtCommon.SgSortFilterProxyModel.Wildcard
                }
            }
        }

        BoardStatus {
            id: boardStatus
            anchors {
                top: opnFilterEditor.bottom
                topMargin: 16
                left: parent.left
                right: parent.right
            }

            height: 500

            visible: false
            showIsConnected: false
            showIsRegistered: false
            showBootloaderId: false
        }

        Row {
            id: buttonRow
            anchors {
                top: boardStatus.bottom
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }

            spacing: 6

            Common.SgButton {
                id: registerBtn
                visible: false
                text: qsTr("Register\nPlatform")
                onClicked: {
                    registrationInit()
                }
            }
        }

        Row {
            anchors {
                top: buttonRow.bottom
                topMargin: 40
                horizontalCenter: parent.horizontalCenter
            }

            spacing: 6

            Common.SgButton {
                text: "DEBUG: JLink load"
                onClicked: {
                    jLinkLoadBoard()
                }
            }

            Common.SgButton {
                text: "DEBUG: JLink load force"
                onClicked: {
                    jLinkLoadForceBoard()
                }
            }

            Common.SgButton {
                text: "DEBUG: JLink erase"
                onClicked: {
                    jLinkEraseBoard()
                }
            }

            Common.SgButton {
                text: "DEBUG: Flasher"
                onClicked: {
                    prtModel.flash("gg","/Users/zbh6nr/proj/images/bubu2-release.bin")
                }
            }
        }
    }

    function registrationInit() {
        registrationInProgress = true
        jLinkDone = false

        var dialog = SgUtils.createDialog("qrc:/TextProgressDialog.qml", page)
        if (dialog) {
            outputStr = ""
            dialog.closePolicy = Popup.NoAutoClose
            dialog.text = Qt.binding(function() { return outputStr})

            dialog.open()
        }

        registrationCheckBoard()
    }

    function registrationCheckBoard() {
        bootloadeId = ""
        firmwareId = ""
        platformId = ""

        outputStr += "Checking board.\n"
        if (prtModel.connectionIds.length === 0) {
            outputStr += "No board connected.\n"
            finishRegistration(false)
            return
        }

        queryFirmware(prtModel.connectionIds[0])
        queryPlatformId(prtModel.connectionIds[0])
        waitTimer.restart();
    }

    function registrationFlashInit() {
        if (bootloadeId.length) {
            outputStr += "Bootloader version: " + bootloadeId + "\n"
        }

        if (firmwareId.length) {
            outputStr += "Firmware version: " + firmwareId + "\n"
        }

        if (platformId.length) {
            outputStr += "platform id: " + platformId + "\n"
            outputStr += "Platform already registered."
            finishRegistration(false)
            return
        }

        if (firmwareId.length || bootloadeId.length) {
            if (firmwareId.length && isFlashVersionValid) {
                //register this platform
                outputStr += "Firmware version is valid " + platformId + "\n"
                registrationRegister();

            } else {
            //download image and flash it
            outputStr += "Downloading firmware for " + boardStatus.opn + "\n"
            fakeDownloadTimer.start()
            }
        } else if (!bootloadeId.length && !firmwareId.length) {
            outputStr += "Bootloader not detected.\n"
            if (jLinkDone) {
                finishRegistration(false);
            } else {
                jlinkConnector.flashBoardRequested("/Users/zbh6nr/proj/images/bootloader-release.bin")
            }
        }
    }


    function registrationRegister() {
        //TODO registration process
        outputStr += "Registering Platform.\n"

        //...
        outputStr += "Fake registration in progress.\n"

        finishRegistration(true)
    }

    function isFlashVersionValid(currentVersion) {
        //TODO: we should check whether flashed version is the version of firmware user picked
        return true
    }

    function registrationFlash() {
        outputStr += "Verifying firmware.\n"

        outputStr += "Flashing firmware.\n"

        prtModel.flash(prtModel.connectionIds[0],"/Users/zbh6nr/proj/images/bubu2-release.bin")
    }

    function finishRegistration(status) {
        if (status) {
            outputStr += "\n"
            outputStr += "Registration DONE.\n"
        } else {
            outputStr += "\n"
            outputStr += "Registration FAILED.\n"
        }

        registrationInProgress = false
    }


    function jLinkLoadBoard() {
        var dialog = SgUtils.createDialog("qrc:/TextProgressDialog.qml", page)
        if (dialog) {
            outputStr = ""
            dialog.closePolicy = Popup.NoAutoClose
            dialog.title = "JLink load"
            dialog.text = Qt.binding(function() { return outputStr})

            dialog.open()
            jlinkConnector.flashBoardRequested("/Users/zbh6nr/proj/images/bootloader-release.bin")
        }
    }

    function jLinkLoadForceBoard() {
        var dialog = SgUtils.createDialog("qrc:/TextProgressDialog.qml", page)
        if (dialog) {
            outputStr = ""
            dialog.closePolicy = Popup.NoAutoClose
            dialog.title = "JLink load force"
            dialog.text = Qt.binding(function() { return outputStr})

            dialog.open()
            jlinkConnector.flashBoardRequested("/Users/zbh6nr/proj/images/bootloader-release.bin", true)
        }
    }

    function jLinkEraseBoard() {
        var dialog = SgUtils.createDialog("qrc:/TextProgressDialog.qml", page)

        if (dialog) {
            outputStr = ""
            dialog.closePolicy = Popup.NoAutoClose
            dialog.title = "JLink erase"
            dialog.text = Qt.binding(function() { return outputStr})

            dialog.open()
            jlinkConnector.flashBoardRequested("", true)
        }
    }

    function queryFirmware(connectionId) {
        var cmd = JSON.stringify({
            "cmd":"get_firmware_info",
            "payload": {}
        })

        prtModel.sendCommand(connectionId, cmd)
    }

    function queryPlatformId(connectionId) {
        var cmd = JSON.stringify({
            "cmd":"get_platform_id",
            "payload": {}
        })

        prtModel.sendCommand(connectionId,cmd)
    }
}
