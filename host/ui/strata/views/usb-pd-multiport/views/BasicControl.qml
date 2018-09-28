import QtQuick 2.9
import QtGraphicalEffects 1.0
import "qrc:/views/usb-pd-multiport/sgwidgets"
import "qrc:/views/usb-pd-multiport/views/basic-partial-views"

Item {
    id: root

    property bool debugLayout: false
    property real ratioCalc: root.width / 1200

    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Image {
        id: name
        anchors {
            fill: root
        }
        source: "images/basic-background.png"
    }

    GraphDrawer {
        id: graphDrawer
        z: 10
    }

    PlugAnimation {
        id: port1Animation
        x: 748 * ratioCalc
        y: 63 * ratioCalc
    }

    PlugAnimation {
        id: port2Animation
        x: 748 * ratioCalc
        y: 255 * ratioCalc
    }

    PlugAnimation {
        id: port3Animation
        x: 748 * ratioCalc
        y: 447 * ratioCalc
    }

    PlugAnimation {
        id: port4Animation
        x: 748 * ratioCalc
        y: 639 * ratioCalc
    }

    Item {
        id: inputColumn
        width: 310 * ratioCalc
        height: root.height
        anchors {
            left: root.left
            leftMargin: 80 * ratioCalc
        }

        Rectangle {
            id: combinedPortStats
            color: "#eee"
            anchors {
                top: inputColumn.top
                topMargin: 35 * ratioCalc
                left: inputColumn.left
                right: inputColumn.right
            }
            height: 300 * ratioCalc

            Rectangle{
                id:combinedStatsBackgroundRect
                color:"#ddd"
                anchors.top:combinedPortStats.top
                anchors.left:combinedPortStats.left
                anchors.right:combinedPortStats.right
                height:combinedPortStats.height/6

                Text{
                    id:combinedStatsText
                    text:"COMBINED PORT STATISTICS"
                    font.pixelSize: 17
                    color: "#bbb"
                    anchors.centerIn: combinedStatsBackgroundRect
                }
            }




            PortStatBox {

                property var inputVoltage:platformInterface.request_usb_power_notification.input_voltage;
                property real port1Voltage:0;
                property real port2Voltage:0;
                property real port3Voltage:0;
                property real port4Voltage:0;

                onInputVoltageChanged: {
                     if (platformInterface.request_usb_power_notification.port ===1)
                         port1Voltage = platformInterface.request_usb_power_notification.input_voltage;
                     else if (platformInterface.request_usb_power_notification.port ===2)
                         port2Voltage = platformInterface.request_usb_power_notification.input_voltage;
                     else if (platformInterface.request_usb_power_notification.port ===3)
                         port3Voltage = platformInterface.request_usb_power_notification.input_voltage;
                     else if (platformInterface.request_usb_power_notification.port ===4)
                         port4Voltage = platformInterface.request_usb_power_notification.input_voltage;
                }

                id:combinedInputVoltageBox
                label: "INPUT VOLTAGE"
                value: Math.round((port1Voltage + port2Voltage + port3Voltage + port4Voltage) *100)/100
                valueSize: 32
                icon: "../images/icon-voltage.svg"
                unit: "V"
                anchors.top: combinedStatsBackgroundRect.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: combinedPortStats.horizontalCenter
                height: combinedPortStats.height/5
                width: combinedPortStats.width/2
            }

            PortStatBox {

                property var inputVoltage: platformInterface.request_usb_power_notification.input_voltage;
                property var inputCurrent: platformInterface.request_usb_power_notification.input_current;
                property real inputPower: inputVoltage * inputCurrent;

                property real port1Power:0;

                onInputPowerChanged: {
                    //only check one of the ports for power, since the input power should be the same on all
                    //four ports.
                    if (platformInterface.request_usb_power_notification.port ===1)
                        port1Power = inputPower;
                }

                id:combinedInputPowerBox
                label: "INPUT POWER"
                value: Math.round((port1Power) *100)/100
                valueSize: 32
                icon: "../images/icon-voltage.svg"
                unit: "W"
                anchors.top: combinedInputVoltageBox.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: combinedPortStats.horizontalCenter
                height: combinedPortStats.height/5
                width: combinedPortStats.width/2
                //visible: combinedPortStats.inputPowerConnected
            }
        }

        Rectangle {
            id: inputConversionStats
            color: combinedPortStats.color
            anchors {
                top: combinedPortStats.bottom
                topMargin: 20 * ratioCalc
                left: inputColumn.left
                right: inputColumn.right
            }
            height: 428 * ratioCalc

            property bool inputPowerConnected: true

            Rectangle{
                id:topBackgroundRect
                color:"#ddd"
                anchors.top:inputConversionStats.top
                anchors.left:inputConversionStats.left
                anchors.right:inputConversionStats.right
                height:inputConversionStats.height/6
            }

            Text{
                id:powerConverterText
                text:"POWER CONVERTER"
                font.pixelSize: 17
                color: "#bbb"
                anchors.top: inputConversionStats.top
                anchors.topMargin:10
                anchors.horizontalCenter: inputConversionStats.horizontalCenter
            }

            Text{
                id:converterNameText
                text:"ON Semiconductor NCP4060A"
                visible: inputConversionStats.inputPowerConnected
                font.pixelSize: 20
                //color: "#bbb"
                anchors.top: powerConverterText.bottom
                anchors.horizontalCenter: inputConversionStats.horizontalCenter
            }

            PortStatBox {
                id:maxPowerBox
                label: "MAX CAPACITY"
                value: "200"
                icon: "../images/icon-max.svg"
                //portColor: root.portColor
                valueSize: 32
                unit: "W"
                anchors.top: topBackgroundRect.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: inputConversionStats.horizontalCenter
                height: inputConversionStats.height/8
                width: inputConversionStats.width/2
                visible: inputConversionStats.inputPowerConnected
            }

            PortStatBox {
                id:voltageOutBox
                label: "VOLTAGE OUTPUT"
                value: "100"
                icon: "../images/icon-voltage.svg"
                //portColor: root.portColor
                valueSize: 32
                unit: "V"
                anchors.top: maxPowerBox.bottom
                anchors.topMargin: 20
                anchors.horizontalCenter: inputConversionStats.horizontalCenter
                height: inputConversionStats.height/8
                width: inputConversionStats.width/2
                visible: inputConversionStats.inputPowerConnected
            }

            Image{
                id:powerConverterIcon
                source:"./images/powerconverter.png"
                opacity:.5
                fillMode:Image.PreserveAspectFit
                anchors.top:voltageOutBox.bottom
                anchors.topMargin:40
                anchors.bottom:inputConversionStats.bottom
                anchors.bottomMargin:40
                anchors.left:inputConversionStats.left
                anchors.right: inputConversionStats.right
            }



        }

        SGLayoutDebug {
            visible: debugLayout
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
            height: 172 * ratioCalc
            anchors {
                top: portColumn.top
                topMargin: 35 * ratioCalc
                left: portColumn.left
                right: portColumn.right
            }
            portConnected: false
            portNumber: 1
            advertisedVoltage:{
                if (platformInterface.request_usb_power_notification.port === 1){
                    return platformInterface.request_usb_power_notification.negotiated_voltage
                }
                else{
                    return portInfo1.advertisedVoltage;
                }
            }
            maxPower:{
                if (platformInterface.request_usb_power_notification.port === 1){
                   return Math.round(platformInterface.request_usb_power_notification.maximum_power *100)/100
                }
                else{
                    return portInfo1.maxPower;
                }
            }
            inputPower:{
                if (platformInterface.request_usb_power_notification.port === 1){
                    return Math.round(platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current * 100)/100
                }
                else{
                    return portInfo1.inputPower;
                }
            }
            outputPower:{
                if (platformInterface.request_usb_power_notification.port === 1){
                    return Math.round(platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current * 100)/100
                }
                else{
                    return portInfo1.outputPower;
                }
            }
            outputVoltage:{
                if (platformInterface.request_usb_power_notification.port === 1){
                    return Math.round(platformInterface.request_usb_power_notification.output_voltage *100)/100
                }
                else{
                    return portInfo1.outputVoltage;
                }
            }
            portTemperature:{
                if (platformInterface.request_usb_power_notification.port === 1){
                    return Math.round(platformInterface.request_usb_power_notification.temperature*10)/10
                }
                else{
                    return portInfo1.portTemperature;
                }
            }
            efficency: {
                var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current;
                var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

                if (platformInterface.request_usb_power_notification.port === 1){
                    if (theInputPower == 0){    //division by 0 would normally give "nan"
                        return "—"
                    }
                    else{
                        return "—"
                        //return Math.round((theOutputPower/theInputPower) * 100)/100
                    }
                }
                else{
                    return portInfo1.efficency;
                }
            }

            property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
            property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

             onDeviceConnectedChanged: {
//                 console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
//                             "state=",platformInterface.usb_pd_port_connect.connection_state);

                 if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_1"){
                     if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                         portInfo1.portConnected = true;
                     }
                 }
             }

             onDeviceDisconnectedChanged:{

                 if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_1"){
                     if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                         portInfo1.portConnected = false;
                     }
                 }
            }

            onShowGraph: {
                graphDrawer.portNumber = portNumber;
                graphDrawer.open();
            }
        }

        PortInfo {
            id: portInfo2
            height: portInfo1.height
            anchors {
                top: portInfo1.bottom
                topMargin: 20 * ratioCalc
                left: portColumn.left
                right: portColumn.right
            }
            portNumber: 2
            portConnected: false
            advertisedVoltage:{
                if (platformInterface.request_usb_power_notification.port === 2){
                    return platformInterface.request_usb_power_notification.negotiated_voltage
                }
                else{
                    return portInfo2.advertisedVoltage;
                }
            }
            maxPower:{
                if (platformInterface.request_usb_power_notification.port === 2){
                    return Math.round(platformInterface.request_usb_power_notification.maximum_power *100)/100
                }
                else{
                    return portInfo2.maxPower;
                }
            }
            inputPower:{
                if (platformInterface.request_usb_power_notification.port === 2){
                    return Math.round(platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current *100)/100
                }
                else{
                    return portInfo2.inputPower;
                }
            }
            outputPower:{
                if (platformInterface.request_usb_power_notification.port === 2){
                    return Math.round(platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current *100)/100
                }
                else{
                    return portInfo2.outputPower;
                }
            }
            outputVoltage:{
                if (platformInterface.request_usb_power_notification.port === 2){
                    return Math.round(platformInterface.request_usb_power_notification.output_voltage *100)/100
                }
                else{
                    return portInfo2.outputVoltage;
                }
            }
            portTemperature:{
                if (platformInterface.request_usb_power_notification.port === 2){
                    return Math.round(platformInterface.request_usb_power_notification.temperature*10)/10;
                }
                else{
                    return portInfo2.portTemperature;
                }
            }
            efficency: {
                var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current;
                var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current

                if (platformInterface.request_usb_power_notification.port === 2){
                    if (theInputPower == 0){    //division by 0 would normally give "nan"
                        return "—"
                    }
                    else{
                        return "—"
                        //return Math.round((theOutputPower/theInputPower) *100)/100
                    }
                }
                else{
                    return portInfo2.efficency
                }
            }

            property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
            property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

             onDeviceConnectedChanged: {
//                 console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
//                             "state=",platformInterface.usb_pd_port_connect.connection_state);

                 if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_2"){
                     if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                         portInfo2.portConnected = true;
                     }
                 }
             }

             onDeviceDisconnectedChanged:{

                 if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_2"){
                     if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                         portInfo2.portConnected = false;
                     }
                 }
            }

            onShowGraph: {
                graphDrawer.portNumber = portNumber;
                graphDrawer.open();
            }
        }

        PortInfo {
            id: portInfo3
            height: portInfo1.height
            anchors {
                top: portInfo2.bottom
                topMargin: 20 * ratioCalc
                left: portColumn.left
                right: portColumn.right
            }
            portNumber: 3
            portConnected: false
            advertisedVoltage:{
                if (platformInterface.request_usb_power_notification.port === 3){
                    return platformInterface.request_usb_power_notification.negotiated_voltage
                }
                else{
                    return portInfo3.advertisedVoltage;
                }
                }
            maxPower:{
                if (platformInterface.request_usb_power_notification.port === 3){
                    return Math.round(platformInterface.request_usb_power_notification.maximum_power *100)/100
                }
                else{
                    return portInfo3.maxPower;
                }
            }
            inputPower:{
                if (platformInterface.request_usb_power_notification.port === 3){
                    return Math.round(platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current *100)/100
                }
                else{
                    return portInfo3.inputPower;
                }
            }
            outputPower:{
                if (platformInterface.request_usb_power_notification.port === 3){
                    return Math.round(platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current *100)/100
                }
                else{
                    return portInfo3.outputPower;
                }
            }
            outputVoltage:{
                if (platformInterface.request_usb_power_notification.port === 3){
                    return Math.round(platformInterface.request_usb_power_notification.output_voltage *100)/100
                }
                else{
                    return portInfo3.outputVoltage;
                }
            }
            portTemperature:{
                if (platformInterface.request_usb_power_notification.port === 3){
                    return Math.round(platformInterface.request_usb_power_notification.temperature*10)/10;
                }
                else{
                    return portInfo3.portTemperature;
                }
            }
            efficency: {
                var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current;
                var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current

                if (platformInterface.request_usb_power_notification.port === 3){
                    if (theInputPower == 0){    //division by 0 would normally give "nan"
                        return "—"
                    }
                    else{
                        //return Math.round((theOutputPower/theInputPower) *100)/100
                        return "—"
                    }
                }
                else{
                  return portInfo3.efficency;
                    }
            }

            property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
            property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

             onDeviceConnectedChanged: {
//                 console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
//                             "state=",platformInterface.usb_pd_port_connect.connection_state);

                 if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_3"){
                     if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                         portInfo3.portConnected = true;
                     }
                 }
             }

             onDeviceDisconnectedChanged:{

                 if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_3"){
                     if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                         portInfo3.portConnected = false;
                     }
                 }
            }
            onShowGraph: {
                graphDrawer.portNumber = portNumber;
                graphDrawer.open();
            }
        }

        PortInfo {
            id: portInfo4
            height: portInfo1.height
            anchors {
                top: portInfo3.bottom
                topMargin: 20 * ratioCalc
                left: portColumn.left
                right: portColumn.right
            }
            portNumber: 4
            portConnected: false
            advertisedVoltage:{
                if (platformInterface.request_usb_power_notification.port === 4){
                    return platformInterface.request_usb_power_notification.negotiated_voltage;
                }
                else{
                   return portInfo4.advertisedVoltage;
                }
            }
            maxPower:{
                if (platformInterface.request_usb_power_notification.port === 4){
                    return Math.round(platformInterface.request_usb_power_notification.maximum_power *100)/100
                }
                else{
                    return portInfo4.maxPower;
                }
            }
            inputPower:{
                if (platformInterface.request_usb_power_notification.port === 4){
                    return Math.round(platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current *100)/100
                }
                else{
                   return portInfo4.inputPower;
                }
            }
            outputPower:{
                if (platformInterface.request_usb_power_notification.port === 4){
                    return Math.round(platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current *100)/100
                }
                else{
                   return portInfo4.outputPower;
                }
            }
            outputVoltage:{
                if (platformInterface.request_usb_power_notification.port === 4){
                    return Math.round(platformInterface.request_usb_power_notification.output_voltage *100)/100
                }
                else{
                   return portInfo4.outputVoltage;
                }
            }
            portTemperature:{
                if (platformInterface.request_usb_power_notification.port === 4){
                    return Math.round(platformInterface.request_usb_power_notification.temperature*10)/10;
                }
                else{
                   return portInfo4.portTemperature;
                }
            }
            efficency: {
                var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current;
                var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current

                if (platformInterface.request_usb_power_notification.port === 4)
                    if (theInputPower == 0){    //division by 0 would normally give "nan"
                        return "—"
                    }
                    else{
                        //return Math.round((theOutputPower/theInputPower) *100)/100
                        return "—"
                    }
                else{
                    return portInfo4.efficency;
                }
            }

            property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
            property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

             onDeviceConnectedChanged: {
//                 console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
//                             "state=",platformInterface.usb_pd_port_connect.connection_state);

                 if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_4"){
                     if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                         portInfo4.portConnected = true;
                     }
                 }
             }

             onDeviceDisconnectedChanged:{

                 if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_4"){
                     if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                         portInfo4.portConnected = false;
                     }
                 }
            }

            onShowGraph: {
                graphDrawer.portNumber = portNumber;
                graphDrawer.open();
            }
        }

        SGLayoutDebug {
            visible: debugLayout
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
                right: deviceColumn.right
            }

            width: parent.width - (100 * ratioCalc)
            spacing: 20 * ratioCalc

            DeviceInfo {
                height: portInfo1.height
                width: parent.width

                MouseArea {
                    anchors {
                        fill: parent
                    }

                    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                    property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                     onDeviceConnectedChanged: {
                         //console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
                         //            "state=",platformInterface.usb_pd_port_connect.connection_state);

                         if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_1"){
                             if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                                 port1Animation.source = "images/cord.gif"
                                 port1Animation.currentFrame = 0
                                 port1Animation.playing = true
                                 port1Animation.pluggedIn = !port1Animation.pluggedIn
                             }
                         }
                     }

                     onDeviceDisconnectedChanged:{

                         if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_1"){
                             if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                                 port1Animation.source = "images/cordReverse.gif"
                                 port1Animation.currentFrame = 0
                                 port1Animation.playing = true
                                 port1Animation.pluggedIn = !port1Animation.pluggedIn
                             }
                         }
                    }

                    onClicked: {
                        if (!port1Animation.pluggedIn) {
                            port1Animation.source = "images/cord.gif"
                            port1Animation.currentFrame = 0
                            port1Animation.playing = true
                            port1Animation.pluggedIn = !port1Animation.pluggedIn
                        } else {
                            port1Animation.source = "images/cordReverse.gif"
                            port1Animation.currentFrame = 0
                            port1Animation.playing = true
                            port1Animation.pluggedIn = !port1Animation.pluggedIn
                        }
                    }
                }
            }

            DeviceInfo {
                height: portInfo1.height
                width: parent.width

                MouseArea {
                    anchors {
                        fill: parent
                    }

                    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                    property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                     onDeviceConnectedChanged: {
                         //console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
                         //            "state=",platformInterface.usb_pd_port_connect.connection_state);

                         if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_2"){
                             if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                                 port2Animation.source = "images/cord.gif"
                                 port2Animation.currentFrame = 0
                                 port2Animation.playing = true
                                 port2Animation.pluggedIn = !port2Animation.pluggedIn
                             }
                         }
                     }

                     onDeviceDisconnectedChanged:{
                         //console.log("device disconnected message received in basicControl. Port=",platformInterface.usb_pd_port_disconnect.port_id,
                          //           "state=",platformInterface.usb_pd_port_disconnect.connection_state);

                         if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_2"){
                             if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                                 port2Animation.source = "images/cordReverse.gif"
                                 port2Animation.currentFrame = 0
                                 port2Animation.playing = true
                                 port2Animation.pluggedIn = !port2Animation.pluggedIn
                             }
                         }
                    }
                    onClicked: {
                        if (!port2Animation.pluggedIn) {
                            port2Animation.source = "images/cord.gif"
                            port2Animation.currentFrame = 0
                            port2Animation.playing = true
                            port2Animation.pluggedIn = !port2Animation.pluggedIn
                        } else {
                            port2Animation.source = "images/cordReverse.gif"
                            port2Animation.currentFrame = 0
                            port2Animation.playing = true
                            port2Animation.pluggedIn = !port2Animation.pluggedIn
                        }
                    }
                }
            }

            DeviceInfo {
                height: portInfo1.height
                width: parent.width

                MouseArea {
                    anchors {
                        fill: parent
                    }

                    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                    property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                     onDeviceConnectedChanged: {
                         //console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
                         //            "state=",platformInterface.usb_pd_port_connect.connection_state);

                         if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_3"){
                             if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                                 port3Animation.source = "images/cord.gif"
                                 port3Animation.currentFrame = 0
                                 port3Animation.playing = true
                                 port3Animation.pluggedIn = !port3Animation.pluggedIn
                             }
                         }
                     }

                     onDeviceDisconnectedChanged:{
                         //console.log("device disconnected message received in basicControl. Port=",platformInterface.usb_pd_port_disconnect.port_id,
                          //           "state=",platformInterface.usb_pd_port_disconnect.connection_state);

                         if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_3"){
                             if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                                 port3Animation.source = "images/cordReverse.gif"
                                 port3Animation.currentFrame = 0
                                 port3Animation.playing = true
                                 port3Animation.pluggedIn = !port3Animation.pluggedIn
                             }
                         }
                    }
                    onClicked: {
                        if (!port3Animation.pluggedIn) {
                            port3Animation.source = "images/cord.gif"
                            port3Animation.currentFrame = 0
                            port3Animation.playing = true
                            port3Animation.pluggedIn = !port3Animation.pluggedIn
                        } else {
                            port3Animation.source = "images/cordReverse.gif"
                            port3Animation.currentFrame = 0
                            port3Animation.playing = true
                            port3Animation.pluggedIn = !port3Animation.pluggedIn
                        }
                    }
                }
            }

            DeviceInfo {
                height: portInfo1.height
                width: parent.width

                MouseArea {
                    anchors {
                        fill: parent
                    }

                    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                    property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                     onDeviceConnectedChanged: {
                         //console.log("device connected message received in basicControl. Port=",platformInterface.usb_pd_port_connect.port_id,
                         //            "state=",platformInterface.usb_pd_port_connect.connection_state);

                         if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_4"){
                             if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                                 port4Animation.source = "images/cord.gif"
                                 port4Animation.currentFrame = 0
                                 port4Animation.playing = true
                                 port4Animation.pluggedIn = !port4Animation.pluggedIn
                             }
                         }
                     }

                     onDeviceDisconnectedChanged:{
                         //console.log("device disconnected message received in basicControl. Port=",platformInterface.usb_pd_port_disconnect.port_id,
                         //            "state=",platformInterface.usb_pd_port_disconnect.connection_state);

                         if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_4"){
                             if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                                 port4Animation.source = "images/cordReverse.gif"
                                 port4Animation.currentFrame = 0
                                 port4Animation.playing = true
                                 port4Animation.pluggedIn = !port4Animation.pluggedIn
                             }
                         }
                    }
                    onClicked: {
                        if (!port4Animation.pluggedIn) {
                            port4Animation.source = "images/cord.gif"
                            port4Animation.currentFrame = 0
                            port4Animation.playing = true
                            port4Animation.pluggedIn = !port4Animation.pluggedIn
                        } else {
                            port4Animation.source = "images/cordReverse.gif"
                            port4Animation.currentFrame = 0
                            port4Animation.playing = true
                            port4Animation.pluggedIn = !port4Animation.pluggedIn
                        }
                    }
                }
            }
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }
}
