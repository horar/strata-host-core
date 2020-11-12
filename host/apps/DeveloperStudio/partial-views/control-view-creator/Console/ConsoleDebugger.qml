import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0


Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#ddd"

            ScrollView {
                anchors.fill: parent
                clip: true

                ListView {
                    anchors.fill: parent
                    model: debugCommands

                    delegate: SGText {
                        text: modelData
                    }
                }

                ListModel {
                    id: debugCommands

                    function sendCommands(command){
                        if(command !== ""){
                            if(command.includes("{") && command.includes("}")){
                                const cmd = {"cmd":command}
                                debugCommands.append(cmd)
                            } else {
                                const errObj = "Syntax Error: Is not an Object"
                                debugCommands.append({errObj})
                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "#ddd"
            RowLayout {
                id: commandRow
                anchors.fill: parent
                property string command: ""
                TextField {
                    id: textField
                    placeholderText: "Type commands here..."
                    Layout.fillWidth: true
                    leftPadding: 5

                    onTextEdited: {
                        commandRow.command = text
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: textField.height
                    color: "#ccc"
                    radius: 5
                    SGText {
                        anchors.centerIn: parent
                        text: "Send command"
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor
                        onClicked: debugCommands.sendCommands(commandRow.command)
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 10
                    color: "#ddd"
                }
            }
        }
        Item {
            Layout.preferredHeight: 10
        }
    }
}
