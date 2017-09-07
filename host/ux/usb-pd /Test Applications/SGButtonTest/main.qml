import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3



ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    SGButton{
        x:100
        y:100
        width:100
        height:50
        color:"red"
        text:"click me"
    }

}
