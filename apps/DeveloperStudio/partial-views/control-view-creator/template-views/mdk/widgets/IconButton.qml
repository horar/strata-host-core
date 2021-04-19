import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

MouseArea {
    id: iconButton
    Layout.fillWidth: true
    Layout.preferredHeight: width
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    property alias source: icon.source
    property alias iconColor: icon.iconColor

    SGIcon {
        id: icon
        source: "qrc:/sgimages/question-circle.svg"
        iconColor: "white"
        anchors {
            fill: parent
        }
        opacity: iconButton.containsMouse ? .8 : 1
    }
}
