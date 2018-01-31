import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id:page2
    width: 400
    height: 400

    Rectangle {
        id: rectangle
        color: "#042bb7"
        anchors.fill: parent

        Button {
            id: button
            x: 150
            y: 180
            text: qsTr("Pop Me!")

            onClicked: {
                StackView.pop()
        }


        }
    }
}
