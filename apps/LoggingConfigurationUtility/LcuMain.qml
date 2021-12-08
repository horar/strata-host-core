/*
 * Copyright (c) 2018-2021 onsemi.
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
    property int middleColumn: 100

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
        placeholderText: "no configuration files found"
        onActivated: {
            console.info("Selected INI file changed to: " + iniFileComboBox.currentText)
            configFileSettings.fileName = iniFileComboBox.currentText
        }
        popupHeight: parent.height - title.height - iniFileComboBox.height

        Connections {
            target: configFileModel
            onCountChanged: {
                if (iniFileComboBox.count == 0) {
                    iniFileComboBox.currentIndex = -1
                } else if (iniFileComboBox.count !== 0 && iniFileComboBox.currentIndex == -1) {
                    iniFileComboBox.currentIndex = 0
                } else {
                    iniFileComboBox.currentIndex = 0
                }
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
        onClicked: {
            configFileModel.reload()
            configFileSettings.fileName = iniFileComboBox.currentText
        }
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
            enabled: currentIndex !== -1 && iniFileComboBox.enabled //disable if log level value doesnt exist OR if no ini files were found
            placeholderText: "no value"
            onActivated: configFileSettings.logLevel = currentText
            //popupHeight: logParamGrid.height - logParamGrid.topMargin
            //This will make sense when there are more rows in the grid layout for other log param's support

            Component.onCompleted: configFileSettings.fileName = iniFileComboBox.currentText
            Connections {
                target: configFileSettings
                onLogLevelChanged: {
                    console.info("log level changed")
                    logLevelComboBox.currentIndex = logLevelComboBox.find(configFileSettings.logLevel)
                }
                onFileNameChanged: {
                    logLevelComboBox.currentIndex = logLevelComboBox.find(configFileSettings.logLevel)
                }
            }
        }

        SGWidgets.SGButton {
            id: setLogLevelButton
            Layout.maximumWidth: height
            text: logLevelComboBox.enabled ? "Unset" : "Set"
            enabled : iniFileComboBox.enabled
            onClicked: {
                if (text == "Unset") {
                    configFileSettings.logLevel = ""
                } else { //set to default value. TBD if default should be info or debug
                    configFileSettings.logLevel = "debug"
                }
            }
        }
    }
}
