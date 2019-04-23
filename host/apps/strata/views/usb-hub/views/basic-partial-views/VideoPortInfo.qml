import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtMultimedia 5.8
import "qrc:/views/usb-pd-multiport/sgwidgets"

Rectangle {
    id: root

    property bool portConnected: false
    property color portColor: "#30a2db"
    property int portNumber: 1
    property alias portName: portTitle.text
    property int basicTitleBackgroundHeight: 50//(2*root.height)/16;
    property int advancedTitleBackgroundHeight: advancedDisplayPortPortHeight/4

    signal showGraph()
    color: "lightgoldenrodyellow"
    radius: 5
    border.color: "black"
    width: 150

    onPortConnectedChanged:{
        if (portConnected)
            hideStats.start()
         else
            showStats.start()
    }

    OpacityAnimator {
        id: hideStats
        target: connectionContainer
        from: 1
        to: 0
        duration: 1000
    }

    OpacityAnimator {
        id: showStats
        target: connectionContainer
        from: 0
        to: 1
        duration: 1000
    }

    function transitionToAdvancedView(){
        portToAdvanced.start()
    }

    ParallelAnimation{
        id: portToAdvanced
        running: false

        PropertyAnimation{
            target:titleBackground
            property: "height"
            to:advancedTitleBackgroundHeight
            duration: basicToAdvancedTransitionTime
        }

        PropertyAnimation {
            target: backgroundRect
            property: "opacity"
            from: 1
            to: 0
            duration: basicToAdvancedTransitionTime
        }

        PropertyAnimation {
            target: video
            property: "anchors.verticalCenterOffset"
            to: 20
            duration: basicToAdvancedTransitionTime
        }
    }

    function transitionToBasicView(){

        portToBasic.start()
    }

    ParallelAnimation{
        id: portToBasic
        running: false

        PropertyAnimation{
            target:titleBackground
            property: "height"
            to:basicTitleBackgroundHeight
            duration: advancedToBasicTransitionTime
        }
        PropertyAnimation {
            target: backgroundRect
            property: "opacity"
            from: 0
            to: 1
            duration: advancedToBasicTransitionTime
        }

        PropertyAnimation {
            target: video
            property: "anchors.verticalCenterOffset"
            to: 0
            duration: advancedToBasicTransitionTime
        }
    }


    Rectangle{
        id:titleBackground
        color:"lightgrey"
        anchors.top: root.top
        anchors.topMargin: 1
        anchors.left:root.left
        anchors.leftMargin: 1
        anchors.right: root.right
        anchors.rightMargin: 1
        height: 50
        radius:5
        z:1

        Rectangle{
            id:squareBottomBackground
            color:"lightgrey"
            anchors.top:titleBackground.top
            anchors.topMargin:(titleBackground.height)/2
            anchors.left:titleBackground.left
            anchors.right: titleBackground.right
            height: (titleBackground.height)/2
        }

        Text {
            id: portTitle
            text: "foo"
            anchors.horizontalCenter: titleBackground.horizontalCenter
            anchors.verticalCenter: titleBackground.verticalCenter
            font {
                pixelSize: 28
            }
            anchors {
                verticalCenter: statsContainer.verticalCenter
            }
            color: root.portConnected ? "black" : "#bbb"
        }
    }

    Rectangle{
        id:backgroundRect
        color:"lightgrey"
        border.color:"black"
        border.width: 1
        height:100
        anchors.left:root.left
        anchors.leftMargin: 2
        anchors.right: root.right
        anchors.rightMargin: 2
        anchors.verticalCenter: root.verticalCenter
    }
    Video {
        id: video
        width : backgroundRect.width - 4
        height : backgroundRect.height - 4
        anchors.verticalCenter: root.verticalCenter
        anchors.horizontalCenter: root.horizontalCenter
        fillMode: VideoOutput.PreserveAspectFit
        source: "../images/penguin.mp4"
        autoPlay: true
        loops: MediaPlayer.Infinite //loop until stopped
        volume: 0      //the video sample has audio, but we don't want to hear it

        Component.onCompleted: {
            //move into the video so there' a screen to see
            video.seek(100)
            video.pause()
        }

        MouseArea {
            anchors.fill: video
            onClicked: {
                video.play()
            }
        }

        focus: true
        Keys.onSpacePressed: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
        Keys.onLeftPressed: video.seek(video.position - 5000)
        Keys.onRightPressed: video.seek(video.position + 5000)

        property var videoIsPlaying: platformInterface.displayport_video_active_notification.video_active
        onVideoIsPlayingChanged: {
            if (videoIsPlaying){
                video.play()
            }
            else{
                video.pause()
            }
        }
    }


    Rectangle {
        id: connectionContainer
        opacity: 1
        z:1

        anchors {
            top:titleBackground.bottom
            left:root.left
            leftMargin: 2
            right:root.right
            rightMargin: 2
            bottom:root.bottom
            bottomMargin: 2
        }

        Image {
            id: connectionIcon
            source: "../images/icon-usb-disconnected.svg"
            height: connectionContainer.height/4
            width: height * 0.6925
            anchors {
                centerIn: parent
                verticalCenterOffset: -connectionText.font.pixelSize / 2
            }
        }

        Text {
            id: connectionText
            color: "#ccc"
            text: "<b>Port Disconnected</b>"
            anchors {
                top: connectionIcon.bottom
                topMargin: 5
                horizontalCenter: connectionIcon.horizontalCenter
            }
            font {
                pixelSize: 14
            }
        }
    }
}

