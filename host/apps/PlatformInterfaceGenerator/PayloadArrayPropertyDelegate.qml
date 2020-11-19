import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

RowLayout {
    id: arrayRowLayout
    Layout.preferredHeight: 30
    Layout.leftMargin: 20
    Layout.fillHeight: true
    spacing: 5

    property int modelIndex

    RoundButton {
        Layout.preferredHeight: 15
        Layout.preferredWidth: 15
        padding: 0
        hoverEnabled: true

        icon {
            source: "qrc:/sgimages/times.svg"
            color: removeItemMouseArea.containsMouse ? Qt.darker("#D10000", 1.25) : "#D10000"
            height: 7
            width: 7
            name: "add"
        }

        Accessible.name: "Remove item from array"
        Accessible.role: Accessible.Button
        Accessible.onPressAction: {
            removeItemMouseArea.clicked()
        }

        MouseArea {
            id: removeItemMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                payloadContainer.payloadArrayModel.remove(modelIndex)
            }
        }
    }

    Text {
        text: "[Index " + modelIndex  + "] Element type: "
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 150
        verticalAlignment: Text.AlignVCenter
    }

    ComboBox {
        id: arrayPropertyType
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        z: 2
        model: ["int", "double", "string", "bool"]

        Component.onCompleted: {
            currentIndex = indexSelected
        }

        onActivated: {
            type = currentText
            indexSelected = modelIndex
        }
    }

    RoundButton {
        id: addItemToArrayButton
        Layout.preferredHeight: 25
        Layout.preferredWidth: 25
        hoverEnabled: true
        visible: modelIndex === payloadContainer.payloadArrayModel.count - 1

        icon {
            source: "qrc:/sgimages/plus.svg"
            color: addItemToArrayMouseArea.containsMouse ? Qt.darker("green", 1.25) : "green"
            height: 20
            width: 20
            name: "add"
        }

        Accessible.name: "Add item to array"
        Accessible.role: Accessible.Button
        Accessible.onPressAction: {
            addItemToArrayMouseArea.clicked()
        }

        MouseArea {
            id: addItemToArrayMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                payloadContainer.payloadArrayModel.append({"type": "int", "indexSelected": 0})
                commandsListView.contentY += 40
            }
        }
    }
}
