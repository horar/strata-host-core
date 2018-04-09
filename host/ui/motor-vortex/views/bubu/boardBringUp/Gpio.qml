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
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        width: 600
        height: 40

        /* passing port name to set "port" member in setPort function */
        SGLeftSegmentedButton{text:"Port A"; portName:"a"}
        SGMiddleSegmentedButton{text:"Port B"; portName: "b"}
        SGMiddleSegmentedButton{text:"Port C"; portName: "c"}
        SGMiddleSegmentedButton{text:"Port D"; portName: "d"}
        SGMiddleSegmentedButton{text:"Port E"; portName: "e"}
        SGRightSegmentedButton{text:"Port F"; portName: "f"}

    }


    Rectangle{
        id:contentRectangle
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.bottom:parent.bottom
        anchors.top:buttonRow.bottom
        ButtonView{opacity: 1}
    }
}




