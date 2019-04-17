import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: page3
    //anchors.fill:parent

    Rectangle {
        id: rectangle
        color: "red"
        anchors.centerIn: parent
        anchors.fill:parent

        Button {
            id: button
            x: 270
            y: 228
            text: qsTr("Pop Me!")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                theStack.pop()
                console.log("page 3 popped")
            }
        }


    }

}
