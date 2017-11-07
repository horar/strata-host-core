import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import "framework"

Rectangle {
    id: device
    width: parent.width; height: parent.width
    property alias deviceLayout: deviceLayout
    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }


    //a grid for the the device, including the input plug
    //deviceGrid
    GridLayout {
        id: deviceGrid
        columns: 5
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

            Image {
                id:deviceOutline
                width:parent.width ; height: width //*.75
                anchors{ horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: 0
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 0 }
                source: "border.svg"
            }

            //a grid for the icon, and ports
            GridLayout {
                id: deviceGridLayout
                columns: 3
                rows: 2
                columnSpacing: 0
                rowSpacing: 0
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
                    id:leftDeviceColumn
                    color:"transparent"
                    Layout.column: 0
                    Layout.columnSpan: 1
                    Layout.row: 0
                    Layout.rowSpan: 2
                    Layout.preferredWidth : deviceGridLayout.deviceGridLayoutWidth(this)
                    Layout. preferredHeight : deviceGridLayout.deviceGridLayoutHeight(this)

                    Image {
                        id:onLogo
                        width: parent.width*.75; height: parent.width*.75
                        anchors{ verticalCenter: parent.verticalCenter; left:parent.left; leftMargin: parent.width/8 }
                        source:"On_Logo_Green.svg"

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

                Rectangle {
                    id:topPortRect
                    color:"transparent"
                    Layout.column: 1
                    Layout.columnSpan: 2
                    Layout.row: 0
                    Layout.rowSpan: 1
                    Layout.preferredWidth : deviceGridLayout.deviceGridLayoutWidth(this)
                    Layout.preferredHeight : deviceGridLayout.deviceGridLayoutHeight(this)
                    border.color: "transparent"
                    radius: 10

                    SGPortGroup {
                        id: portGroupPort1
                        width: parent.width; height:parent.height
                        text: "Port 1"
                        radius: 1
                        color: "transparent"
                    }
                }

                Rectangle {
                    id:bottomPortRect
                    color:"transparent"
                    Layout.column: 1
                    Layout.columnSpan: 2
                    Layout.row: 1
                    Layout.rowSpan: 1
                    Layout.preferredWidth : deviceGridLayout.deviceGridLayoutWidth(this)
                    Layout.preferredHeight : deviceGridLayout.deviceGridLayoutHeight(this)
                    border { color: "transparent" }

                    SGPortGroup {
                        id: portGroupPort2
                        width: parent.width; height:parent.height
                        //width: topPortRect.width; height: topPortRect.height
                        text: "Port 2"
                        radius: 1
                        color: "transparent"
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

            Image {
                id: plugOutline
                width:parent.width * 1.5
                height:parent.height/5
                anchors{ verticalCenter: parent.verticalCenter;
                    horizontalCenter: parent.horizontalCenter ;
                }
                source: "LeftPlug.png"
            }

            Text {
                id: inputPlugName
                text: qsTr("12 V")
                width: inputPlugColumn.width
                horizontalAlignment: Text.AlignRight
                anchors {verticalCenter: parent.verticalCenter}
                font{ family: "Helvetica"
                    bold:true
                }
                color:"grey"
            }

            Component.onCompleted: {
                //adjust font size based on platform
                if (Qt.platform.os === "osx"){
                    inputPlugName.font.pointSize = parent.width/10 > 0 ? parent.width/20 : 1;
                }
                else{
                    fontSizeMode : Text.Fit
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
        graphTitle: "Input Power Graph"
        inVariable1Name: "Power"
        efficencyLabel: true

    }
}
