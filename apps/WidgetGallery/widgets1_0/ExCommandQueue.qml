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
            console.info("sending:" + command)
            logs.append({ log: "sending:" + command })
        } else {
            timer.interval = 1000
            console.info("no commands in queue, sending getData " + counter++)
            logs.append({ log: "no commands in queue, sending getData " + counter++})
        }
    }

    Timer {
        id: timer
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            sendCommand()
        }
    }

    /// VISUAL DEMO CONTROLS: button to add commands manually, and show any existing commands in the queue
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
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

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
                        id: listView2
                        anchors.fill: parent
                        model: commandQueue
                        delegate: delegate2
                        clip: true
                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }
                    }


                    Component {
                        id: delegate2
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
                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }
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
                                text: {
                                    console.info(log)
                                    if(log !== "" || log !== undefined) {
                                        return log
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

