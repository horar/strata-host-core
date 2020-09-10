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
    property string file: model.filename

    function openFile(fileUrl) {
        var request = new XMLHttpRequest();
        request.open("GET", fileUrl, false);
        request.send(null);
        return request.responseText;
    }

    function saveFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        return request.status;
    }

    Component.onCompleted: {
        if (editorRoot.imageFormats.has(model.filetype)) {
            textEditorView.visible = false
            imageView.source = model.filepath
        } else {
            textArea.visible = true
            textArea.text = openFile(model.filepath)
        }
    }

    Connections{
        target: saveButton
        onClicked: saveFile(model.filepath,textArea.text)
    }

    ScrollView  {
        id: textEditorView
        anchors.fill: parent

        visible: true
        TextArea {
            id: textArea
            selectByMouse: true
            font: Fonts.inconsolata

            //selection text is set to gray
            selectionColor: Qt.rgba(0.0, 0.0, 0.0, 0.15)
            selectedTextColor: color
        }
    }

    Image {
        id: imageView

        anchors.fill: parent
        visible: !textEditorView.visible
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter

        asynchronous: true
        cache: true
        /**
         * Fillmode is set as follows:
         * If the image is larger than the parent container in either width or height, then resize it to fit, while keeping aspect ratio.
         * Otherwise, keep the original size
         */
        fillMode: sourceSize.width > parent.width || sourceSize.height > parent.height ? Image.PreserveAspectFit : Image.Pad
    }
}

