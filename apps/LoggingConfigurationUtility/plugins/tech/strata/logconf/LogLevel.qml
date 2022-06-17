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
import tech.strata.logger 1.0

GridLayout {
    id: logLevelGrid

    property alias fileName: configFileSettings.filePath
    property int innerSpacing: 5
    property int shortEdit: 180

    columns: 4
    columnSpacing: innerSpacing
    rowSpacing: innerSpacing

    ConfigFileSettings {
        id: configFileSettings
    }

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
        enabled: currentIndex != -1
        //disable if log level value doesnt exist OR if no INI file was found
        placeholderText: "no value"
        onActivated: configFileSettings.logLevel = currentText

        Connections {
            target: configFileSettings
            onLogLevelChanged: {
                logLevelComboBox.currentIndex = logLevelComboBox.find(configFileSettings.logLevel)
            }
            onFilePathChanged: {
                logLevelComboBox.currentIndex = logLevelComboBox.find(configFileSettings.logLevel)
            }
        }

        Component.onCompleted: {
            currentIndex = find(configFileSettings.logLevel)
        }
    }

    SGWidgets.SGButton {
        id: setLogLevelButton
        Layout.maximumWidth: height
        text: logLevelComboBox.enabled ? "Unset" : "Set"
        enabled: configFileSettings.filePath !== ""
        onClicked: {
            if (text === "Unset") {
                configFileSettings.logLevel = ""
            } else { //set to default value
                configFileSettings.logLevel = "debug"
            }
        }
    }

    Connections {
        target: configFileSettings
        onCorruptedFile: {
            showCorruptedFileDialog(param, errorString)
        }
    }

    function showCorruptedFileDialog(parameter, string) {
        var dialog = SGDialogJS.createDialog(
                    logLevelGrid,
                    "qrc:/CorruptedFileDialog.qml", {
                        "corruptedString": string,
                        "corruptedParam": string === "" ? ("<i>" + parameter + "</i> setting does not contain any value.") : ("Parameter <i>" + parameter + "</i> is currently set to:")
                    })

        dialog.accepted.connect(function() { //set to default
            console.log(Logger.logconfCategory, "Set " + parameter + " to default")
            configFileSettings.logLevel = "debug"
            dialog.destroy()
        })

        dialog.rejected.connect(function() { //remove parameter
            console.log(Logger.logconfCategory, "Removed " + parameter)
            configFileSettings.logLevel = ""
            dialog.destroy()
        })
        dialog.open()
    }
}
