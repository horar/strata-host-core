/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: root

    SGStatusLogBox {
        id: logBox
        enabled: editEnabledCheckBox.checkState

        property int count: 0

        // Optional configuration:
        title: "Default Status Logs"               // Default: "" (title bar will not be visible when empty string)
        // titleTextColor: "#000000"       // Default: "black"
        // titleBoxColor: "#eeeeee"        // Default: "#F2F2F2"
        // titleBoxBorderColor: "#dddddd"  // Default: "#D9D9D9"
        // statusTextColor: "#777777"      // Default: "black"
        // statusBoxColor: "#ffffff"       // Default: "white"
        // statusBoxBorderColor: "#dddddd" // Default: "#D9D9D9"
        // filterEnabled: true             // Default: true (can disable filtration)
        // fontSizeMultiplier: 2           // Default: 1
        // scrollToEnd: false              // Default: true (determines if view scrolls to end when new messages appended)
        copyEnabled: false                 // Default: true (can disable copy key shortcut)

        // Debug options:
        showMessageIds: true           // Default: false (shows internal message ids, for debugging)

        // Available methods (example use buttons below):
        // logBox.append(string message)                        // appends message to list and returns id of message for later manipulation
        // logBox.remove(int id)                                // if message with id found, removes message & returns true, else returns false
        // logBox.updateMessageAtID(string message, int id)     // if message with id found, updates message & returns true, else returns false
    }

    RowLayout {
        // Example use buttons:
        id: row
        spacing: 5
        enabled: editEnabledCheckBox.checkState

        SGButton {
            text: "Add \n Message"
            Layout.alignment: Qt.AlignCenter
            onClicked: {
                var messageID = logBox.append("Message " + logBox.count++)
                console.info("Added message:", messageID)
            }
        }

        SGButton {
            text: "Remove \n message with ID 1"
            Layout.alignment: Qt.AlignCenter
            onClicked: {
                var success = logBox.remove(1);
                console.info((success ? "Removed message with ID 1" : "Message with id 1 not found"))
            }
        }

        SGButton {
            text: "Clear \n Messages"
            Layout.alignment: Qt.AlignCenter
            onClicked: {
                logBox.clear()
                console.info("Cleared")
            }
        }
    }

    /*
        This version of SGStatusLogBox shows how it can be customized for selectable delegates.
    */
    SGStatusLogBoxSelectableDelegates {
        id: logBoxDelegates
        title: "Selectable Status Logs"
        filterEnabled: false
        copyEnabled: false

        Component.onCompleted: {
            for (let i = 0; i < 10; i++){
                logBoxDelegates.append("Message " + i)
            }
        }
    }

    /*
        This version of SGStatusLogBox shows how it can be customized for delegates made up of selectable text.

        This is more efficient for things like output logs (1000+ lines) than a single text component as listView caches out-of-view delegates.
    */
    SGStatusLogBoxSelectableText {
        id: logBoxText
        title: "Selectable Text Status Logs"
        filterEnabled: false

        Component.onCompleted: {
            for (let i = 0; i < 10; i++){
                logBoxText.append("Message " + i)
            }
        }
    }

    SGCheckBox {
        id: editEnabledCheckBox
        text: "Everything enabled"
        checked: true

        onCheckedChanged:  {
            if(checked)
                logBox.opacity = 1.0
            else logBox.opacity = 0.5
        }
    }
}

