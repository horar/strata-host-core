import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: root
    implicitHeight: control.implicitHeight
    implicitWidth: control.implicitWidth
    Layout.fillWidth: true

    property alias toolTipText: toolTip.text
    property alias text: control.text
    property alias buttonEnabled: control.enabled

    signal clicked()

    AbstractButton {
        id: control
        padding: 0
        layer.enabled: true
        opacity: enabled ? 1 : .25
        width: parent.width

        background: Rectangle {
            color: control.pressed ? Theme.palette.gray : Theme.palette.darkGray
            implicitHeight: 25
            implicitWidth: control.contentItem.implicitWidth + 20
        }

        contentItem: SGText {
            text: control.text
            opacity: enabled ? 1.0 : 0.3
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            fontSizeMultiplier: .9
        }

        onClicked: {
            root.clicked()
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onPressed: mouse.accepted = false
        hoverEnabled: true
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    ToolTip {
        id: toolTip
        visible: mouse.containsMouse && toolTip.text !== ""
        delay: 500
    }
}
