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

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "console-messages"

Item {
    id: root
    anchors.fill: parent

    property bool copyEnabled: false
    property alias contextMenuEdit: contextMenuEdit

    TextEdit {
        id: copyHelp // Use TextEdit functions to copy and select all in the console log.
        visible: false
    }

    SGAbstractContextMenu {
        id: contextMenuEdit

        Action {
            id: copyAction
            text: qsTr("Copy")
            enabled: copyEnabled
            onTriggered: {
                root.copySelected()
            }
        }

        Action {
            id: selectAction
            text: qsTr("Select All")
            onTriggered: {
                root.selectAll()
            }
        }

        onClosed: {
            consoleLogs.forceActiveFocus()
        }
    }

    // Copy shortcut
    Shortcut {
        sequence: StandardKey.Copy

        onActivated: {
            root.copySelected()
        }
    }

    // Select all shortcut
    Shortcut {
        sequence: StandardKey.SelectAll

        onActivated: {
            root.selectAll()
        }
    }

    // Copy the selected text into the user's clipboard
    function copySelected() {
        // loop over every index in model and look for selected text
        for (var i = 0; i < consoleLogs.model.count; i++) {
            var listElement = consoleModel.get(consoleLogs.model.mapIndexToSource(i))
            if (listElement.selection) {
                // adds selected text to text field of copyHelp
                if (copyHelp.text) {
                    copyHelp.text += ('\n' + listElement.selection)
                } else {
                    copyHelp.text += (listElement.selection)
                }
            }
        }
        copyHelp.selectAll()
        copyHelp.copy()
        copyHelp.text = "" // resets copyHelp.text
    }

    // Highlight all the text in the console. Then the user can copy all.
    function selectAll() {
        copyEnabled = true
        for (var i = 0; i < consoleLogs.model.count; i++) {
            var listElement = consoleModel.get(consoleLogs.model.mapIndexToSource(i))
            listElement.state = "allSelected" // sets state of every index to allSelected
        }
    }
}
