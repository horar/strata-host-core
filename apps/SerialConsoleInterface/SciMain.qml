/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    property int releasePortDurationInSec: 5

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

    Binding {
        target: sciModel.platformModel
        property: "condensedAtStartup"
        value: Sci.Settings.commandsCondensedAtStartup
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
            text: "Default Board Name Length Length"
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
                    height: tabTextColumn.height + 10

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

                    Column {
                        id: tabTextColumn
                        anchors {
                            left: statusLight.right
                            leftMargin: 2
                            right: buttonRow.visible ? buttonRow.left : parent.right
                            rightMargin: 2
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 1

                        SGWidgets.SGText {
                            id: buttonText
                            width: parent.width
                            text: model.platform.verboseName
                            font: dummyText.font
                            fontSizeMultiplier: dummyText.fontSizeMultiplier
                            color: "black"
                            elide: Text.ElideRight
                        }

                        SGWidgets.SGText {
                            id: deviceNameText
                            width: parent.width
                            text: model.platform.deviceName
                            fontSizeMultiplier: 0.9
                            color: "black"
                            opacity: 0.6
                            elide: Text.ElideRight
                        }
                    }

                    Row {
                        id: buttonRow

                        anchors {
                            right: parent.right
                            rightMargin: 4
                            verticalCenter: parent.verticalCenter
                        }

                        spacing: 4

                        visible: tabDelegate.isCurrent
                                 && ( bgMouseArea.containsMouse
                                     || releasePortButton.hovered
                                     || deleteButton.hovered)

                        SGWidgets.SGIconButton {
                            id: releasePortButton

                            enabled: model.platform.programInProgress === false && model.platform.status !== Sci.SciPlatform.Disconnected
                            icon.source: "qrc:/sgimages/disconnected.svg"
                            hintText: "Release port for "+releasePortDurationInSec+"s"
                            onClicked: {
                                releasePort(index)
                            }
                        }

                        SGWidgets.SGIconButton {
                            id: deleteButton

                            enabled: model.platform.programInProgress === false
                            icon.source: "qrc:/sgimages/times.svg"
                            hintText: "Close tab"
                            onClicked: {
                                if (model.platform.status === Sci.SciPlatform.Ready
                                        || model.platform.status === Sci.SciPlatform.Connected
                                        || model.platform.status === Sci.SciPlatform.NotRecognized) {
                                    SGWidgets.SGDialogJS.showConfirmationDialog(
                                                ApplicationWindow.window,
                                                "Device is active",
                                                "Do you really want to disconnect \"" + model.platform.verboseName + "\" board?",
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
                filterScrollbackModel: model.platform.filterScrollbackModel
                commandHistoryModel: model.platform.commandHistoryModel
                filterSuggestionModel: model.platform.filterSuggestionModel
                tabBorderColor: tabBar.tabBorderColor
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
            if ((tabBar.currentIndex !== 0) || (sciModel.platformModel.count === 1)) {
                tabBar.currentIndex--
            }
        }

        sciModel.platformModel.releasePort(index);
        sciModel.platformModel.removePlatform(index)
    }

    function releasePort(index) {
        sciModel.platformModel.releasePort(index, releasePortDurationInSec * 1000);
    }

    function showPlatformInfoWindow(classId, className) {
        if (platformInfoWindow) {
            platformInfoWindow.close()
        }

        platformInfoWindow = SGWidgets.SGDialogJS.createDialog(
                    ApplicationWindow.window,
                    "qrc:/PlatformInfoWindow.qml",
                    {
                        "platformClassId": classId,
                        "platformClassName": className
                    })


        platformInfoWindow.visible = true
    }
}
