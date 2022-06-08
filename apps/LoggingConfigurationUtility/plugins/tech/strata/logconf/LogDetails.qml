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
    id: logDetailsGrid

    property int innerSpacing: 5
    property int shortEdit: 180
    property int longEdit: 300
    property int infoButtonSize: 15
    property bool maxNoFilesEnabled: false
    property bool maxFileSizeEnabled: false
    property string maxFileSizeSetting: "maxFileSize"
    property string maxNoFilesSetting: "maxNoFiles"
    property string qtFilterRulesSetting: "qtFilterRules"
    property string qtMsgPatternSetting: "qtMessagePattern"
    property string spdlogMsgPatternSetting: "spdlogMessagePattern"

    columns: 4
    columnSpacing: innerSpacing
    rowSpacing: innerSpacing

    LogSettings {
        id: logSettings
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
        onValueModified: {
            logSettings.setvalue(maxFileSizeSetting, value)
            textInputFileSize.text = maxFileSizeSpinBox.value
        }

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
                logSettings.setvalue(maxFileSizeSetting, maxFileSizeSpinBox.to)
                return maxFileSizeSpinBox.to
            } else if (Number.fromLocaleString(locale, text) < maxFileSizeSpinBox.from) {
                logSettings.setvalue(maxFileSizeSetting, maxFileSizeSpinBox.from)
                return maxFileSizeSpinBox.from
            } else {
                return Number.fromLocaleString(locale, text)
            }
        }
        textFromValue: function(value, locale) {
            return Number(value).toLocaleString(locale,'d',0)
        }

        Component.onCompleted: {
            textInputFileSize.text = logSettings.getvalue(maxFileSizeSetting)
            if (textInputFileSize.text === "") {
                maxFileSizeEnabled = false
            } else {
                maxFileSizeSpinBox.value = textInputFileSize.text
                maxFileSizeEnabled = true
            }
        }
    }

    SGWidgets.SGButton {
        id: maxFileSizeButton
        Layout.maximumWidth: height
        text: maxFileSizeSpinBox.enabled ? "Unset" : "Set"
        onClicked: {
            if (text === "Unset") {
                logSettings.removekey(maxFileSizeSetting)
                maxFileSizeEnabled = false
            } else { //set to default value
                logSettings.setvalue(maxFileSizeSetting, logSettings.maxSizeDefault)
                textInputFileSize.text = logSettings.maxSizeDefault
                maxFileSizeSpinBox.value = textInputFileSize.text
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
        onValueModified: {
            logSettings.setvalue(maxNoFilesSetting,value)
            textInputNoFiles.text = maxNoFilesSpinBox.value
        }

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
                logSettings.setvalue("maxNoFiles",maxNoFilesSpinBox.to)
                return maxNoFilesSpinBox.to
            } else if (Number.fromLocaleString(locale, text) < maxNoFilesSpinBox.from) {
                logSettings.setvalue("maxNoFiles", maxNoFilesSpinBox.from)
                return maxNoFilesSpinBox.from
            } else {
                return Number.fromLocaleString(locale, text)
            }
        }
        textFromValue: function(value, locale) {
            return Number(value).toLocaleString(locale,'d',0)
        }

        Component.onCompleted: {
            textInputNoFiles.text = logSettings.getvalue(maxNoFilesSetting)
            if (textInputNoFiles.text === "") {
                maxNoFilesEnabled = false
            } else {
                maxNoFilesSpinBox.value = textInputNoFiles.text
                maxNoFilesEnabled = true
            }
        }
    }

    SGWidgets.SGButton {
        id: maxNoFilesButton
        Layout.maximumWidth: height
        text: maxNoFilesSpinBox.enabled ? "Unset" : "Set"
        onClicked: {
            if (text === "Unset") {
                logSettings.removekey(maxNoFilesSetting)
                maxNoFilesEnabled = false
            } else { //set to default value
                logSettings.setvalue(maxNoFilesSetting, logSettings.maxCountDefault)
                textInputNoFiles.text = logSettings.getvalue(maxNoFilesSetting)
                maxNoFilesSpinBox.value = textInputNoFiles.text
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
        //disable if no. of files is out of min/max value OR if no ini files were found or selected
        onTextEdited: logSettings.setvalue(qtFilterRulesSetting, text)

        Component.onCompleted: {
            qtFilterRulesTextField.text = logSettings.getvalue(qtFilterRulesSetting)
        }
    }

    SGWidgets.SGButton {
        id: qtFilterRulesButton
        Layout.maximumWidth: height
        text: qtFilterRulesTextField.enabled ? "Unset" : "Set"
        onClicked: {
            if (text === "Unset") {
                logSettings.removekey(qtFilterRulesSetting)
            } else { //set to default value
                logSettings.setvalue(qtFilterRulesSetting,logSettings.filterRulesDefault)
            }
            qtFilterRulesTextField.text = logSettings.getvalue(qtFilterRulesSetting)
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
       onTextEdited: logSettings.setvalue(qtMsgPatternSetting, text)

       Component.onCompleted: {
           qtMsgPatternTextField.text = logSettings.getvalue(qtMsgPatternSetting)
       }
    }

    SGWidgets.SGButton {
        id: qtMsgPatternButton
        Layout.maximumWidth: height
        text: qtMsgPatternTextField.enabled ? "Unset" : "Set"
        onClicked: {
            if (text === "Unset") {
                logSettings.removekey(qtMsgPatternSetting)
            } else { //set to default value
                logSettings.setvalue(qtMsgPatternSetting, logSettings.qtMsgDefault)
            }
            qtMsgPatternTextField.text = logSettings.getvalue(qtMsgPatternSetting)
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
        onTextEdited: logSettings.setvalue(spdlogMsgPatternSetting, text)

        Component.onCompleted: {
            spdlogMsgPatternTextField.text = logSettings.getvalue(spdlogMsgPatternSetting)
        }
    }

    SGWidgets.SGButton {
        id: spdlogMsgPatternButton
        Layout.maximumWidth: height
        text: spdlogMsgPatternTextField.enabled ? "Unset" : "Set"
        onClicked: {
            if (text === "Unset") {
                logSettings.removekey(spdlogMsgPatternSetting)
            } else { //set to default value
                logSettings.setvalue(spdlogMsgPatternSetting, logSettings.spdMsgDefault)
            }
            spdlogMsgPatternTextField.text = logSettings.getvalue(spdlogMsgPatternSetting)
        }
    }

    Connections {
        target: logSettings
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
            console.log("Set " + parameter + " to default")
            if (parameter === "maxFileSize") {
                logSettings.setvalue(parameter, logSettings.maxSizeDefault)
                textInputFileSize.text = logSettings.maxSizeDefault
                maxFileSizeSpinBox.value = textInputFileSize.text
                maxFileSizeEnabled = true
            } else if (parameter === "maxNoFiles") {
                logSettings.setvalue(parameter, logSettings.maxCountDefault)
                textInputNoFiles.text = logSettings.maxCountDefault
                maxNoFilesSpinBox.value = textInputNoFiles.text
                maxNoFilesEnabled = true
            } else if (parameter === "qtFilterRules") {
                logSettings.setvalue(parameter, logSettings.filterRulesDefault)
                qtFilterRulesTextField.text = logSettings.filterRulesDefault
            } else if (parameter === "qtMessagePattern") {
                logSettings.setvalue(parameter, logSettings.qtMsgDefault)
                qtMsgPatternTextField.text = logSettings.qtMsgDefault
            } else {
                logSettings.setvalue(parameter, logSettings.spdMsgDefault)
                spdlogMsgPatternTextField.text = logSettings.spdMsgDefault
            }
            dialog.destroy()
        })

        dialog.rejected.connect(function() { //remove parameter
            console.log("Removed " + parameter)
            logSettings.removekey(parameter)
            if (parameter === "maxFileSize") {
                textInputFileSize.text = "no value"
                maxFileSizeEnabled = false
            } else if (parameter === "maxNoFiles") {
                textInputNoFiles.text = "no value"
                maxNoFilesEnabled = false
            } else if (parameter === "qtFilterRules") {
                qtFilterRulesTextField.text = ""
            } else if (parameter === "qtMessagePattern") {
                qtMsgPatternTextField.text = ""
            } else {
                spdlogMsgPatternTextField.text = ""
            }
            dialog.destroy()
        })
        dialog.open()
    }
}
