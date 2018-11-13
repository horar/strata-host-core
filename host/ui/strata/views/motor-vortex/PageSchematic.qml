import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import "qrc:/views/SGPdfViewer/"

import tech.spyglass.DocumentManager 1.0

Rectangle {
    id: container
    // Anchors are not supported on a SlideView ( Parent )

//    ListView {
//        id: schematicList
//        anchors.fill: parent
//        snapMode: ListView.NoSnap
//        /*
//            Point to the specific listModel from documentManager here
//        */
//        model: documentManager.schematicDocuments
//        focus: true
//        clip: true
//        add: Transition { NumberAnimation { properties: "x,y"; from: 100; duration: 1000 } }

//        delegate: Rectangle {
//            width: container.width; height: container.height
//            Image {
//                id: image
//                anchors.fill: parent
//                fillMode: Image.PreserveAspectFit
//                source: "data:image/png;base64," + model.data
//           }
//        }
//        ScrollBar.vertical: ScrollBar {}
//    } // end ListView

    SGPdfViewer {
        id: pdfTestDocument
        url: "qrc:/minified/web/viewer.html?file=file://localhost/Users/zbgzzh/Desktop/schematic.pdf"
        anchors {
            topMargin:2
            fill: container
        }
    }

//    SGPdfViewer {
//        id: pdfViewer
//        url: "qrc:/minified/web/viewer.html" //"?file=file://localhost/Users/zbgzzh/Desktop/schematic.pdf"
//        anchors {
//            topMargin:2
//            fill: container
//        }
//    }

//    Connections {
//        target: documentManager
//        onSchematicDocumentsChanged: {
//            if (documentManager.schematicDocuments.length > 0) {
//                var location = documentManager.schematicDocuments[0].data
//                if (location.endsWith("\n")) {
//                    location = location.replace(/\n$/, '');
//                }
//                pdfTestDocument.url = "qrc:/minified/web/viewer.html?file=" + "file://localhost/" + location
//            } else {
//                pdfTestDocument.url = "qrc:/minified/web/viewer.html"
//            }
//        }
//    }
}
