import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import "qrc:/views/logic-gate/sgwidgets"

Rectangle {
    id: container
    property string gateImageSource
    property string value_A: A
    property string value_B: B
    property string value_C: C
    property var value_ANoti
    property var value_BNoti
    property var value_CNoti
    property int currentIndex: 0

    //Reset view for the nl7sz58 tab
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
        logicSelectionList.index = 0
    }

    anchors {
        fill: parent
    }

    property var test_case: platformInterface.nl7sz58_io_state
    onTest_caseChanged : {
        if(currentIndex == 0) { //NL7SZ58 NAND
            value_A = "B"
            value_ANoti = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CNoti = platformInterface.nl7sz58_io_state.a
        }

        if(currentIndex == 1) { //NL7SZ58 AND NOT B
            value_A = "B"
            value_ANoti = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CNoti = platformInterface.nl7sz58_io_state.a
        }

        if(currentIndex == 2) { //NL7SZ58 AND NOT C
            value_A = "A"
            value_ANoti = platformInterface.nl7sz58_io_state.a
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "B"
            value_CNoti = platformInterface.nl7sz58_io_state.b
        }

        if(currentIndex == 3) { //NL7SZ58 OR
            value_A = "A"
            value_ANoti = platformInterface.nl7sz58_io_state.a
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "B"
            value_CNoti = platformInterface.nl7sz58_io_state.b
        }

        if(currentIndex == 4) { //NL7SZ58 XOR
            value_A = "B"
            value_ANoti = platformInterface.nl7sz58_io_state.b
            value_B = "C"
            value_BNoti = platformInterface.nl7sz58_io_state.c
            value_C = "A"
            value_CNoti = platformInterface.nl7sz58_io_state.b
        }

        if(currentIndex == 5) { //NL7SZ58 Inverter
            value_A = "B"
            value_ANoti = platformInterface.nl7sz58_io_state.b
            value_B = "A"
            value_BNoti = platformInterface.nl7sz58_io_state.a
            value_C = "C"
            value_CNoti = platformInterface.nl7sz58_io_state.c
        }

        if(currentIndex == 6) { //NL7SZ58 Buffer
            value_A = "A"
            value_ANoti = platformInterface.nl7sz58_io_state.a
            value_B = "B"
            value_BNoti = platformInterface.nl7sz58_io_state.b
            value_C = "C"
            value_CNoti = platformInterface.nl7sz58_io_state.c
        }
    }

    // For the Selector Switch Input 2
    property var valueB: value_BNoti
    onValueBChanged: {
        if(valueB === 1) {
            inputTwoToggle.checked = true
        }
        else {
            inputTwoToggle.checked = false
        }
    }

    // For the Selector Switch Input 1
    property var valueA: value_ANoti
    onValueAChanged: {
        if( valueA === 1) {
            inputOneToggle.checked = true
        }
        else {
            inputOneToggle.checked = false
        }
    }

    // For the Selector status light Input 3
    property var valueY:  platformInterface.nl7sz58_io_state.y
    onValueYChanged: {
        if(valueY === 1) {
            sgStatusLight.status = "green"
        }
        else sgStatusLight.status = "off"
    }

    // For the status light output Y
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
            /*
              Changing the setting of the page based on which gate it is
            */
            SGSegmentedButton{  //nl7sz58 Nand
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

            SGSegmentedButton{  //nl7sz58 AND NOT B
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

            SGSegmentedButton{  //nl7sz58 AND NOT C
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

            SGSegmentedButton{  //nl7sz58 OR
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

            SGSegmentedButton{  //nl7sz58 XOR
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

            SGSegmentedButton{  //nl7sz58 Inverter
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

            SGSegmentedButton{  //nl7sz58 Buffer
                text: qsTr("Buffer")
                onClicked: {
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

        Rectangle { //Input 1 Container
            id: inputAToggleContainer
            width: 100
            height: 100

            anchors {
                left: logicContainer.left
                top: logicContainer.top
                topMargin: 20
            }

            SGSwitch {  //Input 1 switch
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
                        }
                        else {
                            platformInterface.write_io.update(0, platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                        }
                    }

                    if(inputOneText.text === "B" ) {
                        // When the function is XOR (index = 4) A = B
                        if(currentIndex === 4) {
                            if(inputOneToggle.checked)  {
                                platformInterface.write_io.update(1,1, platformInterface.nl7sz58_io_state.c)
                            }
                            else {
                                platformInterface.write_io.update(0,0, platformInterface.nl7sz58_io_state.c)
                            }
                        }

                        else {
                            if(inputOneToggle.checked)  {
                                console.log("in the else case of its")
                                platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,1, platformInterface.nl7sz58_io_state.c)
                            }
                            else {
                                platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,0, platformInterface.nl7sz58_io_state.c)
                            }
                        }
                    }

                    if(inputOneText.text === "C") {
                        if(inputOneToggle.checked)  {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,platformInterface.nl7sz58_io_state.b,1)
                        }
                        else {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, platformInterface.nl7sz58_io_state.b,0)
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

        Rectangle { //Input 2 container
            id: inputBToggleContainer
            width: 100
            height: 100

            anchors {
                left: logicContainer.left
                top: inputAToggleContainer.bottom
            }

            SGSwitch {  //Input 2 switch
                id: inputTwoToggle
                anchors{
                    top: parent.top
                    topMargin: 30
                }

                onClicked: {
                    if( inputTwoText.text === "A") {
                        if(inputTwoToggle.checked)  {
                            platformInterface.write_io.update(1,platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                        }
                        else {
                            platformInterface.write_io.update(0,platformInterface.nl7sz58_io_state.b, platformInterface.nl7sz58_io_state.c)
                        }
                    }

                    if(inputTwoText.text === "B") {
                        if(inputTwoToggle.checked)  {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, 1, platformInterface.nl7sz58_io_state.c)
                        }
                        else {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a, 0, platformInterface.nl7sz58_io_state.c)
                        }
                    }

                    if(inputTwoText.text === "C") {
                        if(inputTwoToggle.checked)  {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,platformInterface.nl7sz58_io_state.b,1)
                        }
                        else {
                            platformInterface.write_io.update(platformInterface.nl7sz58_io_state.a,platformInterface.nl7sz58_io_state.b,0)
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
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }

            SGStatusLight { //Input 2 status light
                id: sgStatusLightInputTwo
                label: "<b>" + value_B + "</b>" // Default: "" (if not entered, label will not appear)
                lightSize: 50
                textColor: "black"
                status : "off"
            }
        }

        Image { //Center Image
            id: gatesImage
            source: gateImageSource
            anchors {
                left: inputAToggleContainer.right
            }
            fillMode: Image.PreserveAspectFit
        }

        Rectangle { //Input 3 Container
            id: thirdInput
            width: 50
            height: 50
            anchors {
                left: gatesImage.right
                top: inputAToggleContainer.top
                topMargin: 70
            }

            SGStatusLight { //Input 3 status light
                id: sgStatusLight
                label: "<b>Y</b>" // Default: "" (if not entered, label will not appear)
                lightSize: 50
                textColor: "black"
                status : "off"
            }
        }

        Rectangle { //Output Y Container
            id: fourInputContainer
            width: 50
            height: 50
            anchors {
                top: gatesImage.bottom
                horizontalCenter: gatesImage.horizontalCenter
                horizontalCenterOffset: -30
            }

            SGStatusLight { //Output status light
                id: sgStatusLightTwo
                label: value_C // Default: "" (if not entered, label will not appear)
                lightSize: 50
                textColor: "black"
                status : "off"
            }
        }
    }
}


