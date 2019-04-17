import QtQuick 2.0
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

Rectangle {

    property var currentTab
    property var newTab
//    color: "#888a85"


    Rectangle {
        id: rectangle
        x: 17
        y: 19
        width: 957
        height: 866
        color: "#babdb6"

        function createTab(inTabName, inParent){
            var component  = Qt.createComponent(inTabName);
            var object = component.createObject(inParent);
            return object
        }

        Component.onCompleted: {
            currentTab = createTab("buttonView.qml", contentRectangle);
            currentTab.opacity = 1;

            newTab = createTab("buttonView.qml",contentRectangle);
        }


        Label {
            id: label
            x: 191
            y: 21
            font.pixelSize: 36
            font.bold: true
            color: "gray"
            font.family: "Helvetica"
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("GPIO Configuration")
            anchors.horizontalCenterOffset: 5
        }


        ParallelAnimation{
            id: crosfadeTabs
            OpacityAnimator{
                target: currentTab
                from: 1
                to: 0
                duration: 500
                running: false
            }
            OpacityAnimator{
                target: newTab
                from: 0
                to: 1
                duration: 500
                running: false
            }
        }


        Rectangle{
            id:contentRectangle
            x: 4
            y: 116

            anchors.rightMargin: 14
            anchors.bottomMargin: 8
            anchors.leftMargin: 14
            anchors.topMargin: 12
            z: 2
            color:  "#babdb6"
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            anchors.top:buttonRow.bottom
            ButtonView{}
            ButtonView{}
            ButtonView{}

        }

        ButtonGroup {
            buttons: buttonRow.children
            onClicked: {
                newTab = button.tabName
                crosfadeTabs.start()
                currentTab = newTab
            }
        }

        Row {
            id:buttonRow
            x: 51
            anchors.horizontalCenterOffset: -7
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 81

            SGLeftSegmentedButton{x: 5;text:"Port A"; tabName:ButtonView{}}
            SGMiddleSegmentedButton{text:"Port B"; tabName:ButtonView {}}
            SGMiddleSegmentedButton{text:"Port C"; tabName:ButtonView {}}
            SGMiddleSegmentedButton{text:"Port D"; tabName:ButtonView {}}
            SGMiddleSegmentedButton{text:"Port E"; tabName:ButtonView {}}
            SGRightSegmentedButton{text:"Port F"; tabName:ButtonView {}}

        }


        //        Rectangle {
        //            id: portList
        //            x: 102
        //            y: 102
        //            width: 763
        //            height: 86
        //            color: "#babdb6"

        //            Button {
        //                id: button2
        //                x: 262
        //                y: -1
        //                width: 93
        //                height: 29
        //                text: qsTr("Port C")
        //            }
        //            Button {
        //                id: button3
        //                x: 353
        //                y: -1
        //                width: 85
        //                height: 29
        //                text: qsTr("Port D")
        //            }


        //            Button {
        //                id: portAbutton
        //                x: 93
        //                y: -1
        //                width: 87
        //                height: 29
        //                text: qsTr("Port A")

        //                MouseArea {
        //                    id: myMouseId
        //                    anchors.fill: parent

        //                }

        //                style: ButtonStyle {
        //                    background:
        //                        Rectangle {
        //                        color: myMouseId.pressed ? "green" : "white";
        //                        radius: 1;
        //                    }
        //                }

        //            }


        //            Button {
        //                id: portBbutton
        //                x: 179
        //                y: -1
        //                width: 85
        //                height: 29
        //                text: qsTr("Port B")
        //            }

        //            Button {
        //                id: button4
        //                x: 438
        //                y: -1
        //                text: qsTr("Port E")

        //                Button {
        //                    id: button5
        //                    x: 79
        //                    y: 0
        //                    text: qsTr("Port F")

        //                    Button {
        //                        id: button6
        //                        x: 79
        //                        y: 0
        //                        text: qsTr("Port G")
        //                    }
        //                }
        //            }
        //        }

        //        RowLayout {
        //            id: rowLayout
        //            x: 76
        //            y: 151
        //            width: 789
        //            height: 674
        //        }

        //        Rectangle {
        //            id: rectangle1
        //            x: 117
        //            y: 168
        //            width: 311
        //            height: 634
        //            color: "#888a85"



        //            Label {
        //                id: label1
        //                x: 120
        //                y: 16
        //                width: 58
        //                height: 25
        //                text: qsTr("Bit")
        //                font.bold: true
        //                font.pointSize: 13
        //            }

        //            Label {
        //                id: label3
        //                x: 120
        //                y: 74
        //                text: qsTr("0")
        //                font.pointSize: 13
        //            }

        //            Label {
        //                id: label4
        //                x: 122
        //                y: 144
        //                width: 10
        //                height: 25
        //                text: qsTr("1")
        //                font.pointSize: 13
        //            }

        //            Label {
        //                id: label5
        //                x: 123
        //                y: 216
        //                width: 0
        //                height: 21
        //                text: qsTr("2")
        //                font.pointSize: 13
        //            }

        //            Label {
        //                id: label6
        //                x: 120
        //                y: 290
        //                width: 14
        //                height: 25
        //                text: qsTr("3")
        //                font.pointSize: 13
        //            }

        //            Label {
        //                id: label7
        //                x: 120
        //                y: 357
        //                text: qsTr("4")
        //                font.pointSize: 13
        //            }

        //            Label {
        //                id: label8
        //                x: 120
        //                y: 424
        //                text: qsTr("5")
        //                font.pointSize: 13
        //            }

        //            Label {
        //                id: label9
        //                x: 123
        //                y: 501
        //                text: qsTr("6")
        //                font.pointSize: 13
        //            }

        //            Label {
        //                id: label10
        //                x: 123
        //                y: 570
        //                text: qsTr("7")
        //                font.pointSize: 13
        //            }
        //        }

        //        Rectangle {
        //            id: rectangle2
        //            x: 443
        //            y: 169
        //            width: 363
        //            height: 633
        //            color: "#888a85"

        //            Label {
        //                id: label2
        //                x: 116
        //                y: 13
        //                text: qsTr("Setting")
        //                font.bold: true
        //                font.pointSize: 13
        //            }

        //            GPIOSetting {
        //                x: 96
        //                y: 120
        //                settingMessageOne: "Input Low"
        //                settingMessageTwo: "Input High"
        //                initialState: true

        //            }

        //            GPIOSetting {
        //                x: 96
        //                y: 51
        //                settingMessageOne: "Input Low"
        //                settingMessageTwo: "Input High"
        //                initialState: false

        //            }

        //            GPIOSetting {
        //                x: 96
        //                y: 188
        //                settingMessageOne: "Output Low"
        //                settingMessageTwo: "Output High"
        //                initialState: true
        //            }

        //            GPIOSetting {
        //                x: 96
        //                y: 258
        //                settingMessageOne: "Output Low"
        //                settingMessageTwo: "Output High"
        //            }
        //            GPIOSetting {
        //                x: 96
        //                y: 334
        //                settingMessageOne: "Output Low"
        //                settingMessageTwo: "Output High"
        //            }
        //            GPIOSetting {
        //                x: 96
        //                y: 404
        //                settingMessageOne: "Output Low"
        //                settingMessageTwo: "Output High"
        //            }
        //            GPIOSetting {
        //                x: 96
        //                y: 478
        //                settingMessageOne: "Output Low"
        //                settingMessageTwo: "Output High"
        //                initialState: true
        //            }

        //            Image {
        //                x: 75
        //                y: 561
        //                width: 42
        //                height: 46
        //                source: "lockIcon.png"

        //            }


        //        }
        //    }
    }
}





