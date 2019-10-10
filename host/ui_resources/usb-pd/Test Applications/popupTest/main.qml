import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Button {
        text: "Open"
        onClicked: popup.open()
    }

    Popup {
        id: popup
        x: 100
        y: 100
        width: 479
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            id: rectangle
            x: 125
            y: 50
            width: 200
            height: 200
            color: "#ed0404"
        }
    }
}
