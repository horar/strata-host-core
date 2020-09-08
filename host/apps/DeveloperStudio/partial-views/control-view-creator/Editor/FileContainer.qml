import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

Rectangle {
    id: fileContainerRoot
    Layout.fillHeight: true
    Layout.fillWidth: true
    color: Qt.rgba(Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, Math.random()*0.5 + 0.25, 1) // randomish color

    property int modelIndex: index
    property string file: model.filename

    SGText {
        anchors {
            centerIn: parent
        }
        fontSizeMultiplier: 2
        text: `Text editor loads files here\nThis is file #${fileContainerRoot.file}`
        opacity: .25
    }
}

