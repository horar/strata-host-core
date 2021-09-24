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
import QtQuick.Window 2.12
import tech.strata.logger 1.0

Window {
    id: window
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    title: "Information for " + platformClassName
    visible: true

    property string platformClassId
    property string platformClassName

    Component.onCompleted: {
        populateCommandModel()
    }

    ListModel {
        id: commandModel
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    property bool destroyOnClose: false
    onClosing: {
        if (destroyOnClose) {
            window.destroy()
        }
    }

    CommonCpp.SGSortFilterProxyModel {
        id: commandSortedModel
        sourceModel: commandModel
        invokeCustomLessThan: true

        function lessThan(leftIndex, rightIndex) {
            var leftItem = commandModel.get(leftIndex)
            var rightItem = commandModel.get(rightIndex)

            //exception: core commands at the end
            if (leftItem.type !== rightItem.type) {
                if (leftItem.type === "Core") {
                    return false
                } if (rightItem.type === "Core") {
                    return true
                } else {
                    return leftItem.type < rightItem.type
                }
            } else {
                if (leftItem.name !== rightItem.name) {
                    return leftItem.name < rightItem.name
                }
            }

            return leftIndex < rightIndex
        }
    }

    SGWidgets.SGSplitView {
        id: commandInfo
        anchors {
            fill: parent
        }

        Item {
            id: commandViewWrapper
            Layout.minimumWidth: 150

            ListView {
                id: commandView
                anchors {
                    fill: parent
                    margins: 4
                }

                spacing: 2
                clip: true
                snapMode: ListView.SnapToItem;
                boundsBehavior: Flickable.StopAtBounds;

                model: commandSortedModel
                focus: true

                ScrollBar.vertical: ScrollBar {
                    width: 8
                    anchors {
                        top: commandView.top
                        bottom: commandView.bottom
                        right: commandView.right
                    }

                    policy: ScrollBar.AlwaysOn
                    visible: commandView.height < commandView.contentHeight
                }

                section.property: "type"
                section.criteria: ViewSection.FullString
                section.delegate: Item {
                    width: ListView.view.width
                    height: sectionLabel.contentHeight + 10

                    SGWidgets.SGText {
                        id: sectionLabel
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 4
                            right: parent.right
                            rightMargin: 4
                        }

                        text: section
                        fontSizeMultiplier: 1.2
                        font.bold: true
                        elide: Text.ElideRight
                    }
                }

                delegate: Item {
                    width: ListView.view.width
                    height: commandNameText.contentHeight + 10

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.darker("#aaaaaa", 1.3)
                        visible: commandView.currentIndex === index
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: delegateMouseArea.containsMouse ? 0.1 : 0
                    }

                    MouseArea {
                        id: delegateMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            commandView.currentIndex = index
                            forceActiveFocus()
                        }
                    }

                    SGWidgets.SGText {
                        id: commandNameText
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 4
                            right: parent.right
                            rightMargin: 4
                        }

                        elide: Text.ElideRight
                        alternativeColorEnabled: commandView.currentIndex === index
                        text: model.name
                        fontSizeMultiplier: 1
                        font.bold: true
                    }
                }
            }
        }

        Item {
            Layout.minimumWidth: 400
            Layout.fillWidth: true

            Rectangle {
                anchors.fill: parent
                color: "white"
            }

            SGWidgets.SGMarkdownViewer {
                id: mdView
                anchors {
                    fill: parent
                    margins: 4
                }

                Keys.onUpPressed: {
                    commandView.decrementCurrentIndex()
                }

                Keys.onDownPressed: {
                    commandView.incrementCurrentIndex()
                }

                text: {
                    if(commandView.currentIndex < 0) {
                        return ""
                    }
                    var index = commandSortedModel.mapIndexToSource(commandView.currentIndex)
                    if(index < 0) {
                        console.error(Logger.sciCategory, "Index out of scope.")
                        return ""
                    }

                    var descBase64 = commandModel.get(index)["description"]
                    return CommonCpp.SGUtilsCpp.fromBase64(descBase64)
                }
            }
        }
    }

    function populateCommandModel() {
        if (platformClassId.length === 0) {
            console.log(sciCategory,"no classId")
            return
        }

        var format_version = JSON.parse(sciModel.databaseConnector.getDocument(platformClassId, "format_version"))
        if (format_version !== "1.0") {
            console.log(sciCategory, "unsupported format vesrion", format_version)
            return
        }

        var core_commands = JSON.parse(sciModel.databaseConnector.getDocument("core", "command_list"))
        var platform_commands = JSON.parse(sciModel.databaseConnector.getDocument(platformClassId, "command_list"))
        var platform_core_commands = JSON.parse(sciModel.databaseConnector.getDocument(platformClassId, "core_command_list"))

        commandModel.clear()

        for (var i=0; i < platform_commands.length; ++i) {
            var item = platform_commands[i]
            item.type = ""
            commandModel.append(item)
        }

        for (var i=0; i < platform_core_commands.length; ++i) {
            for (var j=0; j < core_commands.length; ++j) {
                if (platform_core_commands[i] === core_commands[j]["name"]) {
                    var item = core_commands[j]
                    item.type = "Core"
                    commandModel.append(item)

                    break
                }
            }
        }

        commandView.currentIndex = 0
    }
}
