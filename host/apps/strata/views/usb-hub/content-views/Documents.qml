import QtQuick 2.9
import QtQuick.Controls 2.3
import "qrc:/include/Modules/"      // On Semi QML Modules
import "content-widgets"
import Fonts 1.0

Item {
    id: root
    width: parent.width
    height: pdfListView.height + 20
    property alias model: pdfListView.model

    ListView {
        id: pdfListView
        anchors {
            centerIn: parent
        }
        height: contentItem.height
        width: parent.width - 20
        clip: true

        ButtonGroup {
            id: buttonGroup
            exclusive: true
        }

        delegate: SGSelectorButton {
            title: model.dirname.replace(/_/g, ' ');
            uri: "file://localhost/" + model.uri
            width: pdfListView.width
            bottomMargin: 2
            centerText: true
            capitalize: true
            height: 40 + bottomMargin
            underline: true
        }
    }
}
