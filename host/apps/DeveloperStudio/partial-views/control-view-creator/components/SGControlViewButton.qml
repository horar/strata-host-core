import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.fonts 1.0

Rectangle {
    id: root
    color: buttonArea.containsMouse ? "#999" : "#aaa"
    radius: 5

    property alias text: buttonText.text

    SGText {
        id: buttonText
        anchors.centerIn: root
    }

    MouseArea {
        id: buttonArea
        anchors.fill: root
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            parent.onClicked()
        }
    }
}

