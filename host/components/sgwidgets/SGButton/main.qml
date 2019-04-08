import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGButton")

    SGButton {
        textColor: checked ? "#ffffff" : "#26282a"
        text: "Button Text"
        color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
    }
}
