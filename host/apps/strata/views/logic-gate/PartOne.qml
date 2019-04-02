import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import "qrc:/views/logic-gate/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

GridLayout {
    anchors.fill: parent
    anchors.margins: 20
    rowSpacing: 20
    columnSpacing: 20
    flow:  GridLayout.LeftToRight
    property string gateImageSource
    property string value_A: "A"
    property string value_B: "B"
    property string value_C: "C"
    property var value_ANoti
    property var value_BNoti
    property var value_CNoti
    property int currentIndex: 0

    //Reset view for the nl7sz97 tab
    function resetToIndex0(){
        gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/mux.png"
        inputAToggleContainer.anchors.topMargin = -10
        inputBToggleContainer.anchors.topMargin = 50
        inputBToggleContainer.anchors.leftMargin = 0
        thirdInput.anchors.topMargin = 100
        //Input 2 container
        sgStatusLightInputB.visible = false
        inputTwoText.visible = true
        inputTwoToggle.visible = true
        //Input 3 container
        sgStatusLightTwo.visible = false
        toggleSwitch1.visible = true
        inputThirdText.visible = true
        currentIndex = 0
        logicSelection.index = 0
        platformInterface.off_led.update();
        platformInterface.mux_97.update();
    }

    Rectangle {
        id: container
        anchors.centerIn: parent
        Layout.fillWidth: true
        Layout.fillHeight: true


        Component.onCompleted: {
            resetToIndex0();
            Help.registerTarget(thirdInput, "The gate outputs will automatically match the inputs for a given logic function and are also represented on the board by the green LEDs.", 2, "logicGateHelp")
            Help.registerTarget(inputAToggleContainer, "The inputs can be toggled on or off and are also represented on the board by blue LEDs.", 3, "logicGateHelp" )
            Help.registerTarget(logicSelection, "Use these buttons to select which logic function you want to run.", 4, "logicGateHelp")
            Help.registerTarget(gatesImage, "The image displayed represents the logic gate, its input controls and its outputs", 1, "logicGateHelp")
        }


        property var io_state: platformInterface.nl7sz97_io_state

        onIo_stateChanged : {
            if(currentIndex == 0) { //NL7SZ97 MUX
                value_A = "B"
                value_ANoti = platformInterface.nl7sz97_io_state.b
                value_B = "A"
                value_BNoti = platformInterface.nl7sz97_io_state.a
                value_C = "C"
                value_CNoti = platformInterface.nl7sz97_io_state.c
            }

            if(currentIndex == 1) { //NL7SZ97 AND
                value_A = "A"
                value_ANoti = platformInterface.nl7sz97_io_state.a
                value_B = "C"
                value_BNoti = platformInterface.nl7sz97_io_state.c
                value_C = "B"
                value_CNoti = platformInterface.nl7sz97_io_state.b
            }

            if(currentIndex == 2) { //NL7SZ97 OR NOTC
                value_A = "A"
                value_ANoti = platformInterface.nl7sz97_io_state.a
                value_B = "C"
                value_BNoti = platformInterface.nl7sz97_io_state.c
                value_C = "B"
                value_CNoti = platformInterface.nl7sz97_io_state.b
            }

            if(currentIndex == 3) { //NL7SZ97 AND NOTC

                value_A = "B"
                value_ANoti = platformInterface.nl7sz97_io_state.b
                value_B = "C"
                value_BNoti = platformInterface.nl7sz97_io_state.c
                value_C = "A"
                value_CNoti = platformInterface.nl7sz97_io_state.a
            }

            if(currentIndex == 4) { //NL7SZ97 OR
                value_A = "B"
                value_ANoti = platformInterface.nl7sz97_io_state.b
                value_B = "C"
                value_BNoti = platformInterface.nl7sz97_io_state.c
                value_C = "A"
                value_CNoti = platformInterface.nl7sz97_io_state.a
            }

            if(currentIndex == 5) { //NL7SZ97 Inverter
                value_A = "C"
                value_ANoti = platformInterface.nl7sz97_io_state.c
                value_B = "A"
                value_BNoti = platformInterface.nl7sz97_io_state.a
                value_C = "B"
                value_CNoti = platformInterface.nl7sz97_io_state.b
            }

            if(currentIndex == 6) { //NL7SZ97 Buffer
                value_A = "B"
                value_ANoti = platformInterface.nl7sz97_io_state.b
                value_B = "A"
                value_BNoti = platformInterface.nl7sz97_io_state.a
                value_C = "C"
                value_CNoti = platformInterface.nl7sz97_io_state.c
            }
        }

        // For the Selector Input LED Input 2
        property var valueB: value_BNoti
        onValueBChanged: {
            if( valueB === 1) {
                inputTwoToggle.checked = true
                sgStatusLightInputB.status = "green"
            }
            else {
                inputTwoToggle.checked = false
                sgStatusLightInputB.status = "off"
            }
        }

        // For the Selector switch Input 1
        property var valueA: value_ANoti
        onValueAChanged: {
            if( valueA === 1) {
                inputOneToggle.checked = true
            }
            else {
                inputOneToggle.checked = false
            }
        }

        // For output Y LED
        property var valueY:  platformInterface.nl7sz97_io_state.y
        onValueYChanged: {
            if(valueY === 1) {
                sgStatusLight.status = "green"
            }
            else sgStatusLight.status = "off"
        }

        // For the Selector LED Input 3
        property var valueC: value_CNoti
        onValueCChanged: {
            if(valueC === 1) {
                sgStatusLightTwo.status = "green"
                toggleSwitch1.checked = true
            }
            else {
                sgStatusLightTwo.status = "off"
                toggleSwitch1.checked = false
            }
        }

        SGSegmentedButtonStrip {
            id: logicSelection
            radius: 4
            buttonHeight: 45
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
                /*
              Changing the setting of the page based on which gate it is
            */
                SGSegmentedButton{  //nl7sz97 Mux
                    id: muxgate
                    text: qsTr("MUX")
                    checked: true  // Sets default checked button when exclusive
                    onClicked: {
                        gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/mux.png"
                        inputAToggleContainer.anchors.topMargin = -10
                        inputBToggleContainer.anchors.topMargin = 50
                        inputBToggleContainer.anchors.top = inputAToggleContainer.bottom
                        inputBToggleContainer.anchors.right = gatesImage.left
                        inputBToggleContainer.anchors.rightMargin = -5
                        thirdInput.anchors.topMargin = 100
                        //Input 2 container
                        sgStatusLightInputB.visible = false
                        inputTwoText.visible = true
                        inputTwoToggle.visible = true
                        //Input 3 container
                        sgStatusLightTwo.visible = false
                        toggleSwitch1.visible = true
                        inputThirdText.visible = true
                        platformInterface.mux_97.update();
                        currentIndex = 0
                    }
                }

                SGSegmentedButton{  //nl7sz97 And
                    text: qsTr("AND")
                    onClicked: {
                        gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/and.png"
                        inputAToggleContainer.anchors.topMargin = 10
                        inputBToggleContainer.anchors.topMargin = 10
                        inputBToggleContainer.anchors.top = inputAToggleContainer.bottom
                        inputBToggleContainer.anchors.right = gatesImage.left
                        inputBToggleContainer.anchors.rightMargin = -5
                        thirdInput.anchors.topMargin = 80
                        //Input 2 container
                        sgStatusLightInputB.visible = false
                        inputTwoText.visible = true
                        inputTwoToggle.visible = true
                        //Input 3 container
                        sgStatusLightTwo.visible = true
                        toggleSwitch1.visible = false
                        inputThirdText.visible = true
                        platformInterface.and_97.update();
                        currentIndex = 1
                    }
                }

                SGSegmentedButton{  //nl7sz97 OR gate with Not C
                    text: qsTr("OR NOTC")
                    onClicked: {
                        gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/or_nc.png"
                        inputAToggleContainer.anchors.topMargin = 10
                        inputBToggleContainer.anchors.topMargin = 20
                        inputBToggleContainer.anchors.top = inputAToggleContainer.bottom
                        inputBToggleContainer.anchors.right = gatesImage.left
                        inputBToggleContainer.anchors.rightMargin = -5
                        thirdInput.anchors.topMargin = 80
                        //Input 2 container
                        sgStatusLightInputB.visible = false
                        inputTwoText.visible = true
                        inputTwoToggle.visible = true
                        //Input 3 container
                        sgStatusLightTwo.visible = true
                        toggleSwitch1.visible = false
                        inputThirdText.visible = true
                        currentIndex = 2
                        platformInterface.or_nc_97.update();

                    }
                }

                SGSegmentedButton{  //nl7sz97 And gate with Not C
                    text: qsTr("AND NOTC")
                    onClicked: {
                        gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/and_nc.png"
                        inputAToggleContainer.anchors.topMargin = 10
                        inputBToggleContainer.anchors.topMargin = 10
                        inputBToggleContainer.anchors.top = inputAToggleContainer.bottom
                        inputBToggleContainer.anchors.right = gatesImage.left
                        inputBToggleContainer.anchors.rightMargin = -5
                        thirdInput.anchors.topMargin = 80
                        //Input 2 container
                        sgStatusLightInputB.visible = false
                        inputTwoText.visible = true
                        inputTwoToggle.visible = true
                        //Input 3 container
                        sgStatusLightTwo.visible = true
                        toggleSwitch1.visible = false
                        inputThirdText.visible = visible
                        currentIndex = 3
                        platformInterface.and_nc_97.update();
                    }
                }

                SGSegmentedButton{  //nl7sz97 OR gate
                    text: qsTr("OR")
                    onClicked: {
                        gateImageSource = "qrc:/views/logic-gate/images/nl7sz97/or.png"
                        inputAToggleContainer.anchors.topMargin = 10
                        inputBToggleContainer.anchors.topMargin = 20
                        inputBToggleContainer.anchors.top = inputAToggleContainer.bottom
                        inputBToggleContainer.anchors.right = gatesImage.left
                        inputBToggleContainer.anchors.rightMargin = -5
                        thirdInput.anchors.topMargin = 80
                        //Input 2 container
                        sgStatusLightInputB.visible = false
                        inputTwoText.visible = true
                        inputTwoToggle.visible = true
                        //Input 3 container
                        sgStatusLightTwo.visible = true
                        toggleSwitch1.visible = false
                        inputThirdText.visible = true
                        currentIndex = 4
                        platformInterface.or_97.update();
                    }
                }

                SGSegmentedButton{  //nl7sz97 Inverter
                    text: qsTr("Inverter")
                    onClicked: {
                        gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/inverter.png"
                        inputAToggleContainer.anchors.topMargin = 70
                        inputBToggleContainer.anchors.topMargin = 70
                        inputBToggleContainer.anchors.rightMargin = -150
                        thirdInput.anchors.topMargin = 20
                        //Input 2 container
                        sgStatusLightInputB.visible = true
                        inputTwoText.visible = false
                        inputTwoToggle.visible = false
                        //Input 3 container
                        sgStatusLightTwo.visible = true
                        toggleSwitch1.visible = false
                        inputThirdText.visible = true
                        currentIndex = 5
                        platformInterface.inverter_97.update();

                    }
                }

                SGSegmentedButton{  //nl7sz97 Buffer
                    text: qsTr("Buffer")
                    onClicked: {
                        gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/buffer.png"
                        inputAToggleContainer.anchors.topMargin = 70
                        inputBToggleContainer.anchors.topMargin = 70
                        inputBToggleContainer.anchors.rightMargin = -150
                        thirdInput.anchors.topMargin = 20
                        //Input 2 container
                        sgStatusLightInputB.visible = true
                        inputTwoText.visible = false
                        inputTwoToggle.visible = false
                        //Input 3 container
                        sgStatusLightTwo.visible = true
                        toggleSwitch1.visible = false
                        inputThirdText.visible = true
                        currentIndex = 6
                        platformInterface.buffer_97.update();
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
                verticalCenterOffset: -20
                horizontalCenter: logicSelection.horizontalCenter

            }

            Rectangle {

                anchors.centerIn: parent
                width : parent.width - 100
                height : parent.height - 100

                Rectangle { //Input 1 Container
                    id: inputAToggleContainer
                    width: 100
                    height: 100

                    anchors {
                        right : gatesImage.left
                        top: gatesImage.top
                    }

                    SGSwitch {  //Input 1 switch
                        id: inputOneToggle
                        anchors{
                            //top: parent.top
                            verticalCenter: parent.verticalCenter
                            //topMargin:
                        }

                        transform: Rotation { origin.x: 25; origin.y: 25; angle: 270 }

                        onClicked: {
                            if(inputOneText.text === "A") {
                                if(inputOneToggle.checked)  {
                                    platformInterface.write_io_97.update(1, platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                                }
                                else {
                                    platformInterface.write_io_97.update(0,platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                                }
                            }

                            else if(inputOneText.text === "B") {
                                if(inputOneToggle.checked)  {
                                    platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 1 , platformInterface.nl7sz97_io_state.c)
                                }
                                else {
                                    platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 0 , platformInterface.nl7sz97_io_state.c)
                                }
                            }

                            else if(inputOneText.text === "C") {
                                if(inputOneToggle.checked)  {
                                    platformInterface.write_io_97.update( platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b, 1)
                                }
                                else {
                                    platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b, 0)
                                }
                            }
                        }
                    }

                    Text {  //Input 1 text
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

                Rectangle { //Input 2 Container
                    id: inputBToggleContainer
                    width: 100
                    height: 100

                    anchors {
                        right: gatesImage.left
                        top: inputAToggleContainer.bottom
                    }

                    SGSwitch {  //Input 2 switch
                        id: inputTwoToggle
                        anchors{
                            verticalCenter: parent.verticalCenter
                        }

                        onClicked: {
                            if(inputTwoText.text === "A") {
                                if(inputTwoToggle.checked)  {
                                    platformInterface.write_io_97.update(1, platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                                }
                                else {
                                    platformInterface.write_io_97.update(0,platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                                }
                            }

                            else if(inputTwoText.text === "B") {
                                if(inputTwoToggle.checked)  {
                                    platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 1,platformInterface.nl7sz97_io_state.c)
                                }
                                else {
                                    platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, 0,platformInterface.nl7sz97_io_state.c)
                                }
                            }

                            else if(inputTwoText.text === "C") {
                                if(inputTwoToggle.checked)  {
                                    platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a,platformInterface.nl7sz97_io_state.b,1)
                                }
                                else {
                                    platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b,0)
                                }
                            }
                        }
                        transform: Rotation { origin.x: 25; origin.y: 25; angle: 270 }
                    }

                    Text {  //Input 2 text
                        id: inputTwoText
                        text: value_B
                        font.bold: true
                        font.pointSize: 30
                        anchors {
                            left: inputTwoToggle.right
                            // horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    SGStatusLight { //Input 2 Status Light
                        id: sgStatusLightInputB
                        label: "<b>" + value_B + "</b>" // Default: "" (if not entered, label will not appear)
                        lightSize: 50
                        textColor: "black"
                        status: off
                    }
                }

                Image { //Center gate picture
                    id: gatesImage
                    source: gateImageSource
                    anchors {
                        top: parent.top
                        centerIn: parent
                    }
                    fillMode:Image.PreserveAspectFit;
                }

                Rectangle { //Output Container
                    id: thirdInput
                    width: 80
                    height: 50
                    anchors {
                        left: gatesImage.right
                        top: inputAToggleContainer.top
                        topMargin: 50
                    }

                    SGStatusLight { //Output status light
                        id: sgStatusLight
                        label: "<b>Y</b>" // Default: "" (if not entered, label will not appear)
                        lightSize: 50
                        textColor: "black"
                        status : "off"
                        anchors.fill: thirdInput
                    }
                }

                Rectangle { //Input 3 Conatiner
                    id: inputCToggleContainer
                    width: 50
                    height: 50

                    anchors {
                        top: gatesImage.bottom
                        horizontalCenter: gatesImage.horizontalCenter
                        horizontalCenterOffset: -30
                    }

                    SGStatusLight { //Input 3 status light
                        id: sgStatusLightTwo
                        // Optional Configuration:
                        label: value_C // Default: "" (if not entered, label will not appear)
                        lightSize: 50
                        textColor: "black"
                        status : "off"
                    }

                    Text {  //Input 3 text
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

                    SGSwitch {  //Input 3 switch
                        id: toggleSwitch1
                        anchors{
                            left: inputThirdText.right
                        }

                        onClicked: {
                            if(inputThirdText.text === "A") {
                                if(toggleSwitch1.checked)  {
                                    platformInterface.write_io_97.update(1, platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                                }
                                else {
                                    platformInterface.write_io_97.update(0,platformInterface.nl7sz97_io_state.b, platformInterface.nl7sz97_io_state.c)
                                }
                            }

                            else if(inputThirdText.text === "B") {
                                if(toggleSwitch1.checked)  {
                                    platformInterface.write_io_97.update( platformInterface.nl7sz97_io_state.a, 1, platformInterface.nl7sz97_io_state.c)
                                }
                                else {
                                    platformInterface.write_io_97.update( platformInterface.nl7sz97_io_state.a, 0, platformInterface.nl7sz97_io_state.c)
                                }
                            }

                            else if(inputThirdText.text === "C") {
                                if(toggleSwitch1.checked)  {
                                    platformInterface.write_io_97.update( platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b, 1)
                                }
                                else {
                                    platformInterface.write_io_97.update(platformInterface.nl7sz97_io_state.a, platformInterface.nl7sz97_io_state.b,0)
                                }
                            }
                        }

                        transform: Rotation { origin.x: 25; origin.y: 25; angle: 270 }
                    }
                }
            } // end of the logicContainer

        }
    }
}

