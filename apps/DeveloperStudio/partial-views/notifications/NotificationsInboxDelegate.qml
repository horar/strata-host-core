import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import tech.strata.theme 1.0
import tech.strata.notifications 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.logger 1.0

Rectangle {
    id: root
    width: ListView.view.width
    implicitHeight: content.implicitHeight + content.anchors.margins * 2

    property int modelIndex

    MouseArea {
        anchors.fill: parent
    }

    NotificationContent {
        id: content

        onActionClicked: {
            var sourceIndex = sortedModel.mapIndexToSource(modelIndex)
            if (sourceIndex > -1) {
                Notifications.model.remove(sourceIndex)
            } else {
                console.error(Logger.devStudioCategory, "Index out of scope.")
            }
        }

        onCloseClicked: {
            var sourceIndex = sortedModel.mapIndexToSource(modelIndex)
            if (sourceIndex > -1) {
                Qt.callLater(Notifications.model.remove, sourceIndex)
            } else {
                console.error(Logger.devStudioCategory, "Index out of scope.")
            }
        }
    }
}
