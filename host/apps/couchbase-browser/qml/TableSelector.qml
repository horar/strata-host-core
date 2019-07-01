import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4

Rectangle {
    anchors.fill: parent
    color: "transparent"

    property alias model: keySelectorComboBox.model
    property alias currentIndex: keySelectorComboBox.currentIndex

    ColumnLayout {
        id: comboBoxContainer
        width: parent.width
        height: implicitHeight
        spacing: 20
        Label {
            id: keySelectorLabel
            text: "<b>Select Document:</b>"
            color: "white"
            Layout.alignment: Qt.AlignHCenter
            anchors {
                left: keySelectorComboBox.left
                top: parent.top
                topMargin: 15
            }
        }
        ComboBox {
            id: keySelectorComboBox
            Layout.alignment: Qt.AlignHCenter
            model:[]
        }

    }

}
