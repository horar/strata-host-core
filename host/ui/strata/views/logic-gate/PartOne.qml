import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import "qrc:/views/logic-gate/sgwidgets"


Rectangle {
    id: container
    property string gateImageSource
    property string inputName
    anchors {
        fill: parent
    }

    function read_state() {
        console.log("inread")
         inputOneToggle.checked = false;
         inputTwoToggle.checked = false;
         platformInterface.read_io.update();
         platformInterface.read_io.show();
        console.log(JSON.stringify(platformInterface.nl7sz58_io_state.a))
    }

    function checkState( ) {




        var value_a = platformInterface.nl7sz58_io_state.a;
        var value_b = platformInterface.nl7sz58_io_state.b;
        var value_c = platformInterface.nl7sz58_io_state.c;
        var value_y = platformInterface.nl7sz58_io_state.y;
        console.log("a ", value_a)
         console.log("b ", value_b)
         console.log("c ", value_c)
        // console.log("d ", value_)



        if(  value_a === 1) {
            inputOneToggle.checked = true
        }
        else inputOneToggle.checked = false

        if(value_b === 1) {
            inputTwoToggle.checked = true
        }
        else inputTwoToggle.checked = false


        if(value_y === 1) {
            sgStatusLight.status = "green"
        }
        else sgStatusLight.status = "off"
    }

    SGSegmentedButtonStrip {
        id: logicSelection
        //        activeColor: "#666"
        //        inactiveColor: "#dddddd"
        //        textColor: "#666"
        //        activeTextColor: "White"
        radius: 4
        buttonHeight: 25
        visible: true
        anchors {
            top: parent.top
            topMargin: 40
            horizontalCenter: parent.horizontalCenter
        }

        Component.onCompleted: {

            gateImageSource =  "qrc:/views/logic-gate/images/nand.png"
            platformInterface.nand.update()
            read_state();
            checkState();

           // inputName = "A"
        }
        segmentedButtons: GridLayout {
            columnSpacing: 1

            SGSegmentedButton{
                text: qsTr("NAND")
                checked: true  // Sets default checked button when exclusive
                onClicked: {

                    platformInterface.nand.update();
                    platformInterface.nand.show();
                    platformInterface.read_io.update();
                    platformInterface.read_io.show();
                    console.log("uI", JSON.stringify(platformInterface.nl7sz58_io_state))
                    console.log("uI", JSON.stringify(platformInterface.pi_stats))


                    var value_a = platformInterface.nl7sz58_io_state.a;
                    var value_b = platformInterface.nl7sz58_io_state.b;
                    var value_c = platformInterface.nl7sz58_io_state.c;
                    var value_y = platformInterface.nl7sz58_io_state.y;
                    console.log("a ", value_a)
                    console.log("b ", value_b)
                    console.log("c ", value_c)
                   // var notification = JSON.parse(platformInterface.nl7sz58_io_state)
                  //  console.log("uI", JSON.stringify(platformInterface.pi_stats))

                    if(  value_a === 1) {
                        inputOneToggle.checked = true
                    }
                    else inputOneToggle.checked = false

                    if(value_b === 1) {
                        inputTwoToggle.checked = true
                    }
                    else inputTwoToggle.checked = false


                    if(value_y === 1) {
                        sgStatusLight.status = "green"
                    }
                    else sgStatusLight.status = "off"

                  //  console.log()



                    gateImageSource = "qrc:/views/logic-gate/images/nand.png"






                }

            }

            SGSegmentedButton{
                text: qsTr("AND NOTB")
                onClicked: {
                    platformInterface.and_nb.update();

                    gateImageSource = "qrc:/views/logic-gate/images/nand_nb.png"
                   // inputName = "A"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                     read_state()
                    checkState();


                }
            }

            SGSegmentedButton{
                text: qsTr("AND NOTC")
                onClicked: {
                    platformInterface.and_nc.update();
                    gateImageSource = "qrc:/views/logic-gate/images/and_nc.png"
                  //  inputName = "B"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                     read_state()
                    checkState();

                }
            }
            SGSegmentedButton{
                text: qsTr("OR")
                onClicked: {
                    platformInterface.or.update();
                    gateImageSource = "qrc:/views/logic-gate/images/or.png"
                    //inputName = "B"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                     read_state()
                    checkState();

                }
            }
            SGSegmentedButton{
                text: qsTr("XOR")
                onClicked: {
                    platformInterface.xor.update();
                    gateImageSource = "qrc:/views/logic-gate/images/xor.png"
                  //  inputName = "A"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                     read_state()
                    checkState();


                }
            }
            SGSegmentedButton{
                text: qsTr("Inverter")
                onClicked: {
                    platformInterface.inverter.update();
                    inputName = "A and C"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                    gateImageSource = "qrc:/views/logic-gate/images/inverter.png"
                    //                    horizontalLine.opacity = 1
                    //                    textForInput.opacity = 1
                    //                    inputTwoToggle.opacity = 0
                     read_state()
                    checkState();



                }
            }
            SGSegmentedButton{
                text: qsTr("Buffer")
                onClicked: {
                    platformInterface.buffer.update();
                    inputName = "B = C"
                    gateImageSource = "qrc:/views/logic-gate/images/buffer.png"
                    //                    horizontalLine.opacity = 1
                    //                    textForInput.opacity = 1
                    //                    inputTwoToggle.opacity = 0
                     read_state();
                    checkState();

                }
            }
        }
    }

    Rectangle {

        id: logicContainer

        width: parent.width/2
        height: parent.height/2

        anchors{
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: inputToggleContainer
            width: 100
            height: 100

            anchors {
                left: logicContainer.left
                top: logicContainer.top
                topMargin: 20
            }

            SGSwitch {
                id: inputOneToggle
                anchors{
                    top: parent.top
                    topMargin: 30
                }

                transform: Rotation { origin.x: 25; origin.y: 25; angle: 270 }
                onClicked: {
                    console.log("on click of the switch")
                    platformInterface.read_io.update();
                    var value_a = platformInterface.nl7sz58_io_state.a;
                    var value_b = platformInterface.nl7sz58_io_state.b;
                    var value_c = platformInterface.nl7sz58_io_state.c;
                    var value_y = platformInterface.nl7sz58_io_state.y;
                    if(inputOneToggle.checked)  {
                        platformInterface.write_io.update(1, value_b, value_c, value_y)
                        platformInterface.write_io.show();

                    }
                    else {
                        platformInterface.write_io.update(0, value_b, value_c, value_y)
                        platformInterface.write_io.show();
                    }

                }



            }

            Text {
                id: inputOne
                text: "A"
                font.bold: true
                font.pointSize: 30
                anchors {
                    left: inputOneToggle.right
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

            }

        }

        Rectangle {
            id: inputToggleContainerTwo
            width: 100
            height: 100

            anchors {
                left: logicContainer.left
                top: inputToggleContainer.bottom


            }

            SGSwitch {
                id: inputTwoToggle
                anchors{
                    top: parent.top
                    topMargin: 30

                }

                onClicked: {
                    console.log("on click of the switch")
                    platformInterface.read_io.update();
                    var value_a = platformInterface.nl7sz58_io_state.a;
                    var value_b = platformInterface.nl7sz58_io_state.b;
                    var value_c = platformInterface.nl7sz58_io_state.c;
                    var value_y = platformInterface.nl7sz58_io_state.y;
                    if(inputOneToggle.checked)  {
                        platformInterface.write_io.update(1, value_b, value_c, value_y)
                        platformInterface.write_io.show();

                    }
                    else {
                        platformInterface.write_io.update(0, value_b, value_c, value_y)
                        platformInterface.write_io.show();
                    }

                }




                transform: Rotation { origin.x: 25; origin.y: 25; angle: 270 }

            }

            Text {
                id: inputTwo
                text: "B"
                font.bold: true
                font.pointSize: 30
                anchors {
                    left: inputTwoToggle.right
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

            }

        }



        Image {
            id: gatesImage
            source: gateImageSource
            anchors {

                left: inputToggleContainer.right
            }
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: thirdInput
            width: 50
            height: 50
            //color: "green"

            anchors {
                left: gatesImage.right
                top: inputToggleContainer.top
                topMargin: 50
                //  horizontalCenter: parent.horizontalCenter



            }
            SGStatusLight {
                id: sgStatusLight


                // Optional Configuration:
                label: "<b>Y</b>" // Default: "" (if not entered, label will not appear)
                labelLeft: false        // Default: true
                // status: "off"           // Default: "off"
                lightSize: 50           // Default: 50
                textColor: "black"           // Default: "black"

                status : "off"
            }

        }

    }
}

//        Column {

//            id:inputSymbol
//            anchors {
//                horizontalCenter: parent.horizontalCenter
//            }
//            Image {
//                id: gatesImage
//                source: gateImageSource

//                fillMode: Image.PreserveAspectFit
////                width: logicContainer.width/1.5
////                height: logicContainer.height/2

//            }

//            Rectangle {
//                id: horizontalLine
//                width: 10
//                height: 100
//                border.color: "black"
//                border.width: 5
//                radius: 50
//                anchors.horizontalCenter: parent.horizontalCenter
//            }



//            Rectangle {

//                width: 50
//                height: 20
//                anchors.horizontalCenter: parent.horizontalCenter

//                Text {
//                    id: textForInput
//                    text: inputName
//                    font.bold: true
//                    font.pointSize: 30
//                    anchors.horizontalCenter: parent.horizontalCenter

//                }

//                RadioButton {
//                    checked: true
//                    width: 50; height: 20
//                    anchors {
//                        left: textForInput.right

//                    }
//                    text: ""

//                }
//            }

//            //            Rectangle {
//            //                width: 50
//            //                height: 20
//            //                anchors.horizontalCenter: parent.horizontalCenter

//            //                Text {
//            //                    id: textForInput2
//            //                    text: inputName
//            //                    font.bold: true
//            //                    font.pointSize: 30
//            //                    anchors.horizontalCenter: parent.horizontalCenter

//            //                }

//            //                RadioButton {
//            //                    checked: true
//            //                    width: 50; height: 20
//            //                    anchors {
//            //                        top:
//            //                        left: textForInput2.right

//            //                    }
//            //                    text: ""

//            //                }
//            //            }
//        }




//    }





