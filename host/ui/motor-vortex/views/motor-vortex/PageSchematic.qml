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
        model: documentManager.schematicDocuments
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
        ScrollBar.vertical: ScrollBar {}
    } // end ListView

    // Temporary hack crap for demo only:
    ListModel {
        id: images
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-004_lv8907 arduino shi-1.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-004_lv8907 arduino shi-2.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-004_lv8907 arduino shi-3.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-004_lv8907 arduino shi-4.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-004_lv8907 arduino shi-5.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-021_ncs36510_shield_fo-1.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-021_ncs36510_shield_fo-2.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-021_ncs36510_shield_fo-3.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-021_ncs36510_shield_fo-4.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-021_ncs36510_shield_fo-5.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-021_ncs36510_shield_fo-6.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-021_ncs36510_shield_fo-7.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-026_led_control_board-1.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-026_led_control_board-2.png" }
        ListElement {data: "qrc:/views/motor-vortex/pdf2png_schematic/onsec-17-026_led_control_board-3.png" }
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
