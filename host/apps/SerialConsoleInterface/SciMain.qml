import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.fonts 1.0 as StrataFonts
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.common 1.0 as Common
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.logger 1.0

Item {
    id: sciMain
    anchors {
        fill: parent
    }

    property bool programDeviceDialogOpened: false
    property variant platformInfoWindow: null

    property variant boardStorageContent: []
    property int maxBoardStorageLength: 20
    property string boardStoragePath: CommonCpp.SGUtilsCpp.urlToLocalFile(
                                          CommonCpp.SGUtilsCpp.joinFilePath(
                                              QtLabsPlatform.StandardPaths.writableLocation(
                                                  QtLabsPlatform.StandardPaths.AppDataLocation),
                                              "boardStorage.data"))
    ListModel {
        id: tabModel
    }

    Component.onCompleted: {
        loadBoardStorage()
    }

    Connections {
        target:  sciModel.boardManager

        onBoardReady: {
            if (recognized === false) {
                return
            }

            if (programDeviceDialogOpened) {
                return
            }

            var connectionInfo = sciModel.boardManager.getConnectionInfo(connectionId)
            var effectiveVerboseName = connectionInfo.verboseName

            if (connectionInfo.verboseName.length === 0) {
                if (connectionInfo.applicationVersion.lenght > 0) {
                    effectiveVerboseName = "Application v"+connectionInfo.applicationVersion
                } else if (connectionInfo.bootloaderVersion.length > 0) {
                    effectiveVerboseName = "Bootloader v"+connectionInfo.bootloaderVersion
                } else {
                    effectiveVerboseName = "Unknown"
                }
            }

            var platformItem = {
                "connectionId": connectionInfo.connectionId,
                "platformId": connectionInfo.platformId,
                "verboseName": effectiveVerboseName,
                "bootloaderVersion": connectionInfo.bootloaderVersion,
                "applicationVersion": connectionInfo.applicationVersion,
                "status": "connected"
            }

            for (var i = 0; i < tabModel.count; ++i) {
                var item = tabModel.get(i)
                if (item.connectionId === connectionId) {
                    tabModel.set(i, platformItem)
                    return
                }
            }

            tabModel.append(platformItem)

            tabBar.currentIndex = tabModel.count - 1
        }

        onBoardDisconnected: {
            for (var i = 0; i < tabModel.count; ++i) {
                var item = tabModel.get(i)
                if (item.connectionId === connectionId) {
                    tabModel.setProperty(i, "status","disconnected")
                    return
                }
            }
        }
    }

    Item {
        id: tabBarWrapper
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: tabBar.height

        Rectangle {
            anchors.fill: parent
            color: "black"
        }

        SGWidgets.SGText {
            id: dummyText
            visible: false
            fontSizeMultiplier: 1.1
            font.family: StrataFonts.Fonts.franklinGothicBold
            text: "Default Board Name Length"
        }

        Flickable {
            id: tabBar

            width: tabBarWrapper.width
            height: dummyText.contentHeight + 20

            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: tabRow.height
            contentWidth: tabRow.width

            property int currentIndex: -1

            property int statusLightHeight: dummyText.contentHeight + 10
            property int minTabWidth: 100
            property int preferredTabWidth: 2*statusLightHeight + dummyText.contentWidth + 20
            property int availableTabWidth: Math.floor((width - (tabRow.spacing * (tabModel.count-1))) / tabModel.count)
            property int tabWidth: Math.max(Math.min(preferredTabWidth, availableTabWidth), minTabWidth)

            Rectangle {
                height: parent.height
                width: tabBar.contentWidth + tabRow.spacing
                color: "#eeeeee"
            }

            Row {
                id: tabRow
                spacing: 1

                Repeater {
                    model: tabModel

                    delegate: Item {
                        id: delegate
                        width: tabBar.tabWidth
                        height: statusLight.height + 10

                        MouseArea {
                            id: bgMouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                tabBar.currentIndex = index
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: index === tabBar.currentIndex ? "#eeeeee" : SGWidgets.SGColorsJS.STRATA_DARK
                        }

                        SGWidgets.SGStatusLight {
                            id: statusLight
                            anchors {
                                left: parent.left
                                leftMargin: 4
                                verticalCenter: parent.verticalCenter
                            }
                            width: tabBar.statusLightHeight

                            status: {
                                if (model.status === "connected") {
                                    return SGWidgets.SGStatusLight.Green
                                } if (model.status === "disconnected") {
                                    return SGWidgets.SGStatusLight.Off
                                }

                                return SGWidgets.SGStatusLight.Orange
                            }
                        }

                        SGWidgets.SGText {
                            id: buttonText
                            anchors {
                                left: statusLight.right
                                leftMargin: 2
                                verticalCenter: parent.verticalCenter
                                right: deleteButton.shown ? deleteButton.left : parent.right
                                rightMargin: 2
                            }

                            text: model.verboseName
                            font: dummyText.font
                            color: model.index === tabBar.currentIndex ? "black" : "white"
                            elide: Text.ElideRight
                        }

                        SGWidgets.SGIconButton {
                            id: deleteButton
                            anchors {
                                right: parent.right
                                rightMargin: 4
                                verticalCenter: parent.verticalCenter
                            }

                            opacity: shown ? 1 : 0
                            enabled: shown
                            alternativeColorEnabled: model.index !== tabBar.currentIndex
                            icon.source: "qrc:/sgimages/times.svg"

                            property bool shown: bgMouseArea.containsMouse || hovered

                            onClicked: {
                                if (model.status === "connected") {
                                    SGWidgets.SGDialogJS.showConfirmationDialog(
                                                root,
                                                "Device is active",
                                                "Do you really want to disconnect " + model.verboseName + " ?",
                                                "Disconnect",
                                                function () {
                                                    var ret = sciModel.boardManager.disconnect(connectionId)
                                                    if (ret) {
                                                        removeBoard(model.connectionId)
                                                    }
                                                },
                                                "Keep Connected"
                                                )
                                } else {
                                    removeBoard(model.connectionId)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    StackLayout {
        id: platformContentContainer
        anchors {
            top: tabBarWrapper.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        visible: tabModel.count > 0
        currentIndex: tabBar.currentIndex
        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                platformContentContainer.itemAt(currentIndex).forceActiveFocus()
            }
        }

        Repeater {
            id: tabRepeater
            model: tabModel
            delegate: PlatformDelegate {
                id: platformDelegate
                width: platformContentContainer.width
                height: platformContentContainer.height
                rootItem: sciMain

                onSendCommandRequested: {
                    sendCommand(connectionId, message)
                }

                onProgramDeviceRequested: {
                    if (model.status === "connected") {
                        showProgramDeviceDialogDialog(model.connectionId)
                    }
                }

                Connections {
                    target:  sciModel.boardManager
                    onNewMessage: {
                        if (programDeviceDialogOpened) {
                            return
                        }

                        if (model.connectionId === connectionId) {
                            var timestamp = Date.now()
                            appendCommand(createCommand(timestamp, message, "response"))
                        }
                    }
                }

                Component.onCompleted: {
                    loadCommandHistoryList()
                    sanitizeCommandHistory()
                }

                function loadCommandHistoryList() {
                    for (var i = 0; i < index; ++i) {
                        if(tabModel.get(i)["verboseName"] === model.verboseName) {
                            var list = tabRepeater.itemAt(i).getCommandHistoryList()
                            setCommandHistoryList(list)
                            return
                        }
                    }

                    for (var i = 0; i < boardStorageContent.length; ++i) {
                        if (boardStorageContent[i]["verboseName"] === model.verboseName) {
                            setCommandHistoryList(boardStorageContent[i]["commandHistoryList"])
                            break
                        }
                    }
                }

                function saveCommandHistoryList() {
                    if (model.verboseName.length === 0) {
                        return
                    }

                    var list = getCommandHistoryList()
                    if (list.length === 0) {
                        return
                    }

                    var newItem = {
                        "verboseName": model.verboseName,
                        "commandHistoryList": list
                    }

                    for (var i = 0; i < boardStorageContent.length; ++i) {
                        if (boardStorageContent[i]["verboseName"] === model.verboseName) {
                            boardStorageContent.splice(i, 1)
                            break
                        }
                    }

                    boardStorageContent.unshift(newItem)
                }
            }
        }
    }

    Item {
        anchors.fill: platformContentContainer
        visible: tabModel.count === 0
        SGWidgets.SGText {
            anchors.fill: parent

            text: "No Device Connected"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMultiplier: 3
        }
    }

    Component {
        id: programDeviceDialogComponent

        SGWidgets.SGDialog {
            id: dialog

            modal: true
            closePolicy: Popup.NoAutoClose
            focus: true
            padding: 0
            hasTitle: false

            property string connectionId

            contentItem: SGWidgets.SGPage {
                implicitWidth: sciMain.width - 20
                implicitHeight: sciMain.height - 20

                title: "Program Device Wizard"
                hasBack: false

                contentItem: Common.ProgramDeviceWizard {
                    boardManager: sciModel.boardManager
                    closeButtonVisible: true
                    requestCancelOnClose: true
                    loopMode: false
                    checkFirmware: false

                    useCurrentConnectionId: true
                    currentConnectionId: connectionId

                    onCancelRequested: {
                        if (programDeviceDialogOpened) {
                            dialog.close()
                            programDeviceDialogOpened = false
                            refrestDeviceInfo()
                        }
                    }
                }
            }
        }
    }

    function removeBoard(connectionId) {
        for (var i = 0; i < tabModel.count; ++i) {
            var item = tabModel.get(i)
            if (item.connectionId === connectionId) {
                tabRepeater.itemAt(i).saveCommandHistoryList()
                tabModel.remove(i)

                if (tabBar.currentIndex < 0 && tabModel.count > 0) {
                    tabBar.currentIndex = 0;
                }

                return
            }
        }
    }

    function sendCommand(connectionId, message) {
        var timestamp = Date.now()
        platformContentContainer.itemAt(tabBar.currentIndex).appendCommand(createCommand(timestamp, message, "query"))

        sciModel.boardManager.sendMessage(connectionId, message)
    }

    function createCommand(timestamp, message, type) {
        return {
            "timestamp" : timestamp,
            "message": message,
            "type": type,
            "condensed": false,
        }
    }

    function showProgramDeviceDialogDialog(connectionId) {
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(
                    root,
                    programDeviceDialogComponent,
                    {
                        "connectionId": connectionId
                    })

        programDeviceDialogOpened = true
        dialog.open()
    }

    function refrestDeviceInfo() {
        //we need deep copy
        var connectionIds = JSON.parse(JSON.stringify(sciModel.boardManager.connectionIds))

        for (var i = 0; i < connectionIds.length; ++i) {
            sciModel.boardManager.reconnect(connectionIds[i])
        }
    }

    function showPlatformInfoWindow(classId, className) {
        if (platformInfoWindow) {
            platformInfoWindow.close()
        }

        platformInfoWindow = SGWidgets.SGDialogJS.createDialog(
                    root,
                    "qrc:/PlatformInfoWindow.qml",
                    {
                        "platformClassId": classId,
                        "platformClassName": className
                    })


        platformInfoWindow.visible = true
    }

    function saveBoardStorage() {
        var data = ""
        if (boardStorageContent.length > 0) {
            if(boardStorageContent.length > maxBoardStorageLength) {
                boardStorageContent.splice(maxBoardStorageLength, boardStorageContent.length - maxBoardStorageLength)
            }
            data = JSON.stringify(boardStorageContent)
        }

        var dataStored = CommonCpp.SGUtilsCpp.atomicWrite(boardStoragePath, data)
        if(dataStored === false) {
            console.error(Logger.sciCategory,"data store failed")
        }
    }

    function loadBoardStorage() {
        if (CommonCpp.SGUtilsCpp.isFile(boardStoragePath) === false) {
            console.log(Logger.sciCategory,"file does not exist")
            return
        }

        var content = CommonCpp.SGUtilsCpp.readTextFileContent(boardStoragePath)
        if (Object.keys(content).length === 0) {
            return
        }

        try {
            boardStorageContent = JSON.parse(CommonCpp.SGUtilsCpp.readTextFileContent(boardStoragePath))
            console.log("loaded content:", JSON.stringify(boardStorageContent))
        }
        catch(error) {
            console.warning(Logger.sciCategory, "loading board storage failed: ", error)
            boardStorageContent = []
        }
    }

    function saveState() {
        for (var i = 0; i < tabRepeater.count; ++i) {
            tabRepeater.itemAt(i).saveCommandHistoryList()
        }

        saveBoardStorage()
    }
}
