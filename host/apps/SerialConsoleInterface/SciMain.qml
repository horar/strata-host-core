import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.fonts 1.0 as StrataFonts
import tech.strata.commoncpp 1.0 as CommonCpp
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.logger 1.0
import tech.strata.sci 1.0 as Sci

Item {
    id: sciMain
    anchors {
        fill: parent
    }

    property variant platformInfoWindow: null

    Connections {
        target: sciModel.platformModel

        onPlatformConnected: {
            tabBar.currentIndex = index
        }
    }

    Binding {
        target: sciModel.platformModel
        property: "maxScrollbackCount"
        value: {
            if (Sci.Settings.commandsInScrollbackUnlimited) {
                return 200000
            }

            return Sci.Settings.maxCommandsInScrollback
        }
    }

    Binding {
        target: sciModel.platformModel
        property: "maxCmdInHistoryCount"
        value: Sci.Settings.maxCommandsInHistory
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
            property int availableTabWidth: Math.floor((width - (tabRow.spacing * (sciModel.platformModel.count-1))) / sciModel.platformModel.count)
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
                    model: sciModel.platformModel

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
                                if (model.platform.status === Sci.SciPlatform.Ready) {
                                    return SGWidgets.SGStatusLight.Green
                                } else if (model.platform.status === Sci.SciPlatform.NotRecognized) {
                                    return SGWidgets.SGStatusLight.Red
                                } else if (model.platform.status === Sci.SciPlatform.Connected) {
                                    return SGWidgets.SGStatusLight.Orange
                                }

                                return SGWidgets.SGStatusLight.Off
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

                            text: model.platform.verboseName
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
                                if (model.platform.status === Sci.SciPlatform.Ready
                                        || model.platform.status === Sci.SciPlatform.Connected
                                        || model.platform.status === Sci.SciPlatform.NotRecognized) {
                                    SGWidgets.SGDialogJS.showConfirmationDialog(
                                                root,
                                                "Device is active",
                                                "Do you really want to disconnect " + model.platform.verboseName + " ?",
                                                "Disconnect",
                                                function () {
                                                    removeBoard(model.index)
                                                },
                                                "Keep Connected"
                                                )
                                } else {
                                    removeBoard(model.index)
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

        visible: sciModel.platformModel.count > 0
        currentIndex: tabBar.currentIndex
        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                platformContentContainer.itemAt(currentIndex).forceActiveFocus()
            }
        }

        Repeater {
            id: tabRepeater
            model: sciModel.platformModel

            delegate: PlatformDelegate {
                id: platformDelegate
                width: platformContentContainer.width
                height: platformContentContainer.height
                rootItem: sciMain
                scrollbackModel: model.platform.scrollbackModel
                commandHistoryModel: model.platform.commandHistoryModel

                onProgramDeviceRequested: {
                    if (model.platform.status === Sci.SciPlatform.Ready
                            || model.platform.status === Sci.SciPlatform.Connected
                            || model.platform.status === Sci.SciPlatform.NotRecognized) {
                        showProgramDeviceDialogDialog(model.platform.deviceId)
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: platformContentContainer
        visible: platformContentContainer.visible === false
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

            property int deviceId

            contentItem: SGWidgets.SGPage {
                implicitWidth: sciMain.width - 20
                implicitHeight: sciMain.height - 20

                title: "Program Device Wizard"
                hasBack: false

//                contentItem: Common.ProgramDeviceWizard {
//                    boardManager: sciModel.boardManager
//                    closeButtonVisible: true
//                    requestCancelOnClose: true
//                    loopMode: false
//                    checkFirmware: false

//                    useCurrentConnectionId: true
//                    currentConnectionId: dialog.deviceId

//                    onCancelRequested: {
//                        if (sciModel.platformModel.ignoreNewConnections) {
//                            dialog.close()
//                            sciModel.platformModel.ignoreNewConnections = false
//                            sciModel.platformModel.reconectAll()
//                        }
//                    }
//                }
            }
        }
    }

    function removeBoard(index) {
        if (index <= tabBar.currentIndex) {
            //shift currentIndex
            tabBar.currentIndex--
        }

        sciModel.platformModel.disconnectPlatformFromSci(index);
        sciModel.platformModel.removePlatform(index)
    }

    function showProgramDeviceDialogDialog(deviceId) {
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(
                    root,
                    programDeviceDialogComponent,
                    {
                        "deviceId": deviceId
                    })

        sciModel.platformModel.ignoreNewConnections = true
        dialog.open()
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
}
