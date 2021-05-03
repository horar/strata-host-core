import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import tech.strata.theme 1.0
import tech.strata.notifications 1.0
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    width: parent.width
    implicitHeight: content.implicitHeight + content.anchors.margins * 2

    property int modelIndex

    MouseArea {
        anchors.fill: parent
    }

    NotificationContent {
        id: content

        onActionClicked: {
            if (sortedModel.mapIndexToSource(modelIndex) > -1) {
                Notifications.model.remove(sortedModel.mapIndexToSource(modelIndex))
            }
        }

        onCloseClicked: {
            if (sortedModel.mapIndexToSource(modelIndex) > -1) {
                Qt.callLater(Notifications.model.remove, sortedModel.mapIndexToSource(modelIndex))
            }
        }
    }
}
