/*
 * Copyright (c) 2018-2021 onsemi.
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
                    color: removeCommandMouseArea.containsMouse ? Qt.darker("#D10000", 1.25) : "#D10000"
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
                    regExp: /^(?!default|function)[a-z_][a-zA-Z0-9_]+/
                }

                background: Rectangle {
                    border.color: {
                        if (!model.valid) {
                            return "#D10000"
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
                    forceActiveFocus()
                }

                onTextChanged: {
                    if (model.name === text) {
                        return
                    }
                    unsavedChanges = true

                    model.name = text
                    if (text.length > 0) {
                        functions.checkForDuplicateIds(commandsListView.modelIndex)
                    } else {
                        model.valid = false
                    }
                }

                onActiveFocusChanged: {
                    if (activeFocus === false && contextMenuPopupLoader.item && contextMenuPopupLoader.item.visible === false) {
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
                            contextMenuPopupLoader.item.textEditor = cmdNotifName
                            contextMenuPopupLoader.item.popup(null)
                        }
                    }
                }

                Loader {
                    id: contextMenuPopupLoader
                    active: false
                    sourceComponent: contextMenuPopupComponent
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
                        contextMenuPopupLoader.item.textEditor = defaultValueTextField
                        contextMenuPopupLoader.item.popup(null)
                    }
                }
            }

            Loader {
                id: contextMenuPopupLoader
                active: false
                sourceComponent: contextMenuPopupComponent
            }
        }
    }
}
