import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Item {
    property var currentSystemModel: powerStagesModel
    property var currentSchematic: "./images/schematics/PowerStageSchematic.png"
    property var currentVPModel: vpModel2
    property var currentBlockDiagram: "./images/highlightedBlockDiagram/USB-PD_blockDiagram_PowerStage1Highlighted.png"

    GridLayout{
        id: systemContentGridLayout
        columns: 6
        rows: 7
        anchors {fill:parent
                bottomMargin: tabBar.height}
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
                    source:"./images/icons/DC-DCPowerIcon.png"
                }
                Button{
                    id:button1
                    checkable: true
                    checked: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{
                        border.width: 0
                        border.color: "black"
                        radius: 10
                        color: button1.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    contentItem: Text{
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 17 :10
                        text:"Port 1 Power"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: button1.checked ? "white" : "black"
                    }

                    onClicked: {
                        currentSystemModel = powerStagesModel
                        currentSchematic = "./images/schematics/PowerStageSchematic.png"
                        currentBlockDiagram = "./images/highlightedBlockDiagram/USB-PD_blockDiagram_PowerStage1Highlighted.png"
                        currentVPModel = vpModel2
                    }
                }
                Button{
                    id:button2
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{
                        border.width:0
                        border.color:"black"
                        radius: 10
                        color: button2.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    contentItem: Text{
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 17 :10
                        text:"Port 2 Power"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: button2.checked ? "white" : "black"
                    }
                    onClicked: {
                        currentSystemModel = powerStagesModel
                        currentSchematic = "./images/schematics/PowerStageSchematic.png"
                        currentBlockDiagram = "./images/highlightedBlockDiagram/USB-PD_blockDiagram_PowerStage2Highlighted.png"
                        currentVPModel = vpModel2
                    }
                }
                Button{
                    id:button3
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{
                        border.width:0
                        border.color: "black"
                        radius: 10
                        color: button3.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    contentItem: Text{
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 17 :10
                        text:"3.3 V Rail"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: button3.checked ? "white" : "black"
                    }
                    onClicked: {
                        currentSystemModel = threeVoltRailModel
                        currentSchematic = "./images/schematics/ThreeVoltRailSchematic.png"
                        currentBlockDiagram = "./images/highlightedBlockDiagram/USB-PD_blockDiagram_ThreeVoltHighlighted.png"
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
                    source:"./images/icons/ProtectionIcon.png"
                }
                Button{
                    id:button4
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{
                        border.width:0
                        border.color: "black"
                        radius: 10
                        color: button4.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    contentItem: Text{
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 17 :10
                        text:"Battery Protection"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: button4.checked ? "white" : "black"
                    }
                    onClicked: {
                        currentSystemModel = batterySystemModel
                        currentSchematic = "./images/schematics/BatteryProtectionSchematic.png"
                        currentBlockDiagram = "./images/highlightedBlockDiagram/USB-PD_blockDiagram_BatteryProtectionHighlighted.png"
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
                    source:"./images/icons/SensorsIcon.png"
                }
                Button{
                    id:button5
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 15
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:0
                        border.color: "black"
                        radius: 10
                        color: button5.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    contentItem: Text{
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 17 :10
                        text:"Temperature"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: button5.checked ? "white" : "black"
                    }
                    onClicked: {
                        currentSystemModel = tempSensorSystemModel
                        currentSchematic = "./images/schematics/TempSensorSchematic.png"
                        currentBlockDiagram = "./images/highlightedBlockDiagram/USB-PD_blockDiagram_TempSensorHighlighted.png"
                        currentVPModel = vpModel2
                    }
                }
                Button{
                    id:button6
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    visible: false
                    Layout.fillWidth: true
                    Layout.rightMargin: 25
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:0
                        border.color:"black"
                        radius: 10
                        color: button6.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    contentItem: Text{
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 17 :10
                        text:"A/D"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: button6.checked ? "white" : "black"
                    }
                    onClicked: {
                        currentSystemModel = tempSensorSystemModel
                        currentSchematic = "./images/schematics/TempSensorSchematic.png"
                        currentBlockDiagram = "./images/highlightedBlockDiagram/USB-PD_blockDiagram_TempSensorHighlighted.png"
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
                    Layout.rightMargin: 15
                    Layout.bottomMargin: 2
                    fillMode: Image.PreserveAspectFit
                    source:"./images/icons/USBInterfaceIcon.png"
                }
                Button{
                    id:button7
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 25
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:0
                        border.color:"black"
                        radius: 10
                        color: button7.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    contentItem: Text{
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 17 :10
                        text:"USB-C Port 1"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: button7.checked ? "white" : "black"
                    }
                    onClicked: {
                        currentSystemModel = usbCModel
                        currentSchematic = "./images/schematics/USBCInterfaceSchematic1.png"
                        currentBlockDiagram = "./images/highlightedBlockDiagram/USB-PD_blockDiagram_USB-C1Highlighted.png"
                        currentVPModel = vpModel2
                    }
                }
                Button{
                    id:button8
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    Layout.fillWidth: true
                    Layout.rightMargin: 25
                    Layout.leftMargin: 5
                    Layout.preferredHeight: systemContentGridLayout.prefWidth(this)/3
                    background: Rectangle{

                        border.width:0
                        border.color:"black"
                        radius: 10
                        color: button8.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    contentItem: Text{
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 17 :10
                        text:"USB-C Port 2"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: button8.checked ? "white" : "black"
                    }
                    onClicked: {
                        currentSystemModel = usbCModel
                        currentSchematic = "./images/schematics/USBCInterfaceSchematic1.png"
                        currentBlockDiagram = "./images/highlightedBlockDiagram/USB-PD_blockDiagram_USB-C2Highlighted.png"
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
             source:currentBlockDiagram
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
                     color: isPartName? "lightgrey":
                                        index % 2 == 0 ? "ghostwhite":"#EEEEEE"
                     border.width: 1
                     border.color: "white"
                     Text {
                         id: systemDataItem
                         text: file ? "<a href='http:" +file+ "'>"+name+"</a>":name
                         linkColor: Qt.darker("#2eb457")
                         onLinkActivated: documentationPopup.open()
                         anchors.horizontalCenter: parent.horizontalCenter
                         anchors.verticalCenter: parent.verticalCenter
                         font.bold: isPartName? true: false
                     }
                     Popup {
                         id: documentationPopup
                         width: mainWindow.contentItem.width * 0.75; height: mainWindow.contentItem.height * 0.65
                         modal: true
                         focus: true

                         topMargin: mainWindow.contentItem.height/4
                         bottomMargin: mainWindow.contentItem.height/4
                         leftMargin: mainWindow.contentItem.width/4
                         rightMargin: mainWindow.contentItem.width/4

                         closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                         background: Image {
                             id: popupBorder
                             source: "./images/dialogBorder.svg"
                             width:parent.width; height:parent.height

                             MouseArea {
                                 id: mouseArea
                                 width: parent.width/7; height: width
                                 anchors.centerIn: popupBorder.Top
                                 anchors.right: popupBorder.right
                                 onClicked: { documentationPopup.close() }
                             }
                         }
                         contentItem: Rectangle{
                             id: contentRectangle
                             anchors.fill:parent
                             anchors.topMargin:20
                             anchors.leftMargin:20
                             anchors.rightMargin: 20
                             anchors.bottomMargin: 20
                             color:"transparent"
                             border.width:0
                             Image {
                                 anchors.fill: parent
                                 fillMode: Image.PreserveAspectFit
                                 source: "images/NCV81599_test_report.png";
                             }
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
                     border.color: "#2EB457"
                     border.width: 2
                     color:"#802EB457"
                     Text{
                         anchors.centerIn: parent
                         width:parent.width
                         horizontalAlignment: Text.AlignHCenter
                         text:"Open schematic"
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
                         width: mainWindow.contentItem.width * 0.65
                         height: mainWindow.contentItem.height * 0.65
                         modal: true
                         focus: true

                         topMargin: mainWindow.contentItem.height/4
                         bottomMargin: mainWindow.contentItem.height/4
                         leftMargin: mainWindow.contentItem.width/4
                         rightMargin: mainWindow.contentItem.width/4
                         closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                         background: Image {
                             id: popupBorder
                             source: "./images/dialogBorder.svg"
                             width:parent.width
                             height:parent.height

                             MouseArea {
                                 id: mouseArea
                                 width: parent.width/7; height: width
                                 anchors.centerIn: popupBorder.Top
                                 anchors.right: popupBorder.right
                                 onClicked: { schematicPopup.close() }
                             }
                         }
                         contentItem: Rectangle{
                             id: contentRectangle
                             anchors.fill:parent
                             anchors.topMargin:20
                             anchors.leftMargin:20
                             anchors.rightMargin: 20
                             anchors.bottomMargin: 20
                             color:"transparent"
                             border.width:0
                             Image {
                                 anchors.topMargin:20
                                 anchors.leftMargin:20
                                 anchors.rightMargin: 20
                                 anchors.bottomMargin: 20
                                 anchors.fill: parent
                                 fillMode: Image.PreserveAspectFit
                                 source: "images/ONSEC-17-014_schematic.png";
                             }

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
                file: ""
                isPartName: true
            }

            ListElement {
                system: "batterySystem"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "batterySystem"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "batterySystem"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "batterySystem"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "batterySystem"
                name: ""
                file: ""
                isPartName: false
            }



        }

        ListModel {
            id: tempSensorSystemModel
            ListElement {
                system: "tempSensorSystem"
                name: "NVT211"//"NVT211 Dual Channel Temp Monitor"
                file: ""
                isPartName: true
            }
            ListElement {
                system: "tempSensorSystem"
                name: "Test Report"
                file: ""
                isPartName: false
            }

            ListElement {
                system: "tempSensorSystem"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                file: ""
                isPartName: false
            }

            ListElement {
                system: "tempSensorSystem"
                name: "SMMBT3906WT1G"//"SMMBT3906WT1G Auto BJT PNP"
                file: ""
                isPartName: true
            }
            ListElement {
                system: "tempSensorSystem"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                file: ""
                isPartName: false
            }
        }

        ListModel {
            id: threeVoltRailModel
            ListElement {
                system: "3.3V Rail"
                name: "NCV890100"//"NCV890100 1.2A, 2 MHz Automotive Buck Switching Regulator"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "3.3V Rail"
                name: "SEC Test Report"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "EVB Schematic"
                file: ""
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
                file: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "NSVR05F40NX"//"NSVR05F40NX Schottky Barrier Diode"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "3.3V Rail"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                file: ""
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
                file: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "NRVB140SF"//"NRVB140SF Surface Mount Schottky Power Rectifier"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "3.3V Rail"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "tempSensorSystem"
                name: ""
                file: ""
                isPartName: false
            }
        }
        ListModel {
            id: powerStagesModel
            ListElement {
                system: "Power Stages"
                name: "NCV81599"//"NCV81599 Automotive 4 Switch Buck-Boost"
                file: ""
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
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "EVB User Guide"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "EVB GUI Download"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                file: ""
                isPartName: false
            }

            ListElement {
                system: "Power Stages"
                name: "NVTFS5C453"//"NVTFS5C453 Power MOSFET"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "NSVR05F40NX"//"NSVR05F40NX Schottky Barrier Diode"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "BVSS84L"//"BVSS84L Automotive Small Signal MOSFET "
                file: ""
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "2V7002W"//"2V7002W Automotive Small Signal MOSFET"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: ""
                file: ""
                isPartName: false
            }
        }

        ListModel {
            id: usbCModel
            ListElement {
                system: "USB-C Interface"
                name: "NSVR05F40NX"//"NSVR05F40NX Schottky Barrier Diode"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: "NSVR05F40NX"//"SZESD7104 4-ch Transient Voltage Suppressors"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: "2V7002W"//"2V7002W Automotive Small Signal MOSFET"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: "NVTFS5C453"//"NVTFS5C453 Power MOSFET"
                file: ""
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: ""
                file: ""
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
                photo: "qrc:/images/bill_hall.jpg"
            }
        }

        ListModel{
            id: vpModel2
            ListElement {
                name: "Bill Hall"
                photo: "qrc:/images/bill_hall.jpg"
            }

            ListElement {
                name: "Bob Klosterboer"
                photo: "./images/bob_klosterboer.jpg"
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
