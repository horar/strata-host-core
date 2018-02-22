import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import tech.spyglass.ImplementationInterfaceBinding 1.0


ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    title: qsTr("Spectrum Hardware Vision - Vortex Motor Demo")
    property bool hardwareStatus: null
    property bool login_detected: false

    BackSide{}
}
