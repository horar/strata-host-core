import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

MouseArea {
    Layout.fillWidth: true
    implicitHeight: faultCol.implicitHeight
    hoverEnabled: true

    property alias toolTipText: toolTip.text
    property alias text: title.text
    property alias status: statusLight.status

    ToolTip {
        id: toolTip
        visible: parent.containsMouse && text
        delay: 200
    }

    ColumnLayout {
        id: faultCol
        width: parent.width
        spacing: 0

        SGStatusLight {
            id: statusLight
            flatStyle: true
            implicitHeight: 20
            implicitWidth: 20
            Layout.alignment: Qt.AlignHCenter
            status: model.status
        }

        Text {
            id: title
            color: "white"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
