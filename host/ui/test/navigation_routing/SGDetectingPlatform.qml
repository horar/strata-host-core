import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "navigationControl.js" as NavigationControl

Rectangle {
    property string user_id
    property string platform_name

    anchors.fill: parent
    color: "purple"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 2

        BusyIndicator{
            Layout.alignment: Qt.AlignCenter
            id: busyIcon
            running: true
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            text:   qsTr("Waiting for platform connection")
        }

        ComboBox {
            Layout.alignment: Qt.AlignCenter
            id: cbSelector
            textRole: "text"
            model: ListModel {
                id: model
                ListElement { text: "USB-PD 100W";  name: "usb-pd"}
                ListElement { text: "Motor Vortex"; name: "motor-vortex"}
                ListElement { text: "BuBu Interface"; name: "bubu"}
            }
            onActivated: {
                var data = { platform_name: model.get(cbSelector.currentIndex).name}
                NavigationControl.updateState(NavigationControl.events.OFFLINE_MODE_EVENT, data)

            }
        }
    }




}

