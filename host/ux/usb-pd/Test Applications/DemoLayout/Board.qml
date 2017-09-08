import QtQuick 2.0
import QtQuick.Layouts 1.3

Rectangle{
    id: device
    //color:"white"
    //border.color: "black"
    //border.width: 2
    //radius: 10
    height: parent.width
    width: parent.width
    anchors.horizontalCenter: parent.horizontalCenter
    //anchors.horizontalCenterOffset: parent.width* .125
    anchors.verticalCenter: parent.verticalCenter



    //a grid for the the device, including the input plug
    GridLayout{
        id: deviceGrid
        columns: 4
        rows: 1
        columnSpacing: 0
        rowSpacing: 0
        anchors.fill:parent

        property double deviceColMulti : deviceGrid.width / deviceGrid.columns
        property double deviceRowMulti : deviceGrid.height / deviceGrid.rows
        function devicePrefWidth(item){
            return deviceColMulti * item.Layout.columnSpan
            }
        function devicePrefHeight(item){
            return deviceRowMulti * item.Layout.rowSpan
            }

        Rectangle{
            id:inputPlugColumn

            Layout.column: 0
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 1

            Layout.preferredWidth  : deviceGrid.devicePrefWidth(this)
            Layout.preferredHeight : deviceGrid.devicePrefHeight(this)

            //border.color: "black"
            //radius:10

            Rectangle{
                id:plugOutline
                border.color:"black"
                height: parent.height/4
                width:parent.height/4
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:parent.left

                Text {
                    id: inputPlugName
                    text: qsTr("input plug")
                    anchors.horizontalCenter: parent.horizontalCenter;
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: parent.width/10 > 0 ? parent.width/10 : 1
                }
            }
        }
        Rectangle{
            id:deviceLayout

            Layout.column: 1
            Layout.columnSpan: 3
            Layout.row: 0
            Layout.rowSpan: 1

            Layout.preferredWidth  : deviceGrid.devicePrefWidth(this)
            Layout.preferredHeight : deviceGrid.devicePrefHeight(this)

            Rectangle{
                id:deviceOutline
                border.color: "black"
                border.width: 2
                radius:10
                width:parent.width
                height: parent.height *.75

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
            }

            //a grid for the icon, and ports
            GridLayout{
                id: deviceGridLayout
                columns: 2
                rows: 2
                columnSpacing: 0
                rowSpacing: 0
                width: parent.width
                height: parent.height *.75

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0

                property double deviceGridLayoutColMulti : deviceGridLayout.width / deviceGridLayout.columns
                property double deviceGridLayoutRowMulti : deviceGridLayout.height / deviceGridLayout.rows
                function deviceGridLayoutWidth(item){
                    return deviceGridLayoutColMulti * item.Layout.columnSpan
                    }
                function deviceGridLayoutHeight(item){
                    return deviceGridLayoutRowMulti * item.Layout.rowSpan
                    }

                Rectangle{
                    id:leftDeviceColumn
                    color:"transparent"

                    Layout.column: 0
                    Layout.columnSpan: 1
                    Layout.row: 0
                    Layout.rowSpan: 2

                    Layout.preferredWidth  : deviceGridLayout.deviceGridLayoutWidth(this)
                    Layout.preferredHeight : deviceGridLayout.deviceGridLayoutHeight(this)

//                    border.color:"red"
//                    border.width:2
//                    radius: 10


                    Rectangle{
                        id:onLogo
                        color:"green"
                        height: parent.width/2
                        width: parent.width/2
                        radius: width/2
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left:parent.left
                        anchors.leftMargin: parent.width/8
                    }

                }

                Rectangle{
                    id:topPortRect
                    color:"white"

                    Layout.column: 1
                    Layout.columnSpan: 1
                    Layout.row: 0
                    Layout.rowSpan: 1

                    Layout.preferredWidth  : deviceGridLayout.deviceGridLayoutWidth(this)
                    Layout.preferredHeight : deviceGridLayout.deviceGridLayoutHeight(this)

                    border.color:"black"
                    border.width:2
                    radius: 10

                    Text {
                        id: port0Name
                        text: qsTr("port 0")
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: parent.width/10 > 0 ? parent.width/10 : 1
                    }
                }
                Rectangle{
                    id:bottomPortRect

                    Layout.column: 1
                    Layout.columnSpan: 1
                    Layout.row: 1
                    Layout.rowSpan: 1

                    Layout.preferredWidth  : deviceGridLayout.deviceGridLayoutWidth(this)
                    Layout.preferredHeight : deviceGridLayout.deviceGridLayoutHeight(this)

                    border.color:"black"
                    border.width:2
                    radius: 10

                    Text {
                        id: port1Name
                        text: qsTr("port 1")
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: parent.width/10 > 0 ? parent.width/10 : 1
                    }
                }



                Text{
                    text: "board"
                    color: "lightgrey"
                    font.family: "helvetica"
                    font.pointSize: parent.width/10 > 0 ? parent.width/10 : 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
        }
        }
/*
        Rectangle{
            id: leftDeviceColumn
            color:"transparent"
            Layout.column: 1
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 2

            Layout.preferredWidth  : deviceGrid.devicePrefWidth(this)
            Layout.preferredHeight : deviceGrid.devicePrefHeight(this)

            Rectangle{
                color:"green"
                height: parent.width/2
                width: parent.width/2
                radius: width/2
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:parent.left
                anchors.leftMargin: parent.width/8
            }
        }

        Rectangle{
            id: port0Cell
            color:"white"
            border.color: "black"
            border.width: 2
            Layout.column: 2
            Layout.columnSpan: 2
            Layout.row: 0
            Layout.rowSpan: 1

            Layout.preferredWidth  : deviceGrid.devicePrefWidth(this)
            Layout.preferredHeight : deviceGrid.devicePrefHeight(this)
            radius: 10

            Text {
                id: port0Name
                text: qsTr("port 0")
                anchors.horizontalCenter: parent.horizontalCenter;
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: parent.width/10 > 0 ? parent.width/10 : 1
            }
        }
        Rectangle{
            id: port1Cell
            color:"white"
            border.color: "black"
            border.width: 2
            Layout.column: 2
            Layout.columnSpan: 2
            Layout.row: 1
            Layout.rowSpan: 1
            radius: 10

            Layout.preferredWidth  : deviceGrid.devicePrefWidth(this)
            Layout.preferredHeight : deviceGrid.devicePrefHeight(this)

            Text {
                id: port1Name
                text: qsTr("port 1")
                anchors.horizontalCenter: parent.horizontalCenter;
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: parent.width/10 > 0 ? parent.width/10 : 1
            }
        } //port1cell


        //draw the outside of the device, which actually spans the
        //last three columns of the grid layout
        Rectangle{
            id:outline
            radius: 10
            border.color: "black"
            border.width: 2
            width: deviceColMulti * 3
            height: deviceColMulti * 3
        }
*/

    }   //deviceGrid
}
