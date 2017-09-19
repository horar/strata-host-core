import QtQuick 2.0
import QtQuick.Layouts 1.3

Rectangle {
    id: device
    width: parent.width; height: parent.width
    property alias deviceLayout: deviceLayout
    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

    //a grid for the the device, including the input plug
    //deviceGrid
    GridLayout {
        id: deviceGrid
        columns: 4
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
            Layout.columnSpan: 3
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth : deviceGrid.devicePrefWidth(this)
            Layout.preferredHeight : deviceGrid.devicePrefHeight(this)

            Image {
                id:deviceOutline
                width:parent.width; height: parent.height *.75
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
                        width: parent.width/2; height: parent.width/2
                        anchors{ verticalCenter: parent.verticalCenter; left:parent.left; leftMargin: parent.width/3 }
                        source:"On_Logo_Green.svg"
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
                        width: parent.width/0.95; height:parent.height/0.95
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
                        width: parent.width/0.95; height:parent.height/0.95
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
                width:parent.height/3.4; height: parent.height/4
                anchors{ verticalCenter: parent.verticalCenter; left:parent.left }
                source: "LeftPlug.png"

                Text {
                    id: inputPlugName
                    text: qsTr("12 V")
                    anchors { horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: parent.width/7; verticalCenter: parent.verticalCenter }
                    font.pointSize: parent.width/10 > 0 ? parent.width/10 : 1
                }
            }
        }
    }
}
