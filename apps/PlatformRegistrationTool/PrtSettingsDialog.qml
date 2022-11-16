/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logconf 1.0 as LcuPlugin

SGWidgets.SGDialog {
    id: prtSettingsDialog

    title: "Settings"
    headerIcon: "qrc:/sgimages/tools.svg"
    modal: true
    focus: true
    destroyOnClose: true

    property int innerSpacing: 10

    ColumnLayout {
        id: prtSettings
        anchors.fill: parent

        SGWidgets.SGText {
            text: "Logging Configuration"
            fontSizeMultiplier: 1.3
            font.bold: true
        }

        LcuPlugin.LogLevel {
            id: logLevel
            Layout.fillWidth: true
            fileName: Qt.application.name
        }

        SGWidgets.SGText {
            text: "Export log files"
            fontSizeMultiplier: 1.3
            font.bold: true
        }

        LcuPlugin.LogExport {
            id: logExportPane
            Layout.fillWidth: true
            appName: Qt.application.name
        }

        SGWidgets.SGButton {
            id: closeButton
            text: "Close"
            Layout.alignment: Qt.AlignCenter
            onClicked: prtSettingsDialog.accepted()
        }
    }
}
