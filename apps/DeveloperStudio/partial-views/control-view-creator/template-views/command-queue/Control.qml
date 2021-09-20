import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }
    property var commandInlog
    property string class_id // automatically populated for use when the control view is created with a connected board



    PlatformInterface {
        id: platformInterface
    }


    Item {
        id: commandQueueContainer
        width: parent.width/1.5
        height: parent.height
        anchors.centerIn: parent

        ListModel {
            id: commandQueue
        }

        /***addCommand: Appends commands to the queue.
          command = command name ,
          containsPayload = true/false ,
          numberOfPayload = number of payload contain in the command beens end,
          value1 = parameter1 ,
          value2 = parameter2 ,
          value3 = parameter3

         To add more parameter/payload:
         1. Update funtion call to add a new parameter
         2. Append by adding "payloadName" : "parameter" to the end
        ***/

        function addCommand (command , containsPayload = false, numberOfPayload = 0, value1 = undefined, value2 = undefined, value3 = undefined ) {
            commandQueue.append({
                                    "cmd": command,
                                    "containsPayload": containsPayload,
                                    "numberOfPayload": numberOfPayload,
                                    "value1" : value1,
                                    "value2" : value2,
                                    "value3" : value3
                                })

        }
         /**
          To add more parameter/payload to the command:
          1. update sendCommandPayload(command, numberOfPayload) by adding additional "else if" condition.
         **/

        function sendCommandPayload(command, numberOfPayload) {
            if(numberOfPayload === 1) {
                platformInterface.commands[command].update(commandQueue.get(0).value1)
            } else if(numberOfPayload === 2) {
                platformInterface.commands[command].update(commandQueue.get(0).value1,
                                                           commandQueue.get(0).value2)
            } else if(numberOfPayload === 3) {
                platformInterface.commands[command].update(commandQueue.get(0).value1,
                                                           commandQueue.get(0).value2,
                                                           commandQueue.get(0).value3)
            } else {
                platformInterface.commands[command].update()
            }
        }

        property int count: 0 // only to show that getData is increasing in logs, should !remove!

        function sendCommand () {
            timer.running = false
            if (commandQueue.count > 0) {
                let command = commandQueue.get(0).cmd
                if(commandQueue.get(0).containsPayload) {
                    sendCommandPayload(command,commandQueue.get(0).numberOfPayload)

                    //For Demo Only
                    logs.insert(0,{log: "sending:" + JSON.stringify(platformInterface.commands[command])})

                } else {
                    platformInterface.commands[command].update()

                    //For Demo Only
                    logs.insert(0,{log: "sending:" + JSON.stringify(platformInterface.commands[command])})
                }
                commandQueue.remove(0)

            } else {

                //For Demo Only
                logs.insert(0, {log: "no commands in queue " + count++})
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
                commandQueueContainer.sendCommand()
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
                                commandQueueContainer.addCommand("get_data")
                            }
                        }

                        Button {
                            id: commandValue1
                            text: "Add Command \n With Value"
                            anchors.left: command.right
                            anchors.leftMargin: 10

                            onClicked: {
                                commandQueueContainer.addCommand("set_data",true,1,100)
                            }
                        }

                        Button {
                            text: "Add Command \n With Values"
                            anchors.left: commandValue1.right
                            anchors.leftMargin: 10

                            onClicked: {
                                commandQueueContainer.addCommand("set_values",true,3,100,-100,1)
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

                        //For Demo



                        Component {
                            id: commandDelegate
                            Item {
                                width: 20
                                height: 20
                                //ONLY FOR DEMO: Set log command based on number  of payload
                                function setLogCommad(model,numPayload) {
                                    let command
                                    if(numPayload === 1) {
                                        command  = ({
                                                        cmd:  model.cmd,
                                                        value: model.value1
                                                    })
                                    }
                                    if(numPayload === 2) {
                                        command = ({
                                                       cmd:  model.cmd,
                                                       value: model.value1,
                                                       value2: model.value2,
                                                   })
                                    }

                                    if(numPayload === 3) {
                                        command = ({
                                                       cmd:  model.cmd,
                                                       value: model.value1,
                                                       value2: model.value2,
                                                       value3: model.value3
                                                   })
                                    }
                                    return command
                                }

                                Text {
                                    id: commandText
                                    color: "white"

                                    text: {
                                        var value = model.containsPayload
                                        var numPayload = model.numberOfPayload

                                        if (value === true) {
                                            let command =  parent.setLogCommad(model,numPayload)
                                            return JSON.stringify(command)
                                        } else {
                                            let command = ({
                                                               cmd: model.cmd
                                                           })

                                            return JSON.stringify(command)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 350


                ColumnLayout {
                    anchors.fill: parent
                    spacing: 5

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20

                        Text {
                            text: "Commands in the log:"
                            anchors.fill: parent
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "light gray"

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

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        Layout.topMargin: 5
                        Layout.bottomMargin: 5

                        Button {
                            text: "Clear:"

                            onClicked: {
                                logs.clear()
                            }
                        }
                    }
                }
            }
        }
    }

}
