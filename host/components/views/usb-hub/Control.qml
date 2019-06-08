import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import "qrc:/views/usb-hub/sgwidgets"
import "qrc:/views/usb-hub/views"

Item {
    id: controlView
    objectName: "control"
    anchors { fill: parent }

    PlatformInterface {
        id: platformInterface
    }

    property bool basicControlIsVisible: true
    property bool advancedControlIsVisible: false

    TabBar {
        id: navTabs

        anchors {
            top: controlView.top
            left: controlView.left
            right: controlView.right
        }

        TabButton {
            id: basicButton
            text: qsTr("Basic")
            onClicked: {
                //from advanced
                //console.log("basic visible=",basicControl.visible,"advanced visible=",advancedControlIsVisible)
                if (basicControl.visible && advancedControlIsVisible){
                    console.log("going to basic from advanced")
                    basicControl.transitionToBasicView();
                    basicControlIsVisible = true;
                    advancedControlIsVisible = false;
                }
                //from system control
                else if (systemControl.visible){
                    console.log("going from system to basic")
                    crossfadeToBasicControl.start();    //crossfade to basic

                    if (!basicControlIsVisible){
                        basicControl.transitionImmediatelyToBasicView();
                    }
                    basicControlIsVisible = true;
                    advancedControlIsVisible = false;
                }
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("Advanced")
            onClicked: {
                if (basicControl.visible && basicControlIsVisible){
                    console.log("going from basic to advanced")
                    basicControl.transitionToAdvancedView();
                    basicControlIsVisible = false;
                    advancedControlIsVisible = true;
                    //console.log("basic visible=",basicControlIsVisible,"advancedVisible=",advancedControlIsVisible)
                }
                //from system control
                else if (systemControl.visible){
                    console.log("going to advanced from system")
                    crossfadeToBasicControl.start();    //crossfade to basic

                    if (!advancedControlIsVisible){
                        console.log("switching from basic to advanced view")
                        //console.log("basic visible=",basicControlIsVisible,"advancedVisible=",advancedControlIsVisible)
                        basicControl.transitionImmediatelyToAdvancedView()
                    }
                    advancedControlIsVisible = true;
                    basicControlIsVisible = false;
                    //console.log("basic visible=",basicControlIsVisible,"advancedVisible=",advancedControlIsVisible)
                }
            }
        }

        TabButton {
            id: systemButton
            text: qsTr("System")
            onClicked: {
                crossfadeToSystemControl.start()
            }
        }
    }

    ParallelAnimation{
        id:crossfadeToSystemControl
        running: false

        onStarted:{
            systemControl.visible = true
            systemControl.opacity = 0
        }

        PropertyAnimation{
            target: basicControl
            property: "opacity"
            to: 0
            duration:1000
        }

        PropertyAnimation{
            target: systemControl
            property: "opacity"
            to: 1
            duration:1000
        }

        onStopped:{
            basicControl.visible = false
            systemControl.visible = true
        }
    }

    ParallelAnimation{
        id:crossfadeToBasicControl
        running: false

        onStarted:{
            basicControl.visible = true
            basicControl.opacity = 0
        }

        PropertyAnimation{
            target: basicControl
            property: "opacity"
            to: 1
            duration:1000
        }

        PropertyAnimation{
            target: systemControl
            property: "opacity"
            to: 0
            duration:1000
        }

        onStopped:{
            basicControl.visible = true
            systemControl.visible = false
        }
    }

    Item {
        id: controlContainer
        anchors {
            top: navTabs.bottom
            bottom: controlView.bottom
            right: controlView.right
            left: controlView.left
        }

        BasicControl {
            id: basicControl
            visible: true
            property real initialAspectRatio
        }

        SystemControl{
            id: systemControl
            visible: false
            property real initialAspectRatio
        }
    }

    Component.onCompleted: {
        basicControl.initialAspectRatio = controlContainer.width / controlContainer.height

        console.log("Requesting platform Refresh")
        platformInterface.refresh.send() //ask the platform for all the current values

    }
}
