import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.2
import tech.spyglass.ImplementationInterfaceBinding 1.0

import "../framework"

Rectangle {
    id: device
    width: parent.width; height: parent.width * 1.5

    property alias deviceLayout: deviceLayout

    //  Getting realtime data for input voltage
    property double inputVoltage: implementationInterfaceBinding.inputVoltage;
    property double portCurrent: 0;

//    property bool harwareStatus: {
//        device.inputVoltage = implementationInterfaceBinding.inputVoltage;
//        implementationInterfaceBinding.platformState
//    }

    Connections {
        target: implementationInterfaceBinding

//        onPortInputVoltageChanged: {
//            device.inputVoltage = value;
//        }
        onPortCurrentChanged: {
            device.portCurrent = value;
        }
    }
    //anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
    anchors {horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; top:parent.top
            topMargin:parent.height/4}
    color:"black"


    //a grid for the the device, including the input plug
    //deviceGrid
    GridLayout {
        id: deviceGrid
        columns: 6
        rows: 1
        columnSpacing: 0
        rowSpacing: 0
        anchors { fill:parent}

        property double deviceColMulti : deviceGrid.width / deviceGrid.columns
        property double deviceRowMulti : deviceGrid.height / deviceGrid.rows

        function devicePrefWidth(item){
            return deviceColMulti * item.Layout.columnSpan
        }
        function devicePrefHeight(item){
            return deviceRowMulti * item.Layout.rowSpan
        }

        Rectangle {
            id:deviceLayout
            Layout.column: 1
            Layout.columnSpan: 4
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth : deviceGrid.devicePrefWidth(this)
            Layout.preferredHeight : deviceGrid.devicePrefHeight(this)
            color:"transparent"
            z:1 //in front of the plugOutline
            Material.elevation: 6

            Image {
                id:deviceOutline
                width:parent.width ; height: parent.width*1.5
                anchors{ horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: 0
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 0 }
                source: "../images/borderWhite.svg"

            }

            Rectangle{
                id:onLogoRect
                width:60
                height:60
                anchors{ left:parent.left
                         leftMargin: parent.width *.05
                    verticalCenter: parent.verticalCenter}
                color:"transparent"

                Image {
                    id:onLogo
                    width: parent.width; height: parent.width
                    //anchors{ verticalCenter: parent.verticalCenter; left:parent.left; leftMargin: parent.width/8 }
                    source:"../images/icons/onLogoGreen.svg"
                    layer.enabled: true
                    layer.effect:  DropShadow {
                        anchors.fill: onLogo
                        horizontalOffset: 3
                        verticalOffset: 6
                        radius: 12.0
                        samples: 24
                        color: "#60000000"
                        source: onLogo
                    }

                    ScaleAnimator {
                        id: increaseOnMouseEnter
                        target: onLogo;
                        from: 1;
                        to: 1.2;
                        duration: 200
                        running: false
                    }

                    ScaleAnimator {
                        id: decreaseOnMouseExit
                        target: onLogo;
                        from: 1.2;//onLogo.scale;
                        to: 1;
                        duration: 200
                        running: false
                    }

                    MouseArea {
                        id: imageMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered:{
                            increaseOnMouseEnter.start()
                        }
                        onExited:{
                            decreaseOnMouseExit.start()
                        }
                        onClicked: { inputPowergraph.open() }
                    }
                }
            }

            //a grid for the icon, and ports
            GridLayout {
                id: deviceGridLayout
                columns: 4
                rows: 2
                columnSpacing: 0
                //rowSpacing: parent.height/16
                width: parent.width; height: parent.height *.75

                anchors { horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: 0
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 0 }

                property double deviceGridLayoutColMulti : deviceGridLayout.width / deviceGridLayout.columns
                property double deviceGridLayoutRowMulti : deviceGridLayout.height / deviceGridLayout.rows

                function deviceGridLayoutWidth(item){
                    return deviceGridLayoutColMulti * item.Layout.columnSpan
                }

                function deviceGridLayoutHeight(item){
                    return deviceGridLayoutRowMulti * item.Layout.rowSpan
                }



                Rectangle {
                    id:topPortRect
                    color:"transparent"
                    Layout.column: 1
                    Layout.columnSpan: 4
                    Layout.row: 0
                    Layout.rowSpan: 1
                    Layout.preferredWidth : deviceGridLayout.deviceGridLayoutWidth(this)
                    Layout.preferredHeight : deviceGridLayout.deviceGridLayoutHeight(this)
                    border.color: "transparent"

                    AdvancedPort {
                        id: portGroupPort1
                        width: parent.width; height:parent.height
                        text: "Port 1"
                        radius: 1
                        //color: "transparent"
                        portNumber: 1
                        inAdvancedMode: true
                    }
                }

                Rectangle {
                    id:bottomPortRect
                    color:"transparent"
                    Layout.column: 1
                    Layout.columnSpan: 4
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth : deviceGridLayout.deviceGridLayoutWidth(this)
                    Layout.preferredHeight : deviceGridLayout.deviceGridLayoutHeight(this)
                    border { color: "transparent" }

                    AdvancedPort {
                        id: portGroupPort2
                        width: parent.width; height:parent.height
                        text: "Port 2"
                        radius: 1
                        //color: "transparent"
                        portNumber: 2
                        inAdvancedMode: true
                    }
                }
            }
        }

        Rectangle {
            id:inputPlugColumn
            Layout.column: 0
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth : deviceGrid.devicePrefWidth(this)
            Layout.preferredHeight : deviceGrid.devicePrefHeight(this)
            color: "transparent"
            Image {
                id: plugOutline
                width:parent.width*.8
                height:parent.height/7
                anchors{ verticalCenter: parent.verticalCenter;
                    right:parent.right
                    //rightMargin: -17
                }
                source: "../images/leftPowerPlugWhite.svg"
            }



            Text {
                id: inputPlugName
                text: {if (inputVoltage !=0){
                        text = Math.round(device.inputVoltage * 100) / 100 + "V"
                    }
                    else{
                        text: "0V"
                    }
                }
                width: inputPlugColumn.width-2
                horizontalAlignment: Text.AlignHCenter
                anchors {verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: parent.width/10
                        //right:parent.right
                        //rightMargin: -10
                        }
                font{ family: "Helvetica";
                    pointSize: (Qt.platform.os === "osx") ? parent.width/4 +1 : Text.fit
                    bold:true
                }
                color:"grey"

            }


        }

        Rectangle {
            id: connectors
            Layout.column: 5
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth : deviceGrid.devicePrefWidth(this)
            Layout.preferredHeight : deviceGrid.devicePrefHeight(this)
            color:"transparent"

            Rectangle{
                id:port1ConnectorRect
                anchors.top:parent.top
                anchors.topMargin: parent.height/8
                anchors.bottom:parent.verticalCenter
                anchors.left:parent.left
                anchors.right:parent.right
                color:"transparent"

                AdvancedConnector{
                    id:port1Connector
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle{
                id:port2ConnectorRect
                anchors.top:parent.verticalCenter
                anchors.bottom:parent.bottom
                anchors.bottomMargin: parent.height/8 - 10
                anchors.left:parent.left
                anchors.right:parent.right
                color:"transparent"

                AdvancedConnector{
                    id:port2Connector
                    anchors.verticalCenter: parent.verticalCenter
                }

            }
        }
    }
    SGPopup {
        id: inputPowergraph
        x: onLogo.x - onLogo.width / 2; y: onLogo.y - onLogo.height / 2
        width: boardRect.width/0.8 ;height: boardRect.height/2
        leftMargin : 30
        rightMargin : 30
        topMargin: 30
        bottomMargin:30
        axisXLabel: "Time (S)"
        axisYLabel: "Power (W)"
        efficencyLabel: false
        chartType:"Input Power"
        portNumber: 1
        powerMessageVisible: false;
        graphVisible: true;
        overlimitVisibility: false;
        underlimitVisibility: true;
    }
}
