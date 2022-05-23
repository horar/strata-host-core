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
import tech.strata.theme 1.0
import tech.strata.lcu 1.0

GridLayout {
    id: logLevelGrid

    property int innerSpacing: 5
    property int shortEdit: 180

    QtLabsSettings.Settings {
        id: settings
        category: "log"
     }

    columns: 4
    columnSpacing: innerSpacing
    rowSpacing: innerSpacing

    SGWidgets.SGText {
        id: configOptionsText
        Layout.columnSpan: 4
        Layout.fillWidth: true
        text: "Configuration Options"
    }

    SGWidgets.SGText {
        id: logLevelText
        text: "Log level"
        Layout.columnSpan: 2
        Layout.fillWidth: true
    }

    SGWidgets.SGComboBox {
        id: logLevelComboBox
        Layout.preferredWidth: shortEdit
        Layout.alignment: Qt.AlignRight
        model: ["debug", "info", "warning", "error", "critical", "off"]
        enabled: currentIndex !== -1 //disable if log level value doesnt exist OR if INI files was not found
        placeholderText: "no value"
        onActivated: {
            settings.setValue("level", currentText)
        }
        Component.onCompleted: {
            currentIndex = find(settings.value("level"))
        }
    }

    SGWidgets.SGButton {
        id: setLogLevelButton
        Layout.maximumWidth: height
        text: logLevelComboBox.enabled ? "Unset" : "Set"
        onClicked: {
            if (text === "Unset") {
                settings.setValue("level", "")
            } else { //set to default value
                settings.setValue("level", "debug")
            }
            logLevelComboBox.currentIndex = logLevelComboBox.find(settings.value("level"))
        }
    }
}
