import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4

Rectangle {
    anchors.fill: parent
    color: "transparent"

    signal sendIndex(int index)

    property alias model: keySelectorComboBox.model
    property alias currentIndex: keySelectorComboBox.currentIndex

    Component.onCompleted: sendIndex(keySelectorComboBox.currentIndex)

    ColumnLayout {
        id: comboBoxContainer
        width: parent.width
        height: implicitHeight
        spacing: 5
        Label {
            id: keySelectorLabel
            text: "<b>Select Document:</b>"
            color: "white"
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 5
            Layout.topMargin: 10
        }
        ComboBox {
            id: keySelectorComboBox
            width: parent.width - 10
            Layout.alignment: Qt.AlignHCenter
            model:[]
            delegate: ItemDelegate {
                    contentItem: Text {
                        width: keySelectorComboBox.width
                        text: modelData
                        color: "#b55400"
                    }
                    highlighted: keySelectorComboBox.highlightedIndex === index
                }
            background: Rectangle {
                    implicitWidth: keySelectorComboBox.width
                    implicitHeight: 40
                    border.color: keySelectorComboBox.pressed ? "#17a81a" : "#b55400"
                    radius: 2
                }
            onActivated: {
                sendIndex(keySelectorComboBox.currentIndex)
            }
        }

    }

}
