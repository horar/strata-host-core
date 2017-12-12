import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import tech.spyglass.ImplementationInterfaceBinding 1.0
import "framework"

Rectangle {

    property bool hardwareStatusChange: null
    property bool boardScreen: true
    property bool hardwareStatus:  {

        onPlatformStateChanged: {
            var state = implementationInterfaceBinding.platformState;
            if(state == false && boardScreen == true) {
                stack.push([page, {immediate:false}]);
            }
        }
        implementationInterfaceBinding.platformState
    }

    onOpacityChanged: {
        if (opacity == 1)
            rotateInfoIcon.start()
    }

    Component {
        id: page
        SGLoginScreen {
            showLoginOnCompletion: true
        }
    }

    GridLayout {
        id: grid
        columns: 5
        rows: 2
        anchors {fill:parent}
        columnSpacing: 0
        rowSpacing: 0

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
            Layout.fillWidth:true
            Layout.fillHeight:true
            z:1     //set the z level higher so connectors go behind the board
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
            Layout.fillWidth:true
            Layout.fillHeight:true
            Connector { anchorbottom: 1
                portNumber: 1
            }
        }

        Rectangle {
            //Column 3 bottom row, 2nd connector
            Layout.column: 2
            Layout.columnSpan: 1
            Layout.row: 1
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            Connector { anchorbottom: 0
                portNumber: 2
            }
        }

        Rectangle {
            //Column 3 top row, first device
            Layout.column: 3
            Layout.columnSpan: 2
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            Device {
                verticalOffset: parent.height *.3
                port_number: 1
            }
        }

        Rectangle {
            //Column 3 bottom row, second device
            Layout.column: 3
            Layout.columnSpan: 2
            Layout.row: 1
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Layout.fillWidth:true
            Layout.fillHeight:true
            Device {
                verticalOffset: -parent.height*.3
                port_number: 2
            }
        }
    }

    Image {
        id: infoIcon
        anchors{ bottom: parent.bottom;
            bottomMargin: 10
            right: parent.right
            rightMargin: 10}
        height: 50; width:50
        source:"./images/icons/infoIcon.svg"
        layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: infoIcon
            horizontalOffset: 3
            verticalOffset: 6
            radius: 12.0
            samples: 24
            color: "#60000000"
            source: infoIcon
        }

        transform: Rotation {
            id: zRot
            origin.x: infoIcon.width/2; origin.y: infoIcon.height/2;
            axis { x: 0; y: 1; z: 0 }
        }

        NumberAnimation {
            id:rotateInfoIcon
            running: false
            loops: 1
            target: zRot;
            property: "angle";
            from: 0; to: 360;
            duration: 1000;
        }

        ScaleAnimator {
            id: increaseOnMouseEnter
            target: infoIcon;
            from: 1;
            to: 1.2;
            duration: 200
            running: false
        }

        ScaleAnimator {
            id: decreaseOnMouseExit
            target: infoIcon;
            from: 1.2;
            to: 1;
            duration: 200
            running: false
        }

        MouseArea {
            id: imageMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: flipable.flipped = !flipable.flipped
            onEntered:{
                increaseOnMouseEnter.start()
            }
            onExited:{
                decreaseOnMouseExit.start()
            }
        }
    } 
}
