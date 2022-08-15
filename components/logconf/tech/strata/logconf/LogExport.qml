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
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logconf 1.0
import tech.strata.pluginLogger 1.0

RowLayout {
    id: logExportRow
    spacing: 5

    LogFilesCompress {
        id: logFilesCompress
    }

    Timer {
        id: timer
    }

    SGWidgets.SGButton {
        id: logExportButton

        text: "Export log files"
        hintText: "Exports compressed log files into Desktop folder"

        onClicked: {
            logExportRow.enabled = false
            timer.interval = 100  // a short delay, enabled status would change properly.
            timer.triggered.connect(logExportInProgress)
            timer.start()
        }
    }

    SGWidgets.SGCheckBox {
        id: openFolderCheckBox

        text: "Open folder after saving"
    }

    function logExportInProgress() {
        logFilesCompress.logExport(); //compress Files
        timer.triggered.disconnect(logExportInProgress) // remove the callback
        logExportRow.enabled = true
    }
}
