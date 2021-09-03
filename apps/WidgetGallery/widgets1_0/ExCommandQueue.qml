import QtQuick 2.12
import QtQml 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    width: 640
    height: 480
    visible: true

    ListModel {
        id: commandQueue
    }

    function addCommand (command) {
        commandQueue.append({
                                "command": JSON.stringify(command)
                            })
    }

    property int counter: 0 /// only to show that getData is increasing in logs, should !remove!

    function sendCommand () {
        if (commandQueue.count > 0) {
            timer.interval = 500
            let command = commandQueue.get(0).command
            commandQueue.remove(0)
            console.info("sending:", command)
        } else {
            timer.interval = 30
            console.info("no commands in queue, sending getData " + counter++)
            console.info("sending:", "getdataCommand")
        }
    }

    Timer {
        id: timer
        running: true
        repeat: true
        interval: 30
        onTriggered: {
            sendCommand()
        }
    }

    /// VISUAL DEMO CONTROLS: button to add commands manually, and show any existing commands in the queue
    ColumnLayout {
        Button {
            text: "Add Command"

            property var counter: 0
            onClicked: {
                let command = {
                    myCommand: "some command here " + counter++
                }
                addCommand(command)
            }
        }

        Text {
            text: "Commands in Queue:"
        }

        Repeater {
            model: commandQueue
            delegate: Text {
                text: model.command
            }
        }
    }
}
