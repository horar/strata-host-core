import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0

//This represents the port name, a divider line, and a set of icons and text that
//represent the port properties, contained in an SGIconList
Rectangle {
    id: container
    color: "transparent"
    property alias text: portTitle.text
    property int portNumber:0;
    property point theDialogStartPosition;
    property bool inAdvancedMode : false;

    SequentialAnimation{
        id:messageAnimation
        running: false
        PropertyAnimation {
            target:disconnectMessage
            property: "opacity"
            to: 0.0
            duration: 1000
        }
        PropertyAnimation{
            target:iconList
            property:"opacity"
            to: 1.0
            duration: 1000
        }
    }
    SequentialAnimation{
        id:iconListAnimation
        running: false
        PropertyAnimation {
            target:iconList
            property: "opacity"
            to: 0.0
            duration: 1000
        }
        PropertyAnimation{
            target:disconnectMessage
            property:"opacity"
            to: 1.0
            duration: 1000
        }
    }

    Connections {
        target: implementationInterfaceBinding

        onUsbCPortStateChanged: {

            if( portNumber === port ){
                if (value == true) {
                    iconListAnimation.stop()
                    messageAnimation.start()
                }

                else {
                    messageAnimation.stop()
                    iconListAnimation.start()
                }
            }
        }
    }

    Component.onCompleted:  {
        if(visible) {
            if (portNumber == 1) {
                var state = implementationInterfaceBinding.getUSBCPortState(1);
                if(state == true){
                    console.log("USB-C Connected Port1 when app launch ");
                    iconList.opacity = 1.0
                    disconnectMessage.opacity = 0.0
                }
                else {
                    iconList.opacity = 0.0
                    disconnectMessage.opacity = 1.0
                }
            }
            if (portNumber == 2) {
                var state = implementationInterfaceBinding.getUSBCPortState(2);
                if(state == true){
                    console.log("USB-C Connected Port2 when app launch ");
                    iconList.opacity = 1.0
                    disconnectMessage.opacity = 0.0
                }
                else {
                    iconList.opacity = 0.0
                    disconnectMessage.opacity = 1.0
                }
            }
        }
    }

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


        Rectangle{
            id:portNameAndDivider
            Layout.column: 0
            Layout.columnSpan: 2
            Layout.preferredWidth:grid.prefWidth(this)
            Layout.preferredHeight:grid.prefHeight(this)
            color:"transparent"

            PropertyAnimation {
                id: portEnter
                target: portTitle
                property: "font.pointSize"
                to : (Qt.platform.os == "osx") ?
                         parent.width/8 : parent.width/20
                duration: 200
                running: false
            }

            PropertyAnimation {
                id: portExit
                target: portTitle
                property: "font.pointSize"
                to : (Qt.platform.os == "osx") ?
                         parent.width/10 : parent.width/28
                duration: 200
                running: false
            }


            Label {
                id: portTitle
                width: parent.width/2
                text: "Port 1"
                font { family: "Helvetica"; bold: true }
                horizontalAlignment: Text.AlignRight
                color: "Green"

                anchors { verticalCenter: portNameAndDivider.verticalCenter; right: portNameAndDivider.right; rightMargin: 10 }

                MouseArea {
                    anchors { fill: parent }
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: portEnter.start()
                    onExited:  portExit.start()
                    onClicked: portMessage.open();
                }
            }

            Component.onCompleted: {
                //adjust font size based on platform
                if (Qt.platform.os === "osx"){
                    portTitle.font.pointSize = parent.width/10 > 0 ? parent.width/10 : 1;
                }
                else{
                    font.pointSize = Label.Fit



                }
            }

            Rectangle {
                id: divider
                color: (inAdvancedMode)?"white":"black"
                width: portNameAndDivider.width/50;
                //height:portNameAndDivider.height*.75
                anchors{right:portNameAndDivider.right;
                    top:portNameAndDivider.top;
                    topMargin: portNameAndDivider.height/4
                    bottom:portNameAndDivider.bottom
                    bottomMargin: portNameAndDivider.height/4}
            }
        }

        Rectangle {
            id: iconContainer
            Layout.column: 2
            Layout.columnSpan: 2
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Layout.leftMargin: 10
            color:"transparent"


            SGIconList {
                id:iconList
                width: iconContainer.width
                height: iconContainer.height
                portNumber: container.portNumber
            }
            Label {
                id: disconnectMessage
                text:"No connected device"
                color: "grey"

                wrapMode: Label.WordWrap
                width: iconContainer.width
                height: iconContainer.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment:Text.AlignHCenter
                font.family: "helvetica"
                font.pointSize:{
                    if (Qt.platform.os === "osx"){
                        if (iconContainer.width/4 ==0){
                           font.pointSize = 20
                        }
                        else{
                        font.pointSize = iconContainer.width/4
                        }
                    }
                    else{
                        font.pointSize= 14
                    }
                }

            }
        }

        Rectangle {
            id:usbJackContainer
            color: "transparent"
            Layout.column: 4
            Layout.columnSpan: 1
            Layout.row: 0
            Layout.rowSpan: 1
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)


            Rectangle {
                id: usbJack
                width:usbJackContainer.width/4; height:usbJackContainer.height/3
                color: (inAdvancedMode)?"white":"black"
                anchors {
                    verticalCenter: usbJackContainer.verticalCenter
                    right: usbJackContainer.right
                    rightMargin: usbJack.width
                }
            }
        }

        SGPopup {
            id: portMessage
            startPositionX: theDialogStartPosition.x
            startPositionY: theDialogStartPosition.y
            width: boardRect.width/0.8 ;height: boardRect.height/2
            leftMargin : 30
            rightMargin : 30
            topMargin: 30
            bottomMargin:30
            portNumber: container.portNumber
            efficencyLabel: false
            powerMessageVisible: true;
            graphVisible: false;

        }

    }

}
