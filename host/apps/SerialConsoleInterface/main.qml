import QtQuick 2.12
import QtQuick.Window 2.12
import Qt.labs.settings 1.1 as QtLabsSettings

Window {
    id: window

    visible: true
    height: 600
    width: 800
    minimumHeight: 600
    minimumWidth: 800

    title: qsTr("Serial Console Interface")

    QtLabsSettings.Settings {
        category: "ApplicationWindow"

        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color:"#eeeeee"
    }

    SciMain {
        anchors.fill: parent
    }
}
