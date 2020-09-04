import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: fileContainerRoot
    Layout.fillHeight: true
    Layout.fillWidth: true


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
            font: Fonts.inconsolata
            selectionColor: Qt.rgba(0.0, 0.0, 0.0, 0.15)
            selectedTextColor: color

        }
    }


}

