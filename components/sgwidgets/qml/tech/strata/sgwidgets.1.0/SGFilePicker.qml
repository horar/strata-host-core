/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQml 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import QtQuick.Dialogs 1.3

FocusScope {
    id: filePicker
    height: textEdit.height

    property alias filePath: textEdit.text
    property alias label: textEdit.label
    property alias inputValidation: textEdit.inputValidation
    property alias hasHelperText: textEdit.hasHelperText
    property alias placeholderText: textEdit.placeholderText
    property string dialogLabel: "Select File"
    property bool dialogSelectExisting: true
    property string dialogDefaultSuffix: ""
    property variant dialogNameFilters: []
    property alias contextMenuEnabled: textEdit.contextMenuEnabled
    property alias isValid: textEdit.isValid
    property alias activeEditing: textEdit.activeEditing
    property alias textFieldActiveEditingEnabled: textEdit.textFieldActiveEditingEnabled
    property alias showValidationResultIcon: textEdit.showValidationResultIcon
    property alias suggestionModel: textEdit.suggestionListModel
    property alias suggestionModelTextRole: textEdit.suggestionModelTextRole
    property alias textFieldX: textEdit.loaderItemX
    property alias textFieldY: textEdit.loaderItemY
    property alias textFieldHeight: textEdit.loaderItemHeight
    property alias textFieldWidth: textEdit.loaderItemWidth

    function inputValidationErrorMsg() {
        return ""
    }

    /* reimplement this to return data from provided suggestionModel */
    function textRoleValue(index) {
        return ""
    }

    /* reimplement this to remove data from provided suggestionModel */
    function removeAt(index) {
    }

    function setStateIsUnknown() {
        textEdit.setIsUnknown()
    }

    function setStateIsValid() {
        textEdit.setIsValid()
    }

    function setStateIsInvalid(error) {
        textEdit.setIsInvalid(error)
    }

    SGWidgets.SGTextFieldEditor {
        id: textEdit
        anchors {
            left: parent.left
        }

        itemWidth: parent.width - selectButton.width - 10
        label: "File"
        placeholderText: "Select path..."
        focus: true
        textFieldSuggestionDelegateRemovable: true
        textFieldSuggestionCloseWithArrowKey: true
        textFieldSuggestionCloseOnMouseSelection: true
        textFieldSuggestionMaxHeight: 200
        textFieldShowSuggestionButton: suggestionListModel ? true : false

        onTextFieldSuggestionDelegateSelected: {
            text = filePicker.textRoleValue(index)
        }

        onTextFieldSuggestionDelegateRemoveRequested: {
            filePicker.removeAt(index)
        }

        function inputValidationErrorMsg() {
            return filePicker.inputValidationErrorMsg()
        }
    }

    SGWidgets.SGButton {
        id: selectButton
        y: textEdit.loaderItemY + (textEdit.loaderItemHeight - height) / 2
        anchors {
            right: parent.right
        }

        text: "Select"
        onClicked: {
            selectFilePath()
            textEdit.forceActiveFocus()
        }
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            title: "Select File"
            //"file:" scheme has length of 5
            folder: folderRequested.length > 5 ? folderRequested : shortcuts.documents

            property string folderRequested
        }
    }

    function selectFilePath() {
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(
                    ApplicationWindow.window,
                    fileDialogComponent,
                    {
                        "title": dialogLabel,
                        "selectExisting": dialogSelectExisting,
                        "defaultSuffix": dialogDefaultSuffix,
                        "folderRequested": resolveAbsoluteFileUrl(textEdit.text, dialogSelectExisting),
                        "nameFilters": dialogNameFilters,
                    })

        dialog.accepted.connect(function() {
            textEdit.text = CommonCpp.SGUtilsCpp.urlToLocalFile(dialog.fileUrl)
            dialog.destroy()})

        dialog.rejected.connect(function() {
            dialog.destroy()
        })

        dialog.open();
    }

    function resolveAbsoluteFileUrl(path, selectExisting) {
        let fullPath = selectExisting
                       ? CommonCpp.SGUtilsCpp.parentDirectoryPath(path)
                       : CommonCpp.SGUtilsCpp.fileAbsolutePath(path)
        return CommonCpp.SGUtilsCpp.pathToUrl(fullPath)
    }
}
