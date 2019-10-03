import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    width: 200
    height:100
    color:"dimgray"
    opacity:1
    radius: 10


    Row{
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        height: 150
        width:.75* parent.width
        spacing:10

        Button{
            id:reverseButton
            width: parent.width/3
            height:parent.height
            opacity: pressed ? .1 : 1
            background: Rectangle {
                    color:"transparent"
                }

            Image {
                id: reverseIcon
                fillMode: Image.PreserveAspectFit
                width:parent.width
                height:parent.height
                opacity: .5
                mipmap:true
                anchors.centerIn:parent
                source:"../images/reverse-icon.svg"

            }

            onClicked: {
                //send a command to the platform interface
                console.log("reverse clicked")
                platformInterface.change_track.update("restart_track");
            }
            onDoubleClicked: {
                platformInterface.change_track.update("previous_track")
            }

        }

        Button{
            id:playButton
            checkable:true
            width: parent.width/3
            height:parent.height/3
            opacity: pressed ? .1 : 1
            anchors.verticalCenter: parent.verticalCenter

            background: Rectangle {
                    color:"transparent"
                }

            Image {
                id: playIcon
                fillMode: Image.PreserveAspectFit
                width:parent.width
                height:parent.height
                opacity: .5
                mipmap:true
                anchors.centerIn:parent
                source:playButton.checked ? "../images/pause-icon.svg" : "../images/play-icon.svg"

            }

            onClicked: {
                //send a command to the platform interface
                if (checked){
                    console.log("starting play")
                    platformInterface.set_play.update("play")
                }
                 else{
                    console.log("starting pause")
                    platformInterface.set_play.update("pause")
                }
            }

        }

        Button{
            id:fastForwardButton
            width: parent.width/3
            height:parent.height
            opacity: pressed ? .1 : 1
            background: Rectangle {
                    color:"transparent"
                }
            Image {
                id: fasForwardIcon
                fillMode: Image.PreserveAspectFit
                width:parent.width
                height:parent.height
                opacity: .5
                mipmap:true
                anchors.centerIn:parent
                source:"../images/fastForward-icon.svg"

            }

            onClicked: {
                //send a command to the platform interface
                console.log("fast forward clicked")
                platformInterface.change_track.update("next_track")
            }

        }
    }



}
