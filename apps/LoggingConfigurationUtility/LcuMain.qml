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
    property int shortEdit: 180
    property int longEdit: 300
    property int infoButtonSize: 15
    property bool maxNoFilesEnabled: false
    property bool maxFileSizeEnabled: false

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
            console.debug("Selected INI file changed to: " + iniFileComboBox.currentText)
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
        columns: 4
        columnSpacing: innerSpacing
        rowSpacing: innerSpacing

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
            enabled: currentIndex !== -1 && iniFileComboBox.currentIndex !== -1 //disable if log level value doesnt exist OR if no ini files were found or selected
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
            Layout.columnSpan: 2
            Layout.fillWidth: true
        }

        SGWidgets.SGSpinBox {
            id: maxFileSizeSpinBox
            Layout.preferredWidth: shortEdit
            Layout.alignment: Qt.AlignRight
            from: 1000
            to: 2147483647
            stepSize: (value > (to - from) && value != to) ?  to - value : from
            enabled: maxFileSizeEnabled && iniFileComboBox.currentIndex !== -1
            //disable if file size is out of min/max value OR if no ini files were found or selected
            onValueModified: configFileSettings.maxFileSize = value

            contentItem: TextInput {
                id:textInputFileSize
                anchors {
                    left: parent.down.indicator.right
                    right: parent.up.indicator.left
                    top: parent.top
                    bottom: parent.bottom
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: parent.font
                opacity: parent.enabled ? 1 : 0.5
                validator: parent.validator
                inputMethodHints: Qt.ImhDigitsOnly
                onEnabledChanged: parent.enabled ? text = parent.value : text = "no value"
            }
            background: Rectangle {
                anchors.fill: parent.contentItem
                border.width: 2
                border.color: parent.focus && parent.enabled ? palette.highlight : color
                opacity: parent.enabled ? 1 : 0.5
            }

            valueFromText: function(text, locale) {
                if (Number.fromLocaleString(locale, text) > maxFileSizeSpinBox.to) {
                    configFileSettings.maxFileSize = maxFileSizeSpinBox.to
                    return maxFileSizeSpinBox.to
                } else if (Number.fromLocaleString(locale, text) < maxFileSizeSpinBox.from) {
                    configFileSettings.maxFileSize = maxFileSizeSpinBox.from
                    return maxFileSizeSpinBox.from
                } else {
                    return Number.fromLocaleString(locale, text)
                }
            }
            textFromValue: function(value, locale) {
                return Number(value).toLocaleString(locale,'d',0)
            }


            Connections {
                target: configFileSettings
                onMaxFileSizeChanged: {
                    maxFileSizeSpinBox.value = configFileSettings.maxFileSize
                    textInputFileSize.text = maxFileSizeSpinBox.value
                }
                onFilePathChanged: {
                    if (configFileSettings.maxFileSize == 0) {
                        maxFileSizeEnabled = false
                    } else {
                        maxFileSizeSpinBox.value = configFileSettings.maxFileSize
                        maxFileSizeEnabled = true
                        textInputFileSize.text = maxFileSizeSpinBox.value
                    }
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
                    configFileSettings.maxFileSize = 0
                    maxFileSizeEnabled = false
                } else { //set to default value
                    configFileSettings.maxFileSize = configFileSettings.maxSizeDefault
                    maxFileSizeEnabled = true
                }
            }
        }

        SGWidgets.SGText {
            id: maxNoFilesText
            text: "Max number of files"
            Layout.columnSpan: 2
            Layout.fillWidth: true
        }

        SGWidgets.SGSpinBox {
            id: maxNoFilesSpinBox
            Layout.preferredWidth: shortEdit
            Layout.alignment: Qt.AlignRight
            from: 1
            to: 100000
            stepSize: 1
            enabled: maxNoFilesEnabled && iniFileComboBox.currentIndex !== -1
            //disable if no.of files is out of min/max value OR if no ini files were found or selected
            onValueModified: configFileSettings.maxNoFiles = value

            contentItem: TextInput {
                id:textInputNoFiles
                anchors {
                    left: parent.down.indicator.right
                    right: parent.up.indicator.left
                    top: parent.top
                    bottom: parent.bottom
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: parent.font
                opacity: parent.enabled ? 1 : 0.5
                validator: parent.validator
                inputMethodHints: Qt.ImhDigitsOnly
                onEnabledChanged: parent.enabled ? text = parent.value : text = "no value"
            }
            background: Rectangle {
                anchors.fill: parent.contentItem
                border.width: 2
                border.color: parent.focus && parent.enabled ? palette.highlight : color
                opacity: parent.enabled ? 1 : 0.5
            }

            valueFromText: function(text, locale) {
                if (Number.fromLocaleString(locale, text) > maxNoFilesSpinBox.to) {
                    configFileSettings.maxNoFiles = maxNoFilesSpinBox.to
                    return maxNoFilesSpinBox.to
                } else if (Number.fromLocaleString(locale, text) < maxNoFilesSpinBox.from) {
                    configFileSettings.maxNoFiles = maxNoFilesSpinBox.from
                    return maxNoFilesSpinBox.from
                } else {
                    return Number.fromLocaleString(locale, text)
                }
            }
            textFromValue: function(value, locale) {
                return Number(value).toLocaleString(locale,'d',0)
            }

            Connections {
                target: configFileSettings
                onMaxNoFilesChanged: {
                    maxNoFilesSpinBox.value = configFileSettings.maxNoFiles
                    textInputNoFiles.text = maxNoFilesSpinBox.value
                }
                onFilePathChanged: {
                    if (configFileSettings.maxNoFiles == 0) {
                        maxNoFilesEnabled = false
                    } else {
                        maxNoFilesSpinBox.value = configFileSettings.maxNoFiles
                        maxNoFilesEnabled = true
                        textInputNoFiles.text = maxNoFilesSpinBox.value
                    }
                }
            }
        }

        SGWidgets.SGButton {
            id: maxNoFilesButton
            Layout.maximumWidth: height
            text: maxNoFilesSpinBox.enabled ? "Unset" : "Set"
            enabled : iniFileComboBox.currentIndex !== -1 //disable if no ini files were found or selected
            onClicked: {
                if (text === "Unset") {
                    configFileSettings.maxNoFiles = 0
                    maxNoFilesEnabled = false
                } else { //set to default value
                    configFileSettings.maxNoFiles = configFileSettings.maxCountDefault
                    maxNoFilesEnabled = true
                }
            }
        }

        SGWidgets.SGText {
            id: qtFilterRulesText
            text: "Qt filter rules"
            Layout.columnSpan: 2
        }

        SGWidgets.SGTextField {
            id: qtFilterRulesTextField
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            placeholderText: "no qt filter rules"
            enabled: text !== "" && iniFileComboBox.currentIndex !== -1
            //disable if no.of files is out of min/max value OR if no ini files were found or selected
            onTextEdited: configFileSettings.qtFilterRules = text

            Connections {
                target: configFileSettings
                onQtFilterRulesChanged: {
                    qtFilterRulesTextField.text = configFileSettings.qtFilterRules
                }
                onFilePathChanged: {
                    qtFilterRulesTextField.text = configFileSettings.qtFilterRules
                }
            }
        }

        SGWidgets.SGButton {
            id: qtFilterRulesButton
            Layout.maximumWidth: height
            text: qtFilterRulesTextField.enabled ? "Unset" : "Set"
            enabled : iniFileComboBox.currentIndex !== -1 //disable if no ini files were found or selected
            onClicked: {
                if (text === "Unset") {
                    configFileSettings.qtFilterRules = ""
                } else { //set to default value
                    configFileSettings.qtFilterRules = configFileSettings.filterRulesDefault
                }
            }
        }

       SGWidgets.SGText {
           id: qtMsgPatternText
           text: "Qt message pattern"
       }

       SGWidgets.SGIconButton {
           icon.source: "qrc:/sgimages/info-circle.svg"
           icon.width: infoButtonSize
           icon.height: infoButtonSize
           hintText: "Opens web browser with documentation"
           onClicked: Qt.openUrlExternally("https://doc.qt.io/qt-5/qtglobal.html#qSetMessagePattern")
       }

       SGWidgets.SGTextField {
           id: qtMsgPatternTextField
           Layout.alignment: Qt.AlignRight
           Layout.fillWidth: true
           placeholderText: "no qt msg pattern"
           enabled: text !== "" && iniFileComboBox.currentIndex !== -1
           //disable is message pattern value doesn't exist OR if no ini files were found or selected
           onTextEdited: configFileSettings.qtMsgPattern = text

            Connections {
                target: configFileSettings
                onQtMsgPatternChanged: {
                    qtMsgPatternTextField.text = configFileSettings.qtMsgPattern
                }
                onFilePathChanged: {
                    qtMsgPatternTextField.text = configFileSettings.qtMsgPattern
                }
            }
        }

        SGWidgets.SGButton {
            id: qtMsgPatternButton
            Layout.maximumWidth: height
            text: qtMsgPatternTextField.enabled ? "Unset" : "Set"
            enabled : iniFileComboBox.currentIndex !== -1 //disable if no ini files were found or selected
            onClicked: {
                if (text === "Unset") {
                    configFileSettings.qtMsgPattern = ""
                } else { //set to default value
                    configFileSettings.qtMsgPattern = configFileSettings.qtMsgDefault
                }
            }
        }

        SGWidgets.SGText {
            id: spdlogMsgPatternText
            text: "Spdlog message pattern"
        }

        SGWidgets.SGIconButton {
            icon.source: "qrc:/sgimages/info-circle.svg"
            icon.width: infoButtonSize
            icon.height: infoButtonSize
            hintText: "Opens web browser with documentation"
            onClicked: Qt.openUrlExternally("https://github.com/gabime/spdlog/wiki/3.-Custom-formatting")
        }

        SGWidgets.SGTextField {
            id: spdlogMsgPatternTextField
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            placeholderText: "no spdlog msg pattern"
            enabled: text !== "" && iniFileComboBox.currentIndex !== -1
            //disable is message pattern value doesn't exist OR if no ini files were found or selected
            onTextEdited: configFileSettings.spdlogMsgPattern = text

             Connections {
                 target: configFileSettings
                 onSpdlogMsgPatternChanged: {
                     spdlogMsgPatternTextField.text = configFileSettings.spdlogMsgPattern
                 }
                 onFilePathChanged: {
                     spdlogMsgPatternTextField.text = configFileSettings.spdlogMsgPattern
                 }
             }
        }
        SGWidgets.SGButton {
            id: spdlogMsgPatternButton
            Layout.maximumWidth: height
            text: spdlogMsgPatternTextField.enabled ? "Unset" : "Set"
            enabled : iniFileComboBox.currentIndex !== -1 //disable if no ini files were found or selected
            onClicked: {
                if (text === "Unset") {
                    configFileSettings.spdlogMsgPattern = ""
                } else { //set to default value
                    configFileSettings.spdlogMsgPattern = configFileSettings.spdMsgDefault
                }
            }
        }
    }

    Connections {
        target: configFileSettings
        onCorruptedFile: {
            showCorruptedFileDialog(errorString)
        }
    }

    function showCorruptedFileDialog(errorMessage) {
        var dialog = SGDialogJS.createDialog(
                    lcuMain,
                    "qrc:/CorruptedFileDialog.qml",
                    {"errorMessage": errorMessage})

        dialog.accepted.connect(function() {
            //set to default
            console.log("SET TO DEFAULT")
//                configFileSettings.logLevel = "debug"
            dialog.destroy()
        })

        dialog.rejected.connect(function() {
            //remove parameter
            console.log("REMOVE")
//                configFileSettings.logLevel = ""
            dialog.destroy()
        })
        dialog.open()
    }


    SGWidgets.SGPopup {
        id: infoPopup

        padding: 2
        anchors.centerIn: parent
        closePolicy: Popup.NoAutoClose
        modal: true

        contentItem: GridLayout {
            columns: 2
            SGWidgets.SGText {
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignCenter
                text: "Sorry, but selected INI file is corrupted."
            }
            SGWidgets.SGText {
                id: errorText
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignHCenter
                text: "..."
            }
            SGWidgets.SGText {
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignCenter
                text: "Do you want to set the parameter to default value or remove it?"
            }
            SGWidgets.SGButton {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                text: "Set to default"
                onClicked: {
                    configFileSettings.logLevel = "debug"
                    infoPopup.close()
                }
            }
            SGWidgets.SGButton {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                text: "Remove parameter"
                onClicked: {
                    configFileSettings.logLevel = ""
                    infoPopup.close()
                }
            }
        }
//        Connections {
//            target: configFileSettings
//            onCorruptedFile: {
//                infoPopup.open()
//                errorText.text = errorString
//            }
//        }
    }
}
