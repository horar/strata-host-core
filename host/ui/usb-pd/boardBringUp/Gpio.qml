import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

Rectangle {

    property var currentTab : gpioView
    property var newTab:  gpioView

    anchors.fill:parent
    //border.color:"red"


        function createTab(inTabName, inParent){
            var component  = Qt.createComponent(inTabName);
            var object = component.createObject(inParent);
            return object
        }

        Component.onCompleted: {
            currentTab = createTab("buttonView.qml", contentRectangle);
            newTab = createTab("buttonView.qml",contentRectangle);
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
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter
            width: 600
            height: 40


            SGLeftSegmentedButton{x: 5;text:"Port A"; tabName:ButtonView{}}
            SGMiddleSegmentedButton{text:"Port B"; tabName:ButtonView {}}
            SGMiddleSegmentedButton{text:"Port C"; tabName:ButtonView {}}
            SGMiddleSegmentedButton{text:"Port D"; tabName:ButtonView {}}
            SGMiddleSegmentedButton{text:"Port E"; tabName:ButtonView {}}
            SGRightSegmentedButton{text:"Port F"; tabName:ButtonView {}}

        }

        Rectangle{
            id:contentRectangle

//            anchors.fill:parent
//            anchors.rightMargin: 84
//            anchors.bottomMargin: 67
//            anchors.leftMargin: 61
//            anchors.topMargin: 6
            //z: 2
            //color:  "#babdb6"
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            anchors.top:buttonRow.bottom
            ButtonView{opacity: 1}
            ButtonView{opacity: 1}
            ButtonView{opacity: 1}

        }
}




