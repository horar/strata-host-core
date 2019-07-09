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
            //ledTimer.start()
        }
        else{
            ledTimer.stop()
            //receivingData = false
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


        Sensor{
            id:sensor1
            title: "sensor 1"
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: -70
            ButtonGroup.group: sensorButtonGroup
            checked: true   //let sensor 1 be checked initially

            onTransmitterNameChanged:{
                receiver.name = sensor1.title
            }
        }

        Sensor{
            id:sensor2
            title: "sensor 2"
            anchors.left: sensor1.right

            anchors.leftMargin: 30
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: -70
            ButtonGroup.group: sensorButtonGroup

            onTransmitterNameChanged:{
                receiver.name = sensor2.title
            }
        }
        Sensor{
            id:sensor3
            title: "sensor 3"
            anchors.left: sensor2.right
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: -70
            ButtonGroup.group: sensorButtonGroup

            onTransmitterNameChanged:{
                receiver.name = sensor3.title
            }
        }
        Sensor{
            id:sensor4
            title: "sensor 4"
            anchors.left: sensor3.right
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: -70
            ButtonGroup.group: sensorButtonGroup

            onTransmitterNameChanged:{
                receiver.name = sensor4.title
            }
        }


    }
    ButtonGroup{
        id:sensorButtonGroup
        exclusive: true

        onClicked:{
            receiver.name = button.title
            //receiver.color = "red"
        }
    }

    Rectangle{
        id:receiver
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 25
        height:400
        width:400
        radius:30
        color:"slateGrey"
        border.color:"gold"
        border.width:3

        property alias name: receiverName.text

        Text{
            id:receiverName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: 10
            text:"sensor 1"
            font.pixelSize:48
            color:"lightgrey"
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
                id:soilMoistureStats
                anchors.left:parent.left
                anchors.top:parent.top
                anchors.bottom:parent.verticalCenter
                width:parent.width/2
                label: "Soil Moisture"
                value: platformInterface.receive_notification.rssi
                unit: "%"
                icon:""
                labelSize: 18
                valueSize: 85
                unitSize: 24
                bottomMargin: 0

                MouseArea{
                    id:soilMoistureGraphMouseArea
                    anchors.fill:parent
                    hoverEnabled:true

                    onContainsMouseChanged: {
                        if (containsMouse){
                            soilMoisturePopover.show = true
                        }
                    }
                }
            }



            PortStatBox{
                id:pressureStats
                anchors.right:parent.right
                anchors.top:parent.top
                anchors.bottom:parent.verticalCenter
                width:parent.width/2
                label: "Pressure"
                value: {
                    var errorRate = platformInterface.receive_notification.packet_error_rate.toFixed(2) //returns 0.xx
                    return errorRate.substring(1);
                }
                unit: "atm"
                icon:""
                labelSize: 18
                valueSize: 85
                unitSize: 24
                bottomMargin: 0

                MouseArea{
                    id:pressureGraphMouseArea
                    anchors.fill:parent
                    hoverEnabled:true

                    onContainsMouseChanged: {
                        if (containsMouse){
                            pressurePopover.show = true
                        }
                    }
                }
            }


            PortStatBox{
                id:temperature
                anchors.left:parent.left
                anchors.top:parent.verticalCenter
                anchors.bottom:parent.bottom
                width:parent.width/2
                label: "Temperature"
                value: {
                    var errorRate = platformInterface.receive_notification.packet_error_rate.toFixed(2) //returns 0.xx
                    return errorRate.substring(1);
                }
                unit: "°C"
                icon:""
                labelSize: 18
                valueSize: 95
                unitSize: 24
                bottomMargin: 0

                MouseArea{
                    id:temperatureGraphMouseArea
                    anchors.fill:parent
                    hoverEnabled:true

                    onContainsMouseChanged: {
                        if (containsMouse){
                            temperaturePopover.show = true
                        }
                    }
                }
            }
            PortStatBox{
                id:humidity
                anchors.right:parent.right
                anchors.top:parent.verticalCenter
                anchors.bottom:parent.bottom
                width:parent.width/2
                label: "Humidity"
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
                    id:humidityGraphMouseArea
                    anchors.fill:parent
                    hoverEnabled:true

                    onContainsMouseChanged: {
                        if (containsMouse){
                            humidityPopover.show = true
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
            Rectangle{
                id:horizontalDividerBar
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:parent.left
                anchors.right:parent.right
                height:4
                color:"lightgrey"
            }
        }


        Button{
            id:resetButton
            anchors.right: parent.right
            anchors.rightMargin:10
            anchors.bottom:parent.bottom
            anchors.bottomMargin:20
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

    Button{
        id:startStopReceiveButton
        anchors.horizontalCenter: receiver.horizontalCenter
        anchors.top:receiver.bottom
        anchors.topMargin: 40
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

    Popover{
        id: soilMoisturePopover
        anchors.right: receiver.left
        anchors.bottom:receiver.bottom
        anchors.bottomMargin: receiver.height/2
        width:400
        height:350
        arrowDirection: "right"
        backgroundColor: popoverColor
        closeButtonColor: "#E1E1E1"

        SGGraph {
            id: soilMoistureGraph
            title: "Soil Moisture"
            visible: true
            anchors {
                top: soilMoisturePopover.top
                topMargin:20
                bottom: soilMoisturePopover.bottom
                bottomMargin: 45
                right: soilMoisturePopover.right
                rightMargin: 2
                left: soilMoisturePopover.left
                leftMargin:2
            }

            yAxisTitle: "%"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 100                   // Default: 10
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

    Popover{
        id: pressurePopover
        anchors.left: receiver.right
        anchors.bottom:receiver.bottom
        anchors.bottomMargin:receiver.height/2
        width:400
        height:350
        arrowDirection: "left"
        backgroundColor: popoverColor
        closeButtonColor: "#E1E1E1"

        SGGraph {
            id: pressureGraph
            title: "Pressure"
            visible: true
            anchors {
                top: pressurePopover.top
                topMargin:20
                bottom: pressurePopover.bottom
                bottomMargin: 45
                right: pressurePopover.right
                rightMargin: 2
                left: pressurePopover.left
                leftMargin:2
            }
            //width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "atm"
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
        id: temperaturePopover
        anchors.right: receiver.left
        anchors.top:receiver.top
        anchors.topMargin:receiver.height/2
        width:400
        height:350
        arrowDirection: "right"
        backgroundColor: popoverColor
        closeButtonColor: "#E1E1E1"

        SGGraph {
            id: temperatureGraph
            title: "Temperature"
            visible: true
            anchors {
                top: temperaturePopover.top
                topMargin:20
                bottom: temperaturePopover.bottom
                bottomMargin: 45
                right: temperaturePopover.right
                rightMargin: 2
                left: temperaturePopover.left
                leftMargin:2
            }

            yAxisTitle: "°C"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 100                   // Default: 10
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

    Popover{
        id: humidityPopover
        anchors.left: receiver.right
        anchors.top:receiver.top
        anchors.topMargin: receiver.height/2
        width:400
        height:350
        arrowDirection: "left"
        backgroundColor: popoverColor
        closeButtonColor: "#E1E1E1"

        SGGraph {
            id: humidityGraph
            title: "Humidity"
            visible: true
            anchors {
                top: humidityPopover.top
                topMargin:20
                bottom: humidityPopover.bottom
                bottomMargin: 45
                right: humidityPopover.right
                rightMargin: 2
                left: humidityPopover.left
                leftMargin:2
            }

            yAxisTitle: "%"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 100                   // Default: 10
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



}
