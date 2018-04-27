import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3


Rectangle {
    id: pwmOutline
    property var currentTab: pwmView
    property var newTab: pwmView

    anchors.fill:parent

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
            crosfadeTabs.start()

        }
    }


    Row {
        id:pwmbuttonRow
        anchors.horizontalCenter: pwmOutline.horizontalCenter
        anchors.top: pwmOutline.top
        width: 600
        height: 40


        SGLeftSegmentedButton{text:"Port A";}
        SGMiddleSegmentedButton{text:"Port B"; }
        SGMiddleSegmentedButton{text:"Port C";}
        SGMiddleSegmentedButton{text:"Port D";}
        SGMiddleSegmentedButton{text:"Port E";}
        SGRightSegmentedButton{text:"Port F";}

    }
    SwipeView {
        id: pwmbitView
        anchors { left:parent.left
            right:parent.right
            bottom:parent.bottom
            top:pwmbuttonRow.bottom
        }
        currentIndex: 0
       ButtonViewPwm {}
     //  PWMSetting { }

    }

    PageIndicator {
        id: indicator
        count: pwmbitView.count
        currentIndex: pwmbitView.currentIndex
        anchors.bottom: pwmbitView.bottom
        anchors.horizontalCenter: pwmOutline.horizontalCenter

    }

}

