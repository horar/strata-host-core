import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    width: 200
    height:100
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"

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
                opacity: 1
                mipmap:true
                anchors.centerIn:parent
                source:"../images/reverse-icon.svg"

            }

            onClicked: {
                //send a command to the platform interface
                console.log("reverse clicked")
                platformInterface.changeTrack.update("restart_track");
            }
            onDoubleClicked: {
                platformInterface.changeTrack.update("previous_track")
            }

        }

        Button{
            id:playButton
            checkable:true
            checked:false
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
                opacity: 1
                mipmap:true
                anchors.centerIn:parent
                source: "../images/play-icon.svg"

                //listen to the board notification for a change in the play/pause state
                //and update the icon accordingly
                //when not checked, the button should show the play icon. On clicked it will send play
                //when checked, the button should show the pause icon. on click it will send pause
                property var playState: platformInterface.play_pause
                onPlayStateChanged: {
                    if (platformInterface.play_pause.state ==="play" ){
                        source = "../images/pause-icon.svg"
                    }
                    else{
                        source = "../images/play-icon.svg"
                    }
                }

            }

            onClicked: {
                //send a command to the platform interface
                if (!checked){
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
                opacity: 1
                mipmap:true
                anchors.centerIn:parent
                source:"../images/fastForward-icon.svg"

            }

            onClicked: {
                //send a command to the platform interface
                console.log("fast forward clicked")
                platformInterface.changeTrack.update("next_track")
            }

        }
    }



}
