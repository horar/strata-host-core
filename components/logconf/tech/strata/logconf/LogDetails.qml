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
import tech.strata.logconf 1.0
import tech.strata.pluginLogger 1.0

GridLayout {
    id: logDetailsGrid

    property alias fileName: configFileSettings.filePath
    property alias lcuApp: item.enabled
    property int innerSpacing: 5
    property int shortEdit: 180
    property int longEdit: 300
    property int infoButtonSize: 15
    property bool maxNoFilesEnabled: false
    property bool maxFileSizeEnabled: false

    columns: 4
    columnSpacing: innerSpacing
    rowSpacing: innerSpacing

    Component.onCompleted: {
        if (lcuApp == false) {
            configFileSettings.filePath = ""
        } else {

        }
    }

    ConfigFileSettings {
        id: configFileSettings
    }

    Item {
        id: item
        enabled: lcuApp
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
        enabled: maxFileSizeEnabled
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
                if (configFileSettings.maxFileSize == -1) {
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
        enabled: configFileSettings.filePath !== ""
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
        enabled: maxNoFilesEnabled
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
                if (configFileSettings.maxNoFiles == -1) {
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
        enabled: configFileSettings.filePath !== "" //disable if no ini files were found or selected
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
        enabled: text !== ""
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
        enabled: configFileSettings.filePath !== "" //disable if no ini files were found or selected
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
       enabled: text !== ""
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
        enabled: configFileSettings.filePath !== ""//disable if no ini files were found or selected
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
        enabled: text !== ""
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
        enabled: configFileSettings.filePath !== "" //disable if no ini files were found or selected
        onClicked: {
            if (text === "Unset") {
                configFileSettings.spdlogMsgPattern = ""
            } else { //set to default value
                configFileSettings.spdlogMsgPattern = configFileSettings.spdMsgDefault
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
                    logDetailsGrid,
                    "qrc:/CorruptedFileDialog.qml", {
                        "corruptedString": string,
                        "corruptedParam": string === "" ? ("<i>" + parameter + "</i> setting does not contain any value.") : ("Parameter <i>" + parameter + "</i> is currently set to:")
                    })

        dialog.accepted.connect(function() { //set to default
            console.log(Logger.lcuCategory, "Set " + parameter + " to default")
            if (parameter === "log/maxFileSize") {
                configFileSettings.maxFileSize = configFileSettings.maxSizeDefault
                maxFileSizeEnabled = true
            } else if (parameter === "log/maxNoFiles") {
                configFileSettings.maxNoFiles = configFileSettings.maxCountDefault
                maxNoFilesEnabled = true
            } else if (parameter === "log/qtFilterRules") {
                configFileSettings.qtFilterRules = configFileSettings.filterRulesDefault
            } else if (parameter === "log/qtMessagePattern") {
                configFileSettings.qtMsgPattern = configFileSettings.qtMsgDefault
            } else {
                configFileSettings.spdlogMsgPattern = configFileSettings.spdMsgDefault
            }
            dialog.destroy()
        })

        dialog.rejected.connect(function() { //remove parameter
            console.log(Logger.lcuCategory, "Removed " + parameter)
            if (parameter === "log/maxFileSize") {
                configFileSettings.maxFileSize = 0
                textInputFileSize.text = "no value"
                maxFileSizeEnabled = false
            } else if (parameter === "log/maxNoFiles") {
                configFileSettings.maxNoFiles = 0
                textInputNoFiles.text = "no value"
                maxNoFilesEnabled = false
            } else if (parameter === "log/qtFilterRules") {
                configFileSettings.qtFilterRules = ""
            } else if (parameter === "log/qtMessagePattern") {
                configFileSettings.qtMsgPattern = ""
            } else {
                configFileSettings.spdlogMsgPattern = ""
            }
            dialog.destroy()
        })
        dialog.open()
    }
}
