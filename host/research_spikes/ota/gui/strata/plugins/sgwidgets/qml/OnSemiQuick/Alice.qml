import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

// introduce 'Carol' item
import OnSemiQuick 1.0// as Pom

ColumnLayout {
    id: main

    RowLayout {
        Repeater {
            id: buttonRow

            model: ["Button 1", "Button 2"]
//            model: ["Button 1", "Button 2", "Button 3", "Button 4", "Button 5"]

            Button {
                text: modelData
                enabled: (index % 2) === 0
            }
        }
    }

    /*Pom.*/Carol {
        width: parent.width
        height: width

        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    }

    Component.onCompleted: console.log("Alice is completed.. [" + buttonRow.count + "]")
}

