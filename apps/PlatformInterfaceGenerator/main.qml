import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

SGMainWindow {
    id:  window
    title: qsTr("Platform Interface Generator")
    minimumHeight: 800
    minimumWidth: 1000

    visible: true

    PlatformInterfaceCreator {
        id: main
        anchors.fill: parent
        anchors.margins: 20
    }
}
