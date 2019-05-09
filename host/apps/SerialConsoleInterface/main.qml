import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true
    height: 600
    width: 800
    minimumWidth: 640
    minimumHeight: 480
    title: qsTr("Serial Console Interface")

    Rectangle {
        id: bg
        anchors.fill: parent
        color:"#eeeeee"
    }

    SciMain {
        anchors.fill: parent
    }
}
