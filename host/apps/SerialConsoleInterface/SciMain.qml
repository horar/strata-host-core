import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import "./common/Colors.js" as Colors
import tech.strata.sci 1.0 as SciCommon
import "./common" as Common
import tech.strata.fonts 1.0 as StrataFonts
import "./common/SgUtils.js" as SgUtils

Item {
    id: root
    anchors {
        fill: parent
    }

    property bool programDeviceDialogOpened: false

    SciCommon.SciModel {
        id: sciModel
    }

    ListModel {
        id: tabModel
    }

    Connections {
        target:  sciModel.boardController

        onConnectedBoard: {
            if (programDeviceDialogOpened) {
                return
            }

            var connectionInfo = sciModel.boardController.getConnectionInfo(connectionId)

            console.log("onConnectedBoard()",JSON.stringify(connectionInfo))

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

        onDisconnectedBoard: {
            console.log("onDisconnectedBoard()", connectionId)
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

        height: 40

        Rectangle {
            anchors.fill: parent
            color: "black"
        }

        TabBar {
            id: tabBar
            width: Math.min(tabBarWrapper.width - iconRowWrapper.width, 500 * tabModel.count)
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            rightPadding: tabBar.spacing
            currentIndex: -1

            background: Rectangle {
                color: "#eeeeee"
            }

            Repeater {
                model: tabModel

                delegate: TabButton {
                    id: delegate

                    hoverEnabled: true

                    property int currentIndex: TabBar.tabBar.currentIndex

                    background: Rectangle {
                        implicitHeight: 40
                        color: index === currentIndex ? "#eeeeee" : Colors.STRATA_DARK
                    }

                    contentItem: Item {
                        Common.SGStatusLight {
                            id: statusLight
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            height: Math.round(buttonText.paintedHeight) + 10
                            width: height

                            iconStatus: {
                                if (model.status === "connected") {
                                    return Common.SGStatusLight.Green
                                } if (model.status === "disconnected") {
                                    return Common.SGStatusLight.Off
                                }

                                return Common.SGStatusLight.Orange
                            }
                        }

                        Common.SgText {
                            id: buttonText
                            anchors {
                                left: statusLight.right
                                leftMargin: 2
                                verticalCenter: parent.verticalCenter
                                right: delegate.hovered ? deleteButton.left : parent.right
                                rightMargin: 2
                            }

                            fontSizeMultiplier: 1.1
                            text: model.verboseName
                            font.family: StrataFonts.Fonts.franklinGothicBold
                            color: model.index === delegate.currentIndex ? "black" : "white"
                            elide: Text.ElideRight
                        }

                        Common.SgIconButton {
                            id: deleteButton
                            height: Math.round(buttonText.paintedHeight) + 5
                            width: height
                            anchors {
                                right: parent.right
                                rightMargin: 2
                                verticalCenter: parent.verticalCenter
                            }

                            visible: delegate.hovered
                            hasAlternativeColor: model.index !== delegate.currentIndex
                            source: "qrc:/images/times.svg"
                            onClicked: {
                                removeBoard(model.connectionId)
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: iconRowWrapper
            width: iconRow.width + 4
            anchors {
                right: parent.right
                top: tabBar.top
                bottom: tabBar.bottom
            }

            Row {
                id: iconRow
                anchors {
                    centerIn: parent
                }

                spacing: 4

                Common.SgIconButton {
                    height: 30
                    width: height

                    hasAlternativeColor: true
                    source: sidePane.shown ? "qrc:/images/chevron-right.svg" : "qrc:/images/chevron-left.svg"
                    onClicked: {
                        sidePane.shown = !sidePane.shown
                    }
                }
            }
        }
    }

    StackLayout {
        id: platformContentContainer
        anchors {
            top: tabBarWrapper.bottom
            left: root.left
            right: sidePane.left
            bottom: root.bottom
        }

        visible: tabModel.count > 0
        currentIndex: tabBar.currentIndex
        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                platformContentContainer.itemAt(currentIndex).forceActiveFocus()
            }
        }

        Repeater {
            model: tabModel
            delegate: PlatformDelegate {
                id: platformDelegate
                width: platformContentContainer.width
                height: platformContentContainer.height

                onSendCommandRequested: {
                    sendCommand(connectionId, message)
                }

                Connections {
                    target:  sciModel.boardController
                    onNotifyBoardMessage: {
                        if (programDeviceDialogOpened) {
                            return
                        }

                        if (platformDelegate.connectionId === connectionId) {
                            var timestamp = Date.now()
                            appendCommand(createCommand(timestamp, message, "response"))
                        }
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: platformContentContainer
        visible: tabModel.count === 0
        Text {
            anchors.centerIn: parent
            text: "No Device Connected"
            font.pointSize: 50
        }
    }

    Item {
        id: sidePane
        width: shown ? 140 : 0
        anchors {
            top: tabBarWrapper.bottom
            topMargin: 1
            bottom: parent.bottom
            right: parent.right
        }

        visible: shown

        property bool shown: false

        Rectangle {
            anchors.fill: parent
            color: "black"
        }

        Column {
            anchors {
                top: parent.top
                topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }

            spacing: 10

            Common.SgButton {
                text: "Program\nDevice"
                onClicked: showProgramDeviceDialogDialog()
            }
        }
    }

    Component {
        id: programDeviceDialogComponent

        Common.SgDialog {
            id: dialog

            modal: true
            closePolicy: Popup.NoAutoClose
            focus: true
            padding: 0
            hasTitle: false

            Column {
                ProgramDeviceWizard {
                    width: root.width - 20
                    height: root.height - 20

                    onCancelRequested: {
                        dialog.close()
                        programDeviceDialogOpened = false
                        refrestDeviceInfo()
                    }
                }
            }
        }
    }

    function removeBoard(connectionId) {
        for (var i = 0; i < tabModel.count; ++i) {
            var item = tabModel.get(i)
            if (item.connectionId === connectionId) {
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

        sciModel.boardController.sendCommand(connectionId, message)
    }

    function createCommand(timestamp, message, type) {
        return {
            "timestamp" : timestamp,
            "message": message,
            "type": type,
            "condensed": false,
        }
    }

    function showProgramDeviceDialogDialog() {
        var dialog = SgUtils.createDialogFromComponent(root, programDeviceDialogComponent)

        programDeviceDialogOpened = true
        dialog.open()
    }

    function refrestDeviceInfo() {
        for (var i = 0; i < sciModel.boardController.connectionIds.length; ++i) {
            sciModel.boardController.reconnect(sciModel.boardController.connectionIds[i])
        }
    }
}
