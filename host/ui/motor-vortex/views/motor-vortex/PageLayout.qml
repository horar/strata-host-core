import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

import tech.spyglass.DocumentManager 1.0

Rectangle {
    id: container
    // Anchors are not supported on a SlideView ( Parent )

    ListView {
        id: schematicList
        anchors.fill: parent
        snapMode: ListView.NoSnap
        /*
            Point to the specific listModel from documentManager here
        */
        model: documentManager.layoutDocuments
        focus: true
        clip: true
        add: Transition { NumberAnimation { properties: "x,y"; from: 100; duration: 1000 } }

        delegate: Rectangle {
            width: container.width; height: container.height
            Image {
                id: image
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: "data:image/png;base64," + model.data
           }
        }
        ScrollBar.vertical: ScrollBar { }
    } // end ListView

    // Temporary hack crap for demo only:
    ListModel {
        id: images
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-01.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-02.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-03.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-04.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-05.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-06.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-07.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-08.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-09.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-10.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-11.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-12.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-13.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-14.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-004gerbers-15.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-01.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-02.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-03.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-04.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-05.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-06.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-07.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-08.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-09.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-10.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-11.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-12.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-021-13.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-01.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-02.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-03.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-04.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-05.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-06.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-07.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-08.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-09.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-10.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_layout/onsec-17-026gerbers-11.png" }
    }

    ListView {
        visible: Qt.platform.os !== "osx"
        anchors.fill: parent
        snapMode: ListView.NoSnap
        focus: true
        clip: true
        add: Transition { NumberAnimation { properties: "x,y"; from: 100; duration: 1000 } }

        model: images

        delegate: Rectangle {
            width: container.width; height: container.height
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: model.data
           }
        }
        ScrollBar.vertical: ScrollBar {}
    }
}
