import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12

Rectangle {
    id: root
    width: 200
    height:100
    color:"dimgray"
    opacity:1
    radius: 10

    property alias crossoverFrequency: crossoverFrequency.value


    Text{
        id:crossoverText
        text:"crossover"
        color:"white"
        font.pixelSize: 18
        anchors.top:parent.top
        anchors.topMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Row{
        id:sliderRow
        anchors.top:crossoverText.bottom
        anchors.topMargin:10
        anchors.bottom:parent.bottom
        //anchors.bottomMargin:50
        anchors.leftMargin:5
        //anchors.right: parent.right
        anchors.left:parent.left

        ColumnLayout {
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Label {
                text: "2K Hz"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "1.5K Hz"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "1K Hz"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "400 Hz"
                color:"white"
                Layout.fillHeight: true
            }
            Label {
                text: "200 Hz"
                color:"white"
                Layout.fillHeight: true
            }
        }

        Slider {
            id:crossoverFrequency
            from: 200
            value: 25
            to: 2000
            orientation: Qt.Vertical
            anchors.top: parent.top
            //anchors.topMargin: 25
            //anchors.left:parent.left
            //anchors.leftMargin:10
            //anchors.right:parent.right
            //anchors.rightMargin:10
            anchors.bottom:parent.bottom
            anchors.bottomMargin:50

            onMoved:{
                //send the new value to the platformInterface
            }
        }
    }

}
