import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4


Rectangle{
    id:serialTab
    objectName: "serialTab"
    opacity: 1
    anchors.fill:parent

    GroupBox{
        id:testingGroupBox
        title:"I2C Testing"
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        width:parent.width - 100
        height:130
        font.family: "helvetica"
        font.pointSize: 24
        font.bold: true

        Rectangle{
            anchors.top: parent.top
            anchors.topMargin: -10
            anchors.left:parent.left
            anchors.leftMargin:-10
            anchors.right:parent.right
            anchors.rightMargin: -10
            anchors.bottom:parent.bottom
            anchors.bottomMargin: -10

            color:lightGreyColor
        }

        Label {
            id: channelSelect
            text: qsTr("Channel Select:")
            anchors.left: parent.left
            anchors.leftMargin: 20
            font.family:"helvetica"
            font.pointSize: 20
            font.bold: false
        }

        ComboBox {
            id: channelSelectComboBox
            anchors.top:channelSelect.bottom
            anchors.horizontalCenter: channelSelect.horizontalCenter
            font.family:"helvetica"
            font.pointSize: 15
            font.bold: false
            model: ListModel {
                id: model
                ListElement { text: "I2C_1" }
                ListElement { text: "I2C_2" }
                ListElement { text: "I2C_3" }
            }
        }

        Label {
            id : slaveAddress
            text: qsTr("Slave Address:")
            anchors.leftMargin: 40
            anchors.left: channelSelect.right
            font.family:"helvetica"
            font.pointSize: 20
            font.bold: false
        }

        Label {
            id : slaveAddress7Bit
            text: qsTr("(7- bit)")
            anchors.leftMargin: 5
            anchors.left: slaveAddress.right
            anchors.bottom: slaveAddress.bottom
            anchors.bottomMargin:5
            font.family:"helvetica"
            font.pointSize: 12
            font.bold: false
        }

        TextField {
            id: slaveAddressInput
            anchors.top:slaveAddress.bottom
            anchors.topMargin:10
            anchors.horizontalCenter: slaveAddress.horizontalCenter
            width: 128
            height: 26
            //selectByMouse: true
            //cursorVisible : true
            placeholderText: qsTr("0x1F")
            font.family:"helvetica"
            font.pointSize: 20
            font.bold: false
            color: "black"

        }

        Label {
            id: registerAddress
            text: qsTr("Register Address:")
            anchors.leftMargin: 40
            anchors.left: slaveAddress7Bit.right
            font.family:"helvetica"
            font.pointSize: 20
            font.bold: false
        }

        TextField {
            id: registerAddressTextField
            anchors.top:registerAddress.bottom
            anchors.topMargin:10
            anchors.left: registerAddress.left
            width: 121
            height: 26
            placeholderText: qsTr("0x1C")
            font.family:"helvetica"
            font.pointSize: 20
            font.bold: false
        }

        Label {
            id: dataPayload
            anchors.leftMargin: 40
            anchors.left: registerAddress.right
            text: qsTr("Data:")
            font.family:"helvetica"
            font.pointSize: 20
            font.bold: false
        }

        TextField {
            id: dataPayloadTextField
            anchors.top:dataPayload.bottom
            anchors.topMargin:10
            anchors.left: dataPayload.left
            width: 50
            height: 26
            placeholderText: qsTr("0x1C")
            font.family:"helvetica"
            font.pointSize: 20
            font.bold: false
        }

       Row{
           id: bitRow
           anchors.verticalCenter:dataPayloadTextField.verticalCenter
           anchors.verticalCenterOffset: -5
           anchors.left:dataPayload.right
           anchors.leftMargin: 20

           CheckBox {
               id: bit7
               width:25
           }

            CheckBox {
                id: bit6
                width:25
            }

            CheckBox {
                id: bit5
                width:25
            }

            CheckBox {
                id: bit4
                width:25
            }

            CheckBox {
                id: bit3
                width:25
            }

            CheckBox {
                id: bit2
                width:25
            }

            CheckBox {
                id: bit1
                width:25
            }

            CheckBox {
                id: bit0
                width:25
            }
        }

       Label {
           id: bit7Title
           text: qsTr("Bit 7")
           anchors.left:bitRow.left
           anchors.top: bitRow.bottom
           anchors.topMargin: -10
           font.family:"helvetica"
           font.pointSize: 12
           font.bold: false
       }


       Label {
           id: bit0Title
           anchors.right:bitRow.right
           anchors.top: bitRow.bottom
           anchors.topMargin: -10
           text: qsTr("Bit 0")
           font.family:"helvetica"
           font.pointSize: 12
           font.bold: false
       }

       Button {
           id: readButton
           anchors.right: parent.right
           anchors.rightMargin: 20
           anchors.top:parent.top
           anchors.topMargin:-12
           width:100
           height:50
           text: qsTr("Read")
           font.family:"helvetica"
           font.pointSize: 20
           font.bold: false
       }

        Button {
            id: writeButton
            anchors.top:readButton.bottom
            anchors.right: parent.right
            anchors.rightMargin: 20
            width:100
            height:50
            text: "Write"
            font.family:"helvetica"
            font.pointSize: 20
            font.bold: false
        }

  }   //testing group box


    //------------------------------------------------------
    //  I2C Settings
    //------------------------------------------------------
    GroupBox{
        id:i2cGroupBox
        title:"I2C Settings"
        anchors.top: testingGroupBox.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width:parent.width - 100
        height:130
        font.family: "helvetica"
        font.pointSize: 24
        font.bold: true

        Rectangle{
            anchors.top: parent.top
            anchors.topMargin: -10
            anchors.left:parent.left
            anchors.leftMargin:-10
            anchors.right:parent.right
            anchors.rightMargin: -10
            anchors.bottom:parent.bottom
            anchors.bottomMargin: -10

            color:lightGreyColor
        }

        Label {
            id: dataFormatLabel
            anchors.left:parent.left
            anchors.leftMargin: 20
            anchors.top:parent.top
            anchors.topMargin:0
            text: qsTr("Display Format: ")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }


        ButtonGroup {
            id: displayFormatGroup
            exclusive: true
        }

        RadioButton {
            id: radioButton1
            checked:true
            anchors.left:dataFormatLabel.right
            anchors.leftMargin: 10
            anchors.top: dataFormatLabel.top
            anchors.topMargin: -15
            ButtonGroup.group: displayFormatGroup
            text: qsTr("Decimal")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        RadioButton {
            id: radioButton2
            anchors.left:radioButton1.left
            anchors.top:radioButton1.bottom
            anchors.topMargin: -20
            ButtonGroup.group: displayFormatGroup
            text: qsTr("Hexidecimal")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        RadioButton {
            id: radioButton3
            anchors.left:radioButton2.left
            anchors.top:radioButton2.bottom
            anchors.topMargin: -20
            ButtonGroup.group: displayFormatGroup
            text: qsTr("Binary")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }


        Label {
            id: busRateLabel
            anchors.left: dataFormatLabel.right
            anchors.leftMargin: 200
            width: 104
            height: 34
            text: qsTr("Bus Rate:")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        Label {
            id: busRateValue
            anchors.left: busRateLabel.right
            anchors.leftMargin:-10
            anchors.top: busRateLabel.top
            width: 20
            height: 45
            text:  busRateSlider.value
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false

        }

        Label {
            id: busRateUnitValueLabel
            anchors.left: busRateValue.right
            anchors.leftMargin:12
            anchors.bottom: busRateValue.bottom
            anchors.bottomMargin: -3
            width: 20
            height: 45
            text:  "kHz"
            font.family: "helvetica"
            font.pointSize: 15
            font.bold: false

        }

        Slider {
            id: busRateSlider
            anchors.left: busRateUnitValueLabel.right
            anchors.leftMargin: 10
            anchors.verticalCenter: busRateLabel.verticalCenter
            anchors.verticalCenterOffset: -8
            live : true
            width: 200
            height: 32
            from: 1
            to: 100
            value: 1
            stepSize: 1
        }

        Label {
            id: oneKLabel
            anchors.left: busRateSlider.left
            anchors.top: busRateSlider.bottom
            text: qsTr("1")
            font.family: "helvetica"
            font.pointSize: 12
            font.bold: false
        }

        Label {
            id: oneHundredKLabel
            anchors.right: busRateSlider.right
            anchors.top: busRateSlider.bottom
            text: qsTr("100")
            font.family: "helvetica"
            font.pointSize: 12
            font.bold: false
        }
    }

    //-------------------------------------------
    //  SPI groupbox
    //-------------------------------------------
    GroupBox{
        id:spiGroupBox
        title:"SPI Testing"
        anchors.top: i2cGroupBox.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width:parent.width - 100
        height:130
        font.family: "helvetica"
        font.pointSize: 24
        font.bold: true

        Rectangle{
            anchors.top: parent.top
            anchors.topMargin: -10
            anchors.left:parent.left
            anchors.leftMargin:-10
            anchors.right:parent.right
            anchors.rightMargin: -10
            anchors.bottom:parent.bottom
            anchors.bottomMargin: -10

            color:lightGreyColor
        }

        Label {
            id: clockRateLabel
            anchors.left:parent.left
            anchors.leftMargin: 20
            text: qsTr("Clock Rate: ")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        TextField {
            id: clockRateTextField
            anchors.left:clockRateLabel.right
            anchors.leftMargin: 10
            anchors.verticalCenter: clockRateLabel.verticalCenter
            anchors.verticalCenterOffset: 5
            height: 26
            width:50
            placeholderText: qsTr("1")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        Label {
            id: clockRateUnitLabel
            anchors.left:clockRateTextField.right
            anchors.leftMargin: 10
            anchors.verticalCenter:clockRateLabel.verticalCenter
            text: qsTr("MHz")
            font.family: "helvetica"
            font.pointSize: 15
            font.bold: false
        }

        Label {
            id: spiDataLabel
            anchors.left:clockRateUnitLabel.right
            anchors.leftMargin: 20
            text: qsTr("Data:")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        TextField {
            id: spiDataTextField
            anchors.left:spiDataLabel.right
            anchors.leftMargin: 10
            anchors.verticalCenter: spiDataLabel.verticalCenter
            anchors.verticalCenterOffset: 5
            height: 26
            placeholderText: qsTr("0x00")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        Button {
            id: spiReadButton
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top:parent.top
            anchors.topMargin:-12
            width:100
            height:50
            text: qsTr("Read")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false

        }

        Button {
            id: spiWriteButton
            anchors.top:spiReadButton.bottom
            anchors.left:spiReadButton.left
            width:100
            height:50
            text: "Write"
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false

        }

    }

    //---------------------------------
    //  UART testing
    //---------------------------------
    GroupBox{
        id:uartGroupBox
        title:"UART Testing"
        anchors.top: spiGroupBox.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width:parent.width - 100
        height:130
        font.family: "helvetica"
        font.pointSize: 24
        font.bold: true

        Rectangle{
            anchors.top: parent.top
            anchors.topMargin: -10
            anchors.left:parent.left
            anchors.leftMargin:-10
            anchors.right:parent.right
            anchors.rightMargin: -10
            anchors.bottom:parent.bottom
            anchors.bottomMargin: -10

            color:lightGreyColor
        }

        Label {
            id: baudRateLabel
            anchors.left:parent.left
            anchors.leftMargin: 20
            text: qsTr("Baud Rate:")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        TextField {
            id: baudRateTextField
            anchors.left:baudRateLabel.right
            anchors.leftMargin: 10
            anchors.verticalCenter: baudRateLabel.verticalCenter
            anchors.verticalCenterOffset: 5
            height: 26
            placeholderText: qsTr("115200")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        Label {
            id: parityLabel
            anchors.left:baudRateTextField.right
            anchors.leftMargin: 20
            text: qsTr("Parity:")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        CheckBox{
            id:parityCheckBox
            anchors.left:parityLabel.right
            anchors.leftMargin: 0
            anchors.verticalCenter: parityLabel.verticalCenter
        }

        Label {
            id: dataLabel
            anchors.left:parityCheckBox.right
            anchors.leftMargin: 20
            text: qsTr("Data:")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }


        TextField {
            id: dataTextField
            anchors.left:dataLabel.right
            anchors.leftMargin: 10
            anchors.verticalCenter: dataLabel.verticalCenter
            anchors.verticalCenterOffset: 5
            height: 26
            placeholderText: qsTr("0x00")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }



        Label {
            id: stopBitLabel
            anchors.left:dataTextField.right
            anchors.leftMargin: 30
            text: qsTr("Stop Bit:")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }


        ButtonGroup {
            id: tabPositionGroup2
            exclusive:true
        }
        RadioButton {
            id: stopBitRadio
            anchors.left:stopBitLabel.right
            anchors.leftMargin: 10
            anchors.verticalCenter: stopBitLabel.verticalCenter
            ButtonGroup.group: tabPositionGroup2
            checked: true
            text: qsTr("0")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }

        RadioButton {
            id: stopBitRadio1
            anchors.left: stopBitRadio.left
            anchors.top:stopBitRadio.bottom
            anchors.topMargin: -20
            ButtonGroup.group: tabPositionGroup2
            text: qsTr("1")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false
        }


        Button {
            id: uartReadButton
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top:parent.top
            anchors.topMargin:-12
            width:100
            height:50
            text: qsTr("Read")
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false

        }

        Button {
            id: uartWriteButton
            anchors.top:uartReadButton.bottom
            anchors.left:uartReadButton.left
            width: 100
            height: 50
            text: "Write"
            font.family: "helvetica"
            font.pointSize: 20
            font.bold: false

        }




    }
}

