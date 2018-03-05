import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.1
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4

Rectangle {

    id:buttonViewContainer
    anchors.fill:parent

    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 10;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 20;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;


    Rectangle {
        id: bitRectangle
        anchors.right:buttonViewContainer.horizontalCenter
        anchors.rightMargin: 5
        anchors.top:buttonViewContainer.top
        anchors.topMargin: 20
        width: 300
        height: 612
        anchors.bottom: buttonViewContainer.bottom
        anchors.bottomMargin: -30
        color:lightGreyColor


        Label {
            id: label1
            x: 120
            y: 16
            width: 58
            height: 25
            text: qsTr("Bit")
            font.pointSize: largeFontSize
            font.family: "helvetica"
        }

        Label {
            id: label3
            x: 120
            y: 74
            text: qsTr("0")
            font.pointSize: 13
        }

        Label {
            id: label4
            x: 122
            y: 144
            width: 10
            height: 25
            text: qsTr("1")
            font.pointSize: 13
        }

        Label {
            id: label5
            x: 123
            y: 216
            width: 0
            height: 21
            text: qsTr("2")
            font.pointSize: 13
        }

        Label {
            id: label6
            x: 120
            y: 290
            width: 14
            height: 25
            text: qsTr("3")
            font.pointSize: 13
        }

        Label {
            id: label7
            x: 120
            y: 357
            text: qsTr("4")
            font.pointSize: 13
        }

        Label {
            id: label8
            x: 120
            y: 424
            text: qsTr("5")
            font.pointSize: 13
        }

        Label {
            id: label9
            x: 123
            y: 501
            text: qsTr("6")
            font.pointSize: 13
        }

        Label {
            id: label10
            x: 123
            y: 570
            text: qsTr("7")
            font.pointSize: 13
        }
    }

    Rectangle {
        id: rectangle2
        anchors.left:buttonViewContainer.horizontalCenter
        anchors.leftMargin: 5
        anchors.top:parent.top
        anchors.topMargin: 20
        width: 300
        height: 612
        color:lightGreyColor

        Label {
            id: label2
            x: 116
            y: 13
            text: qsTr("Setting")
            font.pointSize: largeFontSize
            font.family: "helvetica"
        }

        GPIOSetting {
            x: 96
            y: 120
            settingMessageOne: "Input Low"
            settingMessageTwo: "Input High"
            initialState: true

        }

        GPIOSetting {
            x: 96
            y: 51
            settingMessageOne: "Input Low"
            settingMessageTwo: "Input High"
            initialState: false

        }

        GPIOSetting {
            x: 96
            y: 188
            settingMessageOne: "Output Low"
            settingMessageTwo: "Output High"
            initialState: true
        }

        GPIOSetting {
            x: 96
            y: 258
            settingMessageOne: "Output Low"
            settingMessageTwo: "Output High"
        }
        GPIOSetting {
            x: 96
            y: 334
            settingMessageOne: "Output Low"
            settingMessageTwo: "Output High"
        }
        GPIOSetting {
            x: 96
            y: 404
            settingMessageOne: "Output Low"
            settingMessageTwo: "Output High"
        }
        GPIOSetting {
            x: 96
            y: 478
            settingMessageOne: "Output Low"
            settingMessageTwo: "Output High"
            initialState: true
        }

        Image {
            x: 75
            y: 561
            width: 42
            height: 46
            source: "lock.svg"

        }

    }

}

