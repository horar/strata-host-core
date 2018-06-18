import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import "qrc:/views/bubu/Control.js" as BubuControl


Rectangle{
    id:serialContainer
    property string binaryConversion: ""
    property int indexHolder: 0
    property string i2c_ack

    /*
      Parse notification to check the acknowledge
    */
    function i2cAckParse(notification) {
        var i2c_Ack = notification.payload.ack_or_nack;

        if(i2c_Ack !== undefined){
            i2cAcknowledge.text = i2c_Ack
            if(i2c_Ack === "ack") {
                i2cAcknowledge.textColor = "green"
            }
            else {
                i2cAcknowledge.textColor = "red"
            }
        }
        else
        {
            console.log("Junk data found", i2c_Ack);
        }
    }

    /*
        Parse i2c notification to get read data
    */
    function i2cReadDataParse(notification) {
        var readData = notification.payload.read_data

        if(readData !== undefined){
            dataValue.text = readData.toString(16);
        }
        else
        {
            console.log("Junk data found", readData);
        }
    }
    /*
        convert hexadecimal to binary
    */
    function hex2bin(hex){
        return ("00000000" + (parseInt(hex, 16)).toString(2)).substr(-8);
    }

    /*
        validate the string to check if it's hexadecimal
    */
    function isHex(str){
        var hexValues = '0123456789ABCDEFabcdef'

        for(var i = 0; i < str.length; ++i) {
            if(!hexValues.includes(str[i])) {
                return false;
            }

        }
        return true;
    }


    Text {
        id: i2cTitle
        text: "I2C Communication"
        font.family: "Helvetica"
        font.pointSize: 24
        anchors {
            left: serialContainer.left
            leftMargin: 10
        }
    }


    RowLayout {
        id: firstRowSetting
        width : parent.width
        height: 100
        anchors.top: i2cTitle.bottom

        Text {
            id: selectChannel
            text: "Channel Select"
            anchors {
                left: firstRowSetting.left
                leftMargin: 10
            }
        }

        ComboBox {
            id: i2cModel
            anchors{ left: selectChannel.right
                leftMargin: 10
            }
            model: ["I2C 1", "I2C 2", "I2C 3"]
            onCurrentIndexChanged: {
                if(currentIndex == 0) {
                    sclkModel.model = ["PB 10"]
                    sdaModel.model = ["PB 11"]

                }
                if(currentIndex == 1){
                    sclkModel.model = ["PC 0"]
                    sdaModel.model = ["PC 1"]

                }

                if(currentIndex == 2){
                    sclkModel.model = ["PB 8"]
                    sdaModel.model = ["PB 9"]

                }
            }

        }

        Text {
            id: selectSDA
            text: "SDA"

        }

        ComboBox {
            id: sdaModel
            anchors{ left: selectSDA.right
                leftMargin: 10
            }
            model: ["First", "Second", "Third"]

        }

        Text {
            id: selectSCLK
            text: "SCLK"
        }

        ComboBox {
            id:sclkModel
            anchors{ left: selectSCLK.right
                leftMargin: 10
            }
            model: ["First", "Second", "Third"]

        }

        Button {
            id: i2cConfig
            text : "Configure I2C"

            onClicked: {
                /*
                  set I2c Configure command
                */
                BubuControl.setI2cBusNumber(i2cModel.currentIndex+1);
                BubuControl.setI2cBusSpeed(busRateValue.text);
                coreInterface.sendCommand(BubuControl.getI2cConfigure());

            }
        }
    }

    RowLayout {
        id: secondRowSetting
        width : parent.width
        height: 100
        anchors.top: firstRowSetting.bottom

        Text {
            id: slaveAddress
            text: "Slave Address (Hex)"
            anchors {
                left: secondRowSetting.left
                leftMargin: 10
            }
        }

        TextField {
            id: slaveAddressValue
            anchors{ left: slaveAddress.right
                leftMargin: 10
            }
            text: "07"

        }

        Text {
            id: registerAddress
            text: "Register Address (Hex)"
        }
        TextField {
            id: registerAddressValue
            anchors{ left: registerAddress.right
                leftMargin: 10
            }
            text: "10"

        }

        Text {
            id: busRate
            text: "Bus Rate"
        }
        TextField {
            id: busRateValue
            anchors{ left: busRate.right
                leftMargin: 10
            }
            text : "400000"
        }
    }

    RowLayout {
        id: thirdRowSetting
        width : parent.width
        height: 100

        anchors.top: secondRowSetting.bottom

        Text {
            id: dataText
            anchors {
                left: thirdRowSetting.left
                leftMargin: 10
            }
            text: "Data (Hex)"
        }
        TextField {
            id: dataValue
            anchors{ left: dataText.right
                leftMargin: 10
            }

            text: "21"
            onTextChanged: {
                if(isHex(dataValue.text) === true) {
                    binaryConversion =  hex2bin(dataValue.text);
                }
                /*
                        Iterating the string to set the list model
                        to display the binary number
                */
                for (var i = 0; i < binaryConversion.length; ++i) {
                    binaryModal.get(i).value = binaryConversion.charAt(i);

                }
            }
        }


        ListView {
            id: bitview
            model: ListModel {
                id:binaryModal
                ListElement{
                    value:"0"
                }
                ListElement{
                    value:"0"
                }
                ListElement{
                    value:"0"
                }
                ListElement{
                    value:"0"
                }
                ListElement{
                    value:"0"
                }
                ListElement{
                    value:"0"
                }
                ListElement{
                    value:"0"
                }
                ListElement{
                    value:"0"
                }
            }

            width: 250
            height: 40
            spacing: 30
            anchors.leftMargin: 20
            orientation: ListView.Horizontal

            delegate: Rectangle  {
                id: binaryContainer
                TextField {
                    id: binaryNumber
                    text: value
                    width: 30
                    height: 30

                }

            }
        }
        Button {
            id: readButton
            anchors { left : bitview.right
                leftMargin: 20
            }
            text: "Read"
            onClicked: {
                /*
                  Set the I2C read command
                */
                BubuControl.setI2cBusNumber(i2cModel.currentIndex+1);
                BubuControl.setI2cSlaveAddressRead(parseInt(slaveAddressValue.text, 16));
                BubuControl.setI2cRegisterAddressRead(parseInt(registerAddressValue.text,16));
                coreInterface.sendCommand(BubuControl.getI2cRead());

            }

        }
        Button {
            id: writeButton
            anchors { left : readButton.right
                leftMargin: 20
            }
            text: "Write"
            onClicked: {
                /*
                  Set the I2C write command
                */
                BubuControl.setI2cBusNumber(i2cModel.currentIndex+1);
                BubuControl.setI2cSlaveAddressWrite(parseInt(slaveAddressValue.text, 16));
                BubuControl.setI2cRegisterAddressWrite(parseInt(registerAddressValue.text,16));
                BubuControl.setI2cData(parseInt(dataValue.text,16));
                coreInterface.sendCommand(BubuControl.getI2cWrite());

            }
        }

        TextField {
            id: i2cAcknowledge
            anchors { left : writeButton.right
                leftMargin: 20
            }
            placeholderText: "ACK/NCK"
        }

    }

    I2CTable {
        anchors.top: thirdRowSetting.bottom
    }


}
