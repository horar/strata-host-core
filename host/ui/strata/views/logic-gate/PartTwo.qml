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

    anchors {
        fill: parent
    }

    property var valueB: platformInterface.nl7sz97_io_state.b


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

    property var valueA: platformInterface.nl7sz97_io_state.a


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

    property var valueY:  platformInterface.nl7sz97_io_state.y

    onValueYChanged: {

        console.log("change in y")

        if(valueY === 1) {
            sgStatusLight.status = "green"
        }
        else sgStatusLight.status = "off"
    }

    property var valueC:  platformInterface.nl7sz97_io_state.c

    onValueCChanged: {

        console.log("change in c")

        if(valueC === 1) {
            sgStatusLightTwo.status = "green"
        }
        else sgStatusLightTwo.status = "off"
    }



    function read_state() {
        console.log("inread")
        platformInterface.read_io_97.update();
        platformInterface.read_io_97.show();

    }

    SGSegmentedButtonStrip {
        id: logicSelection

        radius: 4
        buttonHeight: 25
        visible: true
        anchors {
            top: parent.top
            topMargin: 40
            horizontalCenter: parent.horizontalCenter
        }

        Component.onCompleted: {

            gateImageSource =  "qrc:/views/logic-gate/images/nl7sz97/mux.png"
            platformInterface.mux_97.update();
            value_A = "B"
            value_B = "A"
            value_C = "C"
            read_state();


        }
        segmentedButtons: GridLayout {
            columnSpacing: 1

            SGSegmentedButton{
                text: qsTr("MUX")
                checked: true  // Sets default checked button when exclusive
                onClicked: {

                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/mux.png"
                    platformInterface.mux_97.update();
                    value_A = "B"
                    value_B = "A"
                    value_C = "C"
                    read_state()
                    // checkState()
                }

            }

            SGSegmentedButton{
                text: qsTr("AND")
                onClicked: {

                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/and.png"
                    platformInterface.and_97.update();
                    value_A = "B"
                    value_B = "A"
                    value_C = "C"
                    read_state()
                    //  checkState();


                }
            }

            SGSegmentedButton{
                text: qsTr("OR NOTC")
                onClicked: {
                    platformInterface.or_nc_97.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/or_nc.png"
                    //  inputName = "B"
                    value_A = "A"
                    value_B = "C"
                    value_C = "B"

                    read_state()
                    //    checkState();

                }
            }
            SGSegmentedButton{
                text: qsTr("AND NOTC")
                onClicked: {
                    platformInterface.and_nc_97.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/and_nc.png"
                    value_A = "B"
                    value_B = "C"
                    value_C = "A"

                    read_state()
                    //   checkState();

                }
            }
            SGSegmentedButton{
                text: qsTr("OR")
                onClicked: {
                    platformInterface.or_97.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/or.png"
                    //  inputName = "A"
                    value_A = "B"
                    value_B = "C"
                    value_C = "A"

                    read_state()
                    //  checkState();


                }
            }
            SGSegmentedButton{
                text: qsTr("Inverter")
                onClicked: {
                    platformInterface.inverter_97.update();


                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/inverter.png"
                    read_state()
                    //  checkState();
                }
            }
            SGSegmentedButton{
                text: qsTr("Buffer")
                onClicked: {
                    platformInterface.buffer_97.update();
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
                    console.log("checked ",inputOneToggle.checked )

                    //   platformInterface.read_io.update()
                    if(inputOneToggle.checked)  {

                        platformInterface.write_io_97.update(1, platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                        platformInterface.write_io_97.show()
                        valueA = 1
                        read_state()

                    }
                    else {
                        platformInterface.write_io_97.update(0, platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                        platformInterface.write_io_97.show()
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

                        platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 1, platformInterface.nl7sz97_io_state.c,  platformInterface.nl7sz97_io_state.y)
                        platformInterface.write_io_97.show()
                        valueB = 1
                        read_state()


                    }
                    else {
                        platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 0, platformInterface.nl7sz97_io_state.c,  platformInterface.nl7sz97_io_state.y)
                        platformInterface.write_io_97.show()
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





