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

    color: mouseArea.containsMouse ? "#aaa" : "transparent"

    property alias source: icon.source
    property alias iconRotation: icon.rotation

    SGIcon {
        id: icon
        iconColor: "#ddd"
        anchors.centerIn: parent
        width: 20
        height: width
        rotation: 0
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            parent.functionHandler()
        }
    }
}
