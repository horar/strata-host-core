import QtQuick 2.7
import QtQuick.Controls 2.0

Popup {
    id: container
    property alias axisXLabel: labelAxis_x.text
    property alias axisYLabel: labelAxis_y.text
    property alias axisY2Label: labelAxis_y2.text
    property alias inVariable1Color: labelAxis_y.color
    property alias inVariable2Color: labelAxis_y2.color
    property string chartType: ""
    property real startPositionX: 0
    property real startPositionY: 0
    property bool efficencyLabel: false;
    property int portNumber:0
    property bool powerMessageVisible: false;
    property bool graphVisible: false;
    property var selection: undefined
    property bool overlimitVisibility : false;
    property bool underlimitVisibility: false;

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
        source: "./images/dialogBorder.svg"
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
        width: container.width/10; height: container.height/10
        color: "transparent"
        border.color : "transparent"

        z: 1
        Image {
            id: powerMessage
            width: container.width/1.3; height: container.height/1.3
            visible: powerMessageVisible
            anchors { centerIn: parent }
            z: 2
            source: "./images/Port_Power_Messages_Dialog.png"
        }
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


        SGScopeView {
            id: graph
            z: 1
            visible: graphVisible
            efficencyVisible: efficencyLabel
            width: container.width/1.3 ; height: container.height/1.2
            anchors { centerIn: parent }
            chartType: container.chartType
            portNumber: container.portNumber
            portTempRedZone: overlimitVisibility
            inputPowerRedzone: underlimitVisibility
        }
    }
}

