import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.3

Item {
    id: root
    implicitWidth: 200
    implicitHeight: root.labelLeft ? progressBarContainer.height : progressBarContainer.height + progressStatus.height + progressBarContainer.anchors.topMargin

    property var start_restart
    onStart_restartChanged: {
        console.log("in start", start_restart)
        progressBarFake.restart()

    }

    Rectangle {
        id: progressBarContainer
        height: 30
        border {
            width: 1
            color: "#bbb"
        }
        color: "transparent"
        width: 400
        anchors {
            centerIn: parent
        }

        Rectangle {
            id: progressBar
            color: "#33b13b"
            height: progressBarContainer.height - 6
            anchors {
                verticalCenter: progressBarContainer.verticalCenter
                left: progressBarContainer.left
                leftMargin: 3
            }
            width: 1

            PropertyAnimation {
                id: progressBarFake
                target: progressBar
                property: "width"
                from: root.start_restart
                to: progressBarContainer.width - 6
                duration: 2000
                running: true


            }
        }
    }

    Text {
        id: progressStatus
        text: "" + (100 * progressBar.width / (progressBarContainer.width - 6)).toFixed(0) + "% complete"
        color: "#bbb"
        anchors {
            bottom: progressBarContainer.top
            right: progressBarContainer.right
            bottomMargin: 3
        }

    }
}
