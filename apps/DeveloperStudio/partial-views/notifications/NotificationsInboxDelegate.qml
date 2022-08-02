/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
                console.error(Logger.devStudioCategory, "index out of range")
            }
        }

        onCloseClicked: {
            var sourceIndex = sortedModel.mapIndexToSource(modelIndex)
            if (sourceIndex > -1) {
                Qt.callLater(Notifications.model.remove, sourceIndex)
            } else {
                console.error(Logger.devStudioCategory, "index out of range")
            }
        }
    }
}
