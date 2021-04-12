import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

// This is an example debug menu that shows how you can test your UI by injecting
// spoofed notifications to simulate a connected platform board.
//
// It is for development and should be removed from finalized UI's.

Rectangle {
    id: root
    height: 200
    width: 350
    border {
        width: 1
        color: "#fff"
    }

    Item {
        anchors {
            fill: root
            margins: 1
        }
        clip: true

        Column {
            width: parent.width

            Rectangle {
                id: header
                color: "#eee"
                width: parent.width
                height: 40

                Text {
                    text: "Debug"
                    anchors {
                        verticalCenter: header.verticalCenter
                        left: header.left
                        leftMargin: 15
                    }
                }

                Button {
                    text: "X"
                    height: 30
                    width: height
                    onClicked: root.visible = false
                    anchors {
                        right: header.right
                    }
                }
            }

            Button {
                id: motorRunningTrue
                text: "update periodic values"
                onClicked: {

                    var advertisedMinimumCurrent = ((Math.random() *3) +1).toFixed(0) ;
                    var negotiatedCurrent = ((Math.random() *3) +1).toFixed(0) ;
                    var negotiated_voltage = ((Math.random() *20) +1).toFixed(0) ;
                    var input_voltage = (Math.random()*50).toFixed(2);
                    var output_voltage = (Math.random()*50).toFixed(2);
                    var input_current = (Math.random()*3).toFixed(2);
                    var output_current = (Math.random()*12).toFixed(2);
                     var temperature = (Math.random()*100).toFixed(1);
                     var maxPower = ((Math.random() *7)+1).toFixed(0)* 7.5;


//                    console.log("current=",current);
//                    console.log("voltage=",voltage);


                    function randomState(){
                        if (Math.random() >= .2)
                            return "Halted";
                          else if (Math.random() >= .4)
                            return "Ramping up";
                          else if (Math.random() >= .6)
                            return "Ramping down";
                          else if (Math.random() >= .4)
                            return "Running";
                          else
                            return "Stopped";
                    }


//                    var theState = randomState();
//                    console.log("state=",theState);

                    CorePlatformInterface.data_source_handler('{
                                "value":"usb_power_notification",
                                "payload":{
                                    "port": "1",
                                    "device": "PD",
                                    "advertised_maximum_current": '+advertisedMinimumCurrent+',
                                    "negotiated_current": '+negotiatedCurrent+',
                                    "negotiated_voltage": '+negotiated_voltage+',
                                    "input_voltage": '+input_voltage+',
                                    "output_voltage":'+output_voltage+',
                                    "input_current": '+input_current+',
                                    "output_current":'+output_current+',
                                    "temperature": '+temperature+',
                                    "maximum_power":'+maxPower+'
                                }
                        }')

                }
            }



            Button {
                id: port1connect
                text: "connect"
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"usb_pd_port_connect",
                                "payload":{
                                    "port": "1",
                                    "connection_state": "connected"
                                }
                        }')
                }
            }
            Button {
                id: port1Disconnect
                text: "disconnect"
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"usb_pd_port_connect",
                                "payload":{
                                    "port": "1",
                                    "connection_state": "disconnected"
                                }
                        }')
                }
            }


            //max power output
            //over temperature fault hysterisis
            //Fake fault message


            Button {
                id: systemSettings
                text: "system settings"

                onClicked: {
                    var protectionAction = ((Math.random() * 2) >= 1 ? "nothing" : "retry");
                    var currentMaxPower = ((Math.random() *4)+1).toFixed(0)* 15;
                    var minimumVoltage = ((Math.random() *15) +5).toFixed(0) ;
                    var maximumTemperature = ((Math.random() *80) +20).toFixed(0);
                    var inputFoldbackOnOff = ((Math.random() * 2) >= 1 ? true : false);
                    var inputFoldbackMinVoltage = ((Math.random() *15) +5).toFixed(0);
                    var inputFoldbackOutputPower  = ((Math.random() *4)+1).toFixed(0)* 15;
                    var tempFoldbackOnOff = ((Math.random() * 2) >= 1 ? true : false);
                    var tempFoldbackMaxTemperature = ((Math.random() *80) +20).toFixed(0);
                    var tempFoldbackOutputPower = ((Math.random() *4)+1).toFixed(0)* 15;
                    var tempFoldbackHysterisis = ((Math.random() *45)+5).toFixed(0);

                    //console.log("input power=",inputFoldbackOutputPower);
                    //console.log("maxTemp=",tempFoldbackMaxTemperature);
                    //console.log("protectionAction=",protectionAction);

                    CorePlatformInterface.data_source_handler('{
                                "value":"usb_pd_maximum_power",
                                "payload":{
                                    "port":1,
                                    "watts":'+currentMaxPower+'
                                }
                        }')

                    CorePlatformInterface.data_source_handler('{
                                "value":"usb_pd_protection_action",
                                "payload":{
                                    "action": "'+protectionAction+'"
                                }
                        }')

                    CorePlatformInterface.data_source_handler('{
                                "value":"input_under_voltage_notification",
                                "payload":{
                                    "state": "below",
                                    "minimum_voltage":'+minimumVoltage+'
                                }
                        }')
                    CorePlatformInterface.data_source_handler('{
                                "value":"input_under_voltage_notification",
                                "payload":{
                                    "state": "below",
                                    "minimum_voltage":'+minimumVoltage+'
                                }
                        }')
                    CorePlatformInterface.data_source_handler('{
                                "value":"set_maximum_temperature_notification",
                                "payload":{
                                    "maximum_temperature":'+maximumTemperature+'
                                }
                        }')
                    CorePlatformInterface.data_source_handler('{
                                "value":"temperature_hysteresis",
                                "payload":{
                                    "value":'+tempFoldbackHysterisis+'
                                }
                        }')
                    CorePlatformInterface.data_source_handler('{
                                "value":"input_voltage_foldback",
                                "payload":{
                                    "voltage":0,
                                    "min_voltage":'+inputFoldbackMinVoltage+',
                                    "power":'+inputFoldbackOutputPower+',
                                    "enabled":'+inputFoldbackOnOff+',
                                    "active":false
                                }
                        }')
                    CorePlatformInterface.data_source_handler('{
                                "value":"temperature_foldback",
                                "payload":{
                                    "port":1,
                                    "temperature":0,
                                    "max_temperature":'+tempFoldbackMaxTemperature+',
                                    "power":'+tempFoldbackOutputPower+',
                                    "enabled":'+tempFoldbackOnOff+',
                                    "active":true
                                }
                        }')
                    console.log("debug",platformInterface.temperature_foldback.max_temperature);
                }
            }
        }
    }

    Rectangle {
        id: shadow
        anchors.fill: root
        visible: false
    }

    DropShadow {
        anchors.fill: shadow
        radius: 15.0
        samples: 30
        source: shadow
        z: -1
    }
}
