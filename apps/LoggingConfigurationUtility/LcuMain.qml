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
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.lcu 1.0

Item {
    id: lcuMain

    property int outerSpacing: 10
    property int innerSpacing: 5

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
        id: comboBox
        anchors {
            top: title.bottom
            topMargin: innerSpacing
            left: title.left
            right: reloadButton.left
            rightMargin: innerSpacing
        }
        model: configFileModel
        textRole: "fileName"
        enabled: count !== 0
        placeholderText: "no configuration files found"
        onActivated: {
            configFileSettings.fileName = comboBox.currentText
            console.info("Selected INI file changed to: " + comboBox.currentText)
            logLevelComboBox.currentIndex = logLevelComboBox.find(configFileSettings.logLevel)
        }
        popupHeight: parent.height - title.height - comboBox.height

        Connections {
            target: configFileModel
            onCountChanged: {
                if (comboBox.count == 0) {
                    comboBox.currentIndex = -1
                } else if (comboBox.count !== 0 && comboBox.currentIndex == -1) {
                    comboBox.currentIndex = 0
                } else {
                    comboBox.currentIndex = 0
                }
            }
        }
    }

    SGWidgets.SGButton {
        id: reloadButton
        anchors {
            right: parent.right
            rightMargin: outerSpacing
            verticalCenter: comboBox.verticalCenter
        }
        width: height
        icon.source: "qrc:/sgimages/redo.svg"
        onClicked: {
            configFileModel.reload()
            configFileSettings.fileName = comboBox.currentText
            logLevelComboBox.currentIndex = logLevelComboBox.find(configFileSettings.logLevel)
        }
    }

    SGWidgets.SGText {
        id: logLevelText
        anchors {
            topMargin: innerSpacing
            left: title.left
            rightMargin: innerSpacing
            verticalCenter: logLevelComboBox.verticalCenter
        }
        text: "Log Level: "
    }

    SGWidgets.SGComboBox {
        id: logLevelComboBox
        anchors {
            top: reloadButton.bottom
            topMargin: innerSpacing
            right: setLogLevelButton.left
            rightMargin: innerSpacing
        }
        model: ["debug", "info", "warning", "error", "critical", "off"]
        enabled: currentIndex !== -1 && comboBox.enabled //disable if log level value doesnt exist OR if no ini files were found
        placeholderText: "no value"
        onActivated: {
            configFileSettings.logLevel = currentText
        }

        Component.onCompleted: {
            configFileSettings.fileName = comboBox.currentText
            currentIndex = find(configFileSettings.logLevel)
        }
    }
    SGWidgets.SGButton {
        id: setLogLevelButton
        anchors {
            right: parent.right
            rightMargin: outerSpacing
            verticalCenter: logLevelComboBox.verticalCenter
        }
        width: height
        text: logLevelComboBox.enabled ? "Unset" : "Set"
        onClicked: {
            if (text == "Unset") {
                configFileSettings.logLevel = ""
                logLevelComboBox.currentIndex = -1
            } else {
                logLevelComboBox.currentIndex = 0
            }
        }
    }
}
