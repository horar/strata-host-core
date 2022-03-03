/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12

import tech.strata.sgwidgets 1.0

import "../Components"

CustomPopup {
    id: root

    showMaximizedBtn: true
    defaultHeight: 600
    defaultWidth: 500

    property alias fileUrl: fileInputBox.userInput
    property alias model: listModel
    property bool doubleClicked: false

    signal remove(string dbName)
    signal clear()

    onOpened: listView.positionViewAtBeginning()
    onClosed: fileInputBox.clear()

    content: ColumnLayout {
        width: parent.width
        height: parent.height - 100
        anchors.top: parent.top
        anchors.topMargin: 50

        spacing: 30

        Item {
            id: dbList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter

            visible: model.count > 0
            CustomButton {
                id: clearAllBtn
                height: 25
                width: 100
                anchors{
                    top: parent.top
                    right: listView.right
                    rightMargin: 10
                }

                text: "Clear All"
                onClicked: root.clear()
            }

            ListView {
                id: listView
                height: parent.height - 25
                width: parent.width - 50
                anchors{
                    top: clearAllBtn.bottom
                    topMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }

                model: listModel
                delegate: listCard
                clip: true
                spacing: 5
                ScrollBar.vertical: ScrollBar {
                    id: scrollBar
                    width: 10
                    policy: ScrollBar.AsNeeded
                }
            }
            Component {
                id: listCard
                Rectangle {
                    id: cardBackground
                    width: ListView.view.width - 10
                    height: 60

                    color: "white"
                    border.width: 2
                    border.color: mouse.containsMouse ? "#b55400": "transparent"
                    MouseArea {
                        id: mouse
                        anchors.fill: parent

                        hoverEnabled: true
                        onClicked: root.fileUrl = path
                        onDoubleClicked: {
                            root.fileUrl = path
                            root.doubleClicked = true
                        }
                        onReleased: {
                            if (root.doubleClicked) {
                                root.doubleClicked = false;
                                root.submit()
                            }
                        }
                    }
                    SGIcon {
                        id: deleteIcon
                        width: 12
                        height: 12
                        anchors {
                            top: parent.top
                            right: parent.right
                            margins: 5
                        }
                        opacity: 0.5
                        iconColor: "darkred"
                        source: "../Images/x-icon.svg"
                        fillMode: Image.PreserveAspectFit
                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true
                            onContainsMouseChanged: {
                                deleteIcon.opacity = containsMouse ? 1 : 0.5
                            }
                            onClicked: root.remove(name)
                        }
                    }

                    GridLayout {
                        anchors.fill: parent

                        rows: 2
                        columns: 2
                        clip: true
                        SGIcon {
                            Layout.preferredHeight: 50
                            Layout.preferredWidth: 50
                            Layout.alignment: Qt.AlignCenter
                            Layout.rowSpan: 2

                            iconColor: "#b55400"
                            source: "../Images/database-icon.svg"
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            Layout.alignment: Qt.AlignVCenter

                            text: "Name: " + name
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            Layout.alignment: Qt.AlignVCenter

                            text: "Path: " + path
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            ListModel {
                id: listModel
            }
        }

        UserInputBox {
            id: fileInputBox
            Layout.preferredWidth: 400
            Layout.alignment: Qt.AlignHCenter

            color: "#b55400"
            showButton: true
            showLabel: true
            label: "File Path"
            placeholderText: "File path must be '.../db/[ db_name ]/db.sqlite3'."
            path: "../Images/folder-icon.svg"
            onClicked: fileDialog.visible = true
        }
        CustomButton {
            text: "Open"
            Layout.preferredWidth: 100
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignHCenter

            onClicked: root.submit()
            enabled: fileUrl.length !== 0
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please select a database"
        folder: shortcuts.home
        onAccepted: {
            close()
            fileInputBox.userInput = fileUrl
        }
        onRejected: close()
    }
}

