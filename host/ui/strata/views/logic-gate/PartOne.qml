import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import "qrc:/views/logic-gate/sgwidgets"


Rectangle {
    id: container
    property string gateImageSource
    property string inputName
    property string value_A: "A"
    property string value_B: "B"
    property string value_C: "C"
    property var value_ANoti
    property var value_BNoti
    property var value_CNoti
    property var currentIndex: 0
    property var tabIndex: logicSelection.index

    function resetToIndex0(){
        gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/mux.png"
        platformInterface.mux_97.update();
        /*
          Changing the setting of the page based on which gate it is
        */
        sgStatusLightTwo.opacity = 0
        toggleSwitch1.opacity = 1
        inputThirdText.opacity = 1
        sgStatusLightInputB.opacity = 0
        inputTwoText.opacity = 1
        inputTwoToggle.opacity = 1
        logicSelection.index = 0
     }

    Component.onCompleted: {
        resetToIndex0();
    }


    anchors {
        fill: parent
    }

    property var io_state: platformInterface.nl7sz97_io_state

    onIo_stateChanged : {
        if(currentIndex == 0) {
            value_A = "B"
            value_ANoti = platformInterface.nl7sz97_io_state.b
            value_B = "A"
            value_BNoti = platformInterface.nl7sz97_io_state.a
            value_C = "C"
            value_CNoti = platformInterface.nl7sz97_io_state.c
        }
        if(currentIndex == 1) {
            value_A = "A"
            value_ANoti = platformInterface.nl7sz97_io_state.a
            value_B = "C"
            value_BNoti = platformInterface.nl7sz97_io_state.c
            value_C = "B"
            value_CNoti = platformInterface.nl7sz97_io_state.b

        }
        if(currentIndex == 2) {
            value_A = "A"
            value_ANoti = platformInterface.nl7sz97_io_state.a
            value_B = "C"
            value_BNoti = platformInterface.nl7sz97_io_state.c
            value_C = "B"
            value_CNoti = platformInterface.nl7sz97_io_state.b
        }
        if(currentIndex == 3) {

            value_A = "B"
            value_ANoti = platformInterface.nl7sz97_io_state.b
            value_B = "C"
            value_BNoti = platformInterface.nl7sz97_io_state.c
            value_C = "A"
            value_CNoti = platformInterface.nl7sz97_io_state.a
        }

        if(currentIndex == 4) {
            value_A = "B"
            value_ANoti = platformInterface.nl7sz97_io_state.b
            value_B = "C"
            value_BNoti = platformInterface.nl7sz97_io_state.c
            value_C = "A"
            value_CNoti = platformInterface.nl7sz97_io_state.a

        }
        if(currentIndex == 5) {
            value_A = "C"
            value_ANoti = platformInterface.nl7sz97_io_state.c
            value_B = "A"
            value_BNoti = platformInterface.nl7sz97_io_state.a
            value_C = "B"
            value_CNoti = platformInterface.nl7sz97_io_state.b

        }
        if(currentIndex == 6) {
            value_A = "B"
            value_ANoti = platformInterface.nl7sz97_io_state.b
            value_B = "A"
            value_BNoti = platformInterface.nl7sz97_io_state.a
            value_C = "C"
            value_CNoti = platformInterface.nl7sz97_io_state.c

        }
    }

    property var valueB: value_BNoti


    onValueBChanged: {
        if( valueB === 1) {
            inputTwoToggle.checked = true
             sgStatusLightInputB.status = "green"
        }
        else {
            console.log("switch 1 is off")
            inputTwoToggle.checked = false
              sgStatusLightInputB.status = "off"
        }

    }

    property var valueA: value_ANoti

    onValueAChanged: {

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

        if(valueY === 1) {
            sgStatusLight.status = "green"
        }
        else sgStatusLight.status = "off"
    }

    property var valueC: value_CNoti

    onValueCChanged: {

        console.log("change in c")

        if(valueC === 1) {
            sgStatusLightTwo.status = "green"
            toggleSwitch1.checked = true
        }
        else {
            sgStatusLightTwo.status = "off"
            toggleSwitch1.checked = false

        }
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
        index: tabIndex


        anchors {
            top: parent.top
            topMargin: 40
            horizontalCenter: parent.horizontalCenter
        }

        segmentedButtons: GridLayout {
            id: gatesSelection
            columnSpacing: 1

            SGSegmentedButton{
                id: muxgate
                text: qsTr("MUX")
                checked: true  // Sets default checked button when exclusive
                onClicked: {
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/mux.png"
                    platformInterface.mux_97.update();
                    /*
                      Changing the setting of the page based on which gate it is
                    */
                    sgStatusLightTwo.opacity = 0
                    toggleSwitch1.opacity = 1
                    inputThirdText.opacity = 1
                    sgStatusLightInputB.opacity = 0
                    inputTwoText.opacity = 1
                    inputTwoToggle.opacity = 1
                    currentIndex = 0
                    tabIndex = logicSelection.index

                }
            }

            SGSegmentedButton{
                text: qsTr("AND")
                onClicked: {
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/and.png"
                    platformInterface.and_97.update();
                    sgStatusLightTwo.opacity = 1
                    toggleSwitch1.opacity = 0
                    inputThirdText.opacity = 0
                    sgStatusLightInputB.opacity = 0
                    inputTwoText.opacity = 1
                    inputTwoToggle.opacity = 1
                    currentIndex = 1
                    tabIndex = logicSelection.index
                }
            }

            SGSegmentedButton{
                text: qsTr("OR NOTC")
                onClicked: {
                    platformInterface.or_nc_97.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/or_nc.png"
                    sgStatusLightTwo.opacity = 1
                    toggleSwitch1.opacity = 0
                    inputThirdText.opacity = 0
                    sgStatusLightInputB.opacity = 0
                    inputTwoText.opacity = 1
                    inputTwoToggle.opacity = 1
                    currentIndex = 2
                    tabIndex = logicSelection.index

                }
            }
            SGSegmentedButton{
                text: qsTr("AND NOTC")
                onClicked: {
                    platformInterface.and_nc_97.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/and_nc.png"
                    sgStatusLightTwo.opacity = 1
                    toggleSwitch1.opacity = 0
                    inputThirdText.opacity = 0
                    sgStatusLightInputB.opacity = 0
                    inputTwoText.opacity = 1
                    inputTwoToggle.opacity = 1
                    currentIndex = 3
                    tabIndex = logicSelection.index
                }
            }
            SGSegmentedButton{
                text: qsTr("OR")
                onClicked: {
                    platformInterface.or_97.update();
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/or.png"
                    sgStatusLightTwo.opacity = 1
                    toggleSwitch1.opacity = 0
                    inputThirdText.opacity = 0
                    sgStatusLightInputB.opacity = 0
                    inputTwoText.opacity = 1
                    inputTwoToggle.opacity = 1
                    currentIndex = 4
                    tabIndex = logicSelection.index

                }
            }
            SGSegmentedButton{
                text: qsTr("Inverter")
                onClicked: {
                    platformInterface.inverter_97.update();
                    sgStatusLightTwo.opacity = 1
                    toggleSwitch1.opacity = 0
                    inputThirdText.opacity = 0
                    sgStatusLightInputB.opacity = 1
                    inputTwoText.opacity = 0
                    inputTwoToggle.opacity = 0
                    currentIndex = 5
                    tabIndex = logicSelection.index
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/inverter.png"


                }
            }
            SGSegmentedButton{
                text: qsTr("Buffer")
                onClicked: {
                    platformInterface.buffer_97.update();
                    inputName = "B = C"
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/buffer.png"
                    sgStatusLightTwo.opacity = 1
                    toggleSwitch1.opacity = 0
                    inputThirdText.opacity = 0
                    sgStatusLightInputB.opacity = 1
                    inputTwoText.opacity = 0
                    inputTwoToggle.opacity = 0
                    currentIndex = 6
                    tabIndex = logicSelection.index

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
            id: inputAToggleContainer
            width: 100
            height: 100

           anchors {
                left: logicContainer.left
                top: logicContainer.top

            }

            SGSwitch {
                id: inputOneToggle
                anchors{
                    top: parent.top
                    topMargin: 30
                }

                transform: Rotation { origin.x: 25; origin.y: 25; angle: 270 }

                onClicked: {
                    if(inputOneText.text === "A") {
                        if(inputOneToggle.checked)  {
                            platformInterface.write_io_97.update(1, platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()
                        }
                        else {
                            platformInterface.write_io_97.update(0,platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()
                        }
                    }

                    else if(inputOneText.text === "B") {
                        if(inputOneToggle.checked)  {

                            platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 1 , platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()

                        }
                        else {
                            platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 0 , platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()

                        }
                    }
                    else if(inputOneText.text === "C") {
                        if(inputOneToggle.checked)  {
                            platformInterface.write_io_97.update( platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b, 1)
                            platformInterface.write_io_97.show()

                        }
                        else {
                            platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b, 0)
                            platformInterface.write_io_97.show()

                        }
                    }
                }
            }

            Text {
                id: inputOneText
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
            id: inputBToggleContainer
            width: 100
            height: 100

            anchors {
                left: logicContainer.left
                top: inputAToggleContainer.bottom
            }

            SGSwitch {
                id: inputTwoToggle
                anchors{
                    top: parent.top
                    topMargin: 30

                }

                onClicked: {

                    if(inputTwoText.text === "A") {
                        if(inputTwoToggle.checked)  {
                            platformInterface.write_io_97.update(1, platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()

                        }
                        else {
                            platformInterface.write_io_97.update(0,platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()

                        }
                    }

                    else if(inputTwoText.text === "B") {
                        if(inputTwoToggle.checked)  {
                            platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 1,platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()

                        }
                        else {
                            platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 0,platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()
                        }
                    }
                    else if(inputTwoText.text === "C") {
                        if(inputTwoToggle.checked)  {
                            platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a,platformInterface.nl7sz97_io_state.b,1)
                            platformInterface.write_io_97.show()
                        }
                        else {
                            platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b,0)
                            platformInterface.write_io_97.show()

                        }
                    }
                }
                transform: Rotation { origin.x: 25; origin.y: 25; angle: 270 }
            }

            Text {
                id: inputTwoText
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
                id: sgStatusLightInputB
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

                left: inputAToggleContainer.right
            }
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: thirdInput
            width: 50
            height: 50
            anchors {
                left: gatesImage.right
                top: inputAToggleContainer.top
                topMargin: 50

            }
            SGStatusLight {
                id: sgStatusLight
                // Optional Configuration:
                label: "<b>Y</b>" // Default: "" (if not entered, label will not appear)
                labelLeft: false        // Default: true
                lightSize: 50           // Default: 50
                textColor: "black"           // Default: "black"
                status : "off"


            }
        }

        Rectangle {
            id: inputCToggleContainer
            width: 50
            height: 50

            anchors {
                top: gatesImage.bottom
                horizontalCenter: gatesImage.horizontalCenter
                horizontalCenterOffset: -10

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

            Text {
                id: inputThirdText
                text: value_C
                font.bold: true
                font.pointSize: 30
                anchors {
                    left: parent.left
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter

                }
            }
            SGSwitch {
                id: toggleSwitch1
                anchors{
                    left: inputThirdText.right
                }


                onClicked: {
                    if(inputThirdText.text === "A") {
                        if(toggleSwitch1.checked)  {
                            platformInterface.write_io_97.update(1, platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()

                        }
                        else {
                            platformInterface.write_io_97.update(0,platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()

                        }
                    }

                    else if(inputThirdText.text === "B") {
                        if(toggleSwitch1.checked)  {
                            platformInterface.write_io_97.update( platformInterface.nl7sz97_io_state.a, 1, platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()

                        }
                        else {
                            platformInterface.write_io_97.update( platformInterface.nl7sz97_io_state.a, 0, platformInterface.nl7sz97_io_state.c)
                            platformInterface.write_io_97.show()
                        }
                    }
                    else if(inputThirdText.text === "C") {
                        if(toggleSwitch1.checked)  {

                            platformInterface.write_io_97.update( platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b, 1)
                            platformInterface.write_io_97.show()

                        }
                        else {
                            platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b,0)
                            platformInterface.write_io_97.show()
                        }
                    }
                }

                transform: Rotation { origin.x: 25; origin.y: 25; angle: 270 }

            }

        }

    }

}








