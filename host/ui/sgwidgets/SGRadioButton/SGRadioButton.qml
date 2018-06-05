import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

GroupBox {
    anchors.fill: parent

    //set flat to be true, and fill with a white rectangle to hide the GroupBox background
    Rectangle {
        anchors.fill:parent
        color: "white"
        border.color: "black"
    }

    ColumnLayout {
        id: container
        anchors { centerIn: parent }

        ButtonGroup { buttons: container.children }
        RadioButton {
            text: "5 V"
            id: button
            checked: true
        }
        RadioButton {
            text: "9 V"

        }
        RadioButton {
            text: "12 V"

        }
        RadioButton {
            text: "15 V"
            checkable: false
        }

    }
}
