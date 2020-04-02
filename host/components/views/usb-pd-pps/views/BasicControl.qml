import QtQuick 2.9
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09
import "basic-partial-views/"

Item {
    id: root

    property bool debugLayout: false
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Image {
        id: name
        anchors {
            fill: root
        }
        source: "./images/basic-onePortBackground.png"
    }

    Component.onCompleted: {
        //console.log("finished loading Basic Controls for usb-pd-pps")
    }

    GraphDrawer {
        id: graphDrawer
        z: 10
    }

    PlugAnimation {
        id: port1Animation
        x: 918 * ratioCalc
        y: 350 * ratioCalc
    }



    Item {
        id: inputColumn
        width: 310 * ratioCalc
        height: root.height
        anchors {
            left: root.left
            leftMargin: 230 * ratioCalc
        }

        Rectangle {
            id: combinedPortStats
            color: "#eee"
            anchors {
                top: inputColumn.top
                topMargin: 260 * ratioCalc
                left: inputColumn.left
                right: inputColumn.right
            }
            height: 299 * ratioCalc

            Rectangle{
                id:combinedStatsBackgroundRect
                color:"#ddd"
                anchors.top:combinedPortStats.top
                anchors.left:combinedPortStats.left
                anchors.right:combinedPortStats.right
                height:combinedPortStats.height/6
                visible:false

                Text{
                    id:combinedStatsText
                    text:"COMBINED PORT STATISTICS"
                    font.pixelSize: 17
                    color: "#bbb"
                    anchors.centerIn: combinedStatsBackgroundRect
                }
            }




            PortStatBox {
                property var inputVoltage: Math.trunc(platformInterface.usb_power_notification.input_voltage *100)/100;
                property real portVoltage: 0

                onInputVoltageChanged: {
                    portVoltage = platformInterface.usb_power_notification.input_voltage;
                }

                id:combinedInputVoltageBox
                label: "INPUT VOLTAGE"
                value: {
                    if (portVoltage != 0)
                        return inputVoltage
                    else
                        return "0.00"
                }
                valueSize: 48
                icon: "../images/icon-voltage.svg"
                unit: "V"
                anchors.top: combinedStatsBackgroundRect.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: combinedPortStats.horizontalCenter
                height: combinedPortStats.height/5
                width: combinedPortStats.width*.60
            }

            PortStatBox {
                id:combinedInputPowerBox

                property real inputVoltage: platformInterface.usb_power_notification.input_voltage;
                //property real inputCurrent: platformInterface.usb_power_notification.input_current;
                property real port1Power:0;
                property real port2Power:0;

//                onInputCurrentChanged:{
//                    //console.log("port",platformInterface.usb_power_notification.port,"input Current=",inputCurrent);
//                    if (platformInterface.usb_power_notification.port === 1){
//                        //console.log("input voltage=",inputVoltage,"input Current=",inputCurrent, "input Power=",inputPower);
//                        combinedInputPowerBox.port1Power = combinedInputPowerBox.inputVoltage * combinedInputPowerBox.inputCurrent;
//                    }
//                    else if (platformInterface.usb_power_notification.port === 2){
//                        combinedInputPowerBox.port2Power = combinedInputPowerBox.inputVoltage * combinedInputPowerBox.inputCurrent;
//                    }
//                    //console.log("port1Power=",combinedInputPowerBox.port1Power,"port2Power=",combinedInputPowerBox.port2Power);
//                }

                property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state

                onDeviceConnectedChanged:{

                    if (platformInterface.usb_pd_port_connect.port_id === "1"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "disconnected"){
                            combinedInputPowerBox.port1Power = 0;
                        }
                    }
                    else if (platformInterface.usb_pd_port_connect.port_id === "2"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "disconnected"){
                            combinedInputPowerBox.port2Power = 0;
                        }
                    }
                }

                label: "INPUT POWER"
                value: (combinedInputPowerBox.port1Power + combinedInputPowerBox.port2Power).toFixed(2)
                valueSize: 32
                icon: "../images/icon-voltage.svg"
                unit: "W"
                anchors.top: combinedInputVoltageBox.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: combinedPortStats.horizontalCenter
                height: combinedPortStats.height/5
                width: combinedPortStats.width/2
                visible: false
            }
        }

    }

    Item {
        id: portColumn
        width: 330 * ratioCalc
        height: root.height
        anchors {
            left: inputColumn.right
            leftMargin: 20 * ratioCalc
        }

        PortInfo {
            id: portInfo1
            height: 364 * ratioCalc
            anchors {
                top: portColumn.top
                topMargin: 225 * ratioCalc
                left: portColumn.left
                leftMargin:10
                right: portColumn.right
            }
            portConnected: false
            portNumber: 1
            advertisedVoltage:{
                if (platformInterface.usb_power_notification.port === "1"){
                    return platformInterface.usb_power_notification.negotiated_voltage
                }
                else{
                    return portInfo1.advertisedVoltage;
                }
            }
            pdContract:{
                if (platformInterface.usb_power_notification.port === "1"){
                    return (platformInterface.usb_power_notification.negotiated_current * platformInterface.usb_power_notification.negotiated_voltage);
                }
                else{
                    return portInfo1.pdContract;
                }
            }
//            inputPower:{
//                if (platformInterface.usb_power_notification.port === 1){
//                    return (platformInterface.usb_power_notification.input_voltage * platformInterface.usb_power_notification.input_current).toFixed(2);
//                }
//                else{
//                    return portInfo1.inputPower;
//                }
//            }
            outputPower:{
                if (platformInterface.usb_power_notification.port === "1"){
                    return (platformInterface.usb_power_notification.output_voltage * platformInterface.usb_power_notification.output_current).toFixed(2);
                }
                else{
                    return portInfo1.outputPower;
                }
            }
            outputVoltage:{
                if (platformInterface.usb_power_notification.port === "1"){
                    return (Math.trunc(platformInterface.usb_power_notification.output_voltage*100))/100;
                }
                else{
                    return portInfo1.outputVoltage;
                }
            }
            portTemperature:{
                if (platformInterface.usb_power_notification.port === "1"){
                    return (Math.trunc(platformInterface.usb_power_notification.temperature*100)/100);
                }
                else{
                    return portInfo1.portTemperature;
                }
            }
            //            efficency: {
            //                var theInputPower = platformInterface.usb_power_notification.input_voltage * platformInterface.usb_power_notification.input_current;
            //                var theOutputPower = platformInterface.usb_power_notification.output_voltage * platformInterface.usb_power_notification.output_current;

            //                if (platformInterface.usb_power_notification.port === 1){
            //                    if (theInputPower == 0){    //division by 0 would normally give "nan"
            //                        return "—"
            //                    }
            //                    else{
            //                        return "—"
            //                        //return Math.round((theOutputPower/theInputPower) * 100)/100
            //                    }
            //                }
            //                else{
            //                    return portInfo1.efficency;
            //                }
            //            }

            property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state

            onDeviceConnectedChanged: {
                //                 console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port,
                //                             "state=",platformInterface.usb_pd_port_connect.connection_state);

                if (platformInterface.usb_pd_port_connect.port === "1"){
                    if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                        portInfo1.portConnected = true;
                    }
                    else if (platformInterface.usb_pd_port_connect.connection_state === "disconnected"){
                        portInfo1.portConnected = false;
                    }
                }
            }

            onShowGraph: {
                graphDrawer.portNumber = portNumber;
                graphDrawer.open();
            }
        }




    }

    Item {
        id: deviceColumn
        width: 280 * ratioCalc
        height: root.height
        anchors {
            left: portColumn.right
            leftMargin: 160 * ratioCalc
        }

        Column {
            anchors {
                top: deviceColumn.top
                topMargin: 35 * ratioCalc
                //topMargin: 500 * ratioCalc
                right: deviceColumn.right
            }

            width: parent.width - (100 * ratioCalc)
            spacing: 20 * ratioCalc


            DeviceInfo {
                //note that the placement of the plugs is really controlled by the PlugAnimation above
                height: portInfo1.height
                width: parent.width

                MouseArea {
                    anchors {
                        fill: parent
                    }

                    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state

                    onDeviceConnectedChanged: {
                        //console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port,
                        //            "state=",platformInterface.usb_pd_port_connect.connection_state);

                        if (platformInterface.usb_pd_port_connect.port === "1"){
                            if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                                port1Animation.source = "images/USBCAnim.gif"
                                port1Animation.currentFrame = 0
                                port1Animation.playing = true
                                port1Animation.pluggedIn = !port1Animation.pluggedIn
                            }
                            else if (platformInterface.usb_pd_port_connect.connection_state === "disconnected"){
                                port1Animation.source = "images/USBCAnimReverse.gif"
                                port1Animation.currentFrame = 0
                                port1Animation.playing = true
                                port1Animation.pluggedIn = !port1Animation.pluggedIn
                            }
                        }
                    }

                    //                    onClicked: {
                    //                        if (!port1Animation.pluggedIn) {
                    //                            port1Animation.source = "images/cord.gif"
                    //                            port1Animation.currentFrame = 0
                    //                            port1Animation.playing = true
                    //                            port1Animation.pluggedIn = !port1Animation.pluggedIn
                    //                        } else {
                    //                            port1Animation.source = "images/cordReverse.gif"
                    //                            port1Animation.currentFrame = 0
                    //                            port1Animation.playing = true
                    //                            port1Animation.pluggedIn = !port1Animation.pluggedIn
                    //                        }
                    //                    }
                }
            }


        }

    }
}
