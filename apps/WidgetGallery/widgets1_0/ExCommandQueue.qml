import QtQuick 2.12
import QtQml 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    width: 500
    height: 500


    ListModel {
        id: commandQueue
    }

    //addCommand: Appends commands to the queue.
    function addCommand (command,value = -1) {
        commandQueue.append({
                                "command": JSON.stringify(command),
                                "value" : value

                            })
    }

    property int count: 0 // only to show that getData is increasing in logs, should !remove!

    function sendCommand () {
        timer.running = false
        if (commandQueue.count > 0) {
            let command = commandQueue.get(0).command
            if(commandQueue.get(0).value !== -1) {
                logs.append({ log: "sending:" + command + value }) //For Demo Only

                /** TO USE IT IN CONTROL VIEW: do the following:
                 platformInterface.commands[command].update(commandQueue.get(0).value) **/
            } else {
                logs.append({ log: "sending:" + command }) //For Demo Only

                /** TO USE IT IN CONTROL VIEW: do the following:
                 platformInterface.commands[command].update() **/
            }

            commandQueue.remove(0)

        } else {
            timer.interval = 1000
            logs.append({ log: "no commands in queue, sending getData " + count++ }) //For Demo Only

            /** TO USE IT IN CONTROL VIEW: do the following:
             platformInterface.commands[command].update() **/
        }

        timer.start()
    }


    Timer {
        id: timer
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            //sendCommand() call the cammand in the queue on timer triggered
            sendCommand()
        }
    }

    /// FOR VISUAL DEMO ONLY: button to add commands manually, show any existing commands in the queue, and to add a log of commands been send.
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 220

            ColumnLayout {
                anchors.fill: parent
                spacing: 5

                Item {
                    id: buttonContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.topMargin: 5
                    property var counter: 0

                    Button {
                        id: command
                        text: "Add Command"


                        onClicked: {
                            let command = {
                                myCommand: "some command here " + buttonContainer.counter++
                            }
                            // TO ADD A COMMAND IN QUEUE: addCommand(COMMAND_NAME)
                            // Example addCommand("get_data")
                            addCommand(command)
                        }
                    }

                    Button {
                        text: "Add Command \n With Value"
                        anchors.left: command.right
                        anchors.leftMargin: 10

                        onClicked: {
                            let command = {
                                myCommand: "some command here " + buttonContainer.counter++ ,
                                value: "true"
                            }
                            // TO ADD A COMMAND IN QUEUEe : addCommand(COMMAND_NAME,VAlUE)
                            // Example addCommand("get_data", "true")
                            addCommand(command)
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20

                    Text {
                        text: "Commands in Queue:"
                        anchors.fill: parent
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "gray"

                    ListView {
                        anchors.fill: parent
                        model: commandQueue
                        delegate: logDelegate
                        clip: true
                        ScrollBar.vertical: ScrollBar { active: true }
                    }


                    Component {
                        id: logDelegate
                        Item {
                            width: 20
                            height: 20
                            Text {
                                text: model.command
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            color: "light gray"

            ColumnLayout {
                anchors.fill: parent
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20

                    Text {
                        text: "Commands in the log:"
                        anchors.fill: parent
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: listView
                        anchors.fill: parent
                        model: logs
                        delegate: delegate
                        clip: true
                        ScrollBar.vertical: ScrollBar { active: true }
                    }

                    ListModel {
                        id: logs
                        ListElement { log: "" }
                    }

                    Component {
                        id: delegate
                        Item {
                            width: 20
                            height: 20
                            Text {
                                text: log
                            }
                        }
                    }
                }
            }
        }
    }
}

