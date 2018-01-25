import QtQuick 2.0
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

Rectangle {

    property var currentTab
    property var newTab
//    color: "#888a85"


    Rectangle {
        id: rectangle
        x: 17
        y: 19
        width: 957
        height: 866
        color: "#babdb6"

        function createTab(inTabName, inParent){
            var component  = Qt.createComponent(inTabName);
            var object = component.createObject(inParent);
            return object
        }

        Component.onCompleted: {
            currentTab = createTab("buttonView.qml", contentRectangle);
            currentTab.opacity = 1.0;

            newTab = createTab("buttonView.qml",contentRectangle);
        }

        Label {
            id: label
            x: 191
            y: 21
            font.pixelSize: 36
            font.bold: true
            color: "gray"
            font.family: "Helvetica"
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("GPIO Configuration")
            anchors.horizontalCenterOffset: 5
        }


        ParallelAnimation{
            id: crosfadeTabs
            OpacityAnimator{
                target: currentTab
                from: 1
                to: 0
                duration: 500
                running: false
            }
            OpacityAnimator{
                target: newTab
                from: 0
                to: 1
                duration: 500
                running: false
            }
        }



        ButtonGroup {
            buttons: buttonRow.children
            onClicked: {
                newTab = button.tabName
                crosfadeTabs.start()
                currentTab = newTab
            }
        }


        Row {
            id:buttonRow
            x: 51
            anchors.horizontalCenterOffset: 17
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 87

            SGLeftSegmentedButton{x: 5;text:"Port A"; tabName:ButtonView{}}
            SGMiddleSegmentedButton{text:"Port B"; tabName:ButtonView {}}
            SGMiddleSegmentedButton{text:"Port C"; tabName:ButtonView {}}
            SGMiddleSegmentedButton{text:"Port D"; tabName:ButtonView {}}
            SGMiddleSegmentedButton{text:"Port E"; tabName:ButtonView {}}
            SGRightSegmentedButton{text:"Port F"; tabName:ButtonView {}}

        }

        Rectangle{
            id:contentRectangle
            x: 4
            y: 116
            width: 881
            height: 727

            anchors.rightMargin: 71
            anchors.bottomMargin: 56
            anchors.leftMargin: 74
            anchors.topMargin: 6
            z: 2
            color:  "#babdb6"
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            anchors.top:buttonRow.bottom
            ButtonView{}
            ButtonView{}
            ButtonView{}

        }
    }
}




