import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import "qrc:/views/logic-gate/sgwidgets"


Rectangle {
    id: container
    property string gateImageSource
    property string inputName
    property var value_A
    property var value_B
    property var value_C
    property var value_Y

    anchors {
        fill: parent
    }

    property var valueB: platformInterface.nl7sz58_io_state.b


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

    property var valueA: platformInterface.nl7sz58_io_state.a


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

    property var valueC:  platformInterface.nl7sz58_io_state.c

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

    function checkState( ) {



        console.log("the value of noti a before", platformInterface.nl7sz58_io_state.a)
        console.log("the value of noti b before ", platformInterface.nl7sz58_io_state.b)

        //  valueA = platformInterface.nl7sz58_io_state.a;
        //  valueB = platformInterface.nl7sz58_io_state.b;

        console.log("the value of noti a after", platformInterface.nl7sz58_io_state.a)
        console.log("the value of noti b after ", platformInterface.nl7sz58_io_state.b)

        //valueC = platformInterface.nl7sz58_io_state.c;
        //valueY = platformInterface.nl7sz58_io_state.y;


        console.log("one toggle", inputOneToggle.checked)


        //        property var valueA: platformInterface.nl7sz58_io_state.a


        //        onValueAChanged: {
        //            if( valueA === 1) {
        //                inputOneToggle.checked = true
        //            }
        //            else {
        //                console.log("switch 1 is off")
        //                inputOneToggle.checked = false
        //            }

        //        }


        //        onValueBchanged: {

        //            if(valueB === 1) {
        //                inputTwoToggle.checked = true
        //            }
        //            else  {
        //                console.log("switch 2 is off")
        //                inputTwoToggle.checked = false
        //            }

        //        }

        //        if(value_y === 1) {
        //            sgStatusLight.status = "green"
        //        }
        //        else sgStatusLight.status = "off"
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
            read_state();

          //  checkState();

            // inputName = "A"
        }
        segmentedButtons: GridLayout {
            columnSpacing: 1

            SGSegmentedButton{
                text: qsTr("NAND")
                checked: true  // Sets default checked button when exclusive
                onClicked: {

                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/nand.png"
                    platformInterface.nand.update();
                    read_state()
                    // checkState()
                }

            }

            SGSegmentedButton{
                text: qsTr("AND NOTB")
                onClicked: {


                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/nand_nb.png"
                    // inputName = "A"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                    platformInterface.and_nb.update();
                    read_state()
                    //  checkState();


                }
            }

            SGSegmentedButton{
                text: qsTr("AND NOTC")
                onClicked: {
                    platformInterface.and_nc.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/and_nc.png"
                    //  inputName = "B"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                    read_state()
                    //    checkState();

                }
            }
            SGSegmentedButton{
                text: qsTr("OR")
                onClicked: {
                    platformInterface.or.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/or.png"
                    //inputName = "B"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                    read_state()
                    //   checkState();

                }
            }
            SGSegmentedButton{
                text: qsTr("XOR")
                onClicked: {
                    platformInterface.xor.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/xor.png"
                    //  inputName = "A"
                    inputOneToggle.checked = false;
                    inputTwoToggle.checked = false;
                    read_state()
                    //  checkState();


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

        Rectangle {
            id: fourInput
            width: 50
            height: 50
            //color: "green"

            anchors {

                top: gatesImage.bottom

             //   topMargin: 50
                horizontalCenter: gatesImage.horizontalCenter




            }
            SGStatusLight {
                id: sgStatusLightTwo


                // Optional Configuration:
                label: "<b>C</b>" // Default: "" (if not entered, label will not appear)
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





