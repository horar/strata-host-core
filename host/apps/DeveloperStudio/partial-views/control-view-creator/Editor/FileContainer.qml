import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.1
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0

Rectangle {
    id: fileContainerRoot
    Layout.fillHeight: true
    Layout.fillWidth: true
    color: Qt.rgba(Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, 1) // randomish color

    property int modelIndex: index
    property string file: model.file

    function openFile(fileUrl) {
        var request = new XMLHttpRequest();
        request.open("GET", fileUrl, false);
        request.send(null);
        return request.responseText;
    }

    FileDialog {
        id: openFileDialog
        nameFilters: ["QML files (*.qml)", "All files (*)"]
        onAccepted: {
            console.info(openFileDialog.fileUrl)


        }
    }


    Component.onCompleted: {
        var str =  openFile(model.path)
        console.info(str)
        textArea.text = str

    }

    Flickable {
        id: flickable
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent

        TextArea.flickable: TextArea {
            id: textArea
            //textFormat: Qt.RichText
            wrapMode: TextArea.Wrap
            focus: true
            selectByMouse: true
            persistentSelection: true
            // Different styles have different padding and background
            // decorations, but since this editor is almost taking up the
            // entire window, we don't need them.
            leftPadding: 6
            rightPadding: 6
            topPadding: 0
            bottomPadding: 0
            background: null



            onLinkActivated: Qt.openUrlExternally(link)
        }

        ScrollBar.vertical: ScrollBar {}
    }


}

