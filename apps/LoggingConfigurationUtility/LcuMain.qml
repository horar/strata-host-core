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
import tech.strata.lcu 1.0
import tech.strata.logger 1.0

Item {
    id: lcuMain

    property int outerSpacing: 10
    property int innerSpacing: 5

    QtLabsSettings.Settings {
        id: settings
        category: "ApplicationWindow"

        property alias selectedFileName: iniFileComboBox.currentText

        Component.onCompleted: {
            configFileModel.reload()
            iniFileComboBox.currentIndex = iniFileComboBox.find(settings.value("selectedFileName",""))
        }
    }

    ConfigFileModel {
        id:configFileModel
    }

    ColumnLayout {
        id:mainLayout

        anchors {
            fill: parent
            leftMargin: outerSpacing
            rightMargin: outerSpacing
        }

        SGWidgets.SGText {
            id: title
            text: "Configuration files"
        }

        RowLayout {
            SGWidgets.SGComboBox {
                id: iniFileComboBox
                Layout.fillWidth: true
                model: configFileModel
                textRole: "fileName"
                enabled: count !== 0
                placeholderText: count == 0 ? "No configuration files found" : "Please select config file"
                onActivated: {
                    console.log(Logger.lcuCategory, "Selected INI file changed to:", iniFileComboBox.currentText)
                }
                popupHeight: mainLayout.height

                Connections {
                    target: configFileModel
                    onCountChanged: { //is called always when list of INI files is loaded/reloaded
                        iniFileComboBox.currentIndex = -1
                    }
                }
            }
            SGWidgets.SGButton {
                id: reloadButton
                Layout.preferredWidth: height
                Layout.alignment: Qt.AlignRight
                icon.source: "qrc:/sgimages/redo.svg"
                onClicked: {
                    configFileModel.reload()
                    iniFileComboBox.currentIndex = iniFileComboBox.find(settings.value("selectedFileName",""))
                }
            }
        }

        LogLevel {
            id: logLevelPane
            Layout.fillWidth: true
            fileName: configFileModel.get(iniFileComboBox.currentIndex).filePath
        }

        LogDetails {
            id : logDetailsPane
            Layout.fillWidth: true
            fileName: configFileModel.get(iniFileComboBox.currentIndex).filePath
            lcuApp: true

            Component.onCompleted: {
                configFileModel.reload()
                iniFileComboBox.currentIndex = iniFileComboBox.find(settings.value("selectedFileName",""))
            }
        }
    }
}
