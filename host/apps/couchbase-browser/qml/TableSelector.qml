import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4

Item {
    id: root
    anchors.fill: parent
    Rectangle {
        id: background
        anchors.fill: parent
        color: "transparent"
        ColumnLayout {
            id: comboBoxContainer
            width: parent.width
            height: 300
            Rectangle {
                id: keySelectorContainer
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width - 30
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Label {
                    id: keySelectorLabel
                    text: "<b>Select Key:</b>"
                    color: "white"
                    anchors {
                        left: keySelectorComboBox.left
                        verticalCenter: parent.verticalCenter
                    }
                }
                ComboBox {
                    id: keySelectorComboBox
                    anchors {
                        top: keySelectorLabel.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    model: ["first","second","third"]
                }
            }
//            Rectangle {
//                id: keySelectorContainer
//                Layout.preferredHeight: 80
//                Layout.preferredWidth: parent.width - 30
//                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
//                color: "transparent"
//                Label {
//                    id: keySelectorLabel
//                    color: "white"
//                    text: "<b>Select Key:</b>"
//                    anchors {
//                        left: keySelectorComboBox.left
//                        verticalCenter: parent.verticalCenter
//                    }
//                }
//                ComboBox {
//                    id: keySelectorComboBox
//                    anchors {
//                        top: keySelectorLabel.bottom
//                        horizontalCenter: parent.horizontalCenter
//                    }
//                    model: ["first","second","third"]
//                }
//            }
        }

    }

}
