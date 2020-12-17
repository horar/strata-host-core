import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12


ColumnLayout {
    id: commandsColumn

    width: parent.width

    property ListModel payloadModel: model.payload
    property var modelIndex: index

    RowLayout {
        Layout.fillWidth: true

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
                    commandColumn.commandModel.remove(index)
                }
            }
        }

        TextField {
            id: cmdNotifName
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            placeholderText: commandColumn.isCommand ? "Command name" : "Notification name"
            validator: RegExpValidator {
                regExp: /^(?!default|function)[a-z_][a-zA-Z0-9_]+/
            }

            background: Rectangle {
                border.color: {
                    if (!model.valid) {
                        border.width = 2
                        return "#D10000";
                    } else if (cmdNotifName.activeFocus) {
                        border.width = 2
                        return palette.highlight
                    } else {
                        border.width = 1
                        return "lightgrey"
                    }
                }
                border.width: 2
            }

            Component.onCompleted: {
                text = model.name
                forceActiveFocus()
            }

            onTextChanged: {
                model.name = text

                if (text.length > 0) {
                    finishedModel.checkForDuplicateIds(commandsListView.modelIndex)
                } else {
                    model.valid = false
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

    Rectangle {
        id: hDivider
        Layout.preferredHeight: 1
        Layout.fillWidth: true
        Layout.topMargin: 10
        visible: index !== commandsListView.count - 1
        color: "black"
    }
}
