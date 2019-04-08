import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12


Window {
    id: root
    visible: true
    width: 1000
    height: 500
    title: qsTr("Telestrator 1")

    Row {
        SGTelestrator {
            width: root.width/2
            height: 500
        }

        SGTelestrator {
            width: root.width/2
            height: 500
        }
    }

    Server {
        id: server
    }
}
