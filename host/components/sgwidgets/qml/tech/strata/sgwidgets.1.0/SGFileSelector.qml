import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp
import QtQuick.Dialogs 1.3

FocusScope {
    id: fileSelector
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


    function inputValidationErrorMsg() {
        return ""
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

        function inputValidationErrorMsg() {
            return fileSelector.inputValidationErrorMsg()
        }
    }

    SGWidgets.SGButton {
        id: selectButton
        y: textEdit.itemY + (textEdit.item.height - height) / 2
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
                    fileSelector.parent,
                    fileDialogComponent,
                    {
                        "title": dialogLabel,
                        "selectExisting": dialogSelectExisting,
                        "defaultSuffix": dialogDefaultSuffix,
                        "folderRequested": resolveAbsoluteFileUrl(textEdit.text),
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

    function resolveAbsoluteFileUrl(path) {
        return CommonCpp.SGUtilsCpp.pathToUrl(
            CommonCpp.SGUtilsCpp.parentDirectoryPath(path))
    }
}
