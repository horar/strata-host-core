import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Stack View")

    StackView{
        id:theStack
        initialItem: rectangle
        anchors.centerIn: parent
        anchors.fill:parent

        popEnter: Transition {
            NumberAnimation { property: "opacity"; to: 1.0; duration: 500 }
        }
        popExit: Transition {
            NumberAnimation { property: "opacity"; to: 0.0; duration: 500 }
        }

        Rectangle {
            id: rectangle
            color: "black"
            //anchors.fill: parent
            //anchors.centerIn: parent

            Button {
                id: button1
                x: 170
                y: 193
                width: 300
                height: 94
                text: qsTr("Bottom View")
                font.pointSize: 36
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                onClicked: {
                    console.log("You can't pop the inital screen, you dufus")
                }
            }
        }
    }
    Component.onCompleted:{
        //theStack.push([thirdPage, {immediate:true}, secondPage, {immediate:true},firstPage, {immediate:true}])
        console.log("pushing new views")
        //theStack.push([firstPage,{immediate:true}, secondPage, {immediate:true},thirdPage, {immediate:true}])
        theStack.push(firstPage,{immediate:true})
        theStack.push(secondPage, {immediate:true})
        theStack.push(thirdPage,{immediate:true})
        console.log("pushed new views")
    }
    Component {
        id: firstPage
        Page1 { }
    }
    Component {
        id: secondPage
        Page2 { }
    }
    Component {
        id: thirdPage
        Page3 { }
    }

}

