import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    StackView {
        id: stack
        //initialItem: Page1{}
        anchors.fill: parent


        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
            }
        }

        pushExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to:0
                    duration: 200
                }
            }

        popEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to:1
                    duration: 200
                }
            }

        popExit: Transition{
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 300
            }
        }

    }

    //push items on the stackView
    Component.onCompleted:{
        stack.push([page3, {immediate:true},
                    page2, {immediate:true},
                    page1, {immediate:true}])
    }

    Component {
        id: page1

        Page1{}
    }

    Component {
        id: page2

        Page2{}
    }

    Component {
        id: page3

        Page3{}
    }

    Timer {
            interval: 2000;
            running: true;
            repeat: true
            onTriggered:{
                stack.pop()
            }
        }




}
