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
        validate the string to check if it's hex
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
            left: parent.left
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
                left: parent.left
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
                left: parent.left
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
                left: parent.left
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
                */
                for (var i = 0; i < binaryConversion.length; i++) {
                    binaryModal.get(i).value = binaryConversion.charAt(i);

                }
            }

        }


        ListView {
            id: bitview
            model: ListModel{
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
                  Set the I2c read command
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
                  Set the I2c write command
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

    Button {
        id: addRow
        text: "+"
        anchors.bottom: i2cTable.top
        onClicked: {

            tableModel.append({"serialNum": tableModel.count+1,
                                  "slaveAddress": "0xab",
                                  "registerAddress": "0xcd",
                                  "data": "0x23",
                                  "operation": "R",
                                  "acknowledgement": "ACK/NAK" });
        }
    }

    Button {
        id: exportButton
        anchors { left : deleteRow.right
            leftMargin: 20
            bottom: i2cTable.top
        }
        text: "Export"
        onClicked: {
            /*
              push all the table information in single JSON
            */
            var tableDataHolder = { ListModel : [ ] }
            for (var i = 0; i < tableModel.count; ++i) {
                tableDataHolder.ListModel.push(tableModel.get(i));

            }

            var table = JSON.stringify(tableDataHolder);
            console.log(table);

        }
    }

    Button {
        id: importButton
        anchors { left : exportButton.right
            leftMargin: 20
            bottom: i2cTable.top
        }
        text: "Import"
    }



    Button {
        id: deleteRow
        text: "-"
        anchors.left: addRow.right
        anchors.bottom: i2cTable.top
        onClicked: tableModel.remove(i2cTable.currentRow)
    }

    ListModel {
        id: tableModel
        ListElement {
            serialNum: 1
            slaveAddress: "0xab"
            registerAddress: "0xcd"
            data: "0x23"
            operation: "R"
            acknowledgement: "ACK/NAK"

        }
    }
    Component {
        id: editableDelegate
        Item {
            Text {
                width: parent.width
                anchors.margins: 4
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                elide: styleData.elideMode
                text: styleData.value !== undefined ? styleData.value : ""
                color: styleData.textColor
                visible: !styleData.selected
            }
            Loader {
                id: loaderEditor
                anchors.fill: parent
                anchors.margins: 4
                Connections {
                    target: loaderEditor.item
                    onEditingFinished: {
                        tableModel.setProperty(styleData.row, styleData.role, loaderEditor.item.text)
                    }
                }
                sourceComponent: styleData.selected ? editor : null
                Component {
                    id: editor
                    TextInput {
                        id: textinput
                        color: styleData.textColor
                        text: styleData.value
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: textinput.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }
    TableView {
        id: i2cTable
        width: 1000
        height: 300
        anchors.top: thirdRowSetting.bottom

        TableViewColumn {
            role: "serialNum"
            title: "SR. No"
            width: 60
        }
        TableViewColumn {
            role: "slaveAddress"
            title: "Slave Address"
            width: 200
        }
        TableViewColumn {
            role: "registerAddress"
            title: "Register Address"
            width: 200
        }
        TableViewColumn {
            role: "data"
            title: "Data"
            width: 100
        }

        TableViewColumn {
            role: "operation"
            title: "Operation"
            width: 100
        }

        TableViewColumn {
            role: "acknowledgement"
            title: "Acknowledgement"
            width: 200
        }
        model: tableModel

        itemDelegate: {
            return editableDelegate;
        }
    }

    Button {
        id: execute
        anchors {
            top: i2cTable.bottom
        }
        text: "Execute"
    }

}
