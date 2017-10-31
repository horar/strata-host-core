import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Item {
    property var currentSystemModel: batterySystemModel
    property var currentEVPModel: evpListModel
    property var currentSchematic: "BatteryProtectionSchematic.png"

    GridLayout{
        id: systemContentGridLayout
        columns: 2
        rows: 10
        anchors {fill:parent
                bottomMargin:40}
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
            id: pageTitle
            Layout.column: 0
            Layout.columnSpan: 2
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            border.width: 0
            color:"transparent"
            Text{
                text: "System Content"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Helvetica"
                font.pointSize: 36
            }
        }

        Rectangle{
            id: blockDiagram
            Layout.column: 0
            Layout.columnSpan: 2
            Layout.row: 1
            Layout.rowSpan: 4
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            border.width: 0
            color:"transparent"

            GridLayout{
                id: blockDiagramGridLayout
                columns: 9
                rows: 4
                anchors {fill:parent}
                columnSpacing: 0
                rowSpacing: 0

                property double colMulti : blockDiagramGridLayout.width / blockDiagramGridLayout.columns
                property double rowMulti : blockDiagramGridLayout.height / blockDiagramGridLayout.rows

                function prefWidth(item){
                    return colMulti * item.Layout.columnSpan
                }
                function prefHeight(item){
                    return rowMulti * item.Layout.rowSpan
                }


                Image{
                    id: battery
                    Layout.column: 1
                    Layout.columnSpan: 1
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    fillMode: Image.PreserveAspectFit
                    source:"battery.png"
                }


                Button{
                    id:batterySystem
                    Layout.column: 2
                    Layout.columnSpan: 1
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    checkable: true
                    checked: true
                    ButtonGroup.group: systemButtonGroup
                    background: Rectangle{
                        border.width:batterySystem.checked ? 3 :1
                        border.color: batterySystem.checked? "red" : "black"
                        radius: 4
                        color: batterySystem.checked ? Qt.darker("#2eb457") : "#2eb457"

                    }
                    text: qsTr("Battery Protection")
                    Component.onCompleted: contentItem.wrapMode = Text.WordWrap

                    onClicked: {
                        currentSystemModel = batterySystemModel
                        currentSchematic = "BatteryProtectionSchematic.png"
                        updateEVPList();
                    }

                }


                Button{
                    id:tempSensorSystem
                    Layout.column: 3
                    Layout.columnSpan: 2
                    Layout.row: 2
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    text: qsTr("Temperature Sensor")
                    background: Rectangle{
                        border.width:tempSensorSystem.checked ? 3 :1
                        border.color: tempSensorSystem.checked? "red" : "black"
                        radius: 4
                        color: tempSensorSystem.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }

                    onClicked: {
                        currentSystemModel = tempSensorSystemModel
                        currentSchematic = "TempSensorSchematic.png"
                    }
                }

                Button{
                    id:threeVLineButton
                    Layout.column: 3
                    Layout.columnSpan: 1
                    Layout.row: 4
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    text: qsTr("3.3 Volt Rail")
                    background: Rectangle{
                        border.width:threeVLineButton.checked ? 3 :1
                        border.color: threeVLineButton.checked? "red" : "black"
                        radius: 4
                        color: threeVLineButton.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = threeVoltRailModel
                        currentSchematic = "ThreeVoltRailSchematic.png"
                    }
                }

                Button{
                    id:powerButton1
                    Layout.column: 4
                    Layout.columnSpan: 2
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    text: qsTr("Power Stage")
                    background: Rectangle{
                        border.width:powerButton1.checked ? 3 :1
                        border.color: powerButton1.checked? "red" : "black"
                        radius: 4
                        color: powerButton1.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = powerStagesModel
                        currentSchematic = "NCV81599-PowerStage1.png"
                    }
                }

                Button{
                    id:powerButton2
                    Layout.column: 4
                    Layout.columnSpan: 2
                    Layout.row: 3
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    text: qsTr("Power Stage")
                    background: Rectangle{
                        border.width:powerButton2.checked ? 3 :1
                        border.color: powerButton2.checked? "red" : "black"
                        radius: 4
                        color: powerButton2.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = powerStagesModel
                        currentSchematic = "NCV81599-PowerStage1.png"
                    }
                }

                Rectangle{
                    id: mcu
                    Layout.column: 5
                    Layout.columnSpan: 2
                    Layout.row: 2
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    border.width: 1
                    radius: 4
                    color:"lightgrey"
                    Label{
                        id:mcuLabel
                        text:"MCU"
                        font.pointSize: 24
                        anchors.centerIn: parent
                    }
                }



                Button{
                    id: usb1
                    Layout.column: 7
                    Layout.columnSpan: 2
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    text: qsTr("USB")
                    background: Rectangle{
                        border.width:usb1.checked ? 3 :1
                        border.color: usb1.checked? "red" : "black"
                        radius: 4
                        color: usb1.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = usbCModel
                        currentSchematic = "USBCInterfaceSchematic1.png"
                    }
                }

                Button{
                    id: usb2
                    Layout.column: 7
                    Layout.columnSpan: 2
                    Layout.row: 3
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    checkable: true
                    ButtonGroup.group: systemButtonGroup
                    text: qsTr("USB")
                    background: Rectangle{
                        border.width:usb2.checked ? 3 :1
                        border.color: usb2.checked? "red" : "black"
                        radius: 4
                        color: usb2.checked ? Qt.darker("#2eb457") : "#2eb457"
                    }
                    onClicked: {
                        currentSystemModel = usbCModel
                        currentSchematic = "USBCInterfaceSchematic1.png"
                    }
                }


                Image{
                    id: usbCPort1
                    Layout.column: 9
                    Layout.columnSpan: 1
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    fillMode: Image.PreserveAspectFit
                    source:"usb-c_plug.png"
                }
                Image{
                    id: usbCPort2
                    Layout.column: 9
                    Layout.columnSpan: 1
                    Layout.row: 3
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
                    Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    fillMode: Image.PreserveAspectFit
                    source:"usb-c_plug.png"
                }

            }

            ButtonGroup {
                id: systemButtonGroup
            }
        }

        ListModel {
            id: batterySystemModel
            ListElement {
                system: "batterySystem"
                name: "NVMFS5A140PLZ P-Channel Power MOSFET"
                isPartName: true
            }

            ListElement {
                system: "batterySystem"
                name: "Datasheet"
                isPartName: false
            }

        }

        ListModel {
            id: tempSensorSystemModel
            ListElement {
                system: "tempSensorSystem"
                name: "NVT211 Dual Channel Temp Monitor"
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
                name: "SMMBT3906WT1G Auto BJT PNP"
                isPartName: true
            }
            ListElement {
                system: "tempSensorSystem"
                name: "Datasheet"
                isPartName: false
            }
        }

        ListModel {
            id: threeVoltRailModel
            ListElement {
                system: "3.3V Rail"
                name: "NCV890100 1.2A, 2 MHz Automotive Buck Switching Regulator"
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
                name: "Design Worksheet Download"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "NSVR05F40NX Schottky Barrier Diode"
                isPartName: true
                }
            ListElement {
                system: "3.3V Rail"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "3.3V Rail"
                name: "NRVB140SF Surface Mount Schottky Power Rectifier"
                isPartName: true
                }
            ListElement {
                system: "3.3V Rail"
                name: "Datasheet"
                isPartName: false
            }
        }
        ListModel {
            id: powerStagesModel
            ListElement {
                system: "Power Stages"
                name: "NCV81599 Automotive 4 Switch Buck-Boost"
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "SEC Test Report"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "EVB Schematic"
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
                name: "NVTFS5C453 Power MOSFET"
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "NSVR05F40NX Schottky Barrier Diode"
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "BVSS84L Automotive Small Signal MOSFET "
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "Power Stages"
                name: "2V7002W Automotive Small Signal MOSFET"
                isPartName: true
                }
            ListElement {
                system: "Power Stages"
                name: "Datasheet"
                isPartName: false
            }
        }

        ListModel {
            id: usbCModel
            ListElement {
                system: "USB-C Interface"
                name: "NSVR05F40NX Schottky Barrier Diode"
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: "SZESD7104 4-ch Transient Voltage Suppressors"
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: "2V7002W Automotive Small Signal MOSFET"
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                isPartName: false
            }
            ListElement {
                system: "USB-C Interface"
                name: "NVTFS5C453 Power MOSFET"
                isPartName: true
                }
            ListElement {
                system: "USB-C Interface"
                name: "Datasheet"
                isPartName: false
            }
        }


        Rectangle{
            id:partList
            Layout.column: 0
            Layout.columnSpan: 1
            Layout.row: 5
            Layout.rowSpan: 4
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            border.width: 1
            color:"transparent"

            ListView {
                id: listView1
                anchors.fill:parent
                anchors.leftMargin: 10
                anchors.topMargin: 25
                delegate: Item {
                    x: 5
                    width: 80
                    height: 40
                    Row {
                        id: row2
                        spacing: 5

                        Text {
                            text: name
                            //anchors.verticalCenter: parent.verticalCenter
                            //anchors.left: parent.left
                            leftPadding: isPartName ? 0 : 20
                            font.bold: isPartName ? true : false
                        }
                    }
                }
                model: currentSystemModel
            }
        }

        Rectangle{
            id:schematicImage
            Layout.column: 1
            Layout.columnSpan: 1
            Layout.row: 5
            Layout.rowSpan: 4
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            border.width: 1
            //color:"lightgrey"
            Image {
                id: schematic
                source: currentSchematic
                anchors.fill:parent
                fillMode: Image.PreserveAspectFit
            }
        }

        property var index_bob_klosterboer: 0
        property var index_bill_hall: 1
        ListModel{
            id: evpListModel
            ListElement {
                name: "Bob Klosterboer"
                photo: "bob_klosterboer.jpg"
            }

            ListElement {
                name: "Bill Hall"
                photo: "bill_hall.jpg"
            }
        }

        function updateEVPList()
        {
            currentEVPModel.clear() //clear the list

            for (var i=0; i<currentSystemModel.count; ++i)
            {
                var businessUnitList = currentSystemModel.get(i).businessUnit;
                if (businessUnitList.indexOf("SA") != -1){
                    currentEVPModel.append(evpListModel.get(index_bob_klosterboer))
                }
            }
         }



        Rectangle{
            id:evpHeadshots
            Layout.column: 0
            Layout.columnSpan: 2
            Layout.row: 9
            Layout.rowSpan: 1
            Layout.preferredWidth  : systemContentGridLayout.prefWidth(this)
            Layout.preferredHeight : systemContentGridLayout.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            border.width: 1
            color:"yellow"

            ListView {
                id: listView
                anchors.fill: parent
                anchors.leftMargin: 40
                orientation: ListView.Horizontal
                spacing: 0
                model: evpListModel//currentEVPModel
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
                            //width: 60
                            height: 60
                            fillMode: Image.PreserveAspectFit
                            source: photo
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
