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
                    var direction = ((Math.random() * 2) >= 1 ? "clockwise" : "anti-clockwise");
                    var current = ((Math.random() *100) +1).toFixed(0) ;
                    var voltage = ((Math.random() *100) +1).toFixed(0) ;
                    var rpm = (Math.random()*2000).toFixed(0);

                    console.log("current=",current);
                    console.log("voltage=",voltage);


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

                    function randomColor(){
                        if (Math.random() >= .2)
                            return "red";
                          else if (Math.random() >= .4)
                            return "blue";
                          else if (Math.random() >= .6)
                            return "green";
                          else if (Math.random() >= .4)
                            return "gold";
                          else
                            return "purple";
                    }

                    var theState = randomState();
                    console.log("state=",theState);

                    CorePlatformInterface.data_source_handler('{
                                "value":"link_voltage",
                                "payload":{
                                         "link_v": ' +voltage+ '
                                }
                        }')

                    CorePlatformInterface.data_source_handler('{
                                "value":"phase_current",
                                "payload":{
                                         "p_current": '+current+ '
                                }
                        }')

                    CorePlatformInterface.data_source_handler('{
                                "value":"target_speed",
                                "payload":{
                                         "rpm": ' + rpm + '
                                }
                        }')

                    CorePlatformInterface.data_source_handler('{
                                "value":"direction",
                                "payload":{
                                         "direction": "' + direction + '"
                                }
                        }')

                    CorePlatformInterface.data_source_handler('{
                                "value":"state",
                                "payload":{
                                         "M_state": "' + randomState() + '",
                                        "Statecolor":"' + randomColor() + '"
                                }
                        }')
                }
            }



            Button {
                id: motorSpeed
                text: "motor speed"
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"speed",
                                "payload":{
                                         "rpm": ' + (Math.random()*2000).toFixed(0) + '
                                }
                        }')
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
