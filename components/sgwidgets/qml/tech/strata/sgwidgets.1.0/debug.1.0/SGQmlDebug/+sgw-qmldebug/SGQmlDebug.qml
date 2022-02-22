/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.sgwidgets.debug 1.0 as SGDebugWidgets
import QtQuick.Controls 2.12

Item {
    id: root

    property alias signalTarget: errorConnection.target

    SGQmlErrorListButton {
        id: qmlErrorListButton

        visible: qmlErrorModel.count !== 0
        text: qsTr("%1 QML warnings").arg(qmlErrorModel.count)
        checked: qmlErrorListPopUp.visible

        onCheckedChanged: checked ? qmlErrorListPopUp.open() : qmlErrorListPopUp.close()

        ListModel {
            id: qmlErrorModel
        }

        Connections {
            id: errorConnection
            onNotifyQmlError: {
                qmlErrorModel.append({"data" : notifyQmlError})
            }
        }
    }

    SGQmlErrorListPopUp {
        id: qmlErrorListPopUp

        topMargin: 32
        leftMargin: 32
        anchors.centerIn: ApplicationWindow.overlay
        title: qmlErrorListButton.text
        qmlErrorListModel: qmlErrorModel
    }
}
