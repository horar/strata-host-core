import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

Rectangle {
    id: serialInterfaceI2c

    Rectangle {
        id: rectangle
        x: 135
        y: 142
        width: 823
        height: 455
        color: "#d3d7cf"


        Label {
            id: label
            x: 345
            width: 202
            height: 36
            text: qsTr("Serial Interface")
            anchors.top: parent.top
            anchors.topMargin: 19
            font.bold: true
            font.pointSize: 16
            color: "gray"
            font.family: "Helvetica"
        }

        Label {
            id: label1
            x: 147
            y: 106
            text: qsTr("Clock Rate: ")
            font.pointSize: 13
        }

        TextField {
            id: textField
            x: 277
            y: 108
            placeholderText: qsTr("1 MHz")
        }

        Label {
            id: label2
            x: 504
            y: 108
            width: 58
            height: 28
            text: qsTr("Data:")
            font.pointSize: 13
        }

        TextField {
            id: textField1
            x: 568
            y: 110
            placeholderText: qsTr("0x00")
        }

        Button {
            id: writeButton
            x: 294
            y: 212
            width: 69
            height: 31
            checkable: true
            checked: false
            text: "Write"
            //            ButtonGroup.group: btnGrp
            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: writeButton.width
                    implicitHeight: writeButton.height
                    color: writeButton.checked ? "green" : "white"

                }
            }
        }
        Button {
            id: redButton
            x: 483
            y: 211
            width: 64
            height: 34
            text: qsTr("Read")
            checkable: true
            checked: false
            style: ButtonStyle {
                background: Rectangle {
                    implicitWidth: redButton.width
                    implicitHeight: redButton.height
                    color: redButton.checked ? "green" : "white"

                }
            }
        }
    }

}
