import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.0
//import QtQuick.Controls 2.0


Rectangle {
    id: serialInterfaceI2c

    property real calc : 0


    Rectangle {
        id: serialData
        width: 823
        //        x: 40
        //        y: 76
        height: 314
        // color: "#ffffff"
        color: "lightgray"
        anchors.top: parent.top
        anchors.topMargin: 58
        anchors.horizontalCenterOffset: -23
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: rectangle2
            x: 96
            y: 77
            width: 640
            height: 80
            color: "#ffffff"

            Label {
                id: channelSelect
                //  y: 33
                text: qsTr("Channel Select")
                anchors.left: parent.left
                anchors.leftMargin: 59
                font.pixelSize: 20
            }

            Label {
                id : slaveAddress
                text: qsTr("Slave Address (7- bit)")
                anchors.leftMargin: 36
                anchors.left: channelSelect.right
                font.pixelSize: 20
                //        anchors.horizontalCenter: parent.horizontalCenter
                //        anchors.top: parent.top
                //        anchors.topMargin: 33
            }
            Label {
                id: registerAddress
                //x: 451
                //  y: 33
                text: qsTr("Register Address")
                anchors.leftMargin: 37
                anchors.left: slaveAddress.right
                font.pixelSize: 20
                //anchors.rightMargin: 88
            }

            TextField {
                id: slaveAddressInput
                x: 229
                y: 31
                width: 128
                height: 26
                placeholderText: qsTr("0x1F")
            }

            TextField {
                id: registerAddressInput
                x: 455
                y: 31
                width: 121
                height: 26
                placeholderText: qsTr("0x1C")
            }

            ComboBox {
                id: comboBox
                x: 68
                y: 30
                model: ListModel {
                    id: model
                    ListElement { text: "I2C_1" }
                    ListElement { text: "I2C_2" }
                    ListElement { text: "I2C_3" }
                    //                    ListElement { text: "I2C_4" }
                    //                    ListElement { text: "I2C_5" }

                }
            }


        }


        Button {
            id: writeButton
            x: 266
            y: 267
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
            x: 537
            y: 267
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

        Rectangle {
            id: rectangle1
            x: 96
            y: 163
            width: 640
            height: 90
            color: "gray"
            Label {
                id: label
                x: 47
                y: 35
                text: qsTr("Data :")
            }

            TextField {
                id: textField
                x: 112
                y: 34
                placeholderText: qsTr("0x1c")
            }

            Rectangle {
                id: bitscheckbox
                x: 396
                y: 31
                width: 208
                height: 23
                color: "#d3d7cf"


                CheckBox {
                    id: bit6
                    x: 27
                    width: 21
                    height: 25
                    anchors.top: parent.top
                    anchors.topMargin: -1

                }

                CheckBox {
                    id: bit5
                    x: 54
                    anchors.top: parent.top
                    anchors.topMargin: -1

                }

                CheckBox {
                    id: bit3
                    x: 106
                    anchors.top: parent.top
                    anchors.topMargin: -1

                }
                CheckBox {
                    id: bit2
                    x: 133
                    width: 21
                    height: 25
                    anchors.top: parent.top
                    anchors.topMargin: -1
                }
                CheckBox {
                    id: bit0
                    x: 187
                    anchors.top: parent.top
                    anchors.topMargin: -1

                }
                CheckBox {
                    id: bit1
                    x: 160
                    anchors.top: parent.top
                    anchors.topMargin: -1

                }

                CheckBox {
                    id: bit7
                    x: 0
                    anchors.top: parent.top
                    anchors.topMargin: 0

                }

                CheckBox {
                    id: bit4
                    x: 79
                    anchors.top: parent.top
                    anchors.topMargin: -1

                }
            }

            Label {
                id: bit7Title
                text: qsTr("Bit7")
                anchors.bottom : bitscheckbox.top
                anchors.horizontalCenter: bitscheckbox.left
            }


            Label {
                id: bit0Title
                anchors.bottom : bitscheckbox.top
                anchors.horizontalCenter: bitscheckbox.right
                text: qsTr("Bit 0")
            }
        }
    }




    Rectangle {
        id: rectangle3
        x: 94
        y: 378
        width: 824
        height: serialData.height
        anchors.top : serialData.Bottom
        color: "#babdb6"

        Label {
            id: settingLabel
            x: 351
            y: 8
            width: 94
            height: 33
            text: qsTr("Settings")
            font.bold: true
            font.pointSize: 14
        }

        Label {
            id: label1
            x: 212
            y: 91
            text: qsTr("Display Format: ")
        }

        ColumnLayout {
            x: 351
            y: 56
            width: 123
            height: 94


            ExclusiveGroup { id: tabPositionGroup }
            RadioButton {
                id: radioButton
                x: 290
                y: 38
                exclusiveGroup: tabPositionGroup
                text: qsTr("Decimal")
            }

            RadioButton {
                id: radioButton1
                x: 290
                y: 76
                exclusiveGroup: tabPositionGroup
                text: qsTr("Hexidecimal")
            }

            RadioButton {
                id: radioButton2
                x: 290
                y: 112
                exclusiveGroup: tabPositionGroup
                text: qsTr("Binary")
            }

        }

        Label {
            id: label3
            x: 418
            y: 178
            text: qsTr("1kHz")
        }

        Label {
            id: label5
            x: 654
            y: 178
            text: qsTr("100 kHz")
        }
    }

    Slider {
        id: sliderHorizontal
        x: 522
        y: 580
        width: 261
        height: 32
        maximumValue: 100
        minimumValue: 1
        value: 0.00
        stepSize: 1

        TextField {
            id: check
            width: 42
            height: 30
            text:  sliderHorizontal.value
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenterOffset: 7
            anchors.horizontalCenterOffset: -194
            font.pointSize: 12
            font.bold: true
            anchors.centerIn:  parent
            anchors.top : parent.Bottom

            onTextChanged: {
                sliderHorizontal.value = parseFloat(text); }
        }

    }

    Label {
        id: busRateLabel
        x: 323
        y: 578
        width: 104
        height: 34
        text: qsTr("Bus Rate")
    }
    Label {
        width: 272
        height: 48
        text: "Serial Interface"
        anchors.horizontalCenterOffset: -13
        anchors.top: parent.top
        anchors.topMargin: 81
        font.pixelSize: 36
        font.bold: true
        color: "gray"
        font.family: "Helvetica"
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
