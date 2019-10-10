import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4

Item {
    id: container
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
    /*
         Create the editable field in the table
    */
    Component {
        id: editableDelegate
        Item {
            Text {
                width: parent.width
                anchors { margins: 4
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
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
