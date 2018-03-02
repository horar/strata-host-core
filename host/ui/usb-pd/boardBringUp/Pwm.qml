import QtQuick 2.0
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
//import QtQuick.Controls.Material 2.0

Rectangle {

    property var currentTab: pwmView
    property var newTab: pwmView
    Rectangle {
        anchors.fill:parent

        function createTab(inTabName, inParent){
            var component  = Qt.createComponent(inTabName);
            var object = component.createObject(inParent);
            return object
        }
        Component.onCompleted: {
            currentTab = createTab("PWMSetting.qml", contentRectangle);
            currentTab.opacity = 1;

            newTab = createTab("PWMSetting.qml",contentRectangle);
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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            width: 600
            height: 65


            SGLeftSegmentedButton{text:"Port A"; tabName:PWMSetting{}}
            SGMiddleSegmentedButton{text:"Port B"; tabName:PWMSetting {}}
            SGMiddleSegmentedButton{text:"Port C"; tabName:PWMSetting {}}
            SGMiddleSegmentedButton{text:"Port D"; tabName:PWMSetting {}}
            SGMiddleSegmentedButton{text:"Port E"; tabName:PWMSetting {}}
            SGRightSegmentedButton{text:"Port F"; tabName:PWMSetting{}}

        }
        Rectangle{
            id:contentRectangle
            //x: 4
            //y: 116
            //width: 881
            //height: 727

//            anchors.rightMargin: 212
//            anchors.bottomMargin: 73
//            anchors.leftMargin: 138
//            anchors.topMargin: -15
            //z: 2
            //color:  "#babdb6"
            color:"red"
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            anchors.top:buttonRow.bottom
            PWMSetting{ opacity: 1 /*anchors.rightMargin: 175; anchors.bottomMargin: -37; anchors.leftMargin: -51; anchors.topMargin: 0*/}
            PWMSetting{ opacity: 1}
            PWMSetting{ opacity: 1}
        }

    }
}
