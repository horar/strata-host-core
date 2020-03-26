import QtQuick 2.9
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

// This is an example debug menu that shows how you can test your UI by injecting
// spoofed notifications to simulate a connected platform board.
//
// It is for development and should be removed from finalized UI's.

Rectangle {
    id: root
    height: 300
    width: 150
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
                text: "Brush notifications"
                onClicked: {
                    var binary = ((Math.random() * 2) >= 1 ? true : false);
                    var current = ((Math.random() *100) +1).toFixed(0) ;
                    var voltage = ((Math.random() *100) +1).toFixed(0) ;
                    var frequency = (Math.random() + .01).toFixed(2);
                    var duty = ((Math.random()*100)).toFixed(0) ;

                    console.log("binary=",binary);
                    console.log("frequency=",frequency);


                    CorePlatformInterface.data_source_handler('{
                                "value":"dc_notification",
                                "payload":{
                                    "Current":'+current+',
                                    "Voltage":'+voltage+'
                                }
                        }')

                    CorePlatformInterface.data_source_handler('{
                                "value":"pwm_frequency_notification",
                                "payload":{
                                    "frequency":'+frequency+'
                                }
                        }')

                    CorePlatformInterface.data_source_handler('{
                           "value":"dc_direction_1_notification",
                           "payload":{
                                "direction":'+(binary ? '"clockwise"' : '"counterclockwise"') +'
                             }
                       }')

                    CorePlatformInterface.data_source_handler('{
                           "value":"dc_direction_2_notification",
                           "payload":{
                                "direction":'+(binary ? '"clockwise"' : '"counterclockwise"') +'
                             }
                       }')

                    CorePlatformInterface.data_source_handler('{
                           "value":"dc_duty_1_notification",
                           "payload":{
                                "duty":'+duty+'
                             }
                       }')

                    CorePlatformInterface.data_source_handler('{
                           "value":"dc_duty_2_notification",
                           "payload":{
                                "duty":'+duty+'
                             }
                       }')


                }
            }

            Button {
                id: motorRunningFalse
                text: "Step Notifications"

                onClicked: {
                    var binary = ((Math.random() * 2) > 1 ? true : false);
                    var current = ((Math.random() *100) +1).toFixed(0) ;
                    var voltage = ((Math.random() *100) +1).toFixed(0) ;
                    var speed = (Math.random()*500).toFixed(0) ;
                    var duration = ((Math.random()*100)).toFixed(0) ;
                    var ternary = (Math.random() * 3);

                    var stepOptions = [".9", "1.8", "3.6", "3.75", "7.5", "15", "18"];
                    var stepOptionsIndex = (Math.random()*stepOptions.length ).toFixed(0);
                    var stepOptionsValue = stepOptions[stepOptionsIndex];


                    CorePlatformInterface.data_source_handler('{
                                "value":"step_notification",
                                "payload":{
                                         "Current": '+current+',
                                         "Voltage": '+voltage+'
                                }
                        }');

                    CorePlatformInterface.data_source_handler('{
                           "value":"step_excitation_notification",
                           "payload":{
                                "excitation":'+(binary ? '"half-step"' : '"full-step"') +'
                             }
                       }');

                    CorePlatformInterface.data_source_handler('{
                           "value":"step_direction_notification",
                           "payload":{
                                "direction":'+(binary ? '"clockwise"' : '"counterclockwise"' )+'
                             }
                       }');

                    CorePlatformInterface.data_source_handler('{
                           "value":"step_angle_notification",
                           "payload":{
                                "angle":'+stepOptionsValue+'
                             }
                       }');


                    CorePlatformInterface.data_source_handler('{
                           "value":"step_speed_notification",
                           "payload":{
                                "speed":'+speed+',
                                "unit":'+(binary ? '"sps"' : '"rpm"' )+'
                             }
                       }');




                    CorePlatformInterface.data_source_handler('{
                           "value":"step_duration_notification",
                           "payload":{
                                "duration":'+duration+',
                                "unit":'+(binary ? '"degrees"' : '"steps"') +'
                             }
                       }');


                }
            }

            Button {
                id: dcPWMMode
                text: "dc mode"

                onClicked: {

                     var binary = ((Math.random() * 2) > 1 ? true : false);

                    console.log("setting dc pwm mode to",binary);
                    CorePlatformInterface.data_source_handler('{
                                "value":"dc_pwm_mode_1_notification",
                                "payload":{
                                         "mode": '+(binary ? '"on_off"' : '"on_brake"') +'
                                }
                        }');


                    CorePlatformInterface.data_source_handler('{
                                "value":"dc_pwm_mode_2_notification",
                                "payload":{
                                         "mode": '+(binary ? '"on_off"' : '"on_brake"') +'
                                }
                        }');
                    }
            }

            Button {
                id: dcMotorState
                text: "dc motor"

                onClicked: {

                    var ternary = ((Math.random() * 2)+1).toFixed(0);

                    console.log("setting dc motors to",ternary);
                    CorePlatformInterface.data_source_handler('{
                                "value":"motor_run_1_notification",
                                "payload":{
                                         "mode": '+ternary+'
                                }
                        }');


                    CorePlatformInterface.data_source_handler('{
                                "value":"motor_run_2_notification",
                                "payload":{
                                         "mode": '+ternary+'
                                }
                        }');
                    }
            }

            Button {
                id: refresh
                text: "refresh"

                onClicked: {
                    console.log("sending refresh request");
                    platformInterface.refresh.send();
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
