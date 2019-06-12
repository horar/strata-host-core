import QtQuick 2.10
import QtQuick.Controls 2.3

ApplicationWindow {
    id: mainWindow

    visible: true
    width: 640
    height: 480
    minimumWidth: 640
    minimumHeight: 480

    title: qsTr("ON Semiconductor: %1").arg(Qt.application.displayName)

    Label {
        anchors.fill: parent
        wrapMode: Text.WordWrap
        padding: font.pixelSize * 2
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        text: qsTr("<strong><h2>An unexpected application error has occurred.</h2></strong>" +
                   "<br><br>" +
                   "Please contact your local sales representative.")
    }

    footer: DialogButtonBox {
        standardButtons: DialogButtonBox.Abort
        onRejected: Qt.quit(-1);
    }
}
