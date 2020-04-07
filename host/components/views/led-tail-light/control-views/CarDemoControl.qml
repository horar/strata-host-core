import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/views/led-tail-light/car-lights"


Rectangle {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    color: "black"

    property int transformX:0;
    property int transformY:0;
    ColumnLayout {
        anchors.fill: parent


        Rectangle {
            Layout.preferredHeight: parent.height/1.6
            Layout.preferredWidth: parent.width - 100
            color: "black"
            Layout.alignment: Qt.AlignHCenter


            AnimatedImage {
                id: carImage
                source: "qrc:/views/led-tail-light/car-lights/car-rear-no-lights.jpg"
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.centerIn: parent

            }

        }


        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "grey"

            Image {
                id: carSetting
                source: "carInterior.jpg"
                anchors.fill: parent

                ColumnLayout {
                    width: 50
                    height: 200

                    Rectangle {
                        id: leftLight
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        //anchors.top: parent
                        z:2
                        Image {
                            id: leftArrowImage
                            source: "green-left"
                            anchors.fill: parent
                            z: 3
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Left pressed")
                                    carImage.source = "qrc:/views/led-tail-light/car-lights/car-rear-left-turn.gif"
                                    carImage.playing = true

                                }
                            }
                        }

                    }

                    Rectangle {
                        id: rightLight
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        z:2
                        color: "transparent"
                        Image {
                            id: rightArrowImage
                            source: "yellow_right.jpeg"
                            anchors.fill: parent
                            z: 3
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("right pressed")
                                    carImage.source = "qrc:/views/led-tail-light/car-lights/car-rear-right-turn.gif"
                                    carImage.playing = true

                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }

            }



        }
    }
}
