import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Window 2.6

ApplicationWindow {
    id: mainWnd
    visible: true
    width: 480
    height: 480
    title: qsTr("Main Window")

    Rectangle {
        id: container
        anchors {
            fill: parent
        }

        // This is an example column layout that disappears when all of its contents are popped out
        Rectangle {
            id: column1
            width: popout1.popped && popout2.popped ? 0 : container.width/2
            anchors {
                top: container.top
                bottom: container.bottom
                left: container.left
            }

            SGPopout {
                id: popout1
                title: "Popout 1"
                unpoppedHeight: container.height / 2  // NOTE THIS IS NOT WIDTH, IT IS UNPOPPEDWIDTH (to save the binding)
                unpoppedWidth: column1.width
            }

            SGPopout {
                id: popout2
                title: "Popout 2"
                unpoppedHeight: column1.height / 2
                unpoppedWidth: column1.width
                anchors {
                    top: popout1.bottom
                }
                overlaycolor: "lightblue"
            }
        }

        SGPopout {
            id: popout3
            title: "Popout 3"
            overlaycolor: "lightgreen"
            unpoppedWidth: parent.width / 2
            unpoppedHeight: parent.height
            content: SGGraph {
                id: graph
                inputData: graphData.stream
            }
            anchors {
                left: column1.right
            }
        }
    }

    Timer {
        id: graphData
        property real stream
        property real count: 0
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/500)*3+5;
        }
    }
}

