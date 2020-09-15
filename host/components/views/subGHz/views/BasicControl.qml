import QtQuick 2.10
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../sgwidgets"
import "basic-partial-views"

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
            //ledTimer.stop()
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
            sensorNumber: "0x001"

            onTransmitterNameChanged:{
                receiver.name = sensor1.title
            }
            onSelected:{
                //update the values in the receiver display
                receiver.sensorNumber = sensor1.sensorNumber
                receiver.soilMoisture = sensor1.soilMoisture
                receiver.temperature = sensor1.temperature
                receiver.pressure = sensor1.pressure
                receiver.humidity = sensor1.humidity

                //update the initial values for the graphs
                pressurePopover.graphValue = sensor1.pressure
                rssiPopover.graphValue = sensor1.rssi
                temperaturePopover.graphValue = sensor1.temperature
                humidityPopover.graphValue = sensor1.humidity

                //update which sensors the graphs are following, and reset them.
                pressurePopover.sensorNumber = sensor1.sensorNumber
                rssiPopover.sensorNumber = sensor1.sensorNumber
                temperaturePopover.sensorNumber = sensor1.sensorNumber
                humidityPopover.sensorNumber = sensor1.sensorNumber
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
            sensorNumber: "0x002"

            onTransmitterNameChanged:{
                receiver.name = sensor2.title
            }
            onSelected:{
                receiver.sensorNumber = sensor2.sensorNumber
                receiver.soilMoisture = sensor2.soilMoisture
                receiver.temperature = sensor2.temperature
                receiver.pressure = sensor2.pressure
                receiver.humidity = sensor2.humidity

                //update the initial values for the graphs
                pressurePopover.graphValue = sensor2.pressure
                rssiPopover.graphValue = sensor2.rssi
                temperaturePopover.graphValue = sensor2.temperature
                humidityPopover.graphValue = sensor2.humidity

                pressurePopover.sensorNumber = sensor2.sensorNumber
                rssiPopover.sensorNumber = sensor2.sensorNumber
                temperaturePopover.sensorNumber = sensor2.sensorNumber
                humidityPopover.sensorNumber = sensor2.sensorNumber
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
            sensorNumber: "0x003"

            onTransmitterNameChanged:{
                receiver.name = sensor3.title
            }
            onSelected:{
                receiver.sensorNumber = sensor3.sensorNumber
                receiver.soilMoisture = sensor3.soilMoisture
                receiver.temperature = sensor3.temperature
                receiver.pressure = sensor3.pressure
                receiver.humidity = sensor3.humidity

                //update the initial values for the graphs
                pressurePopover.graphValue = sensor3.pressure
                rssiPopover.graphValue = sensor3.rssi
                temperaturePopover.graphValue = sensor3.temperature
                humidityPopover.graphValue = sensor3.humidity

                pressurePopover.sensorNumber = sensor3.sensorNumber
                rssiPopover.sensorNumber = sensor3.sensorNumber
                temperaturePopover.sensorNumber = sensor3.sensorNumber
                humidityPopover.sensorNumber = sensor3.sensorNumber
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
            sensorNumber: "0x004"

            onTransmitterNameChanged:{
                receiver.name = sensor4.title
            }
            onSelected:{
                receiver.sensorNumber = sensor4.sensorNumber
                receiver.soilMoisture = sensor4.soilMoisture
                receiver.temperature = sensor4.temperature
                receiver.pressure = sensor4.pressure
                receiver.humidity = sensor4.humidity

                //update the initial values for the graphs
                pressurePopover.graphValue = sensor4.pressure
                rssiPopover.graphValue = sensor4.rssi
                temperaturePopover.graphValue = sensor4.temperature
                humidityPopover.graphValue = sensor4.humidity

                pressurePopover.sensorNumber = sensor4.sensorNumber
                rssiPopover.sensorNumber = sensor4.sensorNumber
                temperaturePopover.sensorNumber = sensor4.sensorNumber
                humidityPopover.sensorNumber = sensor4.sensorNumber
            }
        }


    }
    ButtonGroup{
        id:sensorButtonGroup
        exclusive: true

        onClicked:{
            receiver.name = button.title

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
        border.color:"goldenrod"
        border.width:3

        property alias name: receiverName.text
        property alias temperature: temperatureStats.value
        property alias rssi: rssiStats.value
        property alias pressure: pressureStats.value
        property alias humidity: humidityStats.value
        property var soilMoisture: 0
        property string sensorNumber: "0x001"

        onSensorNumberChanged: {
            //console.log("receiver sensor number is now ",sensorNumber)
        }

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
                id:temperatureStats
                anchors.left:parent.left
                anchors.top:parent.top
                anchors.bottom:parent.verticalCenter
                width:parent.width/2
                label: "Temperature"

                property var temperature: platformInterface.receive_notification.data.temperature
                onTemperatureChanged: {
                    if (platformInterface.receive_notification.sensor_id === receiver.sensorNumber){
                        value =  platformInterface.receive_notification.data.temperature.toFixed(1)
                    }
                }

                unit: "°C"
                icon:""
                labelSize: 18
                valueSize: 70
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
                id:rssiStats
                anchors.right:parent.right
                anchors.top:parent.top
                anchors.bottom:parent.verticalCenter
                width:parent.width/2
                label: "RSSI"

                property var rssi: platformInterface.receive_notification.rssi
                onRssiChanged: {
                    if (platformInterface.receive_notification.sensor_id === receiver.sensorNumber){
                        value = platformInterface.receive_notification.rssi.toFixed(0)
                    }
                }

                unit: "dBm"
                icon:""
                labelSize: 18
                valueSize: 70
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


            PortStatBox{
                id:pressureStats
                anchors.left:parent.left
                anchors.top:parent.verticalCenter
                anchors.bottom:parent.bottom
                width:parent.width/2
                label: "Pressure"
                property var pressure: platformInterface.receive_notification.data.pressure
                onPressureChanged: {
                    if (platformInterface.receive_notification.sensor_id === receiver.sensorNumber){
                       value = platformInterface.receive_notification.data.pressure.toFixed(0)
                    }
                }


                unit: "hpa"
                icon:""
                labelSize: 18
                valueSize: 70
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
                id:humidityStats
                anchors.right:parent.right
                anchors.top:parent.verticalCenter
                anchors.bottom:parent.bottom
                width:parent.width/2
                label: "Humidity"
                property var humidity: platformInterface.receive_notification.data.soil
                onHumidityChanged: {
                    if (platformInterface.receive_notification.sensor_id === receiver.sensorNumber){
                        value = platformInterface.receive_notification.data.humidity.toFixed(0)
                        }

                }

                unit: "%"
                icon:""
                labelSize: 18
                valueSize: 70
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
        id: pressurePopover
        anchors.right: receiver.left
        anchors.top:receiver.top
        anchors.topMargin:receiver.height/2
        width:400
        height:350
        arrowDirection: "right"
        backgroundColor: popoverColor
        closeButtonColor: "#E1E1E1"

        property alias sensorNumber: pressureGraph.sensorNumber
        property alias graphValue: pressureGraph.stream
        onSensorNumberChanged: {
            pressureGraph.reset();

        }

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

            yAxisTitle: "hpa"
            xAxisTitle: "Seconds"
            minYValue: 200                    // Default: 0
            maxYValue: 2000                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 60                   // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?
            property string sensorNumber:"0x001"

            property var soilMoistureInfo: platformInterface.receive_notification.data.pressure
            onSoilMoistureInfoChanged:{
                //console.log("new soilMoisture info received for sensor", sensorNumber);
                if (platformInterface.receive_notification.sensor_id === sensorNumber){
                    //console.log("soil moisture graph updated with", platformInterface.receive_notification.stemma.soil);
                    count += interval;
                    stream = platformInterface.receive_notification.data.pressure;
                }
            }

            inputData: stream          // Set the graph's data source here
        }

    }

    Popover{
        id: rssiPopover
        anchors.left: receiver.right
        anchors.bottom:receiver.bottom
        anchors.bottomMargin:receiver.height/2
        width:400
        height:350
        arrowDirection: "left"
        backgroundColor: popoverColor
        closeButtonColor: "#E1E1E1"

        property alias sensorNumber: rssiGraph.sensorNumber
        property alias graphValue: rssiGraph.stream
        onSensorNumberChanged: {
            rssiGraph.reset();
        }

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
            //width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "hpa"
            xAxisTitle: "Seconds"
            minYValue: -120                    // Default: 0
            maxYValue: -30                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 60                   // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?
            property string sensorNumber:"0x001"

            property var rssiInfo: platformInterface.receive_notification
            onRssiInfoChanged:{
                //console.log("new error rate info received ");
                if (platformInterface.receive_notification.sensor_id === sensorNumber){
                    count += interval;
                    stream = platformInterface.receive_notification.rssi
                }
            }

            inputData: stream          // Set the graph's data source here
        }

    }



    Popover{
        id: temperaturePopover
        anchors.right: receiver.left
        anchors.bottom:receiver.bottom
        anchors.bottomMargin: receiver.height/2


        width:400
        height:350
        arrowDirection: "right"
        backgroundColor: popoverColor
        closeButtonColor: "#E1E1E1"

        property alias sensorNumber: temperatureGraph.sensorNumber
        property alias graphValue: temperatureGraph.stream
        onSensorNumberChanged: {
            temperatureGraph.reset();
            //console.log("temperature sensor number changed to",sensorNumber);
        }

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
            maxYValue: 60                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 60                   // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?
            property string sensorNumber:"0x001"

            property var temperatureInfo: platformInterface.receive_notification
            onTemperatureInfoChanged:{
                //console.log("new error rate info received ");
                if (platformInterface.receive_notification.sensor_id === sensorNumber){
                    count += interval;
                    stream = platformInterface.receive_notification.data.temperature
                }
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

        property alias sensorNumber: humidityGraph.sensorNumber
        property alias graphValue: humidityGraph.stream
        onSensorNumberChanged: {
            humidityGraph.reset();
        }

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
            maxXValue: 60                   // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?
            property string sensorNumber:"0x001"

            property var humidityInfo: platformInterface.receive_notification
            onHumidityInfoChanged:{
                //console.log("new error rate info received ");
                if (platformInterface.receive_notification.sensor_id === sensorNumber){
                    count += interval;
                    stream = platformInterface.receive_notification.data.humidity
                }
            }

            inputData: stream          // Set the graph's data source here
        }

    }



}
