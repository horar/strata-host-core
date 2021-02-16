import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGAbstractContextMenu {
    id: contextMenuEdit

    property var textEditor: null
    property bool forceFocus: true

    Action {
        id: undoAction
        text: qsTr("Undo")
        enabled: textEditor.canUndo
        onTriggered: {
            textEditor.undo()
        }
    }
    Action {
        id: redoAction
        text: qsTr("Redo")
        enabled: textEditor.canRedo
        onTriggered: {
            textEditor.redo()
        }
    }
    MenuSeparator { }
    Action {
        id: cutAction
        text: qsTr("Cut")
        enabled: textEditor.selectedText.length > 0
        onTriggered: {
            textEditor.cut()
        }
    }
    Action {
        id: copyAction
        text: qsTr("Copy")
        enabled: textEditor.selectedText.length > 0
        onTriggered: {
            textEditor.copy()
        }
    }
    Action {
        id: pasteAction
        text: qsTr("Paste")
        enabled: textEditor.canPaste
        onTriggered: {
            textEditor.paste()
        }
    }
    MenuSeparator { }
    Action {
        id: selectAction
        text: qsTr("Select All")
        enabled: textEditor.length > 0
        onTriggered: {
            textEditor.selectAll()
        }
    }
    onClosed: {
        if (forceFocus === true) {
            textEditor.forceActiveFocus()
        }
    }
}
