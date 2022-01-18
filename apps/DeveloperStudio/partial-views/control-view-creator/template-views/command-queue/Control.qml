/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    anchors {
        fill: parent
    }

    property string class_id // automatically populated for use when the control view is created with a connected board

    PlatformInterface {
        id: platformInterface
    }

    /**
        Command Queue: Ensures that back-to-back commands are sent at a given interval or slower;
                       prevents commands from being sent at the same time or immediately after each other.
     */
    QtObject {
        id: commandQueue

        property var queue_: []
        signal queueChanged()

        property Timer timer: Timer {
            interval: 1000 // enforce >=1000ms between commands

            onTriggered: {
                if (commandQueue.queue_.length > 0) {
                    // send next command in queue
                    let oldestCommand = commandQueue.queue_.shift()
                    commandQueue.queueChanged()
                    commandQueue.sendCommand(oldestCommand)
                }
            }
        }

        /**
            addCommand(): adds commands to the command queue or sends immediately if queue is empty
            parameters:
                commandName: name of command in PlatformInterface.qml
                payload: any payload values the command needs
            examples:
                commandQueue.addCommand("get_data")                 // command with no payload
                commandQueue.addCommand("set_values", 100, -100, 1) // command with 3 payload values
         */
        function addCommand (commandName, ...payload) { // spread syntax allows variable number of payload arguments
            if (platformInterface.commands.hasOwnProperty(commandName)) {
                let command = {
                    commandName: commandName,
                    payload: payload
                }
                if (timer.running === false) { // if not running, send immediately and start timer
                    sendCommand(command)
                } else { // if running, another command was just sent. add to queue instead.
                    commandQueue.queue_.push(command)
                    commandQueue.queueChanged()
                }
            } else {
                console.error("PlatformInterface does not contain command named", commandName)
            }
        }

        function sendCommand (command) {
            platformInterface.commands[command.commandName].update(...command.payload)
            commandQueue.timer.restart() // timer starts after command is sent to prevent any follow-on command from being sent too quickly

            // For Demo Only ----------- Remove this log code
            logs.insert(0,{log: "Sent: " + JSON.stringify(platformInterface.commands[command.commandName])})
            if (commandQueue.queue_.length === 0) {
                logs.insert(0,{log: "No commands left in queue"})
            }
        }
    }

    //// FOR VISUAL DEMO ONLY: buttons to add commands manually, show any existing commands in the queue, and to add a log of commands been sent.
    //// No code below should be copied for use in production.
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    Item {
        id: commandQueueContainer
        width: parent.width/1.5
        height: parent.height
        anchors.centerIn: parent

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
                            text: "Add Command \n With No Payload"

                            onClicked: {
                                commandQueue.addCommand("get_data")
                            }
                        }

                        Button {
                            id: commandValue1
                            text: "Add Command \n With One Payload Property"
                            anchors.left: command.right
                            anchors.leftMargin: 10

                            onClicked: {
                                commandQueue.addCommand("set_data", 100)
                            }
                        }

                        Button {
                            text: "Add Command \n With Mutiple Payload Properties"
                            anchors.left: commandValue1.right
                            anchors.leftMargin: 10

                            onClicked: {
                                commandQueue.addCommand("set_values", 100, -100, 1)
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20

                        Text {
                            text: "Commands in Queue:"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "gray"

                        ListView {
                            id: currentCommandQueue
                            anchors.fill: parent
                            model: commandQueue.queue_
                            delegate: commandDelegate
                            clip: true
                            ScrollBar.vertical: ScrollBar { active: true }

                            Connections {
                                target: commandQueue
                                onQueueChanged: {
                                    currentCommandQueue.model = commandQueue.queue_
                                }
                            }
                        }

                        Component {
                            id: commandDelegate

                            Text {
                                id: commandText
                                color: "white"
                                text: JSON.stringify(modelData)
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
                            text: "Log of sent commands:"
                            anchors.verticalCenter: parent.verticalCenter
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
                            text: "Clear Log"

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
