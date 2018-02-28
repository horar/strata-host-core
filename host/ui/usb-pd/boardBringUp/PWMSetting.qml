import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.1
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4

Rectangle{
    id:pwmSettingRectangle
    opacity: 1
    anchors.fill:parent

    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 10;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int mediumLargeFontSize: (Qt.platform.os === "osx") ? 20  : 16;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 20;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;

    Rectangle {
        id: bitColumn
        anchors.right:enabledColumn.left
        width: 200
        height: 657
        color:lightGreyColor

        Label {
            id: label
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: 20
            text: qsTr("Bit")
            font.pointSize: largeFontSize
            font.family: "helvetica"

        }

        Label {
            id: label4
            anchors.horizontalCenter: parent.horizontalCenter
            y: 96
            text: qsTr("0")
            font.pointSize: mediumLargeFontSize
        }


        Label {
            id: label6
            anchors.horizontalCenter: parent.horizontalCenter
            y: 242
            height: 20
            text: qsTr("2")
            font.pointSize: mediumLargeFontSize
        }

        Label {
            id: label7
            anchors.horizontalCenter: parent.horizontalCenter
            y: 325
            height: 10
            text: qsTr("3")
            font.pointSize: mediumLargeFontSize
        }

        Label {
            id: label5
            anchors.horizontalCenter: parent.horizontalCenter
            y: 172
            height: 20
            text: qsTr("1")
            font.pointSize: mediumLargeFontSize
        }

        Label {
            id: label2
            anchors.horizontalCenter: parent.horizontalCenter
            y: 394
            height: 20
            text: qsTr("4")
            font.pointSize: mediumLargeFontSize
        }

        Label {
            id: label3
            anchors.horizontalCenter: parent.horizontalCenter
            y: 463
            height: 31
            text: qsTr("5")
            font.pointSize: mediumLargeFontSize
        }

        Label {
            id: label1
            anchors.horizontalCenter: parent.horizontalCenter
            y: 527
            height: 25
            text: qsTr("6")
            font.pointSize: mediumLargeFontSize
        }

        Label {
            id: label11
            anchors.horizontalCenter: parent.horizontalCenter
            y: 602
            height: 26
            text: qsTr("7")
            font.pointSize: mediumLargeFontSize
        }
    }

    Rectangle {
        id: enabledColumn
        anchors.right:pwmSettingRectangle.horizontalCenter
        width: 200
        height: 657
        color:lightGreyColor
        Label {
            id: label8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: 20
            text: qsTr("Enabled")
            font.pointSize: largeFontSize
            font.family: "helvetica"
        }

        PWMSwitch {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 128
            initialState: true
        }

        PWMSwitch {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 348
            initialState: true
        }

        PWMSwitch {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 200
            initialState: true
        }

        PWMSwitch {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 273
            initialState: true
        }

        PWMSwitch {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 418
            initialState: true
        }

        PWMSwitch {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 496
            initialState: true
        }

        PWMSwitch {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 564
            initialState: true
        }

        PWMSwitch {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 631
            initialState: true
        }
}

        //-------------------------------------
        //  frequency column
        //-------------------------------------
        Rectangle {
            id: frequencyColumn
            anchors.left:pwmSettingRectangle.horizontalCenter
            width: 200
            height: 657
            color: lightGreyColor
            Label {
                id: label9
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:parent.top
                anchors.topMargin: 20
                text: qsTr("Frequency  (HZ)")
                font.pointSize: largeFontSize
                font.family: "helvetica"
            }

            TextField {
                id: textField3
                anchors.horizontalCenter: parent.horizontalCenter
                y: 92
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField4
                anchors.horizontalCenter: parent.horizontalCenter
                y: 164
                width: 116
                placeholderText: qsTr("100HZ")
            }

            TextField {
                id: textField5
                anchors.horizontalCenter: parent.horizontalCenter
                y: 240
                width: 116
                placeholderText: qsTr("1000HZ")
            }

            TextField {
                id: textField6
                anchors.horizontalCenter: parent.horizontalCenter
                y: 311
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField7
                anchors.horizontalCenter: parent.horizontalCenter
                y: 383
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField8
                anchors.horizontalCenter: parent.horizontalCenter
                y: 457
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField9
                anchors.horizontalCenter: parent.horizontalCenter
                y: 527
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField10
                anchors.horizontalCenter: parent.horizontalCenter
                y: 604
                width: 116
                height: 25
                placeholderText: qsTr("10 Hz")
            }
        }

        Rectangle {
            id: dutyCycleColumn
            anchors.left:frequencyColumn.right
            width: 200
            height: 657
            color: lightGreyColor
            Label {
                id: label10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:parent.top
                anchors.topMargin: 20
                text: qsTr("Duty Cycle")
                font.pointSize: largeFontSize
                font.family: "helvetica"
            }

            CircularSpinner {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 65
                width: 113
                height: 64
            }

            CircularSpinner {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 141
                width: 104
                height: 62
            }

            CircularSpinner {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 219
                width: 103
                height: 60
            }

            CircularSpinner {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 292
                width: 97
                height: 60
            }

            CircularSpinner {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 369
                width: 113
                height: 60
                from: -0.2
            }

            CircularSpinner {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 443
                width: 113
                height: 60
                from: -0.2
            }

            CircularSpinner {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 520
                width: 113
                height: 59
                from: -0.2
            }

            CircularSpinner {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 592
                width: 113
                height: 59
                from: -0.2
            }
        }


}
