import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1000
    height: 800
    title: qsTr("Hello World")

    property var currentSystemModel: powerStagesModel
    property var currentSchematic: "NCV81599-PowerStage1.png"
    property var currentVPModel: vpModel2

    GridLayout{
        id: systemContentGridLayout
        columns: 6
        rows: 7
        anchors {fill:parent}
        columnSpacing: 0
        rowSpacing: 0

        property double colMulti : systemContentGridLayout.width / systemContentGridLayout.columns
        property double rowMulti : systemContentGridLayout.height / systemContentGridLayout.rows

        function prefWidth(item){
            return colMulti * item.Layout.columnSpan
        }
        function prefHeight(item){
            return rowMulti * item.Layout.rowSpan
        }

        Rectangle{
            id: functionGroup1
            Layout.column: 0
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 4
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            border.width: 0
            radius: 16
            color:"lightgrey"
            ColumnLayout{
                Layout.preferredWidth: systemContentGridLayout.prefWidth(this)
                Layout.fillWidth:true
                spacing: 10
                Image{
                    Layout.preferredWidth: systemContentGridLayout.prefWidth(this)
                    Layout.topMargin: 5
                    Layout.leftMargin: -5
                    Layout.rightMargin: 5
                    fillMode: Image.PreserveAspectFit
                    source:"DC-DCPowerIcon.png"
                }
                Button{
                    id:button1
                    text:"Port 1 Power"
                    checkable: true
                    checked: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:button1.checked ? 3 :1
                        border.color: button1.checked? "red" : "black"
                        radius: 10
                        color: button1.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = powerStagesModel
                        currentSchematic = "NCV81599-PowerStage1.png"
                        currentVPModel = vpModel2
                    }
                }
                Button{
                    id:button2
                    text:"Port 2 Power"
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{
                        border.width:button2.checked ? 3 :1
                        border.color: button2.checked? "red" : "black"
                        radius: 10
                        color: button2.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = powerStagesModel
                        currentSchematic = "NCV81599-PowerStage1.png"
                        currentVPModel = vpModel2
                    }
                }
                Button{
                    id:button3
                    text:"3.3 V"
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{
                        border.width:button3.checked ? 3 :1
                        border.color: button3.checked? "red" : "black"
                        radius: 10
                        color: button3.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = threeVoltRailModel
                        currentSchematic = "ThreeVoltRailSchematic.png"
                        currentVPModel = vpModel2
                    }
                }
            }
            }

         Rectangle{
            id: functionGroup2
            Layout.column: 1
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 4
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            border.width: 0
            radius: 16
            color:"lightgrey"
            ColumnLayout{
                Layout.preferredWidth: systemContentGridLayout.prefWidth(this)
                Layout.fillWidth:true
                spacing: 10
                Image{
                    Layout.preferredWidth: systemContentGridLayout.prefWidth(this)
                    Layout.topMargin: 5
                    Layout.leftMargin: -5
                    Layout.rightMargin: 5
                    Layout.bottomMargin: 6
                    fillMode: Image.PreserveAspectFit
                    source:"ProtectionIcon.png"
                }
                Button{
                    id:button4
                    text:"Battery Protection"
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 10
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:button4.checked ? 3 :1
                        border.color: button4.checked? "red" : "black"
                        radius: 10
                        color: button4.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = batterySystemModel
                        currentSchematic = "BatteryProtectionSchematic.png"
                        currentVPModel = vpModel1
                    }
                }

            }
            }

         Rectangle{
            id: functionGroup3
            Layout.column: 2
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 4
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            border.width: 0
            radius: 16
            color:"lightgrey"
            ColumnLayout{
                Layout.preferredWidth: systemContentGridLayout.prefWidth(this)
                Layout.fillWidth:true
                spacing: 10
                Image{
                    Layout.preferredWidth: systemContentGridLayout.prefWidth(this)
                    Layout.topMargin: 5
                    Layout.leftMargin: -5
                    Layout.rightMargin: 5
                    Layout.bottomMargin: 6
                    fillMode: Image.PreserveAspectFit
                    source:"SensorsIcon.png"
                }
                Button{
                    id:button5
                    text:"Temp"
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:button5.checked ? 3 :1
                        border.color: button5.checked? "red" : "black"
                        radius: 10
                        color: button5.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = tempSensorSystemModel
                        currentSchematic = "TempSensorSchematic.png"
                        currentVPModel = vpModel2
                    }
                }
                Button{
                    id:button6
                    text:"A/D"
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    visible: false
                    Layout.fillWidth: true
                    Layout.rightMargin: 25
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:button6.checked ? 3 :1
                        border.color: button6.checked? "red" : "black"
                        radius: 10
                        color: button6.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = tempSensorSystemModel
                        currentSchematic = "TempSensorSchematic.png"
                        currentVPModel = vpModel2
                    }
                }

            }
            }

         Rectangle{
            id: functionGroup4
            Layout.column: 3
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 4
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            Layout.topMargin: 5
            Layout.bottomMargin: 5
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            border.width: 0
            radius: 16
            color:"lightgrey"
            ColumnLayout{
                Layout.preferredWidth: systemContentGridLayout.prefWidth(this)
                Layout.fillWidth:true
                spacing: 10
                Image{
                    Layout.preferredWidth: systemContentGridLayout.prefWidth(this)
                    Layout.topMargin: 5
                    Layout.leftMargin: -5
                    Layout.rightMargin: 5
                    Layout.bottomMargin: 2
                    fillMode: Image.PreserveAspectFit
                    source:"USBInterfaceIcon.png"
                }
                Button{
                    id:button7
                    text:"USB-C Port 1"
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 25
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:button7.checked ? 3 :1
                        border.color: button7.checked? "red" : "black"
                        radius: 10
                        color: button7.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = usbCModel
                        currentSchematic = "USBCInterfaceSchematic1.png"
                        currentVPModel = vpModel2
                    }
                }
                Button{
                    id:button8
                    text:"USB-C Port 2"
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 25
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:button8.checked ? 3 :1
                        border.color: button8.checked? "red" : "black"
                        radius: 10
                        color: button8.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = usbCModel
                        currentSchematic = "USBCInterfaceSchematic1.png"
                        currentVPModel = vpModel2
                    }
                }

            }
            }

         ButtonGroup {
             id: systemButtonGroup
         }

         Image{
             id: blockDiagram
             Layout.column: 4
             Layout.columnSpan: 2
             Layout.row: 0
             Layout.rowSpan: 3
             Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
             Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
             Layout.fillWidth:true
             Layout.fillHeight:true
             fillMode: Image.PreserveAspectFit
             source:"USB-PD_blockDiagram.png"
             Rectangle{
                 id: portPower1Hotspot
                 x: 123
                 y: 120
                 width: 70
                 height: 43
                 border.color: button1.checked? "red" : "transparent"
                 border.width: 2
                 color:"transparent"
                 Text{
                     anchors.centerIn: parent
                     width:parent.width
                     horizontalAlignment: Text.AlignHCenter
                     text:"Port 1 Power"
                     font.bold: true
                     color: button1.checked? "white" : "transparent"
                     wrapMode: Text.WordWrap

                 }
             }
             Rectangle{
                 id: portPower2Hotspot
                 x: 123
                 y: 213
                 width: 70
                 height: 40
                 border.color: button2.checked? "red" : "transparent"
                 border.width: 2
                 color:"transparent"
                 Text{
                     anchors.centerIn: parent
                     width:parent.width
                     horizontalAlignment: Text.AlignHCenter
                     text:"Port 2 Power"
                     font.bold: true
                     color: button2.checked? "white" : "transparent"
                     wrapMode: Text.WordWrap

                 }
             }
             Rectangle{
                 id: threeVoltHotspot
                 x: 117
                 y: 257
                 width: 35
                 height: 25
                 border.color: button3.checked? "red" : "transparent"
                 border.width: 2
                 color:"transparent"
                 Text{
                     anchors.centerIn: parent
                     width:parent.width
                     horizontalAlignment: Text.AlignHCenter
                     text:"3.3V"
                     font.bold: true
                     color: button3.checked? "white" : "transparent"
                     wrapMode: Text.WordWrap

                 }
             }
             Rectangle{
                 id: batteryProtectionHotspot
                 x: 53
                 y: 120
                 width: 30
                 height: 25
                 border.color: button4.checked? "red" : "transparent"
                 border.width: 2
                 color:"transparent"
                 Text{
                     anchors.centerIn: parent
                     width:parent.width
                     horizontalAlignment: Text.AlignHCenter
                     text:"Battery Protection"
                     font.bold: true
                     font.pointSize: 6
                     color: button4.checked? "white" : "transparent"
                     wrapMode: Text.WordWrap

                 }
             }
             Rectangle{
                 id: temperatureSensorHotspot
                 x: 100
                 y: 163
                 width: 30
                 height: 17
                 border.color: button5.checked? "red" : "transparent"
                 border.width: 2
                 color:"transparent"
                 Text{
                     anchors.centerIn: parent
                     width:parent.width
                     horizontalAlignment: Text.AlignHCenter
                     text:"Battery Protection"
                     font.bold: true
                     font.pointSize: 4
                     color: button5.checked? "white" : "transparent"
                     wrapMode: Text.WordWrap

                 }
             }
             Rectangle{
                 id: usb1Hotspot
                 x: 205
                 y: 135
                 width: 75
                 height: 55
                 border.color: button7.checked? "red" : "transparent"
                 border.width: 2
                 color:"transparent"
                 Text{
                     anchors.centerIn: parent
                     width:parent.width
                     horizontalAlignment: Text.AlignHCenter
                     text:"USB-C Port 1"
                     font.bold: true
                     color: button7.checked? "white" : "transparent"
                     wrapMode: Text.WordWrap

                 }
             }
             Rectangle{
                 id: usb2Hotspot
                 x: 205
                 y: 225
                 width: 75
                 height: 55
                 border.color: button8.checked? "red" : "transparent"
                 border.width: 2
                 color:"transparent"
                 Text{
                     anchors.centerIn: parent
                     width:parent.width
                     horizontalAlignment: Text.AlignHCenter
                     text:"USB-C Port 2"
                     font.bold: true
                     color: button8.checked? "white" : "transparent"
                     wrapMode: Text.WordWrap

                 }
             }
         }

         GridView {
             id:gridView
             Layout.column: 0
             Layout.columnSpan: 4
             Layout.row: 4
             Layout.rowSpan: 2
             Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
             //Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
             height:150
             Layout.fillWidth:true
             //Layout.fillHeight:true
             Layout.leftMargin: 10
             Layout.topMargin: 50
             Layout.bottomMargin: 50
             cellWidth: 150; cellHeight: 25
             highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
             focus: true
             flow: GridView.FlowTopToBottom | GridView.FlowTopToBottom

             model: currentSystemModel
             delegate: Item {
                 x: 25
                 width: 150; height: 25
                 Rectangle{
                     id: itemRectangle
                     anchors.fill:parent
                     color: isPartName? "#2eb457":
                                        index % 2 == 0 ? "ghostwhite":"lightcyan"
                     border.width: 1
                     border.color: "white"
                     Text {
                         id: systemDataItem
                         text: file ? "<a href='http:" +file+ "'>"+name+"</a>":name
                         linkColor: "green"
                         onLinkActivated: documentationPopup.open()
                         anchors.horizontalCenter: parent.horizontalCenter
                         anchors.verticalCenter: parent.verticalCenter
                         font.bold: isPartName? true: false
                     }
                     Popup {
                             id: documentationPopup
                             width: mainWindow.contentItem.width/2
                             height: mainWindow.contentItem.height/2
                             modal: true
                             focus: true

                             topMargin: mainWindow.contentItem.height/4
                             bottomMargin: mainWindow.contentItem.height/4
                             leftMargin: mainWindow.contentItem.width/4
                             rightMargin: mainWindow.contentItem.width/4
                             closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                             contentItem:
                                 Text{
                                 text: "open " + file + " in this window"
                             }
                         }

                 }

             }
         }



         Rectangle{
             id: schematicView
             Layout.column: 4
             Layout.columnSpan: 2
             Layout.row: 3
             Layout.rowSpan: 3
             Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
             Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
             Layout.fillWidth:true
             Layout.fillHeight:true
             border.width: 0

             Image {
                 id: schematic
                 source: currentSchematic
                 anchors.fill:parent
                 fillMode: Image.PreserveAspectFit

                 Rectangle{
                     id: schematicOverlay
                     anchors.fill:parent
                     anchors.topMargin: 60
                     anchors.bottomMargin: 60
                     border.color: "red"
                     border.width: 2
                     color:"#35351580"
                     Text{
                         anchors.centerIn: parent
                         width:parent.width
                         horizontalAlignment: Text.AlignHCenter
                         text:"Click to open schematic"
                         font.bold: true
                         font.pointSize: 24
                         color: "white"
                         wrapMode: Text.WordWrap
                     }
                     MouseArea{
                         anchors.fill:parent
                         onClicked:{
                             schematicPopup.open()
                         }
                     }
                     Popup {
                         id: schematicPopup
                         width: mainWindow.contentItem.width/2
                         height: mainWindow.contentItem.height/2
                         modal: true
                         focus: true

                         topMargin: mainWindow.contentItem.height/4
                         bottomMargin: mainWindow.contentItem.height/4
                         leftMargin: mainWindow.contentItem.width/4
                         rightMargin: mainWindow.contentItem.width/4
                         closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                         contentItem:
                             Text{
                             text: "open " + currentSchematic + " in this window"
                         }
                     }
                 }
             }


         }


        ListModel {
            id: batterySystemModel
            ListElement {
                system: "batterySystem"
                name: "NVMFS5A140PLZ"//"NVMFS5A140PLZ P-Channel Power MOSFET"
                isPartName: true
            }

            ListElement {
                system: "batterySystem"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "batterySystem"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "batterySystem"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "batterySystem"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "batterySystem"
                name: ""
                isPartName: false
            }



        }

        ListModel {
            id: tempSensorSystemModel
            ListElement {
                system: "tempSensorSystem"
                name: "NVT211"//"NVT211 Dual Channel Temp Monitor"
                isPartName: true
            }
            ListElement {
                system: "tempSensorSystem"
                name: "Test Report"
                isPartName: false
            }

            ListElement {
                system: "tempSensorSystem"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                isPartName: false
            }

            ListElement {
                system: "tempSensorSystem"
                name: "SMMBT3906WT1G"//"SMMBT3906WT1G Auto BJT PNP"
                isPartName: true
            }
            ListElement {
                system: "tempSensorSystem"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                isPartName: false
            }
        }

        ListModel {
            id: threeVoltRailModel
            ListElement {
                system: "3.3V Rail"
                name: "NCV890100"//"NCV890100 1.2A, 2 MHz Automotive Buck Switching Regulator"
                isPartName: true
                }
            ListElement {
                system: "3.3V Rail"
                name: "SEC Test Report"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "EVB Schematic"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "EVB User Guide"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "Design Worksheet"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "NSVR05F40NX"//"NSVR05F40NX Schottky Barrier Diode"
                isPartName: true
                }
            ListElement {
                system: "3.3V Rail"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "NRVB140SF"//"NRVB140SF Surface Mount Schottky Power Rectifier"
                isPartName: true
                }
            ListElement {
                system: "3.3V Rail"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                isPartName: false
            }
        }
        ListModel {
            id: powerStagesModel
            ListElement {
                system: "Power Stages"
                name: "NCV81599"//"NCV81599 Automotive 4 Switch Buck-Boost"
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "SEC Test Report"
                file: "NCV81599 Test Report"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "EVB Schematic"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "EVB User Guide"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "EVB GUI Download"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                isPartName: false
            }

            ListElement {
                system: "Power Stages"
                name: "NVTFS5C453"//"NVTFS5C453 Power MOSFET"
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "NSVR05F40NX"//"NSVR05F40NX Schottky Barrier Diode"
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "BVSS84L"//"BVSS84L Automotive Small Signal MOSFET "
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "2V7002W"//"2V7002W Automotive Small Signal MOSFET"
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                isPartName: false
            }
        }

        ListModel {
            id: usbCModel
            ListElement {
                system: "USB-C Interface"
                name: "NSVR05F40NX"//"NSVR05F40NX Schottky Barrier Diode"
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: "NSVR05F40NX"//"SZESD7104 4-ch Transient Voltage Suppressors"
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: "2V7002W"//"2V7002W Automotive Small Signal MOSFET"
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: "NVTFS5C453"//"NVTFS5C453 Power MOSFET"
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                isPartName: false
            }

        }

//------------------------------------------------------------
//      Headshots
//------------------------------------------------------------
        ListModel{
            id: vpModel1
            ListElement {
                name: "Bill Hall"
                photo: "bill_hall.jpg"
            }
        }

        ListModel{
            id: vpModel2
            ListElement {
                name: "Bill Hall"
                photo: "bill_hall.jpg"
            }

            ListElement {
                name: "Bob Klosterboer"
                photo: "bob_klosterboer.jpg"
            }
        }


        Rectangle{
            id:evpHeadshots
            Layout.column: 0
            Layout.columnSpan: 6
            Layout.row: 6
            Layout.rowSpan: 1
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            //border.width: 1
            color:"ghostwhite"

            ListView {
                id: listView
                anchors.fill: parent
                anchors.leftMargin: 10
                orientation: ListView.Horizontal
                model: currentVPModel
                delegate: Item {
                    x: 5
                    width: parent.height
                    height: parent.height
                    Column {
                        id: row1
                        spacing: 0
                        topPadding:5
                        Image {
                            id: headshot
                            width: 60
                            source: photo
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            text: name
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter

                        }

                    }
                }
            }
        }

    }


}
