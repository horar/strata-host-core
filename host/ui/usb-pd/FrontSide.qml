import QtQuick 2.0
import QtQuick.Layouts 1.3

Rectangle {
    anchors{ fill: parent }

    GridLayout {
        id: grid
        columns: 5
        rows: 2
        columnSpacing: 0
        anchors{ fill:parent }

        property double colMulti : grid.width / grid.columns
        property double rowMulti : grid.height / grid.rows

        function prefWidth(item){
            return colMulti * item.Layout.columnSpan
        }
        function prefHeight(item){
            return rowMulti * item.Layout.rowSpan
        }

        Rectangle {
            id:boardRect
            //columns 0 and 1, both rows
            Layout.column: 0
            Layout.columnSpan: 2
            Layout.row: 0
            Layout.rowSpan: 2
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Board{}

        } //board rectangle

        Rectangle {
            //Column 3 top row, 1st connector
            Layout.column: 2
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Connector { anchorbottom: 1 }
        }

        Rectangle {
            //Column 3 bottom row, 2nd connector
            Layout.column: 2
            Layout.columnSpan: 1
            Layout.row: 1
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Connector { anchorbottom: 0 }
        }

        Rectangle {
            //Column 3 top row, first device
            Layout.column: 3
            Layout.columnSpan: 2
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Device { verticalOffset: parent.height/4 }
        }

        Rectangle {
            //Column 3 bottom row, second device
            Layout.column: 3
            Layout.columnSpan: 2
            Layout.row: 1
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Device { verticalOffset: -parent.height/3 }
        }
    } //GridLayout

    Image {
        anchors{ bottom: parent.bottom;right: parent.right}
        height: 40; width:40
        source:"infoIcon.svg"
    }
    MouseArea {
        width: 100; height: 100
        anchors{ right: parent.right;bottom: parent.bottom }
        visible: true
        onClicked: flipable.flipped = !flipable.flipped
    }
}
