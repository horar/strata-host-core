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

SGWidgets.SGAbstractContextMenu {
    id: contextMenuEdit

    property var textEditor: null
    property bool forceFocus: true
    property bool copyEnabled: true // for passwords, they cannot be cut/copied

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
        enabled: copyEnabled && (textEditor.readOnly === false) && (textEditor.selectedText.length > 0)
        onTriggered: {
            textEditor.cut()
        }
    }
    Action {
        id: copyAction
        text: qsTr("Copy")
        enabled: copyEnabled && (textEditor.selectedText.length > 0)
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
