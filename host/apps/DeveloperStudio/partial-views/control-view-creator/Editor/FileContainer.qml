import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
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

    function saveFile(fileUrl, text) {
        console.log(fileUrl)
        console.log(text)
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        return request.status;
    }


    Connections{
        target: saveButton
        onClicked: {
            console.log(model.path)
            console.log(textArea.text)

            saveFile(model.path,textArea.text)
        }
    }

    FileDialog {
        id: openFileDialog
        nameFilters: ["QML files (*.qml)", "All files (*)"]
        onAccepted: {
            console.info(openFileDialog.fileUrl)
        }
    }


    Component.onCompleted: {
        textArea.text = openFile(model.path)
    }

    ScrollView  {
        id: flickable
        anchors.fill: parent

        TextArea {
            id: textArea
            selectByMouse: true
            background: null
            //focus: true
            //wrapMode: TextArea.Wrap
            selectionColor: Qt.rgba(0.0, 0.0, 0.0, 0.15)
            selectedTextColor: color

        }


    }


}

