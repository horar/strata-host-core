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
    property var value_ANoti
    property var value_BNoti
    property var value_CNoti
    property int currentIndex: 0

    function resetToIndex0(){
        gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/nand.png"
        inputAToggleContainer.anchors.topMargin = 10
        inputBToggleContainer.anchors.topMargin = 10
        inputBToggleContainer.anchors.leftMargin = 0
        thirdInput.anchors.topMargin = 80
        // Input 2 Container
        sgStatusLightInputTwo.visible = false
        inputTwoText.visible = true
        inputTwoToggle.visible = true
        currentIndex = 0
//        platformInterface.nand.update();
    }

    anchors {
        fill: parent
    }

    property var test_case: platformInterface.nl7sz58_io_state
    onTest_caseChanged : {
        if(currentIndex == 0) {
            value_A = "B"
            value_ANoti = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CNoti = platformInterface.nl7sz58_io_state.a
        }
        if(currentIndex == 1) {
            value_A = "B"
            value_ANoti = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CNoti = platformInterface.nl7sz58_io_state.a

        }
        if(currentIndex == 2) {
            value_A = "A"
            value_ANoti = platformInterface.nl7sz58_io_state.a
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "B"
            value_CNoti = platformInterface.nl7sz58_io_state.b
        }
        if(currentIndex == 3) {

            value_A = "A"
            value_ANoti = platformInterface.nl7sz58_io_state.a
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "B"
            value_CNoti = platformInterface.nl7sz58_io_state.b
        }

        if(currentIndex == 4) {
            value_A = "B"
            value_ANoti = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CNoti = platformInterface.nl7sz58_io_state.b

        }
        if(currentIndex == 5) {
            value_A = "B"
            value_ANoti = platformInterface.nl7sz58_io_state.b
            value_B = "A"
            value_BNoti = platformInterface.nl7sz58_io_state.a
            value_C = "C"
            value_CNoti = platformInterface.nl7sz58_io_state.c

        }
        if(currentIndex == 6) {
            value_A = "A"
            value_ANoti = platformInterface.nl7sz58_io_state.a
            value_B = "B"
            value_BNoti = platformInterface.nl7sz58_io_state.b
            value_C = "C"
            value_CNoti = platformInterface.nl7sz58_io_state.c

        }
    }


    property var valueB: value_BNoti
    onValueBChanged: {
        if(valueB === 1) {
            inputTwoToggle.checked = true
        }
        else {
            inputTwoToggle.checked = false
        }

    }

    property var valueA: value_ANoti
    onValueAChanged: {
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

    property var valueC: value_CNoti
    onValueCChanged: {
        if(valueC === 1) {
            sgStatusLightTwo.status = "green"
        }
        else sgStatusLightTwo.status = "off"
    }

    SGSegmentedButtonStrip {
        id: logicSelectionList
        radius: 4
        buttonHeight: 25
        visible: true
        anchors {
            top: parent.top
            topMargin: 40
            horizontalCenter: parent.horizontalCenter
        }

        Component.onCompleted: {
            resetToIndex0();
        }
        segmentedButtons: GridLayout {
            columnSpacing: 1

            SGSegmentedButton{
                text: qsTr("NAND")
                checked: true  // Sets default checked button when exclusive
                onClicked: {
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/nand.png"
                    inputAToggleContainer.anchors.topMargin = 10
                    inputBToggleContainer.anchors.topMargin = 10
                    inputBToggleContainer.anchors.leftMargin = 0
                    thirdInput.anchors.topMargin = 80
                    // Input 2 Container
                    sgStatusLightInputTwo.visible = false
                    inputTwoText.visible = true
                    inputTwoToggle.visible = true
                    currentIndex = 0
                    platformInterface.nand.update();
                }
            }

            SGSegmentedButton{
                text: qsTr("AND NOTB")
                onClicked: {
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/nand_nb.png"
                    inputAToggleContainer.anchors.topMargin = 10
                    inputBToggleContainer.anchors.topMargin = 10
                    inputBToggleContainer.anchors.leftMargin = 0
                    thirdInput.anchors.topMargin = 80
                    // Input 2 Container
                    sgStatusLightInputTwo.visible = false
                    inputTwoText.visible = true
                    inputTwoToggle.visible = true
                    currentIndex = 1;
                    platformInterface.and_nb.update();
                }
            }

            SGSegmentedButton{
                text: qsTr("AND NOTC")
                onClicked: {
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/and_nc.png"
                    inputAToggleContainer.anchors.topMargin = 10
                    inputBToggleContainer.anchors.topMargin = 10
                    inputBToggleContainer.anchors.leftMargin = 0
                    thirdInput.anchors.topMargin = 80
                    // Input 2 Container
                    sgStatusLightInputTwo.visible = false
                    inputTwoText.visible = true
                    inputTwoToggle.visible = true
                    currentIndex = 2
                    platformInterface.and_nc.update();
                }
            }
            SGSegmentedButton{
                text: qsTr("OR")
                onClicked: {
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/or.png"
                    inputAToggleContainer.anchors.topMargin = 10
                    inputBToggleContainer.anchors.topMargin = 20
                    inputBToggleContainer.anchors.leftMargin = 0
                    thirdInput.anchors.topMargin = 80
                    // Input 2 Container
                    sgStatusLightInputTwo.visible = false
                    inputTwoText.visible = true
                    inputTwoToggle.visible = true
                    currentIndex = 3
                    platformInterface.or.update();
                }
            }
            SGSegmentedButton{
                text: qsTr("XOR")
                onClicked: {
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/xor.png"
                    inputAToggleContainer.anchors.topMargin = 10
                    inputBToggleContainer.anchors.topMargin = 20
                    inputBToggleContainer.anchors.leftMargin = 0
                    thirdInput.anchors.topMargin = 80
                    // Input 2 Container
                    sgStatusLightInputTwo.visible = false
                    inputTwoText.visible = true
                    inputTwoToggle.visible = true
                    currentIndex = 4
                    platformInterface.xor.update();
                }
            }
            SGSegmentedButton{
                text: qsTr("Inverter")
                onClicked: {
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/inverter.png"
                    inputAToggleContainer.anchors.topMargin = 70
                    inputBToggleContainer.anchors.topMargin = 70
                    inputBToggleContainer.anchors.leftMargin = 150
                    thirdInput.anchors.topMargin = 20
                    // Input 2 Container
                    sgStatusLightInputTwo.visible = true
                    inputTwoText.visible = false
                    inputTwoToggle.visible = false
                    currentIndex = 5
                    platformInterface.inverter.update()
                }
            }
            SGSegmentedButton{
                text: qsTr("Buffer")
                onClicked: {
//                    inputName = "B = C"
                    gateImageSource = "qrc:/views/logic-gate/images/nl7sz58/buffer.png"
                    inputAToggleContainer.anchors.topMargin = 70
                    inputBToggleContainer.anchors.topMargin = 70
                    inputBToggleContainer.anchors.leftMargin = 150
                    thirdInput.anchors.topMargin = 20
                    // Input 2 Container
                    sgStatusLightInputTwo.visible = true
                    inputTwoText.visible = false
                    inputTwoToggle.visible = false
                    currentIndex = 6
                    platformInterface.buffer.update();
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

                    if(inputOneText.text === "A") {
                        if(inputOneToggle.checked)  {
                            platformInterface.write_io.update(1, platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()

                        }
                        else {
                            platformInterface.write_io.update(0, platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()

                        }
                    }
                    if(inputOneText.text === "B") {
                        if(inputOneToggle.checked)  {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,1, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()

                        }
                        else {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,0, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()

                        }
                    }
                    if(inputOneText.text === "C") {
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
                            platformInterface.write_io.update(1,platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()
                        }
                        else {
                            platformInterface.write_io.update(0,platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()
                        }
                    }
                    if(inputTwoText.text === "B") {
                        if(inputTwoToggle.checked)  {

                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, 1, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()
                        }
                        else {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, 0, platformInterface.nl7sz58_io_state.c)
                            platformInterface.write_io.show()
                        }
                    }
                    if(inputTwoText.text === "C") {
                        if(inputTwoToggle.checked)  {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,platformInterface.nl7sz58_io_state.b,1)
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
                id: sgStatusLightInputTwo
                // Optional Configuration:
                label: "<b>" + value_B + "</b>" // Default: "" (if not entered, label will not appear)
//                labelLeft: false        // Default: true
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
                topMargin: 70
            }
//            Rectangle{
//                color: "green"
//                opacity: .15
//                anchors{
//                    fill: parent
//                }
//                z:20
//            }

            SGStatusLight {
                id: sgStatusLight
                label: "<b>Y</b>" // Default: "" (if not entered, label will not appear)
//                labelLeft: false        // Default: true
                // status: "off"           // Default: "off"
                lightSize: 50           // Default: 50
                textColor: "black"           // Default: "black"
                status : "off"
            }
        }
        Rectangle {
            id: fourInputContainer
            width: 50
            height: 50
            anchors {
                top: gatesImage.bottom
                horizontalCenter: gatesImage.horizontalCenter
                horizontalCenterOffset: -30
            }
//            Rectangle{
//                color: "red"
//                opacity: .15
//                anchors{
//                    fill: parent
//                }
//                z:20
//            }

            SGStatusLight {
                id: sgStatusLightTwo
                label: value_C // Default: "" (if not entered, label will not appear)
//                labelLeft: false        // Default: true
                // status: "off"           // Default: "off"
                lightSize: 50           // Default: 50
                textColor: "black"           // Default: "black"
                status : "off"

            }
        }
    }

}


