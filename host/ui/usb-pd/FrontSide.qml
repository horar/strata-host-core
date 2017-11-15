import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

Rectangle {
    id: frontSide

    anchors{ fill:parent }

    StackView {
        id:stack
        anchors { fill: parent }

        popEnter: Transition {
            PropertyAnimation { property: "opacity"; to: 1.0; duration: 1000 }
        }
        popExit: Transition {
            PropertyAnimation { property: "opacity"; to: 0.0; duration: 1000 }
        }
        pushEnter: Transition {
            PropertyAnimation { property: "opacity"; to: 1.0; duration: 1000 }
        }
        pushExit: Transition {
            PropertyAnimation { property: "opacity"; to: 0.0; duration: 1000 }
        }
    }

    Component.onCompleted:{
        stack.push(page2, {immediate:true})
        stack.push(page1, {immediate:true})
    }
    Component {
        id: page1
        SGLoginScreen { }
    }
    Component {
        id: page2
        SGBoardLayout { }
    }
}

