import QtQuick 2.12
import QtQml 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {

    ListModel {
        id: commandQueue
    }

    //addCommand: Appends commands to the queue.
    function addCommand (command,value = -1) {
        commandQueue.append({
                                "cmd": command,
                                "value" : value

                            })

    }

    property int count: 0 // only to show that getData is increasing in logs, should !remove!

    function sendCommand () {
        timer.running = false
        if (commandQueue.count > 0) {
            let command = commandQueue.get(0).cmd
            if(commandQueue.get(0).value !== -1) {
                platformInterface.commands[command].update(commandQueue.get(0).value)
                logs.append ({log: "sending:" + JSON.stringify(platformInterface.commands[command])}) //For Demo Only
            } else {
                platformInterface.commands[command].update()
                logs.append({log: "sending:" + JSON.stringify(platformInterface.commands[command])}) //For Demo Only
            }

            commandQueue.remove(0)

        } else {
            timer.interval = 1000
            logs.append({ log: "no commands in queue " + count++ }) //For Demo Only
        }

        timer.start()
    }


    Timer {
        id: timer
        running: true
        repeat: true
        interval: 500
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
                            addCommand("get_data")

                        }
                    }

                    Button {
                        text: "Add Command \n With Value"
                        anchors.left: command.right
                        anchors.leftMargin: 10

                        onClicked: {
                            addCommand("set_data", 100)
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
                        delegate: commandDelegate
                        clip: true
                        ScrollBar.vertical: ScrollBar { active: true }
                    }


                    Component {
                        id: commandDelegate
                        Item {
                            width: 20
                            height: 20

                            Text {
                                id: commandText
                                text: {
                                    let value = model.value
                                    if (value !== -1) {
                                        let command = ({
                                                           cmd:  model.cmd,
                                                           value: model.value
                                                       })
                                        return JSON.stringify(command)
                                    } else {
                                        let command = ({
                                                           cmd:  model.cmd
                                                       })
                                        return JSON.stringify(command)
                                    }
                                }

                                color: "white"
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
                        delegate: logDelegate
                        clip: true
                        ScrollBar.vertical: ScrollBar { active: true }
                    }

                    ListModel {
                        id: logs
                        ListElement { log: "" }
                    }

                    Component {
                        id: logDelegate
                        Item {
                            width: 20
                            height: 20
                            Text {
                                text: log
                                color: "black"
                            }
                        }
                    }
                }
            }
        }
    }
}

