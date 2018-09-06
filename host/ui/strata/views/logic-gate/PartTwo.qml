import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import "qrc:/views/logic-gate/sgwidgets"


Rectangle {
    id: container
    property string gateImageSource
    property string inputName
    property string value_A: A
    property string value_B: B
    property string value_C: C
    property var value_AIn: A
    property var value_BIn: B
    property var value_CIn: C


    anchors {
        fill: parent
    }

    property var valueB: value_BIn


    onValueBChanged: {
        console.log("change in b")
        if( valueB === 1) {
            inputTwoToggle.checked = true
        }
        else {
            console.log("switch 1 is off")
            inputTwoToggle.checked = false
        }

    }

    property var valueA: value_AIn


    onValueAChanged: {

        console.log("change in a")

        if( valueA === 1) {
            inputOneToggle.checked = true

        }
        else {
            console.log("switch 2 is off")
            inputOneToggle.checked = false

        }

    }

    property var valueY:  platformInterface.nl7sz58_io_state.y

    onValueYChanged: {

        console.log("change in y")

        if(valueY === 1) {
            sgStatusLight.status = "green"
        }
        else sgStatusLight.status = "off"
    }

    property var valueC:  value_CIn

    onValueCChanged: {

        console.log("change in y")

        if(valueC === 1) {
            sgStatusLightTwo.status = "green"
        }
        else sgStatusLightTwo.status = "off"
    }



    function read_state() {
        console.log("inread")
        platformInterface.read_io.update();
        platformInterface.read_io.show();

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

            gateImageSource =  "qrc:/views/logic-gate/images/nl7sz58/nand.png"
            platformInterface.nand.update();
            value_A = "B"
            value_AIn = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BIn = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CIn = platformInterface.nl7sz58_io_state.a
            read_state();

        }
        segmentedButtons: GridLayout {
            columnSpacing: 1

            SGSegmentedButton{
                text: qsTr("NAND")
                checked: true  // Sets default checked button when exclusive
                onClicked: {

                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/nand.png"
                    platformInterface.nand.update();
                    value_A = "B"
                    value_AIn = platformInterface.nl7sz58_io_state.b
                    value_B = "C"
                    value_BIn = platformInterface.nl7sz58_io_state.c
                    value_C = "A"
                    value_CIn = platformInterface.nl7sz58_io_state.a
                    read_state()

                }

            }

            SGSegmentedButton{
                text: qsTr("AND NOTB")
                onClicked: {


                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/nand_nb.png"

                    platformInterface.and_nb.update();
                    value_A = "B"
                    value_AIn = platformInterface.nl7sz58_io_state.b
                    value_B = "C"
                    value_BIn = platformInterface.nl7sz58_io_state.c
                    value_C = "A"
                    value_CIn = platformInterface.nl7sz58_io_state.a
                    read_state()
                    //  checkState();


                }
            }

            SGSegmentedButton{
                text: qsTr("AND NOTC")
                onClicked: {
                    platformInterface.and_nc.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/and_nc.png"

                    read_state()
                    value_A = "A"
                    value_AIn = platformInterface.nl7sz58_io_state.b
                    value_B = "C"
                    value_BIn = platformInterface.nl7sz58_io_state.c
                    value_C = "B"
                    value_CIn = platformInterface.nl7sz58_io_state.b

                }
            }
            SGSegmentedButton{
                text: qsTr("OR")
                onClicked: {
                    platformInterface.or.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/or.png"

                    read_state()
                    value_A = "A"
                    value_AIn = platformInterface.nl7sz58_io_state.b
                    value_B = "C"
                    value_BIn = platformInterface.nl7sz58_io_state.c
                    value_C = "B"
                    value_CIn = platformInterface.nl7sz58_io_state.b


                }
            }
            SGSegmentedButton{
                text: qsTr("XOR")
                onClicked: {
                    platformInterface.xor.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/xor.png"

                    read_state()
                    value_A = "B"
                    value_AIn = platformInterface.nl7sz58_io_state.b
                    value_B = "C"
                    value_BIn = platformInterface.nl7sz58_io_state.c
                    value_C = "A"
                    value_CIn = platformInterface.nl7sz58_io_state.a



                }
            }
            SGSegmentedButton{
                text: qsTr("Inverter")
                onClicked: {
                    platformInterface.inverter.update();
                    inputName = "A and C"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/inverter.png"
                    //                    horizontalLine.opacity = 1
                    //                    textForInput.opacity = 1
                    //                    inputTwoToggle.opacity = 0
                    read_state()
                    //  checkState();



                }
            }
            SGSegmentedButton{
                text: qsTr("Buffer")
                onClicked: {
                    platformInterface.buffer.update();
                    inputName = "B = C"
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/buffer.png"
                    //                    horizontalLine.opacity = 1
                    //                    textForInput.opacity = 1
                    //                    inputTwoToggle.opacity = 0
                    read_state();
                    //   checkState();

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
                    console.log("on click of the switch 1 ")

                    //   platformInterface.read_io.update()
                    if(inputOneToggle.checked)  {

                        platformInterface.write_io.update(1, platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                        platformInterface.write_io.show()
                        valueA = 1
                        read_state()

                    }
                    else {
                        platformInterface.write_io.update(0, platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                        platformInterface.write_io.show()
                        valueA = 0
                        read_state()
                    }


                }



            }

            Text {
                id: inputOne
                text: value_A
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
                    console.log("on click of the switch 2")
                    //   platformInterface.read_io.update();

                    if(inputTwoToggle.checked)  {

                        platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, 1, platformInterface.nl7sz58_io_state.c,  platformInterface.nl7sz58_io_state.y)
                        platformInterface.write_io.show()
                        valueB = 1
                        read_state()


                    }
                    else {
                        platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, 0, platformInterface.nl7sz58_io_state.c,  platformInterface.nl7sz58_io_state.y)
                        platformInterface.write_io.show()
                        valueB = 0
                        read_state()

                    }

                }

                transform: Rotation { origin.x: 25; origin.y: 25; angle: 270 }

            }

            Text {
                id: inputTwo
                text: value_B
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
            anchors {
                left: gatesImage.right
                top: inputToggleContainer.top
                topMargin: 50

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

        Rectangle {
            id: fourInput
            width: 50
            height: 50

            anchors {
                top: gatesImage.bottom
                horizontalCenter: gatesImage.horizontalCenter
            }
            SGStatusLight {
                id: sgStatusLightTwo


                // Optional Configuration:
                label: value_C // Default: "" (if not entered, label will not appear)
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





