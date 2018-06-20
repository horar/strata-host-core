import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3


Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGComboBox Demo")

    SGComboBox {
        id: sgComboBox
    }

    Button {
        id: tester
        y:200
        onClicked: sgComboBox.currentIndex = 2
    }

}
