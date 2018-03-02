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
    property color disabledTextColor: "#484848"
    property color unselectedButtonSegmentTextColor: "black"
    property color textEditFieldBackgroundColor: "#5D5A58"
    property color popupMenuBackgroundColor: "#5D5A58"

    objectName: "advancedControls"


    ListModel {
        id: faultHistoryList
    }

    ListModel {
        id: activeFaultList
    }

    //visibility is the only way we know that this view has been pushed on the stack
    //handle activities that need to happen when the advanced controls view is seen here.
    onVisibleChanged: {


        if(visible){
            faultHistoryList.append({"parameter":"voltage","condition":"<","value":value})
            console.log("message",faultHistoryList)
        }

    }

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


        ScrollView{
            id:settings
            contentHeight: 970// this has to be set manually based on the height of the controlSettings
            //columns 0 and 1, both rows
            Layout.column: 0
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 3
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.fillWidth:true
            Layout.fillHeight:true

            property var collapseAnimationSpeed:900

            ScrollBar.vertical: ScrollBar{
                policy: ScrollBar.AsNeeded
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                active:pressed
                contentItem: Rectangle{
                    //width:40
                    implicitWidth: 1
                    implicitHeight: 100
                    radius: width / 2
                    color: disabledTextColor
                }
            }

            background: Rectangle{
                color:"black"
            }

            AdvancedControlSettings{ id:controlSettings}
        }


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
            AdvancedBoard{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                //anchors.bottomMargin: parent.height/2
            }

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
        //  graphs
        //----------------------------------------
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

            color: "black"

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

                    AdvancedGraph{
                        id:port1VoltageAndCurrentGraph
                        title: "PORT 1: VOLTAGE AND CURRENT"
                        chartType: "Target Voltage"
                        maxYValue: 25
                        portNumber:1
                        anchors.top:parent.top
                        anchors.topMargin: -15
                        anchors.left:parent.left
                        anchors.leftMargin: -15
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin: -12
                        anchors.right:parent.right
                        anchors.rightMargin: -10
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
                    color:"black"

                    AdvancedGraph{
                        id:port2VoltageAndCurrentGraph
                        title: "PORT 2: VOLTAGE AND CURRENT"
                        chartType: "Target Voltage"
                        portNumber:2
                        maxYValue: 25
                        anchors.top:parent.top
                        anchors.topMargin: -15
                        anchors.left:parent.left
                        anchors.leftMargin: -15
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin: -12
                        anchors.right:parent.right
                        anchors.rightMargin: -10
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
                    color:"black"

                    AdvancedGraph{
                        id:port1PowerGraph
                        title: "PORT 1 POWER"
                        chartType: "Port Power"
                        portNumber:1
                        maxYValue: 100
                        anchors.top:parent.top
                        anchors.topMargin: -15
                        anchors.left:parent.left
                        anchors.leftMargin: -15
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin: -12
                        anchors.right:parent.right
                        anchors.rightMargin: -10
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
                    color:"black"

                    AdvancedGraph{
                        id:port2PowerGraph
                        title: "PORT 2 POWER"
                        chartType: "Port Power"
                        portNumber:2
                        maxYValue: 100
                        anchors.top:parent.top
                        anchors.topMargin: -15
                        anchors.left:parent.left
                        anchors.leftMargin: -15
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin: -12
                        anchors.right:parent.right
                        anchors.rightMargin: -10
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
                    color:"black"

                    AdvancedGraph{
                        id:port1TemperatureGraph
                        title: "PORT 1 TEMPERATURE"
                        chartType: "Port Temperature"
                        portNumber:1
                        maxYValue: 100
                        anchors.top:parent.top
                        anchors.topMargin: -15
                        anchors.left:parent.left
                        anchors.leftMargin: -15
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin: -12
                        anchors.right:parent.right
                        anchors.rightMargin: -10
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
                    color:"black"

                    AdvancedGraph{
                        id:port2TemperatureGraph
                        title: "PORT 2 TEMPERATURE"
                        chartType: "Port Temperature"
                        portNumber:2
                        maxYValue: 100
                        anchors.top:parent.top
                        anchors.topMargin: -15
                        anchors.left:parent.left
                        anchors.leftMargin: -15
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin: -12
                        anchors.right:parent.right
                        anchors.rightMargin: -10
                    }
                }

            }
        }

        //----------------------------------------------------
        //  Messages (faults and CC)
        //----------------------------------------------------
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
                            anchors.topMargin: parent.height/15
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/15

                            ScrollBar.vertical: ScrollBar {
                                    active: true
                                    }

                            model: activeFaultsListModel

                            delegate: Text {
                                text: modelData
                                color: "orangered"
                                font.pointSize: smallFontSize
                            }

                        }

                    } //Fault History box

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
                            anchors.topMargin: parent.height/15
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/15

                            ScrollBar.vertical: ScrollBar {
                                    active: true
                                    }

                            model: faultHistoryListModel

                            delegate: Text {
                                text: modelData
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

                        Rectangle{
                            id:usbPDListBackground
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: usbPDMessagesSeparator.bottom
                            anchors.topMargin: parent.height/20
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/20
                            color: "#2B2B2B"
                        }

                        ListModel {
                            id:usbPDListModel
                            ListElement {
                                fault: "Port 1 Temperature: 71°C"
                            }
                        }

                        ListView {
                            id:usbPDListView
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/20
                            anchors.top: usbPDMessagesSeparator.bottom
                            anchors.topMargin: parent.height/15
                            anchors.bottom:parent.bottom
                            anchors.bottomMargin: parent.height/15

                            ScrollBar.vertical: ScrollBar {
                                    active: true
                                    }

                            model: faultHistoryListModel

                            delegate: Text {
                                text: fault
                                color: "#D8D8D8"
                                font.pointSize: smallFontSize
                            }
                        }

//                        Label{
//                            anchors.left: parent.left
//                            anchors.leftMargin: parent.width/20
//                            anchors.right: parent.right
//                            anchors.rightMargin: parent.width/20
//                            anchors.top: usbPDMessagesSeparator.bottom
//                            anchors.topMargin: parent.height/20
//                            anchors.bottom:parent.bottom
//                            anchors.bottomMargin: parent.height/20
//                            background: Rectangle {
//                                color: "#2B2B2B"
//                            }
//                            text: "Capabilities request"
//                            font.pointSize: smallFontSize
//                            color: "#D8D8D8"
//                        }
                    }
                }
            }
    }   //grid layout



}
