import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3



Item {
    id: page1

    GridLayout{
        id: grid
        columns: 3
//        width: 300
//        height:200
        anchors.fill: parent

        property double colMulti : grid.width / grid.columns
        property double rowMulti : grid.height / grid.rows
        function prefWidth(item){
            return colMulti * item.Layout.columnSpan
            }
        function prefHeight(item){
            return rowMulti * item.Layout.rowSpan
            }
        function recalculateColumnSizes(){
            theRect.Layout.preferredWidth = grid.prefWidth(theRect);
            theRect.Layout.preferredHeight = grid.prefHeight(theRect);

            text1.Layout.preferredWidth = grid.prefWidth(text1);
            text1.Layout.preferredHeight = grid.prefHeight(text1);

            busyIndicator.Layout.preferredWidth = grid.prefWidth(busyIndicator);
            busyIndicator.Layout.preferredHeight = grid.prefHeight(busyIndicator);
        }

        onWidthChanged: {
           recalculateColumnSizes();
           console.log("grid width changed:",grid.width);
           console.log("grid height changed:",grid.height);
          }

        Component.onCompleted: {
            console.log("grid height:",grid.height);
            console.log("grid width:", grid.width);
        }

        Rectangle{
            id: theRect
            Layout.column: 0
            Layout.columnSpan: 1
//            Layout.row: 0
//            Layout.rowSpan: 1
//            Layout.preferredWidth  : grid.prefWidth(this)
//            Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true

            Component.onCompleted: {
                console.log("rectangle height:",theRect.height);
                console.log("rectangle width:", theRect.width);
            }

            color:"lightgrey"
            anchors.fill:parent
        }

        Text {
            id: text1

            //width: parent.width/4 //337
            //height: parent.height/4 //111
//            anchors.fill:parent
//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.verticalCenter: parent.verticalCenter

            text: qsTr("page 1")
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 72

            Layout.column: 1
            Layout.columnSpan: 1
            Layout.fillWidth:true
            Layout.fillHeight:true
//            Layout.row: 0
//            Layout.rowSpan: 1
//            Layout.preferredWidth  : grid.prefWidth(this)
//            Layout.preferredHeight : grid.prefHeight(this)
            Component.onCompleted: {
                console.log("text height:",text1.height);
                console.log("text width:", text1.width);
            }
        }

        BusyIndicator {
            id: busyIndicator
            anchors.fill:parent

            Layout.column: 2
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.fillWidth:true
            Layout.fillHeight:true
//            Layout.preferredWidth  : grid.prefWidth(this)
//            Layout.preferredHeight : grid.prefHeight(this)

            Component.onCompleted: {
                console.log("progress height:",busyIndicator.height);
                console.log("progress width:", busyIndicator.width);
            }

//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.verticalCenterOffset: 100
        }
    }


}
