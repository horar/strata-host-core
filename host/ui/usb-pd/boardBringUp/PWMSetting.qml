import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.1
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4

Rectangle{
    id:two
    x: 4
    width: 651
    height: 757
    color: "#babdb6"
    opacity: 1
    anchors.fill:parent

    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 10;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 20;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;


    RowLayout {
        id: rowLayout
        x: -8
        y: -46
        width: 1013
        height: 761
    }

    Rectangle {
        id: rectangle
        x: 37
        y: 0
        width: 200
        height: 657
        color: "#888a85"

        Label {
            id: label
            x: 72
            y: 26
            text: qsTr("Bit")
            font.pointSize: 15
            font.bold: true
        }

        Label {
            id: label4
            x: 68
            y: 96
            text: qsTr("0")
            font.pointSize: mediumFontSize
        }


        Label {
            id: label6
            x: 70
            y: 242
            width: 22
            height: 20
            text: qsTr("2")
            font.pointSize: mediumFontSize
        }

        Label {
            id: label7
            x: 67
            y: 325
            width: 22
            height: 10
            text: qsTr("3")
            font.pointSize: mediumFontSize
        }

        Label {
            id: label5
            x: 68
            y: 172
            width: 12
            height: 20
            text: qsTr("1")
            font.pointSize: mediumFontSize
        }

        Label {
            id: label2
            x: 67
            y: 394
            width: 15
            height: 20
            text: qsTr("4")
            font.pointSize: mediumFontSize
        }

        Label {
            id: label3
            x: 65
            y: 463
            width: 24
            height: 31
            text: qsTr("5")
            font.pointSize: mediumFontSize
        }

        Label {
            id: label1
            x: 65
            y: 527
            width: 24
            height: 25
            text: qsTr("6")
            font.pointSize: mediumFontSize
        }

        Label {
            id: label11
            x: 63
            y: 602
            width: 17
            height: 26
            text: qsTr("7")
            font.pointSize: mediumFontSize
        }
    }

    Rectangle {
        id: rectangle4
        x: 195
        y: 0
        width: 200
        height: 657
        color: "#888a85"
        Label {
            id: label8
            x: 58
            y: 25
            text: qsTr("Enabled")
            font.bold: true
            font.pointSize: 13
        }

        PWMSwitch {
            x: 108
            y: 128
            initialState: true
        }

        PWMSwitch {
            x: 108
            y: 348
            initialState: true
        }

        PWMSwitch {
            x: 108
            y: 200
            initialState: true
        }
        Rectangle {
            id: rectangle5
            x: 197
            y: 0
            width: 383
            height: 657
            color: "#888a85"
            Label {
                id: label9
                x: 88
                y: 27
                text: qsTr("Frequency  (HZ)")
                font.bold: true
                font.pointSize: 13
            }

            TextField {
                id: textField3
                x: 120
                y: 92
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField4
                x: 120
                y: 164
                width: 116
                placeholderText: qsTr("100HZ")
            }

            TextField {
                id: textField5
                x: 120
                y: 240
                width: 116
                placeholderText: qsTr("1000HZ")
            }

            TextField {
                id: textField6
                x: 125
                y: 311
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField7
                x: 125
                y: 383
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField8
                x: 125
                y: 457
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField9
                x: 125
                y: 527
                width: 116
                placeholderText: qsTr("10 Hz")
            }

            TextField {
                id: textField10
                x: 125
                y: 604
                width: 116
                height: 25
                placeholderText: qsTr("10 Hz")
            }
        }

        Rectangle {
            id: rectangle6
            x: 565
            y: 0
            width: 67
            height: 657
            color: "#888a85"
            Label {
                id: label10
                x: -72
                y: 29
                text: qsTr("Duty Cycle")
                font.bold: true
                font.pointSize: 13
            }

            CircularSpinner {
                x: -77
                y: 65
                width: 113
                height: 64
            }

            CircularSpinner {
                x: -76
                y: 141
                width: 104
                height: 62
            }

            CircularSpinner {
                x: -72
                y: 219
                width: 103
                height: 60
            }

            CircularSpinner {
                x: -69
                y: 292
                width: 97
                height: 60
            }

            CircularSpinner {
                x: -77
                y: 369
                width: 113
                height: 60
                from: -0.2
            }

            CircularSpinner {
                x: -77
                y: 443
                width: 113
                height: 60
                from: -0.2
            }

            CircularSpinner {
                x: -76
                y: 520
                width: 113
                height: 59
                from: -0.2
            }

            CircularSpinner {
                x: -77
                y: 592
                width: 113
                height: 59
                from: -0.2
            }
        }

        PWMSwitch {
            x: 106
            y: 273
            initialState: true
        }

        PWMSwitch {
            x: 109
            y: 418
            initialState: true
        }

        PWMSwitch {
            x: 112
            y: 496
            initialState: true
        }

        PWMSwitch {
            x: 113
            y: 564
            initialState: true
        }

        PWMSwitch {
            x: 112
            y: 631
            initialState: true
        }
    }
}
