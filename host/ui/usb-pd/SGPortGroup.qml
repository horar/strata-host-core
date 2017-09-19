import QtQuick 2.0
import QtQuick.Layouts 1.0

Rectangle {
    id: container
    color: "transparent"
    property alias text: portTitle.text

    GridLayout {
        id:grid
        width: container.width; height: container.height
        columns: 5; rows: 1; columnSpacing: 0; rowSpacing: 0
        property double colMulti : grid.width / grid.columns
        property double rowMulti : grid.height / grid.rows

        function prefWidth(item) {
            return colMulti * item.Layout.columnSpan
        }
        function prefHeight(item) {
            return rowMulti * item.Layout.rowSpan
        }

        SGPortTitle {
            id: portTitle
            Layout.column: 0
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            text: "Port 1"
        }

        SGIconList {
            id:iconList
            Layout.column: 2
            Layout.columnSpan: 2
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
        }

        Rectangle {
            id:connectorHolder
            border.color: "transparent"
            color: "transparent"
            Layout.column: 4
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)

            Rectangle {
                width:parent.width/3; height:parent.height/3
                color: "black"
                anchors {
                    right:connectorHolder.right
                    top:connectorHolder.top
                    topMargin: connectorHolder.width/0.88
                }
            }
        }
    }
}
