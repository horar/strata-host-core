import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.fonts 1.0 as StrataFonts
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.common 1.0 as Common

Item {
    id: root
    anchors {
        fill: parent
    }

    property bool programDeviceDialogOpened: false

    ListModel {
        id: tabModel
    }

    Connections {
        target:  sciModel.boardController

        onActiveBoard: {
            if (programDeviceDialogOpened) {
                return
            }

            var connectionInfo = sciModel.boardController.getConnectionInfo(connectionId)

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

            width: tabBarWrapper.width - iconRowWrapper.width
            height: dummyText.contentHeight + 20

            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: tabRow.height
            contentWidth: tabRow.width

            property int currentIndex: -1

            property int statusLightHeight: dummyText.contentHeight + 10
            property int minTabWidth: 300
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
                                                    var ret = sciModel.boardController.disconnect(connectionId)
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

                SGWidgets.SGIconButton {
                    alternativeColorEnabled: true
                    icon.source: sidePane.shown ? "qrc:/images/side-pane-right-close.svg" : "qrc:/images/side-pane-right-open.svg"
                    iconSize: tabBar.statusLightHeight
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
                rootItem: root

                onSendCommandRequested: {
                    sendCommand(connectionId, message)
                }

                onProgramDeviceRequested: {
                    if (model.status === "connected") {
                        showProgramDeviceDialogDialog(model.connectionId)
                    }
                }

                Connections {
                    target:  sciModel.boardController
                    onNotifyBoardMessage: {
                        if (programDeviceDialogOpened) {
                            return
                        }

                        if (model.connectionId === connectionId) {
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
        SGWidgets.SGText {
            anchors.fill: parent

            text: "No Device Connected"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMultiplier: 3
        }
    }

    Item {
        id: sidePane
        width: shown ? content.width + 32 : 0
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

        property int btnWidth: Math.max(aboutBtn.preferredContentWidth, settingsBtn.preferredContentWidth)

        Column {
            id: content
            anchors {
                top: parent.top
                topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }

            spacing: 10

            SGWidgets.SGButton {
                id: aboutBtn
                text: "About"
                icon.source: "qrc:/sgimages/info-circle.svg"
                onClicked: showAboutWindow()

                minimumContentWidth: sidePane.btnWidth
                contentHorizontalAlignment: Text.AlignLeft
            }

            SGWidgets.SGButton {
                id: settingsBtn
                text: "Settings"
                icon.source: "qrc:/sgimages/tools.svg"
                onClicked: showSettingsDialog()
                minimumContentWidth: sidePane.btnWidth
                contentHorizontalAlignment: Text.AlignLeft
            }
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
                implicitWidth: root.width - 20
                implicitHeight: root.height - 20

                title: "Program Device Wizard"
                hasBack: false

                contentItem: Common.ProgramDeviceWizard {
                    boardController: sciModel.boardController
                    closeButtonVisible: true
                    requestCancelOnClose: true
                    loopMode: false
                    checkFirmware: false
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
        var connectionIds = JSON.parse(JSON.stringify(sciModel.boardController.connectionIds))

        for (var i = 0; i < connectionIds.length; ++i) {
            sciModel.boardController.reconnect(connectionIds[i])
        }
    }

    function showSettingsDialog() {
        var dialog = SGWidgets.SGDialogJS.createDialog(root, "qrc:/SciSettingsDialog.qml")
        dialog.open()
    }
}
