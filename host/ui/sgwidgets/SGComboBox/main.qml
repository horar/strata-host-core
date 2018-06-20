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

        model: ["Amps", "Volts", "Watts"]

        // Optional Configuration:
        width: 100
        textColor: "black"
        indicatorColor: "#aaa"
        borderColor: "#aaa"
        boxColor: "white"
        dividers: true

        // Signals:
        onActivated: console.log("item " + index + " activated")
        onCurrentTextChanged: console.log(currentText)
        onCurrentIndexChanged: console.log(currentIndex)
    }

    // Example button setting the index of the SGComboBox
    // - note that it does not trigger an activated signal
    Button {
        text: "Select 3rd Entry"
        y: 150
        onClicked: sgComboBox.currentIndex = 2
    }
}
