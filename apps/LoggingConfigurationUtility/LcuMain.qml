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
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.lcu 1.0

Item {
    id: lcuMain

    property int outerSpacing: 10
    property int innerSpacing: 5
    property int middleColumn: 180

    ConfigFileModel {
        id:configFileModel
    }

    ConfigFileSettings {
        id: configFileSettings
    }

    Component.onCompleted: {
        configFileModel.reload()
    }

    SGWidgets.SGText {
        id: title
        anchors {
            left: parent.left
            leftMargin: outerSpacing
        }
        text: "Configuration files"
    }

    SGWidgets.SGComboBox {
        id: iniFileComboBox
        anchors {
            left: title.left
            right: reloadButton.left
            rightMargin: innerSpacing
            verticalCenter: reloadButton.verticalCenter
        }
        model: configFileModel
        textRole: "fileName"
        enabled: count !== 0
        placeholderText: count == 0 ? "No configuration files found" : "Please select config file"
        onActivated: {
            console.info("Selected INI file changed to: " + iniFileComboBox.currentText)
            configFileSettings.filePath = configFileModel.get(iniFileComboBox.currentIndex).filePath
        }
        popupHeight: parent.height - title.height - iniFileComboBox.height

        Connections {
            target: configFileModel
            onCountChanged: { //is called always when list of INI files is loaded/reloaded
                iniFileComboBox.currentIndex = -1
                logLevelComboBox.currentIndex = -1
                configFileSettings.filePath = ""
            }
        }
    }

    SGWidgets.SGButton {
        id: reloadButton
        anchors {
            top: title.bottom
            topMargin: innerSpacing
            right: parent.right
            rightMargin: outerSpacing
        }
        width: height
        icon.source: "qrc:/sgimages/redo.svg"
        onClicked: configFileModel.reload()
    }

    SGWidgets.SGText {
        id: configOptionsText
        anchors {
            top: reloadButton.bottom
            topMargin: outerSpacing
            left: parent.left
            leftMargin: outerSpacing
        }
        text: "Configuration Options"
    }

    GridLayout {
        id: logParamGrid

        anchors {
            top: configOptionsText.bottom
            topMargin: innerSpacing
            left: configOptionsText.left
            right: reloadButton.right
        }
        columns: 3
        columnSpacing: innerSpacing
        rowSpacing: innerSpacing

        SGWidgets.SGText {
            id: logLevelText
            text: "Log level"
            Layout.fillWidth: true
        }

        SGWidgets.SGComboBox {
            id: logLevelComboBox
            Layout.preferredWidth: middleColumn
            Layout.alignment: Qt.AlignRight
            model: ["debug", "info", "warning", "error", "critical", "off"]
            enabled: currentIndex !== -1 && iniFileComboBox.currentIndex !== -1 //disable if log level value doesnt exist OR if no ini files were found or selected
            placeholderText: "no value"
            onActivated: configFileSettings.logLevel = currentText
            //popupHeight: logParamGrid.height - logParamGrid.topMargin
            //This will make sense when there are more rows in the grid layout for other log param's support

            Connections {
                target: configFileSettings
                onLogLevelChanged: {
                    logLevelComboBox.currentIndex = logLevelComboBox.find(configFileSettings.logLevel)
                }
                onFilePathChanged: {
                    logLevelComboBox.currentIndex = logLevelComboBox.find(configFileSettings.logLevel)
                }
            }
        }

        SGWidgets.SGButton {
            id: setLogLevelButton
            Layout.maximumWidth: height
            text: logLevelComboBox.enabled ? "Unset" : "Set"
            enabled : iniFileComboBox.currentIndex !== -1 //disable if no ini files were found or selected
            onClicked: {
                if (text === "Unset") {
                    configFileSettings.logLevel = ""
                } else { //set to default value. TBD if default should be info or debug
                    configFileSettings.logLevel = "debug"
                }
            }
        }

        SGWidgets.SGText {
            id: maxFileSizeText
            text: "Max file size"
            Layout.fillWidth: true
        }

        SGWidgets.SGSpinBox {
            id: maxFileSizeSpinBox
            Layout.preferredWidth: middleColumn
            Layout.alignment: Qt.AlignRight
            from: 0
            to: 2147483647
            stepSize: 1024
            enabled: value >= 1024 && value <= 2147483647 && iniFileComboBox.currentIndex !== -1
            //disable if file size is out of min/max value OR if no ini files were found or selected
            onValueModified: configFileSettings.maxFileSize = value
            //TODO solve problem with values over 2147483647...the SpinBox sets it automatically to 0
            Connections {
                target: configFileSettings
                onMaxFileSizeChanged: {
                    maxFileSizeSpinBox.value = configFileSettings.maxFileSize
                }
                onFilePathChanged: {
                    maxFileSizeSpinBox.value = configFileSettings.maxFileSize
                }
            }
        }

        SGWidgets.SGButton {
            id: maxFileSizeButton
            Layout.maximumWidth: height
            text: maxFileSizeSpinBox.enabled ? "Unset" : "Set"
            enabled : iniFileComboBox.currentIndex !== -1 //disable if no ini files were found or selected
            onClicked: {
                if (text === "Unset") {
                    maxFileSizeSpinBox.value = 0
                } else { //set to default value. TBD what is default file size
                    maxFileSizeSpinBox.value = 1024
                }
            }
        }

        SGWidgets.SGText {
            id: maxNoFilesText
            text: "Max number of files"
            Layout.fillWidth: true
        }

        SGWidgets.SGSpinBox {
            id: maxNoFilesSpinBox
            Layout.preferredWidth: middleColumn
            Layout.alignment: Qt.AlignRight
            from: 0
            to: 1000
            stepSize: 1
            enabled: value > 0 && iniFileComboBox.currentIndex !== -1
            //disable if no.of files is out of min/max value OR if no ini files were found or selected
            onValueModified: configFileSettings.maxNoFiles = value

            Connections {
                target: configFileSettings
                onMaxNoFilesChanged: {
                    maxNoFilesSpinBox.value = configFileSettings.maxNoFiles
                }
                onFilePathChanged: {
                    maxNoFilesSpinBox.value = configFileSettings.maxNoFiles
                }
            }
        }

        SGWidgets.SGButton {
            id: maxNoFilesButton
            Layout.maximumWidth: height
            text: maxFileSizeSpinBox.enabled ? "Unset" : "Set"
            enabled : iniFileComboBox.currentIndex !== -1 //disable if no ini files were found or selected
            onClicked: {
                if (text === "Unset") {
                    maxNoFilesSpinBox.value = 0
                } else { //set to default value. TBD what is default no. of files
                    maxNoFilesSpinBox.value = 1
                }
            }
        }
    }
}
