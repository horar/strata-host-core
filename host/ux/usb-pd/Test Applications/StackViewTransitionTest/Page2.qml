import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id:page2
    //anchors.fill:parent

    Rectangle {
        id: rectangle
        color: "blue"
        anchors.centerIn: parent
        anchors.fill:parent

        Button {
            id: button
            x: 150
            y: 180
            text: qsTr("Pop Me!")
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                theStack.pop()
                console.log("page 2 popped")
        }


        }
    }
}
