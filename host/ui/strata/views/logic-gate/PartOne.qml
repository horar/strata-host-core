import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import "qrc:/views/usb-pd-multiport/sgwidgets"
Rectangle {
    id: container
    anchors {
        fill: parent
    }


        SGSegmentedButtonStrip {
            id: logicSelection
            activeColor: "#666"
            inactiveColor: "#dddddd"
            textColor: "#666"
            activeTextColor: "White"
            radius: 4
            buttonHeight: 25
            visible: true
            anchors {
                top: parent.top
                topMargin: 40
                horizontalCenter: parent.horizontalCenter
            }


            segmentedButtons: GridLayout {
                columnSpacing: 1

                SGSegmentedButton{
                    text: qsTr("NAND")
                    checked: true  // Sets default checked button when exclusive
                    onClicked: {
                        platformInterface.nand.update()
                    }

                }

                SGSegmentedButton{
                    text: qsTr("AND B")
                    onClicked: {
                        platformInterface.and_nb.update();
                    }
                }

                SGSegmentedButton{
                    text: qsTr("AND C")
                    onClicked: {
                         platformInterface.and_nc.update();
                    }
                }
                SGSegmentedButton{
                    text: qsTr("OR")
                    onClicked: {
                         platformInterface.or.update();
                    }
                }
                SGSegmentedButton{
                    text: qsTr("XOR")
                    onClicked: {
                        platformInterface.xor.update();

                    }
                }
                SGSegmentedButton{
                    text: qsTr("Inverter")
                    onClicked: {
                        platformInterface.inverter.update();

                    }
                }
                SGSegmentedButton{
                    text: qsTr("Buffer")
                    onClicked: {
                        platformInterface.buffer.update();
                    }
                }
            }
        }

        Rectangle {

            id: logicContainer

            width: parent.width/2
            height: parent.height/2


            anchors {
                top: logicSelection.bottom
                topMargin: 40
                left: parent.left
                leftMargin: 40

            }

            Column {
                spacing: 20

                anchors{
                    left: parent.left
                    leftMargin: 30
                    verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: inputOne
                    border.color: "black"
                    border.width: 5
                    radius: 10
                    width: 140
                    height: 100

                    SGSwitch {
                        id: inputOneToggle
                        anchors {
                            top:inputOne.top
                            topMargin: 20
                        }
                        transform: Rotation { origin.x: 25; origin.y: 25; angle: 90 }
                    }

                    Text {
                        text: "A"
                        font.bold: true
                       // font.
                        anchors {
                            left: inputOneToggle.right
                            leftMargin: 10
                            top: inputOne.top
                            topMargin: 40
                        }
                    }



                }
                Rectangle {
                    id: inputTwo
                    width: 140
                    height: 100
                    border.color: "black"
                    border.width: 5
                    radius: 10

                    SGSwitch {
                        id: inputTwoToggle
                        anchors {
                            top:inputTwo.top
                            topMargin: 20
                        }
                        transform: Rotation { origin.x: 25; origin.y: 25; angle: 90 }
                    }
                    Text {
                        text: "B"
                        font.bold: true
                        anchors {
                            left: inputTwoToggle.right
                            leftMargin: 10
                            top: inputTwo.top
                            topMargin: 40
                        }

                    }


                }

            }
        }
}
