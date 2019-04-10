import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

ApplicationWindow {
    id:appWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Segmented Button Test")

    property var currentTab
    property var newTab

    function createTab(inTabName, inParent){
        var component  = Qt.createComponent(inTabName);
        var object = component.createObject(inParent);
        return object
    }

    Component.onCompleted: {
        currentTab = createTab("One.qml", contentRectangle);
        currentTab.opacity = 1;

        newTab = createTab("Two.qml",contentRectangle);
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
        anchors.topMargin: 15

        SGLeftSegmentedButton{text:"one" ; tabName:One{}}
        SGMiddleSegmentedButton{text:"two"; tabName:Two{}}
        SGMiddleSegmentedButton{text:"three"; tabName:Three{}}
        SGRightSegmentedButton{text:"four"; tabName:Four{}}
    }

    Rectangle{
        id:contentRectangle
        anchors.left:parent.left
        anchors.right:parent.right
        anchors.bottom:parent.bottom
        anchors.top:buttonRow.bottom

        One{}       //first page
        Two{}       //second page
        Three{}
        Four{}
    }





}
