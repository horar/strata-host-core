import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
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
        id: tabBar
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: tabRow.y + tabRow.height + tabPadding
        visible: tabRepeater.count > 0

        property int tabPadding: 12
        property int currentIndex: -1
        property int statusLightHeight: dummyText.contentHeight + 10
        property int minTabWidth: 50
        property int preferredTabWidth: 2*statusLightHeight + dummyText.contentWidth + 20
        property int availableTabWidth: Math.floor((width - 2*tabPadding - (tabRow.spacing * (sciModel.platformModel.count-1))) / sciModel.platformModel.count)
        property int tabWidth: Math.max(Math.min(preferredTabWidth, availableTabWidth), minTabWidth)
        property color tabBorderColor: "#999999"

        SGWidgets.SGText {
            id: dummyText
            visible: false
            fontSizeMultiplier: 1.2
            font.bold: true
            text: "Default Board Name Length"
        }

        Rectangle {
            id: bottomLine
            height: 1
            anchors {
                 bottom: tabRow.bottom
                 left: parent.left
                 right: parent.right
            }

            color: tabBar.tabBorderColor
        }

        Row {
            id: tabRow
            anchors {
                top: parent.top
                topMargin: tabBar.tabPadding
                left: parent.left
                leftMargin: tabBar.tabPadding
            }

            Repeater {
                id: tabRepeater
                model: sciModel.platformModel

                delegate: Item {
                    id: tabDelegate
                    width: tabBar.tabWidth
                    height: statusLight.height + 10

                    property bool isFirst: index === 0
                    property bool isLast: index === tabRepeater.count - 1
                    property bool isCurrent: index === tabBar.currentIndex

                    MouseArea {
                        id: bgMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            tabBar.currentIndex = index
                        }
                    }

                    Rectangle {
                        id: bg
                        anchors.fill: parent
                        color: tabBar.tabBorderColor

                        Rectangle {
                            id: contentBg
                            anchors {
                                fill: parent
                                topMargin: 1
                                bottomMargin: tabDelegate.isCurrent ? 0 : 1
                                leftMargin: tabDelegate.isFirst ? 1 : 0
                                rightMargin: 1
                            }

                            color: tabDelegate.isCurrent ? "#eeeeee" : "#bbbbbb"
                        }
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
                        fontSizeMultiplier: dummyText.fontSizeMultiplier
                        color: "black"
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
                        highlightImplicitColor: "#888888"
                        icon.source: "qrc:/sgimages/times.svg"

                        property bool shown: (bgMouseArea.containsMouse || hovered) && model.platform.programInProgress === false

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

    StackLayout {
        id: platformContentContainer
        anchors {
            top: tabBar.bottom
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
            id: platformRepeater
            model: sciModel.platformModel

            delegate: PlatformDelegate {
                id: platformDelegate
                width: platformContentContainer.width
                height: platformContentContainer.height
                rootItem: sciMain
                scrollbackModel: model.platform.scrollbackModel
                commandHistoryModel: model.platform.commandHistoryModel
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

    function removeBoard(index) {
        if (index <= tabBar.currentIndex) {
            //shift currentIndex
            tabBar.currentIndex--
        }

        sciModel.platformModel.disconnectPlatformFromSci(index);
        sciModel.platformModel.removePlatform(index)
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
