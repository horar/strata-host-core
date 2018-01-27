import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0

Rectangle {
    id : serialInterfaceUART

    Rectangle {
        id: rectangle
        x: 129
        y: 152
        width: 823
        height: 455
        color: "#d3d7cf"


        Label {
            id: label
            x: 303
            width: 217
            text: qsTr("Serial Interface")
            anchors.top: parent.top
            anchors.topMargin: 20
            font.bold: true
            font.pointSize: 16
            color: "gray"
            font.family: "Helvetica"
        }

        Label {
            id: label1
            x: 76
            y: 109
            text: qsTr("Baud Rate :")
            font.pointSize: 14
        }

        TextField {
            id: textField
            x: 199
            y: 109
            placeholderText: qsTr("115200")
        }

        Label {
            id: label2
            x: 113
            y: 172
            text: qsTr("Parity :")
            font.pointSize: 14
        }




        Label {
            id: label3
            x: 347
            y: 189
            text: qsTr("Data:")
            font.pointSize: 14
        }


        TextField {
            id: textField2
            x: 408
            y: 190
            width: 113
            height: 26
            placeholderText: qsTr("Hello World")
        }



        Label {
            id: label4
            x: 98
            y: 270
            text: qsTr("Stop Bit:")
            font.pointSize: 14
        }

        Button {
            id: writeButton
            x: 233
            y: 379
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
            x: 333
            y: 376
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
        ColumnLayout {
            x: 193
            y: 154
            width: 79
            height: 62


            ExclusiveGroup { id: tabPositionGroup }
            RadioButton {
                id: radioButton
                x: 290
                y: 38
                exclusiveGroup: tabPositionGroup
                text: qsTr("On")
            }

            RadioButton {
                id: radioButton1
                x: 290
                y: 76
                exclusiveGroup: tabPositionGroup
                text: qsTr("Off")
            }


        }

        ColumnLayout {
            x: 195
            y: 254
            width: 79
            height: 62


            ExclusiveGroup { id: tabPositionGroup2 }
            RadioButton {
                id: radio1
                x: 290
                y: 38
                exclusiveGroup: tabPositionGroup2
                text: qsTr("0")
            }

            RadioButton {
                id: radio2
                x: 290
                y: 76
                exclusiveGroup: tabPositionGroup2
                text: qsTr("1")
            }


        }




    }

}

