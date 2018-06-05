import QtQuick 2.11
import QtQuick.Layouts 1.3

Rectangle {
    id: root

    anchors.fill: parent
    //width: label.width
    height: childrenRect.height

    property string label: ""
    property string info: ""

    onWidthChanged: {
        if (labelText.width + infoContainer.width > root.width){
            grid.columns = 1;
            labelText.padding = 5;
        } else {
            grid.columns = 2;
            labelText.padding = 10;
        }
    }

    GridLayout{
        id: grid
        columnSpacing: 0
        rowSpacing: 0

        Text {
            id: labelText
            width: contentWidth + padding * 2
            text: label
            padding: 10
            anchors.leftMargin: 30
        }

        Rectangle {
            id: infoContainer
            height: 30
            width: 100
            color: "#eeeeee"
            border {
                color: "#000000"
                width: 0
            }

            TextInput {
                id: infoText
                padding: 10
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                text: info
                readOnly: true
            }
        }
    }
}
