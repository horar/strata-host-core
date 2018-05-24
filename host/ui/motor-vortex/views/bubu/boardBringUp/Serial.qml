import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4


Rectangle{
    id:serialContainer
    property string binaryConversion: ""
    property int indexHolder: 0
    // visible: opacity > 0
    anchors.fill:parent

    function hex2bin(hex){
        return ("00000000" + (parseInt(hex, 16)).toString(2)).substr(-8);
    }

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
            anchors{ left: selectChannel.right
             leftMargin: 10
            }
            model: ["I2C 1", "I2C 2", "I2C 3"]
            onCurrentIndexChanged: {
                if(currentIndex == 0) {
                    sclkModel.model = ["PG 14","PB 6", "PB 8"]
                    sdaModel.model = ["PG 13", "PB 7", "PB 9"]

                }
                if(currentIndex == 1){
                    sclkModel.model = ["PF 1","PB 10", "PB 13"]
                    sdaModel.model = ["PF 0", "PB 11", "PB 14"]

                }

                if(currentIndex == 2){
                    sclkModel.model = ["PC 0","PG 7"]
                    sdaModel.model = ["PC 1", "PG 8"]

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
    }

    RowLayout {
        id: secondRowSetting
        width : parent.width
        height: 100
        anchors.top: firstRowSetting.bottom

        Text {
            id: slaveAddress
            text: "Slave Address"
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
            placeholderText: "0XXX"

        }

        Text {
            id: registerAddress
            text: "Register Address"
        }
        TextField {
            id: registerAddressValue
            anchors{ left: registerAddress.right
             leftMargin: 10
            }
            placeholderText: "0X23"

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
            placeholderText: "0"
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

            placeholderText: "0X22"
            onEditingFinished: {

                if(isHex(text) == true) {
                binaryConversion =  hex2bin(text); }

                /*
                    iterating the string to set the list model
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
            anchors { left: dataValue.right
                leftMargin: 20
            }
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
        }
        Button {
            id: writeButton
            anchors { left : readButton.right
            leftMargin: 20
            }
            text: "Write"
        }

    }

    Button {
        id: addRow
        text: "+"
        anchors.bottom: i2cTable.top
        onClicked: tableModel.append({"serialNum": tableModel.count+1,
                                         "slaveAddress": "0xab",
                                         "registerAddress": "0xcd",
                                         "data": "0x23",
                                         "operation": "R",
                                         "acknowledgement": "ACK/NAK" });
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

}
