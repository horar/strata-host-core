import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import tech.spyglass.ImplementationInterfaceBinding 1.0
import "framework"
import "advancedControls"

Rectangle {

    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 8;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 16;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;

    property color enabledTextColor: "#D8D8D8"
    property color disabledTextColor: "#7A7A7A"

    objectName: "advancedControls"


    ListModel {
        id: faultHistoryList
    }

    ListModel {
        id: activeFaultList
    }
    onVisibleChanged: {
        if(visible){
        faultHistoryList.append({"parameter":"voltage","condition":"<","value":value})
        console.log("message",faultHistoryList)
    }}

    // signal handling
    Connections {
        target: implementationInterfaceBinding

        onMinimumVoltageChanged: {
            if(state) {
                faultHistoryList.append({"parameter":"voltage","condition":"<","value":value})
            }
            else {
                faultHistoryList.append({"parameter":"voltage","condition":">","value":value})
            }

        }
    }

    GridLayout {
        id: grid
        columns: 3
        rows: 3
        anchors {fill:parent}
        columnSpacing: 0
        rowSpacing: 0

        property double colMulti : grid.width / grid.columns
        property double rowMulti : grid.height / grid.rows

        function prefWidth(item){
            return colMulti * item.Layout.columnSpan
        }
        function prefHeight(item){
            return rowMulti * item.Layout.rowSpan
        }


//        Rectangle {
        ScrollView{
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            //clip: true
            contentHeight: AdvancedControlSettings.height+1

            id:settings

            property var collapseAnimationSpeed:900

            //columns 0 and 1, both rows
            Layout.column: 0
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 3
            Layout.preferredWidth  : grid.prefWidth(this)
            //Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true

            //color: "black"




                AdvancedControlSettings{}
            }



//        } //settings rectangle

        Rectangle {
            id:boardRect
            //columns 0 and 1, both rows
            Layout.column: 1
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 2
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            z:1     //set the z level higher so connectors go behind the board
            color:"black"
            AdvancedBoard{}

            Text{
                id:usbPDText
                text:"USB-PD Dual"
                font.family: "helvetica"
                font.pointSize: extraLargeFontSize
                color:"#D8D8D8"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height/20
            }
            Text{
                text:"Advanced Controls"
                font.family: "helvetica"
                font.pointSize: largeFontSize
                color:"#D8D8D8"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: usbPDText.bottom
                anchors.topMargin: usbPDText.height/4
            }
        } //board rectangle

        //----------------------------------------
        //

        Rectangle {
            id:graphs
            //column 2, 2 rows
            Layout.column: 2
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 2
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true

            color: "yellow"

            GridLayout{
                id: graphGrid
                columns: 2
                rows: 3
                anchors {fill:parent}
                columnSpacing: 0
                rowSpacing: 0

                property double colMulti : graphGrid.width / graphGrid.columns
                property double rowMulti : graphGrid.height / graphGrid.rows

                function prefWidth(item){
                    return colMulti * item.Layout.columnSpan
                }
                function prefHeight(item){
                    return rowMulti * item.Layout.rowSpan
                }
                Rectangle{
                    id:port1VoltageAndCurrentRect
                    Layout.column: 0
                    Layout.columnSpan: 1
                    Layout.row: 0
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port1VoltageAndCurrentHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 1 VOLTAGE AND CURRENT"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port1VoltageAndCurrent
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port1VoltageAndCurrentHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }
                Rectangle{
                    id:port2VoltageAndCurrentRect
                    Layout.column: 1
                    Layout.columnSpan: 1
                    Layout.row: 0
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port2VoltageAndCurrentHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 2 VOLTAGE AND CURRENT"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port2VoltageAndCurrent
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port2VoltageAndCurrentHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }

                Rectangle{
                    id:port1PowerRect
                    Layout.column: 0
                    Layout.columnSpan: 1
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port1PowerHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 1 POWER"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port1Power
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port1PowerHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }
                Rectangle{
                    id:port2PowerRect
                    Layout.column: 1
                    Layout.columnSpan: 1
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port2PowerHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 2 POWER"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port2Power
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port2PowerHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }
                Rectangle{
                    id:port1TemperatureRect
                    Layout.column: 0
                    Layout.columnSpan: 1
                    Layout.row: 2
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port1TemperatureHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 1 TEMPERATURE"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port1Temperature
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port1TemperatureHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }

                Rectangle{
                    id:port2TemperatureRect
                    Layout.column: 1
                    Layout.columnSpan: 1
                    Layout.row: 2
                    Layout.rowSpan: 1
                    Layout.preferredWidth  : graphGrid.prefWidth(this)
                    Layout.preferredHeight : graphGrid.prefHeight(this)
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Rectangle{
                        id:port2TemperatureHeader
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:parent.top
                        height:20
                        color:"black"

                        Text{
                            text:"PORT 2 TEMPERATURE"
                            horizontalAlignment: Text.Center
                            font.family: "helvetica"
                            font.pointSize: smallFontSize
                            color:"#D8D8D8"
                            anchors.left:parent.left
                            anchors.right:parent.right
                            anchors.top:parent.top
                            anchors.verticalCenter: parent.verticalCenter
                            height:20
                        }
                    }

                    Image{
                        id:port2Temperature
                        source: "./images/placeholders/blackGraph.png"
                        anchors.left:parent.left
                        anchors.right:parent.right
                        anchors.top:port2TemperatureHeader.bottom
                        anchors.bottom:parent.bottom
                    }
                }

            }
        }

            Rectangle {
                id:message
                //row 3, columns 2 and 3
                Layout.column: 1
                Layout.columnSpan: 2
                Layout.row: 2
                Layout.rowSpan: 1
                Layout.preferredWidth  : grid.prefWidth(this)
                Layout.preferredHeight : grid.prefHeight(this)
                Layout.fillWidth:true
                Layout.fillHeight:true

                RowLayout{
                    anchors.fill:parent
                    spacing:-1
                    Rectangle{
                        id:activeFaults
                        Layout.preferredWidth:parent.width/3
                        Layout.preferredHeight:parent.height
                        color:"black"
                        border.color:"black"

                        Label{
                            id: activeFaultsLabel
                            text: "Active Faults"
                            font.family: "Helvetica"
                            font.pointSize: mediumFontSize
                            color: "#D8D8D8"
                            anchors.left:parent.left
                            anchors.top:parent.top
                            anchors.leftMargin: parent.width/20
                            anchors.topMargin: parent.height/20
                            }

                        Rectangle{
                           id:activeFaultsSeparator
                           anchors.left: parent.left
                           anchors.right: parent.right
                           anchors.leftMargin: parent.width/20
                           anchors.rightMargin: parent.width/20
                           anchors.top: activeFaultsLabel.bottom
                           anchors.topMargin: activeFaultsLabel.height
                           height: 1
                           color:"#CCCCCC"
                        }

                        Rectangle{
                            id:activeFaultsListBackground
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: activeFaultsSeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20
                            color: "#2B2B2B"
                        }

                        ListModel {
                            id:activeFaultsListModel
                            ListElement {
                                fault: "Port 1 Temperature: 71°C"
                            }
                        }

                        ListView {
                            id:activeFaultsListView
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: activeFaultsSeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20

                            model: activeFaultsListModel

                            delegate: Text {
                                text: fault
                                color: "orangered"
                                font.pointSize: smallFontSize
                            }

                        }

                    } //Active Fonts box

                    Rectangle{
                        id: faultHistory
                        Layout.preferredWidth:parent.width/3
                        Layout.preferredHeight:parent.height
                        color:"black"
                        border.color:"black"



                        Label{
                            id: faultHistoryLabel
                            text: "Fault History"
                            font.family: "Helvetica"
                            font.pointSize: mediumFontSize
                            color: "#D8D8D8"
                            anchors.left:parent.left
                            anchors.top:parent.top
                            anchors.leftMargin: parent.width/20
                            anchors.topMargin: parent.height/20
                            }

                        Rectangle{
                           id: faultHistorySeparator
                           anchors.left: parent.left
                           anchors.right: parent.right
                           anchors.leftMargin: parent.width/20
                           anchors.rightMargin: parent.width/20
                           anchors.top: faultHistoryLabel.bottom
                           anchors.topMargin: faultHistoryLabel.height
                           height: 1
                           color:"#CCCCCC"
                        }

                        Rectangle{
                            id:faultHistoryListBackground
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: faultHistorySeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20
                            color: "#2B2B2B"
                        }

                        ListModel {
                            id:faultHistoryListModel
                            ListElement {
                                fault: "Port 1 Temperature: 71°C"
                            }
                        }

                        ListView {
                            id:faultHistoryListView
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: faultHistorySeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20

                            model: faultHistoryListModel

                            delegate: Text {
                                text: fault
                                color: "#D8D8D8"
                                font.pointSize: smallFontSize
                            }
                        }


                    }
                    Rectangle{
                        id: usbPdMessages
                        Layout.preferredWidth:parent.width/3 +1
                        Layout.preferredHeight:parent.height
                        color:"black"
                        border.color:"black"

                        Label{
                            id: usbPDMessagesLabel
                            text: "USB-PD Messages"
                            font.family: "Helvetica"
                            font.pointSize: mediumFontSize
                            color: "#D8D8D8"
                            anchors.left:parent.left
                            anchors.top:parent.top
                            anchors.leftMargin: parent.width/20
                            anchors.topMargin: parent.height/20
                            }

                        Rectangle{
                           id: usbPDMessagesSeparator
                           anchors.left: parent.left
                           anchors.right: parent.right
                           anchors.leftMargin: parent.width/20
                           anchors.rightMargin: parent.width/20
                           anchors.top: usbPDMessagesLabel.bottom
                           anchors.topMargin: usbPDMessagesLabel.height
                           height: 1
                           color:"#CCCCCC"
                        }

                        Label{
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: usbPDMessagesSeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20
                            background: Rectangle {
                                color: "#2B2B2B"
                            }
                            text: "Capabilities request"
                            font.pointSize: smallFontSize
                            color: "#D8D8D8"
                        }
                    }
                }
            }
    }   //grid layout



}
