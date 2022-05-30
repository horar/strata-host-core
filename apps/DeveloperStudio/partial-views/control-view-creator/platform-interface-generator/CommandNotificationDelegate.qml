/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQml 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

Rectangle {
    width:  ListView.view.width
    height: commandsColumn.height + 10
    color: "#efefef"

    property ListModel payloadModel: commandsColumn.payloadModel

    ColumnLayout  {
        id: commandsColumn
        anchors {
            left: parent.left
            right: parent.right
            rightMargin: 5
            leftMargin: 5
            verticalCenter: parent.verticalCenter
        }

        property ListModel payloadModel: model.payload
        property var modelIndex: index

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RoundButton {
                Layout.preferredHeight: 15
                Layout.preferredWidth: 15

                padding: 0
                hoverEnabled: true

                icon {
                    source: "qrc:/sgimages/times.svg"
                    color: removeCommandMouseArea.containsMouse ? Qt.darker(Theme.palette.onsemiOrange, 1.25) : Theme.palette.onsemiOrange
                    height: 7
                    width: 7
                    name: "Remove command / notification"
                }

                Accessible.name: "Remove command / notification"
                Accessible.role: Accessible.Button
                Accessible.onPressAction: {
                    removeCommandMouseArea.clicked()
                }

                MouseArea {
                    id: removeCommandMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (cmdNotifName.text !== "") {
                            unsavedChanges = true
                        }

                        let commands = finishedModel.get(commandsListView.modelIndex).data
                        let payload = commands.get(commandsColumn.modelIndex).payload
                        if (model.duplicate) {
                            model.name = "A" // use 'A' because the name can't be an uppercase. So this won't produce duplicates
                            functions.loopOverDuplicates(commands, index)
                        }
                        if (!model.valid) {
                            functions.invalidCount--
                        }
                        functions.checkAllValidFlag(payload, true)
                        commandColumn.commandModel.remove(index)
                    }
                }
            }

            TextField {
                id: cmdNotifName
                Layout.preferredHeight: 30
                Layout.fillWidth: true
                selectByMouse: true
                persistentSelection: true // must deselect manually
                placeholderText: commandColumn.isNoti ? "Notification name" : "Command name"

                validator: RegExpValidator {
                    regExp: /^[a-z_][a-zA-Z0-9_]*/
                }

                background: Rectangle {
                    border.color: {
                        if (!model.valid) {
                            return Theme.palette.onsemiOrange
                        } else if (cmdNotifName.activeFocus) {
                            return palette.highlight
                        } else {
                            return "lightgrey"
                        }
                    }

                    border.width: (!model.valid || cmdNotifName.activeFocus) ? 2 : 1
                }

                Component.onCompleted: {
                    text = model.name
                    if (!text) {
                        model.valid = false
                        functions.invalidCount++
                    }
                    forceActiveFocus()
                }

                onTextChanged: {
                    if (model.name === text) {
                        return
                    }
                    unsavedChanges = true

                    model.name = text
                    let commands = finishedModel.get(commandsListView.modelIndex).data
                    functions.checkForValidKey(commands, index, model.valid)
                }

                onActiveFocusChanged: {
                    if (activeFocus === false && (contextMenuPopupLoader.item == null || contextMenuPopupLoader.item.visible === false)) {
                        cmdNotifName.deselect()
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    acceptedButtons: Qt.RightButton
                    onClicked: {
                        cmdNotifName.forceActiveFocus()
                    }
                    onReleased: {
                        if (containsMouse) {
                            contextMenuPopupLoader.active = true
                            contextMenuPopupLoader.item.popup(null)
                        }
                    }
                }

                Loader {
                    id: contextMenuPopupLoader
                    active: false
                    sourceComponent: SGContextMenuEditActions {
                        textEditor: cmdNotifName
                    }
                }
            }
        }

        /*****************************************
        * This Repeater corresponds to each property in the payload
        *****************************************/
        Repeater {
            id: payloadRepeater
            model: commandsColumn.payloadModel

            delegate: PayloadPropertyDelegate {}
        }

        Button {
            id: addPropertyButton
            text: "Add Payload Property"
            Layout.alignment: Qt.AlignHCenter
            visible: commandsListView.count > 0
            enabled: cmdNotifName.text !== ""

            Accessible.name: addPropertyButton.text
            Accessible.role: Accessible.Button
            Accessible.onPressAction: {
                addPropertyButtonMouseArea.clicked()
            }

            MouseArea {
                id: addPropertyButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    commandsColumn.payloadModel.append(templatePayload)
                    if (commandsColumn.modelIndex === commandsListView.count - 1) {
                        commandsListView.contentY += 70
                    }
                }
            }
        }
    }

    Component {
        id: defaultValue

        Item {
            id: defaultValueContainer

            property int leftMargin: 20
            property int rightMargin: 0

            property alias text: defaultValueTextField.text
            property alias checked: defaultValueSwitch.checked

            RowLayout {
                anchors {
                    fill: parent
                    rightMargin: parent.rightMargin
                }

                Text {
                    Layout.leftMargin: leftMargin
                    text: "Default Value:"
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    TextField {
                        id: defaultValueTextField
                        enabled: !defaultValueSwitch.enabled
                        visible: enabled
                        width: parent.width
                        height: parent.height
                        selectByMouse: true
                        persistentSelection: true // must deselect manually
                    }

                    SGSwitch {
                        id: defaultValueSwitch
                        x: 10
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: isBool
                        visible: enabled
                        checkedLabel: "True"
                        uncheckedLabel: "False"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.RightButton
                visible: !defaultValueSwitch.enabled

                onClicked: {
                    defaultValueTextField.forceActiveFocus()
                }

                onReleased: {
                    if (containsMouse) {
                        contextMenuPopupLoader.active = true
                        contextMenuPopupLoader.item.popup(null)
                    }
                }
            }

            Loader {
                id: contextMenuPopupLoader
                active: false
                sourceComponent: SGContextMenuEditActions {
                    textEditor: defaultValueTextField
                }
            }
        }
    }
}
