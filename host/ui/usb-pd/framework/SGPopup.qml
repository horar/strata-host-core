import QtQuick 2.7
import QtQuick.Controls 2.0


Popup {
    id: container
    property alias axisXLabel: labelAxis_x.text
    property alias axisYLabel: labelAxis_y.text
    property alias axisY2Label: labelAxis_y2.text
    property alias inVariable1Name: graph.variable1Name
    property alias inVariable2Name: graph.variable2Name
    property alias inVariable1Color: graph.variable1Color
    property alias inVariable2Color: graph.variable2Color
    property alias graphTitle: graph.title
    property real startPositionX: 0
    property real startPositionY: 0
    property bool efficencyLabel: false;

    modal: true
    focus: false
    dim: true

    transformOrigin : Popup.Center

    background: Rectangle {
        opacity: 0.0
        color: "transparent"
        border.color : "transparent"
    }
        Image {
            id: popupBoarder
            source: "./images/boarder_graph.svg"
            width: container.width; height: container.height
            z: 0

            MouseArea {
                id: mouseArea
                width: parent.width/7; height: width
                anchors.centerIn: popupBoarder.Top
                anchors.right: popupBoarder.right
                onClicked: { container.close() }
            }
        }



        enter: Transition {
            // grow and fade_in
            ParallelAnimation {
                NumberAnimation { property: "scale"; from: 0.1; to: 1.0; easing.type: Easing.OutQuint; duration: 1000 }
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 1000  }
                //NumberAnimation { property: "x"; from: startPositionX; to:parent.width/4-container.width/2; duration: 1000}
                //NumberAnimation { property: "y"; from: startPositionY; to:parent.height/4-container.height/2; duration: 1000}
            }
        }

        exit: Transition {
            // shrink and fade_out
            ParallelAnimation {
                NumberAnimation { property: "scale"; from: 1.0; to: 0.1; easing.type: Easing.OutQuint; duration: 500 }
                NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 500 }
            }
        }
    contentItem:
        Rectangle {
        id:contentItem
        width: container.width; height: container.height
        color: "transparent"
        border.color : "transparent"
        z: 2
        Label {
            id: labelAxis_x
            y: 430
            width: 100; height: 50
            z: 2
            color: "grey"
            fontSizeMode:Text.Fit
            font{ family:"helvetica"}
            anchors { bottom: contentItem.bottom; horizontalCenter: contentItem.horizontalCenter}
        }
        Label {
            id: labelAxis_y
            width: 100; height: 50
            z: 2
            color: inVariable1Color
            fontSizeMode:Text.Fit
            font{ family:"helvetica"}
            rotation: -90
            anchors { left: contentItem.left;
                verticalCenter: contentItem.verticalCenter;
            }
        }
        Label {
            id: labelAxis_y2
            width: 100; height: 50
            z: 2
            color: inVariable2Color
            fontSizeMode:Text.Fit
            font{ family:"helvetica" }
            rotation: 90
            anchors { right: contentItem.right ;
                verticalCenter: contentItem.verticalCenter ;
                verticalCenterOffset: labelAxis_y2.height;}
        }
        Label {
            width: 100; height: 50
            text: "Efficency: 95% "
            visible: efficencyLabel
            z: 2
            anchors { bottom: contentItem.bottom; left: contentItem.left ; leftMargin: 10 }
        }

        SGLineGraph {
            id: graph
            z: 1
            width: container.width/1.2 ; height: container.height/1.2
            anchors { centerIn: parent }
            secondValueVisible: true;
            efficencyLable: true;
            variable1Name: inVariable1Name
            variable2Name: inVariable2Name
            variable1Color: inVariable1Color
            variable2Color: inVariable2Color
        }
    }
}

