import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0

Rectangle {
    id: frontSide

    anchors{ fill:parent }

    StackView {
        id:stack
        anchors { fill: parent }
    }
    Component.onCompleted:{
        stack.push([page2, {immediate:true},page1, {immediate:true}])
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

