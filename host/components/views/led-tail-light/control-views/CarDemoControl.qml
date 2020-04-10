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
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    property int transformX:0;
    property int transformY:0;
    RowLayout {
        anchors.fill: parent


        Rectangle {
            Layout.preferredHeight: parent.height/1.5
            Layout.preferredWidth: parent.width/2
            //            Layout.preferredHeight: parent.height/1.6
            //            Layout.preferredWidth: parent.width - 100
            color: "red"
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
            color: "black"



            Image {
                id: carSetting
                source: "tesla-dash.jpg"
                width: 500
                height: 300
                anchors.centerIn: parent
                anchors.top:parent.top
                anchors.bottom: parent.bottom
                Rectangle {
                    width: 170
                    height: 80
                    anchors.right: parent.right
                    anchors.rightMargin: 40
                    anchors.verticalCenter: parent.verticalCenter

                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            RowLayout {
                                anchors.fill: parent
                                spacing: 10

                                Rectangle {
                                    id: leftLight
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "transparent"

                                    Image {
                                        id: leftArrowImage
                                        source: "leftArrow.jpg"
                                        anchors.fill: parent
                                        anchors.top:parent.top
                                        //  anchors.topMargin: 5


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
                                    //   z:2
                                    color: "transparent"
                                    Image {
                                        id: rightArrowImage
                                        source: "rightArrow.jpg"
                                        anchors.fill: parent
                                        anchors.top:parent.top
                                        //  anchors.topMargin: 6
                                        //z: 3
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
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            RowLayout {
                                anchors.fill: parent
                                spacing: 10

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    Text {
                                        id:  breakText
                                        text: qsTr("B")
                                        font.pixelSize: 25
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            console.log("Break pressed")
                                            carImage.source = "qrc:/views/led-tail-light/car-lights/car-rear-brake-lights.jpg"
                                            carImage.playing = true

                                        }
                                    }

                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    Text {
                                        id:  reverseText
                                        text: qsTr("R")
                                        font.pixelSize: 25
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            console.log("Reverse pressed")
                                            carImage.source = "qrc:/views/led-tail-light/car-lights/car-rear-hazard-lights.gif"
                                            carImage.playing = true

                                        }
                                    }
                                }
                            }

                        }

                    }

                }

            }
        }

    }

    Widget09.SGDrawerMenu {
        height:parent.height
        menuWidth: parent.width/3

        drawerMenuItems: Item {

            SGAlignedLabel {
                id: hightLightLabel
                target: highlight
                text: "Hightlight"
                color: "white"
                alignment: SGAlignedLabel.SideTopCenter


                fontSizeMultiplier: ratioCalc * 1.2
                font.bold : true

                SGSwitch {
                    id: highlight
                    labelsInside: true
                    checkedLabel: "On"
                    uncheckedLabel: "Off"
                    textColor: "black"              // Default: "black"
                    handleColor: "white"            // Default: "white"
                    grooveColor: "#ccc"             // Default: "#ccc"
                    grooveFillColor: "#0cf"         // Default: "#0cf"
                    fontSizeMultiplier: ratioCalc
                    checked: false
                }
            }

        }

        //            RowLayout {
        //                anchors.fill: parent
        //                Rectangle {
        //                    Layout.fillHeight: true
        //                    Layout.fillWidth: true
        //                    SGAlignedLabel {
        //                        id: hightLightLabel
        //                        target: highlight
        //                        text: "Hightlight"
        //                        color: "white"
        //                        alignment: SGAlignedLabel.SideTopCenter


        //                        fontSizeMultiplier: ratioCalc * 1.2
        //                        font.bold : true

        //                        SGSwitch {
        //                            id: highlight
        //                            labelsInside: true
        //                            checkedLabel: "On"
        //                            uncheckedLabel: "Off"
        //                            textColor: "black"              // Default: "black"
        //                            handleColor: "white"            // Default: "white"
        //                            grooveColor: "#ccc"             // Default: "#ccc"
        //                            grooveFillColor: "#0cf"         // Default: "#0cf"
        //                            fontSizeMultiplier: ratioCalc
        //                            checked: false
        //                        }
        //                    }

        //                }
        //                Rectangle {
        //                    Layout.fillHeight: true
        //                    Layout.fillWidth: true
        //                }
        //            }



    }
}
