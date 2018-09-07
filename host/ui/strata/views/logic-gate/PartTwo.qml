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
    property var value_AIn
    property var value_BIn
    property var value_CIn
    property var currentIndex: 0


    anchors {
        fill: parent
    }

    property var test_case: platformInterface.nl7sz58_io_state
    onTest_caseChanged : {
        if(currentIndex == 0) {
            value_A = "B"
            value_AIn = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BIn = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CIn = platformInterface.nl7sz58_io_state.a
        }
        if(currentIndex == 1) {
            value_A = "B"
            value_AIn = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BIn = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CIn = platformInterface.nl7sz58_io_state.a

        }
        if(currentIndex == 2) {
            value_A = "A"
            value_AIn = platformInterface.nl7sz58_io_state.a
            value_B = "C"
            value_BIn = platformInterface.nl7sz58_io_state.c
            value_C = "B"
            value_CIn = platformInterface.nl7sz58_io_state.b
        }
        if(currentIndex == 3) {

            value_A = "A"
            value_AIn = platformInterface.nl7sz58_io_state.a
            value_B = "C"
            value_BIn = platformInterface.nl7sz58_io_state.c
            value_C = "B"
            value_CIn = platformInterface.nl7sz58_io_state.b
        }

        if(currentIndex == 4) {
            value_A = "B"
            value_AIn = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BIn = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CIn = platformInterface.nl7sz58_io_state.a

        }
        if(currentIndex == 5) {
            value_A = "A"
            value_AIn = platformInterface.nl7sz58_io_state.a
            value_B = "B"
            value_BIn = platformInterface.nl7sz58_io_state.b
            value_C = "C"
            value_CIn = platformInterface.nl7sz58_io_state.c

        }
        if(currentIndex == 6) {
            value_A = "B"
            value_AIn = platformInterface.nl7sz58_io_state.b
            value_B = "A"
            value_BIn = platformInterface.nl7sz58_io_state.a
            value_C = "C"
            value_CIn = platformInterface.nl7sz58_io_state.c

        }
    }


    property var valueB: value_BIn


    onValueBChanged: {
        console.log("change in b", valueB)
        if( valueB === 1) {
            inputTwoToggle.checked = true
        }
        else {
            console.log("switch 1 is off")
            inputTwoToggle.checked = false
        }

    }

    // property var valueA: platformInterface.nl7sz58_io_state.a
    property var valueA: value_AIn


    onValueAChanged: {

        console.log("change in a", valueA)

        if( valueA === 1) {
            inputOneToggle.checked = true

        }
        else {

            inputOneToggle.checked = false
        }

    }

    property var valueY:  platformInterface.nl7sz58_io_state.y

    onValueYChanged: {



        if(valueY === 1) {
            sgStatusLight.status = "green"
        }
        else sgStatusLight.status = "off"
    }

    // property var valueC: platformInterface.nl7sz58_io_state.c
    property var valueC: value_CIn

    onValueCChanged: {

        console.log("change in y", value_CIn)

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
            //            platformInterface.nand.update();

            //            read_state()

            //            value_A = "B"
            //            //  property var valueAIn: platformInterface.nl7sz58_io_state.b
            //            value_AIn = platformInterface.nl7sz58_io_state.b


            //            value_B = "C"
            //            value_BIn =  platformInterface.nl7sz58_io_state.c


            //            value_C = "A"
            //            value_CIn = platformInterface.nl7sz58_io_state.a

            //            console.log("noti:", JSON.stringify(platformInterface.nl7sz58_io_state))

        }
        segmentedButtons: GridLayout {
            columnSpacing: 1


            SGSegmentedButton{
                text: qsTr("NAND")
                checked: true  // Sets default checked button when exclusive
                onClicked: {

                    currentIndex = 0
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/nand.png"
                    platformInterface.nand.update();

                    //    read_state()

                }

            }

            SGSegmentedButton{
                text: qsTr("AND NOTB")
                onClicked: {


                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/nand_nb.png"


                    platformInterface.and_nb.update();
                    sgStatusLightInputTwo.opacity = 0
                    inputTwo.opacity = 1
                    inputTwoToggle.opacity = 1
                    currentIndex = 1;




                }
            }

            SGSegmentedButton{
                text: qsTr("AND NOTC")
                onClicked: {
                    platformInterface.and_nc.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/and_nc.png"
                    sgStatusLightInputTwo.opacity = 0
                    inputTwo.opacity = 1
                    inputTwoToggle.opacity = 1
                    currentIndex = 2
                    //  read_state()


                }
            }
            SGSegmentedButton{
                text: qsTr("OR")
                onClicked: {
                    platformInterface.or.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/or.png"
                    sgStatusLightInputTwo.opacity = 0
                    inputTwo.opacity = 1
                    inputTwoToggle.opacity = 1

                    currentIndex = 3





                }
            }
            SGSegmentedButton{
                text: qsTr("XOR")
                onClicked: {
                    platformInterface.xor.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/xor.png"
                    sgStatusLightInputTwo.opacity = 0
                    inputTwo.opacity = 1
                    inputTwoToggle.opacity = 1

                    currentIndex = 4

                }
            }
            SGSegmentedButton{
                text: qsTr("Inverter")
                onClicked: {
                    platformInterface.inverter.update()
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/inverter.png"
                    sgStatusLightInputTwo.opacity = 1
                    inputTwo.opacity = 0
                    inputTwoToggle.opacity = 0
                    currentIndex = 5


                }
            }
            SGSegmentedButton{
                text: qsTr("Buffer")
                onClicked: {
                    platformInterface.buffer.update();
                    inputName = "B = C"
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/buffer.png"
                    sgStatusLightInputTwo.opacity = 1
                    inputTwo.opacity = 0
                    inputTwoToggle.opacity = 0
                    currentIndex = 6

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

                    if(inputOne.text === "A") {
                        if(inputOneToggle.checked)  {
                            platformInterface.write_io.update(1, platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()

                        }
                        else {
                            platformInterface.write_io.update(0, platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()

                        }
                    }
                    if(inputOne.text === "B") {
                        if(inputOneToggle.checked)  {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,1, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()

                        }
                        else {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,0, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()

                        }
                    }
                    if(inputOne.text === "C") {
                        if(inputOneToggle.checked)  {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,platformInterface.nl7sz58_io_state.b,1)
                            platformInterface.write_io.show()

                        }
                        else {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, platformInterface.nl7sz58_io_state.b,0)
                            platformInterface.write_io.show()

                        }
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
                    console.log("in the click")
                    if(inputTwo.text === "A") {
                        console.log("in the click A")
                        if(inputTwoToggle.checked)  {
                            platformInterface.write_io.update(1,platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()
                        }
                        else {
                            platformInterface.write_io.update(0,platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()
                        }
                    }
                    if(inputTwo.text === "B") {
                        if(inputTwoToggle.checked)  {

                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, 1, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()
                        }
                        else {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, 0, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()
                        }
                    }
                    if(inputTwo.text === "C") {
                        if(inputTwoToggle.checked)  {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,platformInterface.nl7sz58_io_state.b,1 )
                            platformInterface.write_io.show()
                        }
                        else {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,platformInterface.nl7sz58_io_state.b,0)
                            platformInterface.write_io.show()
                        }
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

            SGStatusLight {
                id: sgStatusLightInputTwo
                // Optional Configuration:
                label: "<b>" + value_B + "</b>" // Default: "" (if not entered, label will not appear)
                labelLeft: false        // Default: true
                // status: "off"           // Default: "off"
                lightSize: 50           // Default: 50
                textColor: "black"           // Default: "black"
                status : "off"


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


