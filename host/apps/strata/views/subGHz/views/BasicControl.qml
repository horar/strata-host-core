import QtQuick 2.10
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "qrc:/views/subGHz/sgwidgets"
import "qrc:/views/subGHz/views/basic-partial-views"

Rectangle {
    id: root
    anchors.fill:parent
    color:"dimgrey"

    property string textColor: "white"
    property string secondaryTextColor: "grey"
    property string windowsDarkBlue: "#2d89ef"
    property string backgroundColor: "#FF2A2E31"
    //property string backgroundColor: "light grey"
    property string transparentBackgroundColor: "#002A2E31"
    property string dividerColor: "#3E4042"
    property string switchGrooveColor:"dimgrey"
    property color popoverColor: "#CECECE"
    property int leftSwitchMargin: 40
    property int rightInset: 50

    property real widthRatio: root.width / 1200

    property bool receiving: false
    property bool receivingData: false


    onReceivingChanged:{
        if (receiving){
            ledTimer.start()
        }
        else{
            ledTimer.stop()
            receivingData = false
        }
    }

    //----------------------------------------------------------------------------------------
    //                      Views
    //----------------------------------------------------------------------------------------


    Rectangle{
        id:deviceBackground
        color:backgroundColor
        radius:10
        height:(7*parent.height)/16
        anchors.left:root.left
        anchors.leftMargin: 12
        anchors.right: root.right
        anchors.rightMargin: 12
        anchors.top:root.top
        anchors.topMargin: 12
        anchors.bottom:root.bottom
        anchors.bottomMargin: 12
        clip:true


        Text{
            id:platformName
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left:parent.left
            anchors.leftMargin: 15
            width:100
            text:"Point-to-point Wireless\nCommunication Link"
            font.pixelSize:24
            color:"dimgrey"
        }

        Rectangle{
            id:transmitter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: -50
            height:300
            width:300
            radius:30
            color:"slateGrey"
            //border.color:"dimgrey"
            border.color:"gold"
            border.width:3

            Text{
                id:transmitterName
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom:parent.bottom
                anchors.bottomMargin: 15
                text:"transmitter"
                font.pixelSize:48
                color:"lightgrey"
            }


            AnimatedImage{
                id:transmitterAntenna
                source: "images/animatedBroadcastAntenna.gif"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:transmitter.bottom
                width:40
                height:40
                fillMode:Image.PreserveAspectFit
                playing:root.receiving

                onPlayingChanged: {
                    if (!playing){
                        //if stopping the animation, reset the image to the first one
                        currentFrame = 0;
                    }
                }
            }



        }
    }

    Rectangle{
        id:receiver
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 25
        height:300
        width:300
        radius:30
        color:"slateGrey"
        border.color:"gold"
        border.width:3

        Text{
            id:receiverName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: 10
            text:"receiver"
            font.pixelSize:48
            color:"lightgrey"
        }


        AnimatedImage{
            id:receiverAntenna
            source: "images/animatedAntenna.gif"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:parent.top
            width:40
            height:40
            fillMode:Image.PreserveAspectFit
            //opacity:.5
            playing:root.receiving

            onPlayingChanged: {
                if (!playing){
                    //if stopping the animation, reset the image to the first one
                    currentFrame = 0;
                }
            }
        }

        Timer{
            id: ledTimer
            interval:1000
            running:false
            repeat:true

            onTriggered:{
                receivingData = !receivingData;
            }

        }

        Rectangle{
            id:receiveLED
            anchors.left:receiverAntenna.horizontalCenter
            anchors.leftMargin: -5
            anchors.top:receiverAntenna.verticalCenter
            width:10
            height:10
            radius:5
            opacity: receivingData ? 1 : 0
            color:"lawngreen"
        }

        Rectangle{
            id:statsBackground
            anchors.left:parent.left
            anchors.leftMargin: parent.border.width
            anchors.right:parent.right
            anchors.rightMargin: parent.border.width
            anchors.top:parent.top
            anchors.topMargin:75
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 75

            PortStatBox{
                id:rssiStats
                anchors.left:parent.left
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                width:parent.width/2
                label: "RSSI"
                value: platformInterface.receive_notification.rssi
                unit: "dBm"
                icon:""
                labelSize: 18
                valueSize: 95
                unitSize: 24
                bottomMargin: 0

                MouseArea{
                    id:rssiGraphMouseArea
                    anchors.fill:parent
                    hoverEnabled:true

                    onContainsMouseChanged: {
                        if (containsMouse){
                            rssiPopover.show = true
                        }
                    }
                }
            }

            Rectangle{
                id:dividerBar
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                width:4
                color:"lightgrey"
            }

            PortStatBox{
                id:errorRate
                anchors.right:parent.right
                anchors.top:parent.top
                anchors.bottom:parent.bottom
                width:parent.width/2
                label: "Packet Error Rate"
                value: {
                    var errorRate = platformInterface.receive_notification.packet_error_rate.toFixed(2) //returns 0.xx
                    return errorRate.substring(1);
                }
                unit: "%"
                icon:""
                labelSize: 18
                valueSize: 95
                unitSize: 24
                bottomMargin: 0

                MouseArea{
                    id:errorRateGraphMouseArea
                    anchors.fill:parent
                    hoverEnabled:true

                    onContainsMouseChanged: {
                        if (containsMouse){
                            errorRatePopover.show = true
                        }
                    }
                }
            }
        }
        Button{
            id:startStopReceiveButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 20
            height:40
            text:root.receiving ? "stop" : "start"

            contentItem: Text {
                text: startStopReceiveButton.text
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -3
                font.pixelSize: 36
                opacity: enabled ? 1.0 : 0.3
                color: startStopReceiveButton.down ? "black" : "lightgrey"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 140
                opacity: .75
                color: root.receiving ? "red" : "forestgreen"
                border.width: 1
                radius: 10
            }

            onClicked:{

                platformInterface.toggle_receive.update(!root.receiving)
                root.receiving = !root.receiving
            }
        }

        Button{
            id:resetButton
            anchors.right: parent.right
            anchors.rightMargin:10
            anchors.bottom:startStopReceiveButton.bottom
            height:20
            text:"reset"

            contentItem: Text {
                text: resetButton.text
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 12
                color:{
                    if (resetButton.down)
                        color = "black" ;
                    else if (resetButton.hovered)
                        color = "white";
                    else
                        color = "dimgrey";
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 60
                color: "transparent"
                border.width: 0
                radius: resetButton.height/2
            }

            onHoveredChanged:{
                if (hovered){
                    resetButton.background.border.width = 1;
                    resetButton.contentItem.color = "white";
                }
                else{
                    resetButton.background.border.width = 0;
                    resetButton.contentItem.color = "dimgrey";
                }
            }

            onClicked:{
                errorGraph.series.clear()
            }
        }

    }

    Popover{
        id: errorRatePopover
        anchors.left: receiver.right
        anchors.top:receiver.top
        width:400
        height:350
        arrowDirection: "left"
        backgroundColor: popoverColor
        closeButtonColor: "#E1E1E1"

        SGGraph {
            id: errorGraph
            title: "Error Rate"
            visible: true
            anchors {
                top: errorRatePopover.top
                topMargin:20
                bottom: errorRatePopover.bottom
                bottomMargin: 45
                right: errorRatePopover.right
                rightMargin: 2
                left: errorRatePopover.left
                leftMargin:2
            }
            //width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "%"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 10                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 10                   // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var errorRateInfo: platformInterface.receive_notification
            onErrorRateInfoChanged:{
                //console.log("new error rate info received ");
                count += interval;
                stream = platformInterface.receive_notification.packet_error_rate
            }

            inputData: stream          // Set the graph's data source here
        }

    }

    Popover{
        id: rssiPopover
        anchors.right: receiver.left
        anchors.top:receiver.top
        width:400
        height:350
        arrowDirection: "right"
        backgroundColor: popoverColor
        closeButtonColor: "#E1E1E1"

        SGGraph {
            id: rssiGraph
            title: "RSSI"
            visible: true
            anchors {
                top: rssiPopover.top
                topMargin:20
                bottom: rssiPopover.bottom
                bottomMargin: 45
                right: rssiPopover.right
                rightMargin: 2
                left: rssiPopover.left
                leftMargin:2
            }

            yAxisTitle: "-dBm"
            xAxisTitle: "Seconds"
            minYValue: -100                    // Default: 0
            maxYValue: 0                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 10                   // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var errorRateInfo: platformInterface.receive_notification
            onErrorRateInfoChanged:{
                //console.log("new error rate info received ");
                count += interval;
                stream = platformInterface.receive_notification.rssi
            }

            inputData: stream          // Set the graph's data source here
        }

    }



    SGStatusListBox {
        id: dataConsole

        width: 300
        color:"transparent"
        titleBoxColor:root.backgroundColor
        titleTextColor:"lightgrey"
        titleTextSize:15
        titleBoxBorderColor:"black"
        statusTextColor: "white"
        statusBoxColor: "red"
        statusBoxBorderColor: "black"
        anchors.top:receiver.bottom
        anchors.topMargin: 40
        anchors.bottom:deviceBackground.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: receiver.horizontalCenter
        title: "DATA CONSOLE"
        model: dataPacketModel

        property var dataPacket: platformInterface.receive_notification.data_packet

        onDataPacketChanged: {
            var currentdate = new Date();
            var seconds = currentdate.getSeconds();
            if (seconds < 10){
                seconds = "0"+seconds;
            }

            var timeStamp = currentdate.getHours() + ":"
                    + currentdate.getMinutes() + ":" + seconds + "  ";
            var timeStampedDataPacket = timeStamp + dataPacket
            dataPacketModel.append({"status":timeStampedDataPacket});
        }

        ListModel{
            id:dataPacketModel
        }
    }

    Button{
        id:clearTextButton
        anchors.right: dataConsole.right
        anchors.rightMargin:10
        anchors.top:dataConsole.bottom
        anchors.topMargin: 5
        height:20
        text:"clear"

        contentItem: Text {
            text: clearTextButton.text
            anchors.verticalCenter: parent.verticalCenter
            //anchors.verticalCenterOffset: -3
            font.pixelSize: 12
            //opacity: enabled ? 1.0 : 0.3
            color: clearTextButton.down ? "black" : "dimgrey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 60
            //implicitHeight: 20
            opacity: enabled ? 1 : 0.3
            color: "#FF2A2E31"
            border.width: 1
            radius: clearTextButton.height/2


        }

        onClicked:{
            dataConsole.model.clear()
        }
    }



}
