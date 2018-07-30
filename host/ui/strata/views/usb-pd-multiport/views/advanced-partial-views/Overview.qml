import QtQuick 2.9
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: root
    width: parent.width

    Item{
        id: leftColumn
        anchors {
            left: root.left
            top: root.top
            right: rightColumn.left
            bottom: root.bottom
        }

        Item {
            id: margins
            anchors {
                fill: parent
                margins: 15
            }

            SGCapacityBar {
                id: capacityBar
                width: margins.width
                labelLeft: false
                barWidth: margins.width
                maximumValue: 200
                showThreshold: true
                thresholdValue: 180

                gaugeElements: Row {
                    id: container
                    property real totalValue: childrenRect.width // Necessary for over threshold detection signal

                    SGCapacityBarElement{
                        id: port1BarElement
                        color: miniInfo1.portColor
                        value: {
                            if (platformInterface.request_usb_power_notification.port === 1){
                                return platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current
                            }
                            else{
                               return port1BarElement.value;
                            }
                        }
                    }

                    SGCapacityBarElement{
                        id: port2BarElement
                        color: miniInfo2.portColor
                        value: {
                            if (platformInterface.request_usb_power_notification.port === 2){
                                return platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current
                            }
                            else{
                               return port2BarElement.value;
                            }
                        }
                    }

                    SGCapacityBarElement{
                        id: port3BarElement
                        color: miniInfo3.portColor
                        value: {
                            if (platformInterface.request_usb_power_notification.port === 3){
                                return platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current
                            }
                            else{
                               return port3BarElement.value;
                            }
                        }
                    }

                    SGCapacityBarElement{
                        id: port4BarElement
                        color: miniInfo4.portColor
                        value: {
                            if (platformInterface.request_usb_power_notification.port === 4){
                                return platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current
                            }
                            else{
                               return port4BarElement.value;
                            }
                        }
                    }
                }
            }

            PortInfoMini {
                id: miniInfo1
                portNum: 1
                anchors {
                    top: capacityBar.bottom
                    topMargin: 10
                    left: margins.left
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                portColor: "#4eafe0"

                property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
                property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state

                onDeviceConnectedChanged: {
                    if (platformInterface.usb_pd_port_connect.port_id === "USB_C_port_1"){
                        if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                            miniInfo1.portConnected = true;
                        }
                    }
                }

                onDeviceDisconnectedChanged: {
                    if (platformInterface.usb_pd_port_disconnect.port_id === "USB_C_port_1"){
                        if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                            miniInfo1.portConnected = false;
                        }

                    }
                }

                negotiatedVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 1){
                        return platformInterface.request_usb_power_notification.negotiated_voltage
                    }
                    else{
                        return miniInfo1.negotiatedVoltage;
                    }
                }
                maxPower:{
                    if (platformInterface.request_usb_power_notification.port === 1){
                       return Math.round(platformInterface.request_usb_power_notification.negotiated_voltage * platformInterface.request_usb_power_notification.negotiated_current *100)/100
                    }
                    else{
                        return miniInfo1.maxPower;
                    }
                }
                inputPower: {
                    if (platformInterface.request_usb_power_notification.port === 1){
                        return platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current
                    }
                    else{
                        return miniInfo1.inputPower;
                    }
                }
                outputVoltage:{
                    if (platformInterface.request_usb_power_notification.port === 1){
                        return Math.round(platformInterface.request_usb_power_notification.output_voltage *100)/100
                    }
                    else{
                        return miniInfo1.outputVoltage;
                    }
                }
                portTemperature:{
                    if (platformInterface.request_usb_power_notification.port === 1){
                        return platformInterface.request_usb_power_notification.temperature
                    }
                    else{
                        return miniInfo1.portTemperature;
                    }
                }
                outputPower: {
                    if (platformInterface.request_usb_power_notification.port === 1){
                        return platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current
                    }
                    else{
                        return miniInfo1.outputPower;
                    }
                }
                portEfficency: {
                    var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current;
                    var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

                    if (platformInterface.request_usb_power_notification.port === 1){
                        if (theInputPower == 0){    //division by 0 would normally give "nan"
                            return "—"
                        }
                        else{
                            return theOutputPower/theInputPower
                        }
                    }
                    else{
                        return miniInfo1.portEfficency;
                    }
                }

            }

            PortInfoMini {
                id: miniInfo2
                portNum: 2
                anchors {
                    top: capacityBar.bottom
                    topMargin: 10
                    left: miniInfo1.right
                    leftMargin: 20
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                portColor: "#69db67"
            }

            PortInfoMini {
                id: miniInfo3
                portNum: 3
                anchors {
                    top: capacityBar.bottom
                    topMargin: 10
                    left: miniInfo2.right
                    leftMargin: 20
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                portColor: "#e09a69"
            }

            PortInfoMini {
                id: miniInfo4
                portNum: 4
                anchors {
                    top: capacityBar.bottom
                    topMargin: 10
                    left: miniInfo3.right
                    leftMargin: 20
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                portConnected: false
            }
        }
    }

    Item{
        id: rightColumn
        anchors {
            right: root.right
            top: root.top
            bottom: root.bottom
        }
        width: root.width/3

        SGStatusListBox {
            id: currentFaults
            height: rightColumn.height/2
            width: rightColumn.width
            title: "Current Faults:"
        }

        SGOutputLogBox {
            id: faultHistory
            height: rightColumn.height/2
            anchors {
                top: currentFaults.bottom
            }
            width: rightColumn.width
            title: "Fault History:"
        }
    }
}
