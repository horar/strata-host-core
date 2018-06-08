import QtQuick 2.11
import QtQuick.Layouts 1.3

Rectangle {
    id: root

//    anchors {
//        fill: parent
//    }

    width: childrenRect.width
    height: childrenRect.height

    property string label: ""
    property string info: ""
    property real infoBoxWidth: 50
    property color infoBoxColor: "#eeeeee"
    property color infoBoxBorderColor: "#cccccc"
    property real infoBoxBorderWidth: 1

//    onWidthChanged: {
//        if (labelText.width + infoContainer.width > root.parent.width){
//            grid.columns = 1;
//            labelText.padding = 5;
//        } else {
//            grid.columns = 2;
//            labelText.padding = 10;
//        }
//    }

    GridLayout{
        id: grid
        columnSpacing: 0
        rowSpacing: 0

        Text {
            id: labelText
            width: contentWidth + padding * 2
            text: label

            Component.onCompleted: text == "" ? padding = 0 : padding = 10;
        }

        Rectangle {
            id: infoContainer
            height: 30
            width: root.infoBoxWidth
            color: root.infoBoxColor
            border {
                color: root.infoBoxBorderColor
                width: root.infoBoxBorderWidth
            }

            TextInput {
                id: infoText
                padding: 10
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                text: info
                selectByMouse: true
                readOnly: true
            }
        }
    }
}
