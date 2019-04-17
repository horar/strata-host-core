import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Button {
        id: button
        x: 248
        y: 172
        width: 191
        height: 40
        text: qsTr("Button")
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 19
        font.bold: true

        contentItem: Text {
                text: button.text
                font: button.font
                opacity: enabled ? 1.0 : 0.3
                color: button.down ? "white" : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

        background: Rectangle {
            //implicitWidth: 100
            //implicitHeight: 25
            //border.width: 0
            //border.color: "black"
            //radius: 0
            color: button.down ? Qt.darker("#2eb457") : "#2eb457"


        }


    }


}
