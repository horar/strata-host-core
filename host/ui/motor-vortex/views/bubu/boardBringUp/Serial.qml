import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4


Rectangle{
    id:serialContainer
    // visible: opacity > 0
    anchors.fill:parent

    function hex2bin(hex){
        return ("00000000" + (parseInt(hex, 16)).toString(2)).substr(-8);
    }

    Text {
        id: i2cTitle
        text: "I2C Communication"
        font.family: "Helvetica"
        font.pointSize: 24
    }


    RowLayout {
        id: firstRowSetting
        width : parent.width
        height: 100
        anchors.top: i2cTitle.bottom

        Text {
            id: selectChannel
            text: "Channel Select"
        }

        ComboBox {
            model: ["I2C 1", "I2C 2", "I2C 3"]
        }

        Text {
            id: selectSDA
            text: "SDA"
        }

        ComboBox {
            model: ["First", "Second", "Third"]
        }

        Text {
            id: selectSCLK
            text: "SCLK"
        }

        ComboBox {
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
        }

        TextField {
            id: slaveAddressValue
            placeholderText: "0XXX"


        }

        Text {
            id: registerAddress
            text: "Register Address"
        }
        TextField {
            id: registerAddressValue
            placeholderText: "0X23"

        }

        Text {
            id: busRate
            text: "Bus Rate"
        }
        TextField {
            id: busRateValue
            placeholderText: "0"
        }
    }

    RowLayout {
        id: thirdRowSetting
        width : parent.width
        height: 100
        anchors.top: secondRowSetting.bottom

        Text {
            text: "Data"
        }
        TextField {
            id: dataValue
            placeholderText: "0X22"
            onEditingFinished: { var binaryCoversion =  hex2bin(text);
                for (var i = 0; i < binaryCoversion.length; ++ i) {
                    console.log( binaryCoversion.charAt(i));
                    bitview.model
                }
            }
        }

        ListView {
            id: bitview
            model: 10
            width: 250
            height: 40
            spacing: 30
            anchors { left: dataValue.right
                leftMargin: 20
            }
            orientation: ListView.Horizontal

            delegate: Rectangle  {
                TextField {
                    placeholderText: "0"
                    width: 30
                    height: 30

                }
            }
        }
        Button {
            text: "Read"
        }
        Button {
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
        height: 200
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
